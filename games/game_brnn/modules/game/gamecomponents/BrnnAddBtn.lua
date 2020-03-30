local BrnnAddBtn = class("BrnnAddBtn",function(paras) 
    return paras.node
end)

local IButton = import("..components.IButton")
local ChipCls = require("src.common.Chip")

BrnnAddBtn.TAG = "BrnnAddBtn"

function BrnnAddBtn:ctor(paras)
    self:init()

end 

function BrnnAddBtn:init()
    self:setVisible(false)
end

local chipList = {1, 10, 50, 100, 500, 1000, 5000}

---根据场次选择按钮的图片
--matchesInfo 场次信息表
--刷新筹码是否可选
function BrnnAddBtn:updateBtnsStatus(gold)
    gold = gold or 0
    gold =  Cache.packetInfo:getProMoney(gold)
    gold = gold/Cache.BrniuniuDesk.maxOdds

    for k,v in pairs(self.defaultMatchesInfo) do
        local btn = self["btn"..k]
        btn.value = v
        if gold < v then 
            self:setBtnO(btn,155)
        else
            self:setBtnO(btn,255)
        end
    end
end

function BrnnAddBtn:initBtns()
    self._chipView = ccui.Helper:seekWidgetByName(self,"Panel_22")
    self._chipView:setContentSize(cc.size(1110, 200))
    self._chipListView = ccui.Helper:seekWidgetByName(self,"ListView_23")

    self.defaultMatchesInfo = Cache.BrniuniuDesk.addChipList
    self.btnNum = #self.defaultMatchesInfo
    
    for i = 1, self._chipView:getChildrenCount() do
        local btn = ccui.Helper:seekWidgetByName(self._chipView,"add_btn_"..i)
        if i <= self.btnNum then
            btn:setVisible(true)
            self["btn"..i] = btn
        else
            btn:setVisible(false)
        end
    end
    self:refreshBtns()
end

function BrnnAddBtn:refreshBtns()
    self:setVisible(true)
    local valueTbl = self.defaultMatchesInfo
    local colorIndex = BrnnConstants.ColorIndex
    Cache.BrniuniuDesk.brAddChooice = 0
    for i = 1, self.btnNum do
        local node = self["btn"..i]

        --替换新的按钮筹码样式
        local colorPath = ChipCls.getColorPath(CHIPCOLOR[colorIndex[i]]) 
        local imgPath = colorPath .. "/chip.png"
        local fntPath  = colorPath .. "/number.fnt"
        local scale = Cache.packetInfo:isRealGold() and BrnnConstants.addBtnScale_RealGold or BrnnConstants.addBtnScale_Gold
        node:loadTextureNormal(imgPath)
        ChipCls.addNumberFnt(node, {fntPath = fntPath, number = valueTbl[i], scale = scale, offset = {y = 10}})

        node.value = valueTbl[i]
        addButtonEvent(node,function()
            if node.canTouch ~= true then return end 
            Cache.BrniuniuDesk.brAddChooice = node.value
            self:chooiceBtn(i,node.value)
        end)
        node.canTouch = true

        --通过在按钮上面放置一个放大的透明的自己， 达到可点击区域大一点的效果
        local tmpNode = node:clone()
        local size = node:getContentSize()
        tmpNode:setPosition(cc.p(size.width/2,size.height/2))
        tmpNode:setScale(1.5)
        tmpNode:setOpacity(0)
        node:addChild(tmpNode)

        --增加选中按钮特效
        Util:addChipSelectAni(node)
    end
    --将当前的按钮状态重置即可
    self:chooiceBtn(0,0)
end

function BrnnAddBtn:setBtnO(btn,value)
    local bTouch = value == 255
    if bTouch == btn.canTouch then
        return        
    end
    if bTouch then
        btn:setColor(cc.c3b(255,255,255))
        btn:getChildByName("number"):setColor(cc.c3b(255,255,255))
    else
        btn:setColor(cc.c3b(100,100,100))
        btn:getChildByName("number"):setColor(cc.c3b(100,100,100))
    end
    btn.canTouch = bTouch
    btn:setTouchEnabled(bTouch)
end

function BrnnAddBtn:smartChoice()
    local brUser = Cache.BrniuniuDesk.br_user
    local uin = Cache.user.uin
    local gold
    if brUser and brUser[uin] and brUser[uin].chips then
        gold = brUser[uin].chips
    end
    if gold == nil then
        return
    end
    -- local gold = Cache.BrniuniuDesk.br_user[Cache.user.uin].chips
    self:updateBtnsStatus(gold)
    Cache.BrniuniuDesk.brAddChooice = Cache.BrniuniuDesk.brAddChooice or 0
    gold =  Cache.packetInfo:getProMoney(gold)
    gold = gold / Cache.BrniuniuDesk.maxOdds
    if Cache.BrniuniuDesk.brAddChooice < gold and Cache.BrniuniuDesk.brAddChooice ~= 0 then --当前选择的按钮 小于所持有的金币数
        return
    end
    --优先选择当前最大的按钮
    local v = 0
    local chooice = 0
    -- for i = 1 , self.btnNum do
    --     local btn = self["btn"..i]
    --     if gold >= btn.value then
    --         if v < btn.value then
    --             chooice = i
    --             v = btn.value
    --         end
    --     end
    -- end

    if gold >= self["btn1"].value then
        chooice = 1
        v = self["btn1"].value
    end

    Cache.BrniuniuDesk.brAddChooice = v
    self:chooiceBtn(chooice, v)
end

function BrnnAddBtn:chooiceBtn(chooice,gold)
    for i = 1, self.btnNum do
        self["btn"..i].chooice = false
        self["btn"..i]:setScale(0.86)
        self["btn"..i]:getChildByName("selectAni"):setVisible(false)
    end
    local btn = self["btn"..chooice]
    Cache.BrniuniuDesk.brAddChooice = 0
    if btn == nil then return end
    btn:setScale(1.0)

    Cache.BrniuniuDesk.brAddChooice = gold
    btn:getChildByName("selectAni"):setVisible(true)
    btn.chooice = true
end

function BrnnAddBtn:delayRun(time,cb)
    local action = cc.Sequence:create(
        cc.DelayTime:create(time),
        cc.CallFunc:create(function (  )
            if cb then cb() end
        end)
    )
    self:runAction(action)
end

function BrnnAddBtn:test()
    self:initBtns()
    self.defaultMatchesInfo = {1,1,1,1,1}
    for i = 1, #self.defaultMatchesInfo do
        local btn = self["btn"..i]
        local x,y = btn:getPosition()
    end
end

return BrnnAddBtn