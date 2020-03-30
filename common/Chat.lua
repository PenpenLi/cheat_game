local ChatTxtLayer = require("src.common.ChatTxtLayer")
local Chat = class("Chat",function(paras)
    return cc.Node:create()
end)

local PanelType = {
    EMOJI = 1,
    CHAT = 2,
    HISTORY = 3,
}

--Chat 文字列表
Chat.chat_word = {
    GameTxt.chat_txt_1,
    GameTxt.chat_txt_2,
    GameTxt.chat_txt_3,
    GameTxt.chat_txt_4,
    GameTxt.chat_txt_5,
    GameTxt.chat_txt_6,
}

-- Chat 表情列表
Chat.Emoji_List ={
	EMOJI1 = {
		name = 'smiley8',
		res  = GameRes.EMOJI01,
		list ={GameRes.EMOJI_LIST_01}
	},
	EMOJI2 = {
		name = 'smiley9',
		res  = GameRes.EMOJI02,
		list ={GameRes.EMOJI_LIST_02}
	},
	EMOJI3 = {
		name = 'smiley10',
		res  = GameRes.EMOJI03,
		list ={GameRes.EMOJI_LIST_03}
	},
	EMOJI4 = {
		name = 'smiley11',
		res  = GameRes.EMOJI04,
		list ={GameRes.EMOJI_LIST_04}
	},
	EMOJI5 = {
		name = 'smiley12',
		res  = GameRes.EMOJI05,
		list ={GameRes.EMOJI_LIST_05}
	}
}

local emojiConvertTbl = {
    1,2,28,5,
    8,23,18,14,
    16,12,9,25,
    24,15,19,26,
    21,4,20,6,
    3,17,7,29,
    11,13,27,30,
    10,22
}

--最多记录50条
local recordItemMax = 50

function Chat:ctor(paras)
    if qf.device.platform == "ios" then
        self.isIosVersion=true
    end
    self.winSize      = cc.Director:getInstance():getWinSize()
    self._parent_view = paras.view
    self.GameAnimationConfig = paras.GameAnimationConfig

    self._chatCmd = paras.ChatCmd
    print("chatcmd >>>>>>>>>", self._chatCmd)
    self:setEmojiIndex(Chat.Emoji_List)
    self:initGui()
    self:initEmoji()
    self:initChatList()
    self:initRecordList()
    self:initInputBox()
    self:fullScreenAdaptive()
    self.recordDatalist = {}

end 

function Chat.getChatBtn()
    local chatBtn = ccui.Button:create()
    local chatBtnRes = GameRes.chat_info_cbtn
    chatBtn:loadTextures(chatBtnRes, "", "")
    chatBtn:setTouchEnabled(true)
    return chatBtn
end

function Chat:getChatTxtLayer()
    local chatTxtLayer = ChatTxtLayer.new({view = self._parent_view})
    self._chatTxtLayer = chatTxtLayer
    return chatTxtLayer
end

--function--
function Chat:fullScreenAdaptive()
    -- if FULLSCREENADAPTIVE then
    --     local winSize = cc.Director:getInstance():getWinSize()
    --     local size = self.gui:getContentSize()
    --     self.gui:setContentSize(cc.size(winSize.width, size.height))
    --     self.chatBgPos.x = self.chatBgPos.x + winSize.width-1920
    -- end
end


--ios输入处理
function Chat:inputMessage( ... )
    print(" CustomerServicesChat ===== inputMessage ")
    qf.platform:callInputKeyBoard({
        placeHolderString = "",
        valueString = self.placeHolderText:getString() == GameTxt.chat_input_placeHolder_txt and "" or self.placeHolderText:getString(),
        returnType = "done",
        maxLength = 20,
        cb = function (paras)
            local rsp = qf.json.decode(paras)
            if rsp.status == "return" or rsp.status == "done" then
                if rsp.text ~= "" then
                    self.placeHolderText:setString(rsp.text)
                else
                    self.placeHolderText:setString(GameTxt.chat_input_placeHolder_txt)
                end
            end
        end
    })
