--上庄列表界面
local LHDDelarList = class("LHDDelarList", CommonWidget.PopupWindow)
LHDDelarList.TAG = "LHDDelarList"

function LHDDelarList:ctor(isExit)

	self.root =  ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.delarListJson) 
    LHDDelarList.super.ctor(self, {id=PopupManager.POPUPWINDOW.lhdDelarList, child =self.root }) 
    self.isExit = isExit
    self:init()
    self:initTouch()
    self.deskCache = Cache.DeskAssemble:getCache(LHD_MATCHE_TYPE)
    qf.event:dispatchEvent(LHD_ET.BR_QUERY_BANKER_LIST_CLICK)
    if FULLSCREENADAPTIVE then
        self:initFullScreenAdaptive()
    end
end

function LHDDelarList:initFullScreenAdaptive()
    local dx = (cc.Director:getInstance():getWinSize().width-1920)/2
    Util:setPosOffset(self.root, {x = dx})
end


function LHDDelarList:init()
    self.deskCache = Cache.DeskAssemble:getCache(LHD_MATCHE_TYPE)
    self.infoCache = Cache.lhdinfo
    self.list_item = self.root:getChildByName("list_item")
    local min_banker = Util:getProductFormatString(Cache.packetInfo:getProMoney(self.deskCache.min_banker))
    local min_pool_banker = Util:getProductFormatString(Cache.packetInfo:getProMoney(self.deskCache.min_pool_banker))
    local str = string.format(LHD_Games_txt.br_delarlist_txt1,min_banker, min_pool_banker)

    self.root:getChildByName("txt_2"):setString(str)
    self.root:getChildByName("txt_2"):setFontSize(35)
    
    self:gotoDelar(self.isExit)
    self.list_item:setVisible(false)

    Util:registerKeyReleased({self=self, cb = function( sender )
        self:close()
    end})
    --自动刷新上庄列表
    self:initUpdateSchedule()

    local label = ccui.Helper:seekWidgetByName(self.root, "Label_24_1")
    if label then
        label:setString(GameTxt.string_delarlist_1)
    end
end

function LHDDelarList:gotoDelar(status)
    self.isExit = status    
    if status == true then
        self.root:getChildByName("application_up"):getChildByName("Image_89"):loadTexture(GameRes.game_btn_not_want_be_delar_txt)
    else
        self.root:getChildByName("application_up"):getChildByName("Image_89"):loadTexture(GameRes.game_btn_want_be_delar_txt)
    end
end

function LHDDelarList:show()
    LHDDelarList.super.show(self)
end

function LHDDelarList:initTouch()
    local back = self.root:getChildByName("back_btn")
    local btn = self.root:getChildByName("application_up")
    addButtonEvent(back,function() 
        self:close()
    end)
    Util:enlargeCloseBtnClickArea(back,function() 
        self:close()
    end)
    addButtonEvent(self.root,function() 
        self:close()
    end)
    addButtonEvent(btn,function() 
        if self.isExit == true then
            qf.event:dispatchEvent(LHD_ET.BR_DELAR_EXIT_REQ)
        else
            qf.event:dispatchEvent(LHD_ET.BR_DELAR_REQ)
            self.showing = false
            --self:gotoDelar(true)
        end
    end)
end
function LHDDelarList:update(bAni)
    if self.root == nil then return end
    if bAni then
        self:refreshListViewWithOutAni()
    else
        self:refreshListView()
    end
    --显示前方等待上庄数
    self.root:getChildByName("txt_1"):setString(string.format(LHD_Games_txt.br_delarlist_wait_num, self.infoCount))

    self:gotoDelar(self.infoCache.be_delaring)  
end


function LHDDelarList:refreshListView()
    local allInfo = self.infoCache.delars

    self.infoCount = 0

