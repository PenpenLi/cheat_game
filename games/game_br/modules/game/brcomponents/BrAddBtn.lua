local BrAddBtn = class("BrAddBtn",function(paras) 
    return paras.node
end)

local IButton = import("..components.IButton") 
local ChipCls = require("src.common.Chip")
BrAddBtn.TAG = "BrAddBtn"

function BrAddBtn:ctor(paras)
    self.defaultMatchesInfo = {}
    self:init()
end 

function BrAddBtn:init()
    self:setVisible(false)
end

local chipList = {1, 10, 50, 100, 500, 1000, 5000}

---根据场次选择按钮的图片
--matchesInfo 场次信息表
--刷新筹码是否可选
function BrAddBtn:updateBtnsStatus(gold)
    gold = gold or 0
    gold = Cache.packetInfo:getProMoney(gold)
    -- gold = gold / GameConstants.RATE
    gold = gold / Cache.brdesk.maxOdds

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

function BrAddBtn:initBtns()
    self._chipView = ccui.Helper:seekWidgetByName(self,"Panel_22")
    self._chipView:setContentSize(cc.size(1110, 200))
    self._chipListView = ccui.Helper:seekWidgetByName(self,"ListView_23")
    self.defaultMatchesInfo = Cache.brdesk.addChipList 
    -- self.defaultMatchesInfo = {}
    self.btnNum = #self.defaultMatchesInfo
    
    for i = 1, self._chipView:getChildrenCount() do
        local btn = ccui.Helper:seekWidgetByName(self._chipView,"add_btn_"..i)
        if i <= self.btnNum then
            btn:setVisible(true)
            self["btn"..i] = btn
        else
            if btn then
                btn:setVisible(false)
            end
        end
    end
    self:refreshBtns()
end

function BrAddBtn:refreshBtns()
    self:setVisible(true)

    local valueTbl = self.defaultMatchesInfo
    local colorIndex = BrConstants.ColorIndex
    Cache.brdesk.brAddChooice = 0

    for i = 1, self.btnNum do
        local node = self["btn"..i]

        --替换新的按钮筹码样式
        local colorPath = ChipCls.getColorPath(CHIPCOLOR[colorIndex[i]]) 
        local imgPath = colorPath .. "/chip.png"
        local fntPath  = colorPath .. "/number.fnt"
        local scale = Cache.packetInfo:isRealGold() and BrConstants.addBtnScale_RealGold or BrConstants.addBtnScale_Gold
        node:loadTextureNormal(imgPath)
        ChipCls.addNumberFnt(node, {fntPath = fntPath, number = valueTbl[i], scale = scale, offset = {y = 10}})

        node.value = valueTbl[i]
        addButtonEvent(node,function()
            if node.canTouch ~= true then return end 
            Cache.brdesk.brAddChooice = node.value
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

function BrAddBtn:setBtnO(btn,value)
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

function BrAddBtn:smartChoice()
    local gold = Cache.brdesk.br_user[Cache.user.uin].chips
    self:updateBtnsStatus(gold)
    Cache.brdesk.brAddChooice = Cache.brdesk.brAddChooice or 0
    -- gold = gold / GameConstants.RATE
    gold = Cache.packetInfo:getProMoney(gold)
    gold = gold / Cache.brdesk.maxOdds
    if Cache.brdesk.brAddChooice < gold and Cache.brdesk.brAddChooice ~= 0 then --当前选择的按钮 小于所持有的金币数
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

    Cache.brdesk.brAddChooice = v
    self:chooiceBtn(chooice, v)
end

function BrAddBtn:chooiceBtn(chooice,gold)
    for i = 1, self.btnNum do
        self["btn"..i].chooice = false
        self["btn"..i]:setScale(0.86)
        self["btn"..i]:getChildByName("selectAni"):setVisible(false)
    end
    local btn = self["btn"..chooice]
    Cache.brdesk.brAddChooice = 0
    if btn == nil then return end
    btn:setScale(1.0)

    Cache.brdesk.brAddChooice = gold
    btn:getChildByName("selectAni"):setVisible(true)
    btn.chooice = true
end

function BrAddBtn:delayRun(time,cb)
    local action = cc.Sequence:create(
        cc.DelayTime:create(time),
        cc.CallFunc:create(function (  )
            if cb then cb() end
        end)
    )
    self:runAction(action)
end

function BrAddBtn:test()
    self:initBtns()
    self.defaultMatchesInfo = {1,1,1,1,1}
    for i = 1, #self.defaultMatchesInfo do
        local btn = self["btn"..i]
        local x,y = btn:getPosition()
    end
end

return BrAddBtn