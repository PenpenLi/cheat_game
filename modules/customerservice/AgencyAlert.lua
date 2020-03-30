local AgencyAlert = class("AgencyAlert", CommonWidget.PopupWindow)

AgencyAlert.TAG = "AgencyAlert"

local margin = 64
local topY = - 50

function AgencyAlert:ctor(parameters)
    self.winSize = cc.Director:getInstance():getWinSize()
    self.root = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.agencyAlertJson)
    self:init(parameters)
    self.super.ctor(self, {id=PopupManager.POPUPWINDOW.agencyAlert, child=self.root})
end

function AgencyAlert:init(parameters)
    local defaultHandler = handler(self, self.onButtonEvent)
    local uiTbl = {
        -- {name = "userHead",         path = "content/inner_content/head"},
        -- {name = "userName",         path = "content/inner_content/nick"},
        {name = "mesgContent",     path = "content/inner_content"},
        -- {name = "mesgTxt",          path = "content/inner_content/mesg/text"},       
        {name = "replyBtn",         path = "content/replyBtn",  handler = defaultHandler},
        {name = "closeBtn",         path = "content/closeBtn",  handler = defaultHandler}
    }

    Util:bindUI(self, self.root, uiTbl)
    if FULLSCREENADAPTIVE then
        self.root:setContentSize(cc.size(self.root:getContentSize().width + self.winSize.width-1920,self.root:getContentSize().height))
    end
    self:layoutTextLines()
    self.messageData = parameters.data
    self:updateAgencyInfo(parameters.data)
end

function AgencyAlert:initContentText( ... )
    if self.contentText then return end
    local contentSize = cc.size(600, 240)
    self.contentText = ccui.RichText:create()
    self.contentText:ignoreContentAdaptWithSize(false)
    self.contentText:setContentSize(contentSize)
    self.contentText:setAnchorPoint(cc.p(0, 0))
    self.contentText:setPosition(cc.p(0 - 260, -4))
    self.contentText:setVerticalSpace(27)
    self.mesgContent:addChild(self.contentText)
end

function AgencyAlert:layoutTextLines( ... )
    local lineMax = 5
    for i = 1, 5 do
        local line = ccui.ImageView:create(GameRes.customer_msg_alert_line)
        line:setAnchorPoint(cc.p(0,0))
        line:setPosition(cc.p((self.mesgContent:getContentSize().width - line:getContentSize().width)/2, margin*i + topY))
        self.mesgContent:addChild(line)
    end
end

function AgencyAlert:updateAgencyInfo(data)
    if not data then return end
    if not data.textInfo then return end
    local str = data.textInfo.msg or ""
    
    self:updateMessageInfo(str)
end

--更新数据
function AgencyAlert:updateMessageInfo(message)

    local leftMargin = 36
    local maxLen = self.mesgContent:getContentSize().width - leftMargin*2

    local textTbl = Util:createMultiLineText(message, {maxLen = maxLen})
    for i, v in ipairs(textTbl) do
        v:setTextHorizontalAlignment(2)
        v:setColor(cc.c3b(119,119,119))
        v:setAnchorPoint(cc.p(0,0))
        v:setZOrder(2)
        v:setPosition(cc.p(leftMargin, self.mesgContent:getContentSize().height - margin*i -10 ))
        self.mesgContent:addChild(v)
    end
end

function AgencyAlert:onButtonEvent(sender)
    if sender.name == "replyBtn" then
        self:replyAgencyAction()
    elseif sender.name == "closeBtn" then
        self:close()
    end
end

function AgencyAlert:replyAgencyAction( ... )
    self:close()
    qf.event:dispatchEvent(ET.CUSTOM_CHAT,{autoLink = true})
end

function AgencyAlert:close(parameters)
    Cache.cusChatInfo:notifyLastReadInfoToServer(self.messageData, 0, self.messageData.proxy_data_id)
    self.super.close(self, parameters)
end

function AgencyAlert:getRoot() 
    return LayerManager.PopupLayer
end

return AgencyAlert