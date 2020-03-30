--无座玩家页面
local BrPerson = class("BrPerson",CommonWidget.PopupWindow)

BrPerson.TAG_ID = "brPerson"
function BrPerson:ctor()
    self.root = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.noSeatJson)
    self.super.ctor(self, {id=PopupManager.POPUPWINDOW.brPerson, child =self.root })
    self:init()
    self:initTouch()
    if FULLSCREENADAPTIVE then
        local dx = (cc.Director:getInstance():getWinSize().width-1920)/2
        Util:setPosOffset(self.root, {x=  dx})
    end
    if not Cache.packetInfo:isShangjiaBao() then
        Util:addTangKuangEffect(Util:getChildEx(self.root, "top"))
    end
end
function BrPerson:init()
    self.list_item = self.root:getChildByName("list_item")
    self.list_item:setVisible(false)
    for i = 1 , 3 do
        self.list_item:getChildByName("item_"..i):setVisible(false)
    end
    self.listview = self.root:getChildByName("listview")
    Util:registerKeyReleased({self=self, cb = function( sender )
        self:close()
    end})
    local listview = self.root:getChildByName("listview")
    listview:setItemModel(self.list_item)
    self.root:getChildByName("person_txt"):setString("")
end

function BrPerson:show()
    self.super.show(self)
end

function BrPerson:initTouch()
    local back = self.root:getChildByName("back_btn")
    local hideFunc = function() 
        self:hide()
    end
    addButtonEvent(back,hideFunc)
    Util:enlargeCloseBtnClickArea(back,hideFunc)
end

function BrPerson:update()
    if self.root == nil then return end
    local count = Cache.brinfo.others_count
    if tolua.isnull(self.root) then
        return
    end

    self.root:getChildByName("person_txt"):setString(string.format(GameTxt.br_no_seat_player,count))
    performWithDelay(self, function ( ... )
        self:refreshList()
    end, 0.15)
end

function BrPerson:addItem(idx)
    local item = self.list_item:clone()
    item:setVisible(false)
    item:setPosition(cc.p(0,5))
    for i = 1 , 3 do
        item:getChildByName("item_"..i):setVisible(true)
    end
    
    local y = 2*self.interSpace + self.rowHight*(self.realRow - idx)
    item:setPosition(cc.p(0, y))
    self.scrollview:addChild(item)
    return item
end

