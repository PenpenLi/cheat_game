local BaseHallView = class("BaseHallView", qf.view)
BaseHallView.TAG = "BasehallView"

function BaseHallView:ctor(parameters)
    print("BaseHallView ctor>>>>>>")
    self.super.super.ctor(self, parameters)
end

function BaseHallView:init(paras)
    self.winSize = cc.Director:getInstance():getWinSize()
    self:initPublicModule()
    if FULLSCREENADAPTIVE then
        self:setPositionX(self.winSize.width/2-1920/2)
    end

    self:updateUserInfo()
    self:initGuangbo()
    self:requestDeskListInfoEx(true)
end

function BaseHallView:openErji(parameters)
end

function BaseHallView:compareDesk(v1, v2)
    if (not v1) or (not v2) then return true end
    if #v1.portrait_list ~= #v2.portrait_list then return true end
    for k, v in pairs(v1) do
        if k ~= "portrait_list" then
            if v1[k] ~= v2[k] then
                -- print("1111111111111", v1[k], v2[k])
                return true
            end
        end
    end

    for i, v in ipairs(v1.portrait_list) do
        for k, vv in pairs(v) do
            if vv ~= v2.portrait_list[i][k] then
                -- print("111111111111122222222222222")
                -- print(vv, v2.portrait_list[i][k])
                return true
            end
        end
    end
end

function BaseHallView:checkNeedRefreshDesk(cdata)
    if self.cacheData then
        if #self.cacheData ~= #cdata then 
            print(#self.cacheData, #cdata)
            return true 
        end
        local compareDesk = function (v1, v2)
            if #v1.portrait_list ~= #v2.portrait_list then return true end

            for k, v in pairs(v1) do
                if k ~= "portrait_list" then
                    if v1[k] ~= v2[k] then
                        -- print("1111111111111", v1[k], v2[k])
                        return true
                    end
                end
            end

            for i, v in ipairs(v1.portrait_list) do
                for k, vv in pairs(v) do
                    if vv ~= v2.portrait_list[i][k] then
                        -- print("111111111111122222222222222")
                        -- print(vv, v2.portrait_list[i][k])
                        return true
                    end
                end
            end
        end
        for i = 1, #cdata do
            if compareDesk(cdata[i], self.cacheData[i]) then
                return true
            end
        end
    else
        -- self.cacheData = cdata
        return true
    end
    return false
end

function BaseHallView:startRefreshDesk()
    self:requestDeskListInfoEx(false)
end

function BaseHallView:requestDeskListInfoEx(bfirst)
    self.errorTxt:setVisible(true)
    self.errorTxt:setString(GameTxt.table_tips_txt_2)
    self:requestDeskListInfo({game_id = self:getGameid()}, function (data)
        if tolua.isnull(self) then return end
        if data then
            local beginTime = socket.gettime()
            local cdata = self:convertClientData(data)
            --由于2s刷新过于频繁 所以如果数据没有进行更改 就不要进行刷新了
            if self:checkNeedRefreshDesk(cdata) then
                print("需要刷新")
                local atime = socket.gettime()
                print("转换客户端与比较客户端时间一共花了的时间", atime - beginTime)

                self:refreshAllTable(cdata, bfirst)
                local btime = socket.gettime()
                print("刷新所有桌子 一共花了的时间", btime - atime)
                self:calculateOnlineNumber(cdata)
                self.cacheData = cdata
                self.errorTxt:setVisible(false)
            end
        else
            self.errorTxt:setVisible(false)
        end
        
        --维护中才展示
        if ret == 1055 then
            self.errorTxt:setVisible(true)
            self.errorTxt:setString(Cache.Config._errorMsg[ret])
        end
    end)
end

function BaseHallView:convertClientData(data)
    return Cache.deskListInfo:convertClientData(data)
end


function BaseHallView:processGameChangeGoldEvt()
    self.goldNumber:setString(Util:getFormatString(Cache.user.gold))
end

function BaseHallView:enterGame(paras)
    -- body
    self:getInRoom(paras.level)
end

-- --初始化button事件
function BaseHallView:initGuangbo()
    --广播
    local broadcast_txt_func = cc.CallFunc:create(function ()
        if not self.has_broadcast_txt then
            self.has_broadcast_txt = true
            qf.event:dispatchEvent(ET.GLOBAL_SHOW_BROADCASE_TXT) --回到主界面接收世界广播
        end
    end)
    local broadcast_layout_func = cc.CallFunc:create(function ()
        if not self.has_broadcast_layout then
            self.has_broadcast_layout = true
            qf.event:dispatchEvent(ET.GLOBAL_SHOW_BROADCASE_LAYOUT)
        end
    end)
    
    self:runAction(cc.Sequence:create(
        cc.DelayTime:create(4.0)
        , broadcast_txt_func
        , cc.DelayTime:create(1.0)
    , broadcast_layout_func))
end


function BaseHallView:initPublicModule()
    -- body
    self.root = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.gameTableJSON)
    local defaultHandler = handler(self, self.onButtonEvent)
    local uiTbl = {
        {name = "title",             path = "game_name/Image_62"},
        {name = "goldNumber",        path = "player_Info/gold",      handler = defaultHandler},
        {name = "personName",        path = "player_Info/name",      handler = nil},
        {name = "addGoldBtn",           path = "player_Info/add_gold",      handler = defaultHandler},
        {name = "menuBtn",           path = "btnMenu",      handler = defaultHandler},
        {name = "onlineNum",           path = "online_num",      handler = nil},
        {name = "playerIcon",           path = "player_Info/icon",      handler = nil},
        {name = "playerHead",           path = "player_Info/head",      handler = defaultHandler},
        {name = "panelBox",           path = "Panel_box",      handler = defaultHandler},
        {name = "backBtn",          path = "btnBack",   handler = defaultHandler},
        {name = "helpBtn",          path = "btnHelp",   handler = defaultHandler},

        {name = "tlistView",          path = "Panel_138/tableListView"},
        {name = "tItem",              path = "Panel_138/tableListView/table_item"},
        {name = "errorTxt",              path = "Panel_138/error_txt"},
    }
    self.root:getChildByName("bg"):setTouchEnabled(true)
    Util:bindUI(self, self.root, uiTbl)
    self:addChild(self.root)
    self:updateGameTitle()
    Util:registerKeyReleased({self = self, cb = function ()
        self:goBcak()
    end})
    self:refreshOnlineNumber(0)
    self:initListView()
