local BrnnDelarList = class("BrnnDelarList",CommonWidget.PopupWindow)

BrnnDelarList.TAG = "BrnnDelarList"

function BrnnDelarList:ctor(isExit)
    self.root =  ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.delarListJson) 
    self.super.ctor(self, {id=PopupManager.POPUPWINDOW.brDelarList, child =self.root }) 
    self.isExit = isExit
    self:init()
    self:initTouch()
    qf.event:dispatchEvent(BRNN_ET.BR_QUERY_BANKER_LIST_CLICK)

    if FULLSCREENADAPTIVE then
        self:initFullScreenAdaptive()
    end
end

function BrnnDelarList:initFullScreenAdaptive()
    local dx = (cc.Director:getInstance():getWinSize().width-1920)/2
    Util:setPosOffset(self.root, {x = dx})
end

function BrnnDelarList:init()
    self.list_item = self.root:getChildByName("list_item")
    local str = Util:getOldFormatString( Cache.packetInfo:getProMoney(Cache.BrniuniuDesk.min_banker))


    local min_banker = Util:getProductFormatString( Cache.packetInfo:getProMoney(Cache.BrniuniuDesk.min_banker))
    local min_pool_banker = Util:getProductFormatString(Cache.packetInfo:getProMoney(Cache.BrniuniuDesk.min_poor_bank))
    local str = string.format(BrniuniuTXT.br_delarlist_txt1,min_banker, min_pool_banker)
    self.root:getChildByName("txt_2"):setFontSize(35)
    self.root:getChildByName("txt_2"):setString(str)

    self:gotoDelar(self.isExit)
    self.list_item:setVisible(false)

    Util:registerKeyReleased({self=self, cb = function( sender )
        self:close()
    end})

    local label = ccui.Helper:seekWidgetByName(self.root, "Label_24_1")
    label:setString(GameTxt.string_delarlist_1)
end

function BrnnDelarList:gotoDelar(status)
    self.isExit = status
    if status == true then
        self.root:getChildByName("application_up"):getChildByName("Image_89"):loadTexture(GameRes.game_btn_not_want_be_delar_txt)
    else
        self.root:getChildByName("application_up"):getChildByName("Image_89"):loadTexture(GameRes.game_btn_want_be_delar_txt)
    end
end


function BrnnDelarList:show()
    self.super.show(self)
end

function BrnnDelarList:initTouch()
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
            qf.event:dispatchEvent(ET.GLOBAL_TOAST, {txt=BrniuniuTXT.br_delarlist_exit_tip})
            qf.event:dispatchEvent(BRNN_ET.BR_DELAR_EXIT_REQ)
        else
            qf.event:dispatchEvent(BRNN_ET.BR_DELAR_REQ)
            self.showing = false
        end
    end)
end

function BrnnDelarList:update()
    if self.root == nil then return end
    self:refreshListView()
    
    --显示前方等待上庄数
    self.root:getChildByName("txt_1"):setString(string.format(BrniuniuTXT.br_delarlist_wait_num, self.infoCount))
    self:gotoDelar(Cache.BrniuniuInfo.be_delaring)  
end


function BrnnDelarList:refreshListView()
    local allInfo = Cache.BrniuniuInfo.delars
    self.infoCount = 0
    --判断里面是不是有正在坐的庄家
    local bcurrentDelar = false
    for k,v in pairs(allInfo) do
        if v.uin == Cache.BrniuniuDesk.br_delar.uin then
            bcurrentDelar = true
        end
    end
    if bcurrentDelar == true then
        self.infoCount = #allInfo-1;
    else
        self.infoCount = #allInfo
    end
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
        local remarkname,is_remarkname = Util:getFriendRemark(info.uin,info.nick)
        item:getChildByName("name"):setString(remarkname)
        local gold = info.chips
        item:getChildByName("gold"):setString(Util:getFormatString(Cache.packetInfo:getProMoney(gold)))
        self:updateHead(item:getChildByName("head"), info.portrait, info.gender)
        addButtonEvent(item,function (sender)
            qf.event:dispatchEvent(ET.GAME_SHOW_USER_INFO,{uin = info.uin})
        end)

    end
    local index = 0
    for k,v in pairs(allInfo) do
        if v ~= nil and v.uin == Cache.BrniuniuDesk.br_delar.uin then 
               --如果当前有庄家，那么allInfo的第一个内容不属于等待庄家列表，直接到下一次循环                            
        else
            index = index + 1
            _updateItem(index, v)    --如果当前无庄家，那么allInfo的第一个内容也属于等待庄家列表
        end                
    end
end

function BrnnDelarList:delayRun(time,cb)
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

function BrnnDelarList:stopDelayRun()
    ccui.Helper:seekWidgetByName(self.root,"listview"):stopAllActions()
end
function BrnnDelarList:updateHead(node,portrait,sex, extparas)
    local scale=node:getContentSize().width
    local paras = {scale=scale, url=true, sq = true, circle = false, add = true}
    if extparas then
        for k,v in pairs(extparas) do
            paras[k] = v
        end
    end
    Util:updateUserHead(node, portrait, sex, paras)
end

return BrnnDelarList