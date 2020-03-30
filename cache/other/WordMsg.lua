local WordMsg = class("WordMsg")

WordMsg.TAG = "WordMsg"
WordMsg.maxMsgList = 20
function WordMsg:ctor ()

end

function WordMsg:init() 
    if self.deafultMsgList ~= nil then return end
    self.totalMsgList = {}
    self.deafultMsgList = {}
    self.curentIndex = 1
    self.deafIndex = 1
end

--更新msg列表
function WordMsg:saveMsg(paras)
    self:init()
	local msgItem = {}
    msgItem.time = os.time()
	msgItem.level = paras.level
	msgItem.nick = paras.nick
	msgItem.content = paras.content
    msgItem.new_content = paras.new_content
    msgItem.contents={}
    msgItem.contents["str1"] = paras.contents["str1"]
    msgItem.contents["str2"] = paras.contents["str2"]
    msgItem.contents["str3"] = paras.contents["str3"]
    msgItem.contents["str4"] = paras.contents["str4"]
    msgItem.forGame = paras.forGame or 0
    msgItem.forCustomer = paras.forCustomer or 0
    msgItem.forHall = paras.forHall or 0
    if paras.level ~= 500 then
        msgItem.forHall = 1
    end
    table.insert(self.totalMsgList,msgItem)
    if #self.totalMsgList > self.maxMsgList then
        table.remove(self.totalMsgList,1)
    end
    --排下序 等级高的优先，然后先来后到
    self:sortMsgByRule(self.totalMsgList)
    self.curentIndex = #self.totalMsgList
end

--[[
    根据展示类型获取广播消息
    1、大厅展示
    2、客服聊天广播
    3、大厅内广播
]]
function WordMsg:getMsgByType(msgType)
    local msg = {}
    local index = 1
    local totalMsgList = self.totalMsgList or {}
    for _,v in pairs(totalMsgList) do
        if msgType == GameConstants.BroadCastType.Game and v.forGame == 1 then
            msg[index] = v
            index = index + 1
        elseif msgType == GameConstants.BroadCastType.Customer and v.forCustomer == 1 then
            msg[index] = v
            index = index + 1
        elseif msgType == GameConstants.BroadCastType.Hall and v.forHall == 1 then
            msg[index] = v
            index = index + 1
        end
    end
    if #msg > 0 then
        self:sortMsgByRule(msg)
    end
    return msg
end

function WordMsg:sortMsgByRule(msg)
    if not msg then return end
    table.sort(msg, function(a, b)
        --先看等级
        if a.level == b.level then
            return a.time < b.time
        end
        return a.level > b.level
    end)
end

--获取某个等级的msg
function WordMsg:getMsg(level)
    self:init()
    local msg = {}
    local nLen = #self.totalMsgList
    for i=self.curentIndex,nLen do
        if level == 0 then
           msg =  self.totalMsgList[i]
           break
        else
           if self.totalMsgList[i].level == level then
              msg =  self.totalMsgList[i]
              break
           end
        end      
    end
    self.curentIndex = self.curentIndex+1
    if self.curentIndex>nLen then
    	self.curentIndex  = 1
    end
    return msg
end

--获取所有msg
function WordMsg:getAllMsg()
    self:init()
    local AllMsg = {}
    for k,v in pairs(self.deafultMsgList) do
        table.insert(AllMsg,v)
    end

    for k,v in pairs(self.totalMsgList) do
        table.insert(AllMsg,v)
    end
    return AllMsg
end

return WordMsg