--[[
    聊天数据管理
--]]
local Chat = class("Chat")
Chat.TAG = "Chat"

local chatDataMax = 50
local chatDataMaxTime = 3 --天 
local defaultSendMsg = "☆成功绑定，可开始进行对话☆"

function Chat:ctor ()
    self.data = {}
    self.sendFailData = {}
end

-- 用于断线重连或者重新清空数据
function Chat:initData( ... )
    --先拉取本地缓存数据
    local chatCacheData = cc.UserDefault:getInstance():getStringForKey("Chat_Cache_" .. Cache.user.uin, "")
    if chatCacheData ~= "" then
    	self.data = qf.json.decode(chatCacheData)
    end

    -- 加载之前的未发送成功的记录
    for k,v in pairs(self.data) do
    	if v.reSend and not v.bLoad then
    		table.insert(self.sendFailData, v)
    	end
    end
end

-- 更新当前和哪个假的代理客服在聊天
function Chat:updateLastChatProxcyDataId(proxy_data_id)
	-- 校验用户有没有形成有效聊天
	local messageData = self:getChatDataByType(GameConstants.ChatUserType.PROXCY, proxy_data_id, true)
	if not messageData or #messageData == 0 then return end
	self:setProxcyDataId(proxy_data_id)
end

function Chat:setProxcyDataId(proxy_data_id)
	cc.UserDefault:getInstance():setIntegerForKey("Chat_Cache_Proxy_Data_ID_" .. Cache.user.uin, tonumber(proxy_data_id))
	cc.UserDefault:getInstance():flush()
end

-- 获取当前和哪个假的代理客服在聊天
function Chat:getLastChatProxcyDataId()
	local proxy_data_id = cc.UserDefault:getInstance():getIntegerForKey("Chat_Cache_Proxy_Data_ID_" .. Cache.user.uin, "0")
	return tonumber(proxy_data_id)
end

function Chat:getChatDataByType(targeType, proxy_data_id, bMySelf)
	local data = {}
	local currentTime = os.time()
	local dataIndex = 1
	local originData = clone(self.data)
	table.sort(originData, function (a, b)
		return tonumber(a.timestamp) > tonumber(b.timestamp)
	end)
	for _,v in ipairs(originData) do
		local proxy_uid = tonumber(v.proxy_data_id) or 0
		if proxy_uid == proxy_data_id then
			if targeType == GameConstants.ChatUserType.PROXCY then
	            if v.uin == Cache.user.invite_from or (v.uin == Cache.user.uin and v.targetid == Cache.user.invite_from) then
	            	if dataIndex <= chatDataMax and (currentTime - tonumber(v.timestamp)) <= chatDataMaxTime*24*60*60 then
	            		if bMySelf and v.uin == Cache.user.uin then

	            		else
	            			table.insert(data, v)
		            		dataIndex = dataIndex + 1
	            		end
	            	end
	            end
	        else
	            if Cache.user:isCustomerService(v.uin) or (v.uin == Cache.user.uin and Cache.user:isCustomerService(v.targetid)) then
	            	if dataIndex <= chatDataMax and (currentTime - tonumber(v.timestamp)) <= chatDataMaxTime*24*60*60 then
	            		if bMySelf and v.uin == Cache.user.uin then

	            		else
	            			table.insert(data, v)
		            		dataIndex = dataIndex + 1
	            		end
	            	end
	            end
	        end
		end
	end
	table.sort(data, function (a, b)
		return tonumber(a.timestamp) < tonumber(b.timestamp)
	end)
	return data
end

--[[
	获取最后一条消息时间
	1.代理或者客服发的消息中最后一条消息
]]
function Chat:getLastOtherTargetUserMessage(targeType)
	local lastMesg = {}
	for i = #self.data,1,-1 do--倒序
		local msg = self.data[i]
		if targeType == GameConstants.ChatUserType.PROXCY then
			if msg.uin == Cache.user.invite_from and msg.bLoad == true then
				lastMesg = msg
				break
			end
		else
			if Cache.user:isCustomerService(msg.uin) and msg.bLoad == true then
				lastMesg = msg
				break
			end
		end
	end
	return lastMesg