end


function Chat:clearInputBox()
    if targetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_IPAD then
        self.placeHolderText:setString(GameTxt.chat_input_placeHolder_txt)
    else
        self.inputBox:setText("")
    end
end

function Chat:showPanel(panelType)
    print("showPanel >>>>>>>>>   】】】】】】】", panelType)
    local bEmoji = panelType == PanelType.EMOJI
    local bChat = panelType == PanelType.CHAT
    local bRecord = panelType == PanelType.HISTORY
    self.emoji_panel:setVisible(bEmoji)
    self.emojibtn:setBright(not bEmoji)
    self.emojibtn:setTouchEnabled(not bEmoji)

    self.chat_panel:setVisible(bChat)
    self.chatbtn:setBright(not bChat)
    self.chatbtn:setTouchEnabled(not bChat)

    self.record_panel:setVisible(bRecord)
    self.recordbtn:setBright(not bRecord)
    self.recordbtn:setTouchEnabled(not bRecord)
end

function Chat:onButtonEvent(sender)
    print("sname >>>>123123>>>>>", sender.name)
    if sender.name == "emojibtn" then
        self:showPanel(PanelType.EMOJI)
    elseif sender.name == "chatbtn" then
        self:showPanel(PanelType.CHAT)
    elseif sender.name == "recordbtn" then
        self:showPanel(PanelType.HISTORY)
    elseif sender.name == "sendbtn" then
        self:sendFunc()
    elseif sender.name == "diFrame" then
        self:inputMessage()
    elseif sender.name == "closePanel" then
        self.chatP:setVisible(true)
        self:hide()
    end

end

--初始化画面
function Chat:initGui()
    self:setVisible(false)
    self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.chatViewJson)
    self:addChild(self.gui)
    local defaultHandler = handler(self, self.onButtonEvent)
    local uiTbl = {
        {name = "closePanel",           path = "closePanel",                  handler = defaultHandler},

        {name = "playerP",           path = "normalroomP",                  handler = nil},
        {name = "emojibtn",        path = "normalroomP/emojibtn", handler = defaultHandler},
        {name = "recordbtn",        path = "normalroomP/historybtn", handler = defaultHandler},
        {name = "chatbtn",     path = "normalroomP/textbtn",       handler = defaultHandler},   

        {name = "sendbtn",     path = "send",       handler = defaultHandler},               

        {name = "emoji_panel",     path = "emoji_panel",       handler = nil},               
        {name = "emoji_listview_panel",   path = "emoji_panel/emoji_listview_panel",          handler = nil},
        {name = "emoji_exp",              path = "emoji",          handler = nil},
        {name = "emoji_item",             path = "emoji_item_panel",          handler = nil},        

        {name = "chat_panel",     path = "chat_panel",       handler = nil},               
        {name = "chat_item",          path = "chat_item_panel",             handler = nil},

        {name = "record_panel",     path = "record_panel",       handler = nil},       
        {name = "record_item_panel",     path = "record_item_panel",       handler = nil},
        {name = "diFrame",     path = "input_bg",       handler = defaultHandler},
        {name = "chatP", path = "chatP"},
        {name = "chatBg", path = "chatP/bg"},
        {name = "placeHolderText", path = "placeHolderText"},
    }
    self.gui:setVisible(true)
    Util:bindUI(self, self.gui, uiTbl)
    self.chatBgPos=cc.p(self.chatBg:getPositionX(),self.chatBg:getPositionY())
    self:showPanel(PanelType.EMOJI)
    if FULLSCREENADAPTIVE then
        local wSize = cc.Director:getInstance():getWinSize()
        self.closePanel:setContentSize(wSize)
    end
    self:showPanel(PanelType.HISTORY)
end