function BrPerson:refreshList()
    local allInfo = clone(Cache.brinfo.others)
    -- local function sortByChip(a,b)
    --     return checknumber(a.chips)> checknumber(b.chips)
    -- end
    -- table.sort(allInfo, sortByChip)

    local cnt = #allInfo
    local csize = self.list_item:getContentSize()
    self.root:getChildByName("listview"):setVisible(false)
    self.allInfo = allInfo

    local interSpace = 40 --空隙
    local restOne = (cnt %3 ~= 0 and 1 or 0 )
    local restRow =  ((cnt - (cnt % 3)) / 3) + restOne
    local innerHeight = restRow * (csize.height + interSpace) + interSpace
    local scrollview = self.root:getChildByName("scrollview")
    local innerSize = scrollview:getInnerContainerSize()
    local maxRow = 5 --最多显示5行
    self.scrollview = scrollview
    local realRow = restRow
    if realRow > maxRow then
        realRow = maxRow
    end

    self.maxRow = maxRow
    self.realRow = realRow
    self.totalRow = restRow
    self.interSpace = interSpace
    self.rowHight = csize.height + interSpace
    if self.items == nil then
        self.items = {}
        for i = 1, maxRow do
            local item = self:addItem(i)
            self.items[#self.items + 1] = {item = item, list = {}}
            for k = 1,3 do
                self.items[#self.items].list[k] = item:getChildByName("item_" .. k)
            end
        end        
    end

    self:cacheYList()
    scrollview:setInnerContainerSize(cc.size(innerSize.width, innerHeight))
    local innerContainer = scrollview:getInnerContainer()
    self.scrollHeight = scrollview:getContentSize().height
    self._lastTime = socket.gettime()

    --当y等于0 表示已经到达底层了
    scrollview:addEventListener(function (sender, eventType)
        if eventType == ccui.ScrollviewEventType.scrolling then
            local lasttime = socket.gettime()
            if lasttime - self._lastTime > 0.2 then
                self._lastTime = lasttime
                self:showRange(innerContainer:getPositionY())
            end
        elseif eventType == ccui.ScrollviewEventType.scrollToTop then
            self:showRange(innerContainer:getPositionY())
        elseif eventType == ccui.ScrollviewEventType.scrollToBottom then
            self:showRange(innerContainer:getPositionY())
        end
    end)

    self:showRange(innerContainer:getPositionY())
end


function BrPerson:updateHead(node,portrait,sex, extparas)
    -- local scale= node:getContentSize().width
    -- print("scale >>>>", scale)
    local paras = {url=true}
    if extparas then
        for k,v in pairs(extparas) do
            paras[k] = v
        end
    end
    Util:updateUserHead(node, portrait, sex, paras)
end

function BrPerson:updateItem(item, info)
    item:setVisible(true)
    local remarkname,is_remarkname= Util:getFriendRemark(info.uin,info.nick)
    item:getChildByName("name"):setString(remarkname)
    local gold = info.chips
    local extparas = {}
    local defaultImg
    if Util:checkSysZhuangUin(info.uin) then
        extparas.default=GameRes.defaultZhuangImg
        defaultImg= GameRes.defaultZhuangCircleImg
    end

    extparas.uin = item.uin
    extparas.pcb = function (uin)
        return item.uin ~= uin
    end
    extparas.sq = true
    extparas.add = true
    local goldTxt = Util:getFormatString(Cache.packetInfo:getProMoney(gold))
    item:getChildByName("gold"):setString(goldTxt)
    self:updateHead(item:getChildByName("head"),info.portrait,info.gender,extparas)
    addButtonEvent(item,function (sender)
        qf.event:dispatchEvent(ET.GAME_SHOW_USER_INFO,{uin = info.uin, defaultImg = defaultImg, showGoldTxt = goldTxt})
    end) 
end

function BrPerson:cacheYList()
    self._cacheYList = {}
    for i = 1, self.totalRow do
        local yBegin = 2*self.interSpace + self.rowHight*(self.totalRow - i)
        self._cacheYList[i] = yBegin
    end

    if self.totalRow <= 2 then
        for i = 1, self.totalRow do
            self._cacheYList[i] = self._cacheYList[i] + self.rowHight * (3 - self.totalRow) - 100
        end
    end

    self._restItemIdxList = {}
    for i = 1, self.maxRow do
        self._restItemIdxList[i] = i
    end
    self.yCacheBeginList = {}
    self.idxItemList = {}
end

-- 根据range 把item显示出来
-- 如果iY 等于 0 表示显示的应该就是最后四个
function BrPerson:showRange(iY)
    local iBegin = math.ceil(self.totalRow - (-iY + self.scrollHeight -  2*self.interSpace) /self.rowHight)
    local iEnd = math.floor(self.totalRow - (-iY -  2*self.interSpace -self.rowHight) /self.rowHight)
    if iBegin < 1 then
        iBegin = 1
    end

    if iEnd > self.totalRow then
        iEnd = self.totalRow
    end
    --如果当前的位置已经铺满了 就不要进行移动了
    if self.yCacheBeginList then
        local flag = true
        for i = iBegin, iEnd do
            local idx = table.indexof(self.yCacheBeginList, self._cacheYList[i])
            if idx == false then
                flag = false
                break
            end
        end

        if flag then
            return
        end
    end

    --这个函数得到了哪些item 是可以使用的
    if self.yCacheBeginList then
        local removeList = {}
        for i, v in ipairs(self.yCacheBeginList) do
            -- print(v, self._cacheYList[iBegin], self._cacheYList[iEnd])
            if v > self._cacheYList[iBegin] or v < self._cacheYList[iEnd] then
                local idx = self.idxItemList[i]
                self._restItemIdxList[#self._restItemIdxList + 1] = self.idxItemList[i]
                removeList[#removeList + 1] = i
                self.items[idx].item:setVisible(false)
            end
        end

        table.sort(removeList)
        local len = #removeList
        for i = len, 1, -1 do
            local idx = removeList[i]
            table.remove(self.yCacheBeginList, idx)
            table.remove(self.idxItemList, idx)
        end
    end

    local rCnt = 1
    for i = iBegin, iEnd do
        local yBegin = self._cacheYList[i]
        local idx = table.indexof(self.yCacheBeginList, yBegin)
        if idx == false then
            local rIdx = self._restItemIdxList[rCnt]
            print(rIdx)
            local rItem = self.items[rIdx].item
            local rItemlist = self.items[rIdx].list
            self.yCacheBeginList[#self.yCacheBeginList + 1] = yBegin
            self.idxItemList[#self.idxItemList + 1] = rIdx
            rCnt = rCnt + 1
            rItem:setVisible(true)
            rItem:setPositionY(yBegin)
            for k = 3, 1, -1 do
                local curnode = rItemlist[k]
                local curinfo = self.allInfo[3*i-(3-k)] 
                if self.allInfo[3*i-(3-k)] then
                    curnode:setVisible(true)
                    if curnode.uin ~= curinfo.uin then
                        curnode.uin = curinfo.uin
                        self:updateItem(curnode, curinfo)
                    end
                else
                    curnode:setVisible(false)
                end
            end
        end
    end

    local tempRestItemIdxList = {}
    for i = rCnt, #self._restItemIdxList do
        tempRestItemIdxList[#tempRestItemIdxList + 1] = self._restItemIdxList[i]
    end
    self._restItemIdxList = tempRestItemIdxList
end



function BrPerson:delayRun(time,cb)
    self.listview:runAction(
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

function BrPerson:stopDelayRun()
    self.listview:stopAllActions()
end

return BrPerson