end

function Chat:startDataMonite( ... )
	self:initData()
	ChatServer:registerDataCallBackEvent({callback = function (data)
        --有新的消息的查询rsp，这个只查新的消息
        if data.name == "SyncMsgRes" then
        	local newMessages = self:updateNewChatMessage(data)
            if #newMessages > 0 then
            	print(" ==== 有新的消息 大厅推送了 ===== ")
            	self:dataUpdate(true, newMessages)
            	qf.event:dispatchEvent(ET.SHOW_PROXCY_POP, {message = newMessages[#newMessages], addListPopup = true})
            end
        --有用户消息过来了，发起同步消息数据请求 SyncMsgReq
        elseif data.name == "SyncMsgPush" then
            --同步远程消息
            self:syncNewUserMsg(data)
        --查询更多聊天数据或者说是历史聊天数据
        elseif data.name == "SyncRemoteMsgRes" then
        	local newMessages = self:updateChatHistoryMessage(data)
        	if #newMessages > 0 then
        		self:dataUpdate(true, newMessages)
        	end
        elseif data.name == "SendMsgRes" then
        	--这个不处理即可
        elseif data.name == "QuitProxyFakeRsp" then
        	-- 这里是退出社区
        	if data.model then
        		if data.model.result == 1 then
        			qf.event:dispatchEvent(ET.HIDE_CUSTOM_CHAT)
        			if data.model.low_client_flag == 0 and Cache.user:getCommunityStatus() == 1 then
        				local proxcyData = Cache.agencyInfo:getPersonalInfo()
        				qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = string.format(GameTxt.community_tips_txt_2, proxcyData.nick)})
        			end
        			if data.model.low_client_flag == 1 then
        				self:clearAllLocalChatMessage()
        			end
        			Cache.user:updateCommunityStatus(data.model.low_client_flag, true)
        		end
        	end
        end
    end})
end

function Chat:getCurrentTimeStampAndSessionInfo( ... )
	local timestamp = os.time() --秒的时间戳
	local session_info = math.floor(socket.gettime()*1000) --毫秒时间戳
	return timestamp, session_info
end

-- 代理小号发的欢迎语
function Chat:insertProxcySonWelcomeTips(data)
	local timestamp, session_info = self:getCurrentTimeStampAndSessionInfo()
	local message = {
        bLoad        = true,
        msg_type     = GameConstants.ChatMsgType.MSG_TEXT,
        sequence     = session_info,
        session_info = session_info,
        targetid     = Cache.user.uin,
        textInfo     = {
            msg = data.welcome_words
        },
   		bWelcomeTips = true;
        timestamp = timestamp,
        uin = data.uin,
        proxy_data_id = data.proxy_data_id
    }
    -- 先存储数据
    -- table.insert(self.data, message)
    -- self:_chacheChatData()
    self:dataUpdate(true, {[1] = message})
end

-- 绑定代理，自动发送的文字欢迎语
function Chat:insertProxcyToUserWelcomeTxtTips(data, showPop)
	if not data then return end
	if data.welcome_words == "" or data.welcome_words == " " then return end
	local timestamp, session_info = self:getCurrentTimeStampAndSessionInfo()
	local message = {
        bLoad        = true,
        msg_type     = GameConstants.ChatMsgType.MSG_TEXT,
        sequence     = session_info,
        session_info = session_info,
        targetid     = Cache.user.uin,
        textInfo     = {
            msg = data.welcome_words
        },
   		bWelcomeTips = true;
        timestamp = timestamp,
        is_welcome = 0,
        uin = data.uin,
        proxy_data_id = 0
    }
    -- 先存储数据
    table.insert(self.data, message)
    self:_chacheChatData()
    -- 发送弹框
    if showPop then
    	qf.event:dispatchEvent(ET.SHOW_PROXCY_POP, {message = message, addListPopup = true})
    else
    	self:dataUpdate(true, {[1] = message})
    end
end

-- 绑定代理，自动发送的图片欢迎语
function Chat:insertProxcyToUserWelcomeImageTips(data)
	local timestamp, session_info = self:getCurrentTimeStampAndSessionInfo()
	local message = {
        bLoad        = true,
        msg_type     = GameConstants.ChatMsgType.MSG_PIC_BRIEF,
        sequence     = session_info,
        session_info = session_info,
        targetid     = Cache.user.uin,
        picInfo     = {
            thumble_url = data.thumble_url,
           	url = data.url
        },
   		bWelcomeTips = true;
        timestamp = timestamp,
        uin = data.uin,
        is_welcome = 0,
        proxy_data_id = 0
    }
    -- 先存储数据
    table.insert(self.data, message)
    self:_chacheChatData()
    -- 发送弹框
    qf.event:dispatchEvent(ET.SHOW_PROXCY_POP, {message = message, addListPopup = false})
end

function Chat:dataUpdate(bAdd, messages)
	qf.event:dispatchEvent(ET.CHAT_MONITOR_EVENT, {data = messages, bAdd = bAdd})
end

--[[
	通知服务器已读消息时间
	消息体：
	optional int32 req_uid = 1; //请求用户的uid
	optional int32 timestamp = 2; //此用户的最新阅读时间
	optional int32 proxy_uid = 3; //被同步代理用户的uid
]]

function Chat:notifyLastReadInfoToServer(lastMesg, openChat, proxy_data_id)
	ChatServer:sendRequest({
    	pbName = 'ProxyMsgReadReq',
    	body = {
    		req_uid = Cache.user.uin,
    		timestamp = lastMesg and tonumber(lastMesg.session_info) or 0,
    		targetid = lastMesg and lastMesg.uin or 0,
    		open_chat = openChat or 0,
    		proxy_data_id = proxy_data_id
    	}
    })
end

-- 查询历史聊天记录
function Chat:syncHistoryMsg(targetid)
    ChatServer:sendRequest({
    	pbName = 'SyncRemoteMsgReq',
    	body = {
    		timestamp = math.floor(socket.gettime()*1000),
    		sync_uid = targetid,
    		info = '{"is_first":2}'
    	}	
    })
end

-- 进退社区
function Chat:communityRequest(status)
	ChatServer:sendRequest({
    	pbName = 'QuitProxyFakeReq',
    	body = {
    		op_type = status
    	}	
    })
end

-- 有消息过来，发起同步消息请求
function Chat:syncNewUserMsg( ... )
	print("【Chat】 syncNewUserMsg 获取新的消息")
    ChatServer:sendRequest({
    	pbName = 'SyncMsgReq'	
    })
end

--[[
	1.id_type 代理：0 客服：5
	2.targetid 客服：100 代理id登录获取
]]
function Chat:sendChatMessage(paras)
	if not paras.msg_type then return end
	local timestamp = paras.timestamp or os.time() --秒的时间戳
	local session_info = paras.session_info or math.floor(socket.gettime()*1000) --毫秒时间戳
	-- 组装数据
	local msgInfo = nil
	if paras.msg_type == GameConstants.ChatMsgType.MSG_TEXT then
		msgInfo = pb.new("TextMsgInfo")
		msgInfo.msg = paras.msg
	elseif paras.msg_type == GameConstants.ChatMsgType.MSG_PIC_BRIEF then
		msgInfo = pb.new("PicBriefInfo")
		msgInfo.pic_size = paras.pic_size
		msgInfo.height = paras.height
		msgInfo.width = paras.width
		msgInfo.thumble_url = paras.thumb_url
		msgInfo.url = paras.url
	end
	ChatServer:sendRequest({
    	pbName = 'SendMsgReq',
    	body = {
    		msg_head = {
    			source_userinfo = {
	    			cid = Cache.user.uin,
	    			id_type = GameConstants.ChatIDType.ID_SINGLE,
	    		},
	    		target_userinfo = {
	    			cid = paras.forceLinkType == GameConstants.ChatUserType.PROXCY and Cache.user.invite_from or 100, --现在先和代理聊，后面根据相关处理
	    			id_type = GameConstants.ChatIDType.ID_SINGLE,
	    		},
	    		msg_type = paras.msg_type,
	    		timestamp = timestamp
    		},
    		msg_info = pb.serializeToString(msgInfo),
    		session_info = session_info,
    		proxy_data_id = paras.proxy_data_id or 0
    	}
    })
end

--[[
	更新聊天历史记录
]]
function Chat:updateChatHistoryMessage(rsp)
	local model = rsp.model
	if not model then return end
	local message = self:_updateChatMessage(model)
	return message
end

-- 解析单个消息
function Chat:updateMessage(msg, msgInfo)
	local filedname = {
		"session_info",
		"proxy_data_id", --代客充值中客服的id
		"is_welcome" --是不是代理充值
	}
	--先去解头
	for k,v in pairs(filedname) do
		msgInfo[v] = msg[v]
	end
	msgInfo.is_welcome = msgInfo.is_welcome or 0
	local msg_Head = msg.msg_head
	local msg_Info = msg.msg_info
	--解析消息内容
	local msgType = msg_Head.msg_type
	msgInfo.msg_type = msgType

	--文字
	if msgType == GameConstants.ChatMsgType.MSG_TEXT then
		local textInfo = pb.new("TextMsgInfo")
		pb.parseFromString(textInfo, msg_Info)
		msgInfo.textInfo = {}
		msgInfo.textInfo.msg = textInfo.msg --转换换行符
	--图片摘要
	elseif msgType == GameConstants.ChatMsgType.MSG_PIC_BRIEF then
		local picInfo = pb.new("PicBriefInfo")
		pb.parseFromString(picInfo, msg_Info)
		msgInfo.picInfo = {}
		msgInfo.picInfo.pic_size = picInfo.pic_size
		msgInfo.picInfo.height = picInfo.height
		msgInfo.picInfo.width = picInfo.width
		msgInfo.picInfo.thumble_url = picInfo.thumble_url
		msgInfo.picInfo.url = picInfo.url
		--判断下有没有下载
	end

	--解析信息的拥有者
	if msg_Head.source_userinfo then
		msgInfo.uin = msg_Head.source_userinfo.cid
	end

	if msg_Head.target_userinfo then
		msgInfo.targetid = msg_Head.target_userinfo.cid
	end

	msgInfo.bLoad = true --这个可以用来识别有没有加载成功
	msgInfo.timestamp = msg_Head.timestamp --时间戳
	msgInfo.sequence = msg_Head.sequence --唯一序列号
	-- 如果用户给代理发消息
	if msgInfo.uin == Cache.user.uin and msgInfo.targetid == Cache.user.invite_from then
		self:setProxcyDataId(msgInfo.proxy_data_id)
	end
end

-- 更新新的聊天信息
function Chat:updateNewChatMessage(rsp)
	local model = rsp.model
	if not model then return end
	local message = self:_updateChatMessage(model)
	return message
end

-- 客服 1 代理 2
function Chat:getLastMessageWhenPush(targeType)
	local lastMesg = nil
	for _,v in pairs(self.data) do
		if targeType == GameConstants.ChatUserType.PROXCY then
            if v.uin == Cache.user.invite_from or (v.uin == Cache.user.uin and v.targetid == Cache.user.invite_from) then
                lastMesg = v
            end
        else
            if Cache.user:isCustomerService(v.uin) or (v.uin == Cache.user.uin and Cache.user:isCustomerService(v.targetid)) then
                lastMesg = v
            end
        end
	end
	return lastMesg
end

-- 插入本地数据
-- 判断的唯一依据就是timestamp
function Chat:insertLocalData(paras)
	if not paras then return end
	if not paras.timestamp then return end
	if not paras.session_info then return end
	local data = {}
	data.msg_type = paras.msg_type
	data.timestamp = paras.timestamp
	data.session_info = paras.session_info
	data.bLoad = false
	data.reSend = paras.reSend
	data.oldMessage = paras.oldMessage
	if paras.msg_type == GameConstants.ChatMsgType.MSG_TEXT then
		data.textInfo = {}
		data.textInfo.msg = string.nl2br(paras.msg)
	elseif paras.msg_type == GameConstants.ChatMsgType.MSG_PIC_BRIEF then
		data.picInfo = {}
		data.picInfo.nativePath = paras.nativePath
	end
	data.uin = paras.uin
	data.proxy_data_id = paras.proxy_data_id
	data.targetid = paras.targetid
	table.insert(self.data, data)
	return data
end

function Chat:checkIfHaveLocalData(session_info)
	for k,v in pairs(self.data) do
		if tostring(v.session_info) == tostring(session_info) then
			return k, v
		end
	end
	return nil, nil
end

function Chat:_deleteChatMessage(sessionInfo)
	local index = nil
	local index
	for k,v in pairs(self.data) do
		if tostring(v.session_info) == tostring(sessionInfo) then
			index = k
			break
		end
		
	end
	if index then
		table.remove(self.data, index)
	end
	self:_chacheChatData()
end

function Chat:_updateChatMessage(model)
	local newMsg = {}
	local currentTime = os.time()
	for i = 1, model.msgs:len() do
		local msg = model.msgs:get(i)
		local msgInfo = {}
		self:updateMessage(msg, msgInfo)
		-- 如果本地数据有,则更新数据
		local index, localData = self:checkIfHaveLocalData(msgInfo.session_info)
		if localData then
			-- 自己发的等待消息，这里是先展示，后更新数据才过来的
			if localData.bLoad == false and localData.uin == Cache.user.uin and not localData.reSend then
				msgInfo.targetid = localData.targetid
				if msgInfo.picInfo then
					msgInfo.picInfo.nativePath = localData.picInfo.nativePath
				end
				if index then
					self.data[index] = msgInfo
				end
				if localData.msg_type == GameConstants.ChatMsgType.MSG_PIC_BRIEF then
					qf.event:dispatchEvent(ET.UPDATE_CHAT_ITEM,{sessionInfo = msgInfo.session_info, mesgType = localData.msg_type})
				end
				-- 文字比较特殊，界面不展示，只是为了处理targetid
				if localData.msg_type == GameConstants.ChatMsgType.MSG_TEXT then
					qf.event:dispatchEvent(ET.UPDATE_CHAT_ITEM,{sessionInfo = msgInfo.session_info, mesgType = localData.msg_type})
				end
			else
				-- 删除之前未重发记录
				if localData.reSend then
					if index then
						-- 新消息重置
						self.data[index] = msgInfo
					end
					self:_deleteChatMessage(localData.oldMessage)
					--未重新发送的队列需要重新排列
					self.sendFailData[localData.session_info] = nil
					qf.event:dispatchEvent(ET.UPDATE_CHAT_ITEM,{remove = true, sessionInfo = localData.oldMessage})
					msgInfo.targetid = localData.targetid
					-- 重发是新的记录，但是数据要清除，界面展示
					table.insert(newMsg,msgInfo)
				end
			end
		else
			if msgInfo.msg_type == GameConstants.ChatMsgType.MSG_TEXT and msgInfo.textInfo.msg == defaultSendMsg then
				
			else
				table.insert(self.data, msgInfo)
				table.insert(newMsg,msgInfo)
			end
		end
	end
	--按时间排序
	table.sort(self.data, function (a, b)
		return tonumber(a.timestamp) < tonumber(b.timestamp)
	end)

	table.sort(newMsg, function (a, b)
		return tonumber(a.timestamp) < tonumber(b.timestamp)
	end)
	-- 每次服务器这边通知都要缓冲数据
	self:_chacheChatData()
	return newMsg
end

-- 缓存聊天数据
function Chat:_chacheChatData(...)
	local customerDataIndex = 1
	local proxcyDataIndex = 1
	local originData = clone(self.data)
	local cacheData = {}
	table.sort(originData, function (a, b)
		return tonumber(a.timestamp) > tonumber(b.timestamp)
	end)
	-- 当前时间
	local currentTime = os.time()
	for _, v in ipairs(originData) do
		--代理聊天记录
        if v.uin == Cache.user.invite_from or (v.uin == Cache.user.uin and v.targetid == Cache.user.invite_from) then
            if customerDataIndex <= chatDataMax and (currentTime - tonumber(v.timestamp)) <= chatDataMaxTime*24*60*60 then
            	table.insert(cacheData, v)
            	customerDataIndex = customerDataIndex + 1
            end
        end
        --客服聊天记录
        if Cache.user:isCustomerService(v.uin) or (v.uin == Cache.user.uin and Cache.user:isCustomerService(v.targetid)) then
            if proxcyDataIndex <= chatDataMax and (currentTime - tonumber(v.timestamp)) <= chatDataMaxTime*24*60*60 then
            	table.insert(cacheData, v)
            	proxcyDataIndex = proxcyDataIndex + 1
            end
        end
	end

	table.sort(cacheData, function (a, b)
		return tonumber(a.timestamp) < tonumber(b.timestamp)
	end)

	--存储聊天数据
	cc.UserDefault:getInstance():setStringForKey("Chat_Cache_" .. Cache.user.uin,  qf.json.encode(self.data));
    cc.UserDefault:getInstance():flush()
end

-- 更新未读状态
function Chat:updateUnReadMessage(message)
	if not message then return end
	for _,v in pairs(self.data) do
		if v.uin == message.uin and v.targetid == message.targetid and message.sequence == v.sequence and v.is_welcome == 0 then
			v.unreadType = Cache.user:isCustomerService(message.uin) and 1 or 2
			break
		end
	end
	self:_chacheChatData()
end

function Chat:updateSendFailMessage(message)
	if not message then return end
	self.sendFailData[message.session_info] = message

	--更新属性
	for k,v in pairs(self.data) do
		if tostring(v.session_info) == tostring(message.session_info) and not v.reSend then
			dump(v)
			v.reSend = true
			break
		end
	end
	self:_chacheChatData()
end

function Chat:resendFailMessage(sessionInfo, forceLinkType)
	if not sessionInfo then return end
	-- 重发用当前时间
	local timestamp = os.time()
	local currentSessionTime = math.floor(socket.gettime()*1000)
	local message = nil
	local index
	-- 去新的业务上面找
	for k,v in pairs(self.data) do
	 	if tostring(v.session_info) == tostring(sessionInfo) then
	 		message = v
	 		index = k
	 		break
	 	end
	 end
	if message then
		-- 先插入一条本地数据
		Cache.cusChatInfo:insertLocalData({
	        timestamp = timestamp,
	        session_info = currentSessionTime,
	        msg_type = message.msg_type,
	        msg = message.textInfo.msg,
	        uin = Cache.user.uin,
	        targetid = forceLinkType == GameConstants.ChatUserType.PROXCY and Cache.user.invite_from or 100,
	        reSend = true,
	        oldMessage = message.session_info,
	        proxy_data_id = message.proxy_data_id
	    })
	    -- 发送消息
	 	self:sendChatMessage({
	        msg = message.textInfo.msg,
	        timestamp = timestamp,
	        session_info = currentSessionTime,
	        msg_type = message.msg_type,
	        forceLinkType = forceLinkType,
	        proxy_data_id = message.proxy_data_id
	    })
	    table.remove(self.sendFailData, index)
	end
	
end

function Chat:clearUnReadMessage(unreadType)
	for _,v in pairs(self.data) do
		if v.unreadType then
			if v.unreadType == unreadType then
				v.unreadType = nil
			end
		end
	end
	self:_chacheChatData()
end

function Chat:getUnReadMessage(unreadType)
	return self:_getUnReadMessage(unreadType)
end

function Chat:_getUnReadMessage(unreadType)
	local unreadMessage = nil
	for k,v in pairs(self.data) do
		if v.unreadType then
			if v.unreadType == unreadType and v.is_welcome == 0 then
				unreadMessage = v
				break
			end
		end
	end
	return unreadMessage
end

-- 清除本地聊天记录
function Chat:clearAllLocalChatMessage( ... )
	cc.UserDefault:getInstance():setStringForKey("Chat_Cache_" .. Cache.user.uin,  "");
    cc.UserDefault:getInstance():flush()
end

function Chat:clear( ... )
	self.data = {}
	ChatServer:unRegisterDataCallBackEvent()
end

return Chat