--初始化聊天的列表
function Chat:initChatList()
    self.chat_panel:setItemModel(self.chat_item)
    for i=1,#Chat.chat_word do
        self.chat_panel:pushBackDefaultItem()
        local layout_item = self.chat_panel:getItem(i - 1)
        layout_item:setVisible(true)
        local img        = ccui.Helper:seekWidgetByName(layout_item,"Image_63")
        local imgTexture = "ui/chat2/chat_info_txt_"  .. i .. ".png"
        print(imgTexture)
        img:loadTexture(imgTexture)
        addButtonEventNoVoice(layout_item,function ()
            self:_send(self._chatCmd, {content=Chat.chat_word[i]})
        end)
    end
end

function Chat:initRecordList()
    self.record_panel:setItemModel(self.record_item_panel)
end

function Chat:initInputBox()
    -- ios 这边出入框特殊处理
    if targetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_IPAD then
        self.placeHolderText:setVisible(true)
        self.diFrame:setTouchEnabled(true)
    else
        self.diFrame:setTouchEnabled(false)
        self.placeHolderText:setVisible(false)
        if Chat.inputBox == nil then
            Chat.inputBox = Util:createEditBox(self.diFrame, {
                placeTxt = "可输入10个汉字字符",
                retType = cc.KEYBOARD_RETURNTYPE_DONE,
                holdColor = cc.c3b(185, 185, 185),
                fontcolor = cc.c3b(30, 30, 30),
                posOffset = {x = 10, y = 0},
                maxLen = 10,
                bAlone = true
            })
            Chat.inputBox:retain()
        end

        self.diFrame:addChild(Chat.inputBox)
        self.inputBox = Chat.inputBox
        self.inputBox:setText("")
    end
end


function Chat:editboxEventHandler( strEventName,sender )
    if strEventName == "began" then
    elseif strEventName == "ended" then
    elseif strEventName == "return" then
    elseif strEventName == "changed" then
    end
end

--初始化表情图像
function Chat:initEmoji()
    self.emoji_listview_panel:setItemModel(self.emoji_item)
    self.emoji_listview_panel:setItemsMargin(35)
    --总共有多少个表情
    local emojiSum = 30
    --每行多少个表情
    local num_per_col = 4
    local colnum = math.ceil(emojiSum / num_per_col)
    print("colunum >>>>>", colnum)
    for i=1,colnum do
        self.emoji_listview_panel:pushBackDefaultItem()
        local layout_item = self.emoji_listview_panel:getItem(i - 1)
        for j = (i-1)*num_per_col+1, (i-1)*num_per_col+num_per_col do
            if j<= 30 then
                local less = math.modf(j%num_per_col)
                if less == 0 then
                    less = num_per_col
                end
                local Sprite = self.emoji_exp:clone()
                -- print("j>>>>>>>>>>>>>>>>", j)
                local idx = Chat.getEmojiIndex(j)
                -- print("idx >>>>>", idx)
                Sprite:loadTexture("emoji"..tostring(idx)..".png",1)
                Sprite:setPosition(18+(less-1)*43,60)
                layout_item:addChild(Sprite)
                Sprite:setScale(0.5)
                Sprite:setTouchEnabled(true)
                --点击播放
                addButtonEventNoVoice(Sprite,function ()
                    -- print(">>>>>>>>>>>>>>>idx", j)
                    -- GameNet:send({cmd=self._chatCmd,body={content="#"..tostring(j)}})
                    self:_send(self._chatCmd, {content="#"..tostring(j)})
                end)
            end
        end
    end
end


--初始化VIP表情图像
-- function Chat:initVipEmoji()
--     -- body
--     self.vemoji_listview_panel:setItemModel(self.vemoji_item)

--     for i=1,6 do
--         self.vemoji_listview_panel:pushBackDefaultItem()
--         local layout_item = self.vemoji_listview_panel:getItem(i - 1)
--         for j = (i-1)*3+1, (i-1)*3+3 do
--             if j<= 20 then

--                 local less = math.modf(j%3)
--                 if less == 0 then
--                     less = 3
--                 end
--                 local Sprite = self.vemoji_exp:clone()
    
