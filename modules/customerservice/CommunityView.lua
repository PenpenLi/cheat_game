local CommunityView = class("CommunityView", CommonWidget.PopupWindow)

CommunityView.TAG = "CommunityView"

function CommunityView:ctor(parameters)
    self.winSize = cc.Director:getInstance():getWinSize()
    self.root = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.communityViewJson)
    self:init(parameters)
    self.super.ctor(self, {id=PopupManager.POPUPWINDOW.communityView, child=self.root})
end

function CommunityView:init(parameters)
    local defaultHandler = handler(self, self.onButtonEvent)
    local uiTbl = {
        {name = "headIcon",                 path = "pannal/content_pannal/master_info/head"},
        {name = "reasonTf" ,                path = "pannal/content_pannal/request_content_reason/tf"},
        {name = "requestBtn",               path = "pannal/content_pannal/master_info/request_btn",  handler = defaultHandler},
        {name = "requestToCommunityBtn",    path = "pannal/content_pannal/request_to_community_btn",  handler = defaultHandler},
        {name = "closeBtn",                 path = "pannal/title/btn_close",  handler = defaultHandler}
    }

    Util:bindUI(self, self.root, uiTbl)
    if FULLSCREENADAPTIVE then
        self.root:setContentSize(cc.size(self.root:getContentSize().width + self.winSize.width-1920,self.root:getContentSize().height))
    end
    Util:addButtonScaleAnimFuncWithDScale(self.requestBtn, defaultHandler)
    Util:addButtonScaleAnimFuncWithDScale(self.requestToCommunityBtn, defaultHandler)
    self:updateBaseInfo()
end

function CommunityView:onButtonEvent(sender)
    if sender.name == "closeBtn" then
        self:close()
    elseif sender.name == "requestBtn" then
        self:requestToCommunity()
    elseif sender.name == "requestToCommunityBtn" then
        self:requestToMaster()
    end
end

function CommunityView:requestToCommunity()
    Cache.cusChatInfo:communityRequest(0)
end

function CommunityView:requestToMaster( ... )
    self.reasonTf:setText("")
    qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.become_master_txt})
end

function CommunityView:updateProxcyHead( ... )
    local data = Cache.agencyInfo:getPersonalInfo()
    Util:updateUserHead(self.headIcon, data.proxy_portrait, data.sex, {add = true, sq = true, url = true, circle=true})
end

function CommunityView:updateBaseInfo( ... )
    if Cache.agencyInfo:getPersonalInfo() then
        self:updateProxcyHead()
    else
        -- 刷新代理信息
        Cache.agencyInfo:requestGetAgencyInfo({}, function (data)
            if not tolua.isnull(self) then
                self:updateProxcyHead()
            end
        end)
    end
end

function CommunityView:close(parameters)
    self.super.close(self, parameters)
end

function CommunityView:getRoot() 
    return LayerManager.PopupLayer
end

return CommunityView