end

function BaseHallView:initListView()
    self.tItem:setVisible(true)
    self.tlistView:setItemModel(self.tItem)
    --fix 头像居中问题
    local len = 92
    for i = 1, 3 do
        for j = 1, 5 do
            local head = Util:getChildEx(self.tItem, "table_" .. i .. "/player_" .. j)
            local circle = Util:getChildEx(self.tItem, "table_" .. i .. "/player_" .. j .. "/circle")
            head:setContentSize(cc.size(len,len))
            circle:setPosition(cc.p(len/2, len/2))
        end
        if self:getGameHallName() == "niuniuhall" then
            local zhunru_txt = Util:getChildEx(self.tItem, "table_" .. i .. "/zhunru_txt")
            zhunru_txt:setColor(cc.c3b(245,223,79))
        end
    end

    self.tlistView:setVisible(true)
    self.tlistView:removeAllChildren()
end

function BaseHallView:updateGameTitle()
    if tolua.type(self.title) == "ccui.ImageView" then
        self.title:loadTexture(self:getTitleRes(), 0)
    elseif tolua.type(self.title) == "ccui.TextBMFont" then
        self.title:setString(self:getTitleName())
    end
end

local COL = 3
function BaseHallView:refreshAllTable(data, bfirst)
    local childNum = #self.tlistView:getChildren()
    local row = math.ceil(#data/3)
    for i = childNum+1, row do
        self.tlistView:pushBackDefaultItem()
    end

    for i = row+1, childNum do
        self.tlistView:removeLastItem()
    end

    local idx = 0
    for i = 1, row do
        local item = self.tlistView:getItem(i - 1)
        item.tag = i
        local idx = COL * (i-1)+1
        for j = 1, COL do
            self:refreshItem(item, data, j, idx + j - 1)
        end
    end

    if bfirst then
        self.tlistView:setOpacity(0)
        performWithDelay(self.tlistView, function ( ... )
            self.tlistView:setOpacity(255)
            self.tlistView:jumpToTop()
        end, 0.01)
    end
end

function BaseHallView:refreshItem(item, data, pos, dpos)
    local rdata = data[dpos]
    local _item = item:getChildByName("table_" .. pos)
    _item.tag = pos
    if rdata then
        _item:setVisible(true)
        -- if self.cacheData and self:compareDesk(rdata, self.cacheData[dpos]) then
            -- self:refreshOneTable(_item, rdata)
        -- end
        -- local brefresh = true
        -- print("]]]]]]]]]]", self.cacheData)
        if (self.cacheData == nil) or (self.cacheData and self:compareDesk(rdata, self.cacheData[dpos])) then
            -- print("XXXXXX", self.cacheData)
            self:refreshOneTable(_item, rdata)
        end
    else
        _item:setVisible(false)
    end
end

function BaseHallView:refreshOneTable(nodeTbl, data)
    for i = 1, 5 do
        local head = nodeTbl:getChildByName("player_" .. i)
        head:setVisible(false)
    end
    local lineNum = nodeTbl:getParent().tag
    local addImgName = "add_head_Img"
    for i = 1, #data.portrait_list do
        local info = data.portrait_list[i]
        local idx = info.seat_id + 1
        local head = nodeTbl:getChildByName("player_" .. idx)
        head:setVisible(true)
        local img = head:getChildByName(addImgName)
        if head.portrait == info.portrait and head.sex == info.sex then 
        else
            head:runAction(cc.Sequence:create(
                cc.DelayTime:create(1/60 *i*lineNum*nodeTbl.tag),
                cc.CallFunc:create(function ( ... )
                    Util:updateUserHead(head, info.portrait, info.sex, {add = true, sq = true, url = true, circle=true, addname = addImgName})
                    head.portrait = info.portrait
                    head.sex = info.sex
                end)
            ))
            
        end
    end

    nodeTbl:getChildByName("difen_txt"):setVisible(true)
    nodeTbl:getChildByName("num_txt"):setVisible(true)    
    nodeTbl:getChildByName("num_bg"):setVisible(true)
    nodeTbl:getChildByName("num_txt"):setString(data.show_desk_id)
    local limitMin, limitStr = self:getCurLimitGold(data)
    nodeTbl:getChildByName("zhunru_txt"):setString(GameTxt.hall_txt_6 .. limitStr)

    local res = self:getTableRes(data)
    nodeTbl:loadTexture(res, ccui.TextureResType.plistType)
    nodeTbl:setTouchEnabled(true)
    nodeTbl:setEnabled(true)
    addButtonEvent(nodeTbl, function ()
        self:getInRoom({desk_id = data.desk_id, room_id = data.room_id})
    end)
end

function BaseHallView:onButtonEvent(sender)
    if sender.name == "backBtn" then
        self:goBcak()
    elseif sender.name == "helpBtn" then
        qf.event:dispatchEvent(ET.GAMERULE, {GameType = self:getGameType()})
    elseif sender.name == "setBtn" then
        qf.event:dispatchEvent(ET.SETTING)
    elseif sender.name == "shopBtn" then
        qf.event:dispatchEvent(ET.SHOP)
    elseif sender.name == "outPanel" then
        self.panelBox:setVisible(false)
    elseif sender.name == "bankBtn" then
        qf.event:dispatchEvent(ET.SAFE_BOX)
    elseif sender.name == "addGoldBtn" then
        qf.event:dispatchEvent(ET.SHOP)
    elseif sender.name == "menuBtn" then
        self:goBcak()
    elseif sender.name == "playerHead" then
        qf.event:dispatchEvent(ET.GLOBAL_SHOW_USER_INFO,{uin=Cache.user.uin})
    end
end

function BaseHallView:refreshOnlineNumber(number)
    self.onlineNum:setString(string.format(GameTxt.hall_txt_1, number))
end

function BaseHallView:calculateOnlineNumber(cdata)
    local playerNum = 0
    for i, v in ipairs(cdata) do
        playerNum = playerNum + v.current_players
    end
    self.playerCntNum = playerNum
    self:refreshOnlineNumber(playerNum)
end

function BaseHallView:updateUserInfo()
    -- 更新信息栏
    self.goldNumber:setString(Util:getFormatString(Cache.user.gold))
    self.personName:setString(Cache.user.nick)
    self.playerIcon:removeAllChildren()
    self.playerIcon:setLocalZOrder(2)
    Util:updateUserHead(self.playerIcon, Cache.user.portrait, Cache.user.sex, {add = true, sq = true, url = true, scale = 120, circle=true})
end


function BaseHallView:getRoot() 
    return LayerManager.ChoseHallLayer
end

function BaseHallView:goBcak()
    self.root:runAction(cc.Sequence:create(cc.FadeTo:create(0.3, 0)))
    self:runAction(cc.Sequence:create(
        cc.MoveBy:create(0.3, cc.p(733, 0)), 
        cc.CallFunc:create(function (sender)
            local hallName = self:getGameHallName()
            qf.event:dispatchEvent(ET.MODULE_HIDE, hallName)
            ModuleManager[hallName]:remove()
            ModuleManager.gameshall:initModuleEvent()
        end)))
    ModuleManager.gameshall:show()
    ModuleManager.gameshall:showReturnHallAni({lastview = "hallview"})
end

function BaseHallView:requestDeskListInfo(paras, cb)
    Cache.deskListInfo:requestDeskListInfo(paras, cb)
end

function BaseHallView:enter()
end

function BaseHallView:exit()
end

--由于在父类中调用子类方法 所以暂时采用这种方法来代替
function BaseHallView:getTableRes()
end
function BaseHallView:getGameHallName()
end
function BaseHallView:getTitleName( ... )
end
function BaseHallView:getGameid()
end
function BaseHallView:getCurLimitGold(paras)
end
function BaseHallView:ifNeedReturnMainView(roomid)
end
function BaseHallView:getGameType()
end
function BaseHallView:getTitleRes()
end


function BaseHallView:getZhunRuScore()
    -- body
    return 0
end

return BaseHallView