--                 Sprite:loadTexture("vip_emoji_"..tostring(j)..".png",1)
--                 Sprite:setPosition(100+(less-1)*200,120)
--                 layout_item:addChild(Sprite)
--                 Sprite:setScale(0.8)
--                 Sprite:setTouchEnabled(true)

--                 --点击播放
--                 addButtonEventNoVoice(Sprite,function ()
--                     GameNet:send({cmd=self._chatCmd,body={content="$"..tostring(j)}})
--                 end)
--             end
--         end
--     end
-- end


-- function Chat:getList()
--     -- body
--     return Cache.DDZDesk.chat
-- end

--初始化聊天记录
-- function Chat:initChatRecord()

--     self.record_panel:setItemModel(self.record_item)
--     self.record_panel:removeAllChildren()



--     local item = self:getList()
--     if item then
--     for i=1,#item do

--         self.record_panel:pushBackDefaultItem()
--         local layout_item   = self.record_panel:getItem(i - 1)
--         local font          = nil
--         local icon          = nil
--         local emoji          = nil
--         local font_r        = ccui.Helper:seekWidgetByName(layout_item,"font_r")
--         local icon_r        = ccui.Helper:seekWidgetByName(layout_item,"icon_r")
--         local emoji_r        = ccui.Helper:seekWidgetByName(layout_item,"emoji_r")
--         local font_l        = ccui.Helper:seekWidgetByName(layout_item,"font_l")
--         local icon_l        = ccui.Helper:seekWidgetByName(layout_item,"icon_l")
--         local emoji_l        = ccui.Helper:seekWidgetByName(layout_item,"emoji_l")

--         font_r:setVisible(false)
--         icon_r:setVisible(false)
--         emoji_r:setVisible(false)
--         font_l:setVisible(false)
--         icon_l:setVisible(false)
--         emoji_l:setVisible(false)
        
--         if item[i].uin ~= Cache.user.uin then
--             font = font_r
--             icon = icon_r
--             emoji = emoji_r
--         else
--             font = font_l
--             icon = icon_l
--             emoji = emoji_l
--             --默认显示33的字符就需要换行了
--             if #item[i].content <=33 then
--                 font:setTextHorizontalAlignment(2)
--             end
            
--         end
--         local content=Util:filterEmoji(item[i].content or "")
--         font:setString(content)

--         Util:updateUserHead(icon, item[i].portrait, item[i].sex, {add=true, sq=true, url=true})
        
  
--         if item[i].emoji then
--             local index      = string.sub(item[i].content,1,1)
--             local content=string.sub(item[i].content,2,string.len(item[i].content))
--             local png
--             if index == "#" then
--                 png="emoji"..content..".png" 
--             elseif index == "$" then
--                 png="vip_emoji_"..content..".png" 
--                 emoji:setScale(0.7)
--             end
--             if index== "#" and string.len(item[i].content)>1 and tonumber(content)>0 and tonumber(content)<=30 or index== "$" and string.len(item[i].content)>1 and tonumber(content)>0 and tonumber(content)<=18 then
--                 emoji:loadTexture(png,ccui.TextureResType.plistType)
--                 emoji:setVisible(true)
--             else
--                 font:setString(item[i].content)
--                 font:setVisible(true)
--             end
--         else
--             font:setString(item[i].content)
--             font:setVisible(true)
--         end
--         icon:setVisible(true)
--         addButtonEventNoVoice(layout_item,function( ... )
--             -- body
--             self.input:setText("")
--             self.input:setText(item[i].content)
--         end)
--     end
--     end

--     self.record_panel:jumpToBottom()
-- end

function Chat:getChatListIndex(chatContent)--获得是第几条话语
    -- body
    for i=1,#Chat.chat_word do
        if Chat.chat_word[i]==chatContent then
            return i
        end
    end
end