--    if #allInfo == 1 then
--        self.infoCount = #allInfo
--    elseif #allInfo >= 2 and allInfo[1].uin == nil then
--        self.infoCount = #allInfo - 1
--    end
    self.infoCount = #allInfo-1;
    if self.infoCount<0 then 
        self.infoCount = 0;
    end

    local listview = ccui.Helper:seekWidgetByName(self.root,"listview")
    self:stopDelayRun()
    listview:removeAllChildren(true)
    listview:setItemModel(self.list_item)
    
    local function _updateItem(index,info)
        listview:pushBackDefaultItem()
        local item = listview:getItem(index-1)
        item:setVisible(true)
        local remarkname,is_remarkname=Util:getFriendRemark(info.uin,info.nick)
        item:getChildByName("name"):setString(remarkname)
        local gold = info.chips
        -- if checkint(info.uin) >= 1000 and checkint(info.uin) <= 1010 then
        --     gold = 88880000
        -- end
        item:getChildByName("gold"):setString(Util:getFormatString(gold))
        self:updateHead(item:getChildByName("head"), info.portrait, info.gender)
        addButtonEvent(item,function (sender)
            qf.event:dispatchEvent(LHD_ET.GAME_SHOW_USER_INFO,{uin = info.uin})
        end)
        -- Display:showScalePop({view = item,time = 0.1})

    end
    for k,v in pairs(allInfo) do
        -- self:delayRun((k - 1 )*LIST_ITEM_TIME,function()
            if k==1 then
                local delar = self.deskCache:getDelar()
                if v ~= nil and v.uin == delar.uin then 
                       --如果当前有庄家，那么allInfo的第一个内容不属于等待庄家列表，直接到下一次循环                            
                else
                    _updateItem(k, v)    --如果当前无庄家，那么allInfo的第一个内容也属于等待庄家列表
                end                
            else
                _updateItem(k-1, v)      
            end
        -- end)
    end
end



function LHDDelarList:updateHead(node,portrait,sex, extparas)
    local scale=node:getContentSize().width
    local paras = {scale=scale, url=true, sq = true, circle = false, add = true}
    if extparas then
        for k,v in pairs(extparas) do
            paras[k] = v
        end
    end
    Util:updateUserHead(node, portrait, sex, paras)
end

function LHDDelarList:refreshListViewWithOutAni()
    local allInfo = self.infoCache.delars
    self.infoCount = #allInfo-1;
    if self.infoCount<0 
    then 
        self.infoCount = 0;
    end

    local listview = ccui.Helper:seekWidgetByName(self.root,"listview")
    self:stopDelayRun()
    listview:removeAllChildren(true)
    listview:setItemModel(self.list_item)
    
    local function _updateItem(index,info)
        listview:pushBackDefaultItem()
        
        local item = listview:getItem(index-1)
        item:setVisible(true)
        local remarkname,is_remarkname=Util:getFriendRemark(info.uin,info.nick)
        item:getChildByName("name"):setString(remarkname)
        local gold = info.chips
        -- if checkint(info.uin) >= 1000 and checkint(info.uin) <= 1010 then
        --     gold = 88880000
        -- end
        item:getChildByName("gold"):setString(Util:getFormatString(gold))
        self:updateHead(item:getChildByName("head"), info.portrait, info.gender)
        addButtonEvent(item,function (sender)
            qf.event:dispatchEvent(LHD_ET.GAME_SHOW_USER_INFO,{uin = info.uin})
        end)
    end
    for k,v in pairs(allInfo) do
        if k==1 then
            local delar = self.deskCache:getDelar()
            if v ~= nil and v.uin == delar.uin then 
                    --如果当前有庄家，那么allInfo的第一个内容不属于等待庄家列表，直接到下一次循环                            
            else
                _updateItem(k, v)    --如果当前无庄家，那么allInfo的第一个内容也属于等待庄家列表
            end                
        else
            _updateItem(k-1, v)      
        end
    end
end

function LHDDelarList:stopDelayRun()
    ccui.Helper:seekWidgetByName(self.root,"listview"):stopAllActions()
end

function LHDDelarList:delayRun(time,cb)
    ccui.Helper:seekWidgetByName(self.root,"listview"):runAction(
        cc.Sequence:create(
            cc.DelayTime:create(time),
            cc.CallFunc:create( 
                function() 
                    if cb then 
                        cb() 
                    end 
                end))
    )
end


function LHDDelarList:initUpdateSchedule()
    schedule(self, function()
        local _cmd = CMD.LHD_QUERY_BANKER_LIST 
        GameNet:send({cmd = _cmd, callback = function(rsp)
            if rsp.ret == 0 then 
                Cache.lhdinfo:updateDelarList(rsp.model)
                if tolua.isnull(self) == false then
                    self:update(true)
                end
            end
        end})
    end , 1)
end

return LHDDelarList