--显示chat面板
function Chat:show()
    self:showPanel(PanelType.EMOJI)
    local bg=ccui.Helper:seekWidgetByName(self.chatP,"bg")
    local p1 = cc.p(self.chatBgPos.x,self.chatBgPos.y)
    local size = bg:getContentSize()
    bg:setPosition(p1)
    bg:setScale(0.01)
    bg:setVisible(true)
    self:setVisible(true)
    bg:runAction(cc.Sequence:create(
        cc.EaseSineOut:create(cc.ScaleTo:create(0.2,1)),
        cc.CallFunc:create(function(sender)
            self:setVisible(true)
        end)
    ))
end


--影藏chat面板
function Chat:hide()
    local bg=ccui.Helper:seekWidgetByName(self.chatP,"bg")
    bg:runAction(cc.Sequence:create(
        cc.EaseSineIn:create(cc.ScaleTo:create(0.2,0,0)),
        cc.CallFunc:create(function(sender)
            self:setVisible(false)
        end)
    ))
    if self.chat_edit_box_for_ios and self.chat_edit_box_for_ios:isVisible() then
        self.chat_edit_box_for_ios:setVisible(false)
        self.isShowVirtualEditBoxing=false
    end
end


function Chat:setVirtualEditBox()
    local winsize = cc.Director:getInstance():getWinSize()
    local fsize = cc.Director:getInstance():getOpenGLView():getFrameSize()
    self.chat_edit_box_for_ios:setVisible(true)
    self.chatP:setVisible(false)

    local box_width=self.chat_edit_box_for_ios:getContentSize().width
    self.chat_edit_box_for_ios:setAnchorPoint(0.5,0.0)
    self.chat_edit_box_for_ios:setPositionX(winsize.width/2)
    local  rate=winsize.width/box_width
    self.chat_edit_box_for_ios:setScale(rate)


    if string.len(self.input:getStringValue())>0 then
        self.editName:setText(self.input:getStringValue())
    -- else
    --     self.input:setPlaceHolder(GameTxt.string632)
    end
    self.isShowVirtualEditBoxing=true
    qf.platform:openKeyboard({close = 0})
  
end


function Chat:closeVirtualBox(hide)
    -- if self.editName then
    --     self.input:setText(self.editName:getText())
    -- end
    if self.isIosVersion==true then
      qf.platform:closeKeyboard({close = 1})
    end
    if self.isIosVersion==true then
         self.chat_edit_box_for_ios:setVisible(false)
         self.chatP:setVisible(true)
         --self.editName:setAttachWithIME(false)
         --self.editName:setText("")
         --self.editName.num=0
         --self.arrow_text:setVisible(false)
         --self.arrow_text:setPosition(self.editName:getContentSize().width+1,self.editName:getContentSize().height*0.5)
      end
end

function Chat:receiveNewMsg(paras)
    local index, lenght, num = self:resolveChatTxt(paras.model)
    if index ~= "#" then --文本记录下来
        local content = paras.model.content
        local nick = paras.name
        if paras.uin == Cache.user.uin then
            nick = GameTxt.chat_myself_txt
        end
        local data = { newMsg = content, uin =  paras.uin, nick = nick}
        dump(data)
        self.recordDatalist[#self.recordDatalist + 1] = data
        -- dump(data)
        self:refreshRecordPanel(data)
    end
end

function Chat:refreshRecordPanel(data)
    local rpanel = self.record_panel
    if #self.recordDatalist > recordItemMax then
        rpanel:removeItem(0)
        table.remove(self.recordDatalist, 1)
    end

    rpanel:pushBackDefaultItem()
    local items = rpanel:getItems()
    local item = items[#items]
    local label = item:getChildByName("Label_73")

    if data.uin == Cache.user.uin then
        label:setString(data.nick .. "： " .. data.newMsg)
        label:setColor(cc.c3b(120, 169, 255))
    else
        local nicklabel = label:clone()
        item:addChild(nicklabel)
        nicklabel:setString(data.nick .. "： ")
        nicklabel:setColor(cc.c3b(185, 185, 185))
        label:setString(data.newMsg)
        local nickSize = nicklabel:getContentSize()
        Util:setPosOffset(label, {x = nickSize.width, y = 0})
    end
    performWithDelay(rpanel, function ( ... )
        rpanel:jumpToBottom()
    end, 0.01)
end

-- local cnt = 1
function Chat:sendFunc()
    print("sendeFunc")
    local sendMessage = nil
    if self.inputBox then
        sendMessage = self.inputBox:getText()
    else
        sendMessage = self.placeHolderText:getString()
        if sendMessage == GameTxt.chat_input_placeHolder_txt then
            sendMessage = ""
        end
    end

    -- local sendMessage = filter_spec_chars(sendMessage)
    -- print("sendMessage >>>>>", sendMessage)
    if not sendMessage then return end
    self:_send(self._chatCmd, {content=sendMessage})
    -- GameNet:send({cmd=self._chatCmd,body={content=sendMessage}})
    -- self:receiveNewMsg({newMsg = "" .. cnt})
    -- cnt = cnt + 1
    -- rpanel:getChld
    -- local txt 

    -- self.record_panel:setItemModel(self.record_item_panel)
    -- for i=1,#recordDatalist do
    --     self.record_panel:pushBackDefaultItem()
    --     local layout_item = self.record_panel:getItem(i - 1)
    --     layout_item:getChildByName("Label_73"):setString(recordDatalist[i])
    --     addButtonEventNoVoice(layout_item,function ()
    --         print("asdfsafdadfasdf 123123", i)
    --         -- GameNet:send({cmd=self._chatCmd,body={content=Chat.chat_word[i]}})
    --     end)
    -- end

end


function Chat.init(GameAnimationConfig)
end

function Chat.getEmojiIndex(index)
    return emojiConvertTbl[index]
end

--聊天统一处理
--model 收到的数据 user 哪个用户
function Chat:chatProtocol(model, user, del, paras)
    --如果有自定义的函数可以直接调用自定义函数
    if paras and paras.callfunc then
        paras.callfunc()
        return
    end

    -- if Cache.user.uin == model.op_uin then del._chat:hide() end
    if not user then
        return
    end
    if user then
        if user.showPopChat then
            user:showPopChat(model, del)
            -- self:receiveNewMsg(model)
        else
            print("user have no showPopChat function!!!")
        end
    end

    -- local index = del._chat:getChatListIndex(model.content)

    -- if user:getSexByCache(model.op_uin)==0 and index then
    --     MusicPlayer:playEffectFile(string.format(Niuniu_Games_res.all_music.CHAT_0,index))
    -- elseif index then
    --     MusicPlayer:playEffectFile(string.format(Niuniu_Games_res.all_music.CHAT_1,index))
    -- end

    -- MusicPlayer:playEffectFile(effectFile)
end

--得到聊天内容
function Chat:resolveChatTxt(model)
    -- body
    local index = string.sub(model.content,1,1)
	local lenght = string.len(model.content)
    local num = string.sub(model.content,2,lenght)
    return index, lenght, num
end

function Chat:showPopChatProtocol(model, del, paras)
    if paras and paras.callfunc then
        paras.callfunc()
        return 
    end

    -- #24
    local index, lenght, num = self:resolveChatTxt(model)
	dump(model)
	dump(model.content)
	print("index >>>>>>>>>", index)
	print("lenght >>>>>>>>>", lenght)
    print("num >>>>>>>>>", num)
    if index == "#" and string.len(model.content)>1 and tonumber(num) and tonumber(num)>0 and tonumber(num)<=30 then
		local lenght = string.len(model.content)
		local num = string.sub(model.content,2,lenght)
        num = Chat.getEmojiIndex(tonumber(num))

        if del.emoji then
            del:emoji(num, self.Emoji_index)
        else
            print("user have no emoji function")
        end
	else
        if paras and paras.chatDel then
            local content = model.content
            if content == "" then return end
            local chat_txt_layer = paras.chatDel.chat_txt_layer
            print("chat_txt_layer>>>>>>>>>>>", chat_txt_layer, content)
            if del.playShowChatMsg then
                del:playShowChatMsg(chat_txt_layer, content)
            else
                print("user have no playShowChatMsg")
            end
        end
	end
end

--表情配置
function Chat:setEmojiIndex(Emoji_List)
    self.Emoji_index = {
        [1] = {
            animation = Emoji_List.EMOJI1,
            index     = 1,
        },
        [2] = {
            animation = Emoji_List.EMOJI1,
            index     = 3,
        },
        [3] = {
            animation = Emoji_List.EMOJI1,
            index     = 2,
        },  
        [4] = {
            animation = Emoji_List.EMOJI1,
            index     = 4,
        },  
        [5] = {
            animation = Emoji_List.EMOJI2,
            index     = 0,
        },  
        [6] = {
            animation = Emoji_List.EMOJI2,
            index     = 1,
        },  
        [7] = {
            animation = Emoji_List.EMOJI2,
            index     = 2,
        },
        [8] = {
            animation = Emoji_List.EMOJI1,
            index     = 0,
        },  
        [9] = {
            animation = Emoji_List.EMOJI3,
            index     = 0,
        },  
        [10] = {
            animation = Emoji_List.EMOJI3,
            index     = 1,
        },
        [11] = {
            animation = Emoji_List.EMOJI3,
            index     = 2,
        },
        [12] = {
            animation = Emoji_List.EMOJI3,
            index     = 3,
        },

        [13] = {
            animation = Emoji_List.EMOJI3,
            index     = 4,
        },
        [14] = {
            animation = Emoji_List.EMOJI3,
            index     = 5,
        },

        [15] = {
            animation = Emoji_List.EMOJI2,
            index     = 3,
        },  

        [16] = {
            animation = Emoji_List.EMOJI2,
            index     = 4,
        },  
        [17] = {
            animation = Emoji_List.EMOJI2,
            index     = 5,
        },  

        [18] = {
            animation = Emoji_List.EMOJI4,
            index     = 0,
        },  

        [19] = {
            animation = Emoji_List.EMOJI4,
            index     = 1,
        },
        [20] = {
            animation = Emoji_List.EMOJI4,
            index     = 2,
        },
        [21] = {
            animation = Emoji_List.EMOJI4,
            index     = 3,
        },
        [22] = {
            animation = Emoji_List.EMOJI4,
            index     = 4,
        },
        [23] = {
            animation = Emoji_List.EMOJI4,
            index     = 5,
        },
        [24] = {
            animation = Emoji_List.EMOJI4,
            index     = 6,
        },

        [25] = {
            animation = Emoji_List.EMOJI5,
            index     = 0,
        },
        [26] = {
            animation = Emoji_List.EMOJI5,
            index     = 1,
        },
        [27] = {
            animation = Emoji_List.EMOJI5,
            index     = 2,
        },
        [28] = {
            animation = Emoji_List.EMOJI5,
            index     = 3,
        },
        [29] = {
            animation = Emoji_List.EMOJI5,
            index     = 4,
        },
        [30] = {
            animation = Emoji_List.EMOJI5,
            index     = 5,
        },
    }
end

function Chat:_send(cmd, body)
    -- body
    if body.content == "" then
        qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.chat_limit_empty_txt})
        return
    end
    -- print("zxcvzxvzxvzxcv !!!!! XXXXXX")
    self.lastTime = self.lastTime or 0
    self.curTime = socket.gettime()
    local diffTime = 2
    if (self.curTime - self.lastTime) < diffTime then
        print("too frequent !!!")
        qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_safebox_8})
        return
    end
    self.lastTime = self.curTime
    dump(body)
    GameNet:send({cmd=self._chatCmd,body=body})
    self.inputBox:setText("")
    self:hide()
end

return Chat