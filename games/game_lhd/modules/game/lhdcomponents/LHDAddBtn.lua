--筹码按钮
local LHDAddBtn = class("LHDAddBtn",function(paras) 
    return paras.node end)

local IButton = import("..components.IButton") 
local ChipCls = require("src.common.Chip")
LHDAddBtn.TAG = "LHDAddBtn"

function LHDAddBtn:ctor(paras)
    self:init()
end 

function LHDAddBtn:init()
    self.deskCache = Cache.DeskAssemble:getCache(LHD_MATCHE_TYPE)
    self:initBtns()
end

function LHDAddBtn:initBtns()
    --下注筹码改为后台配置
    self._chipView = ccui.Helper:seekWidgetByName(self,"Panel_76")
    self._chipView:setContentSize(cc.size(1000, 200))
    self._chipListView = ccui.Helper:seekWidgetByName(self,"ListView_43")
    dump(self._chipListView:getPosition3D())
    local clistViewSize = self._chipListView:getContentSize()
    -- performWithDelay(self, function ( ... )
    --     dump(self._chipListView:getPosition3D())
    -- end, 3)

    -- Util:setPosOffset(self._chipListView, {x =clistViewSize.width/2, y = clistViewSize.height/2})
    self._chipListView:setPosition3D(cc.p(75,0))
    self._chipList = Cache.lhdinfo.chip_list 

    --暂时设置为5个按钮 颜色排序依次如下
    local colorIndex = LHD_Games_Constant.ColorIndex
    for i = 1, #self._chipList do
        local btn = IButton.new({node = ccui.Helper:seekWidgetByName(self,"add_btn_"..i)})
        btn:setCallback(function() 
            if btn.canTouch ~= true then return end
            self:chooiceBtn(i,btn.value)
            logd("br现则  value-->"..self["btn"..i].value,self.TAG)

            -- Util:lookUpNode(self:getParent(), function (str, nodename, v)
            --     print(str, nodename, tolua.type(v))
            -- end)
            print("bvis >>>>", self:isVisible())
            local margin = self:getLayoutParameter():getMargin()
            dump(margin)
            print("localZOrder >>>>>>>>", self:getLocalZOrder())
        end)
        local colorPath = ChipCls.getColorPath(CHIPCOLOR[colorIndex[i]]) 
        local imgPath = colorPath .. "/chip.png"
        btn:loadTextureNormal(imgPath)
        btn:setScale(0.8)
        local fntPath  = colorPath .. "/number.fnt"
        local scale = Cache.packetInfo:isRealGold() and LHD_Games_Constant.addBtnScale_RealGold or LHD_Games_Constant.addBtnScale_Gold
        ChipCls.addNumberFnt(btn, {fntPath = fntPath,number = Cache.packetInfo:getProMoney(self._chipList[i]), scale = scale, offset = {y = 10}})
        btn.canTouch = true
        self["btn"..i] = btn


        --通过在按钮上面放置一个放大的透明的自己， 达到可点击区域大一点的效果
        local node = ccui.Helper:seekWidgetByName(self,"add_btn_"..i)
        local tmpNode = node:clone()
        local size = node:getContentSize()
        tmpNode:setPosition(cc.p(size.width/2,size.height/2))
        tmpNode:setScale(1.5)
        tmpNode:setOpacity(0)
        tmpNode:setTouchEnabled(true)
        addButtonEvent(tmpNode,function ()
            -- print("tempNodeclicke", i, btn.value)
            if btn.canTouch ~= true then return end
            self:chooiceBtn(i,btn.value)
            logd("br现则  value-->"..self["btn"..i].value,self.TAG)

        end)
        btn:addChild(tmpNode)
        
        --增加选中按钮特效
        Util:addChipSelectAni(btn)

    end
    for i = 1, self._chipView:getChildrenCount() do
        local btn = ccui.Helper:seekWidgetByName(self,"add_btn_"..i)
        if i <= #self._chipList then
            btn:setVisible(true)
        else
            btn:setVisible(false)
        end
    end
    self.deskCache._add_chooice = 0
end

--更新当前按钮的状态 与 显示
function LHDAddBtn:updateBtnsStatus(gold)
    logd("百人场次加钱"..gold,self.TAG)
    if gold == nil then return end

    for k,v in pairs(self._chipList) do
        local btn = self["btn"..k]
        btn.value = v
        -- btn:getChildByName("number"):setString(v / GameConstants.RATE)
        if gold < v then
            self:setBtnO(btn, 155)
        else
            self:setBtnO(btn, 255)
        end
    end
end

function LHDAddBtn:setBtnO(btn,value)
    local bTouch = value == 255
    btn.colorvalue = value
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

--进入房间后根据筹码初始化下注按钮状态
function LHDAddBtn:initBtnsStatus()
end

--如果已经选定了筹码 且这个筹码大于当前自己的筹码值 就重新选定一个当前能够选定的最大的那个
--如果还没有选定则选定一个最大的筹码
function LHDAddBtn:smartChoice()
    self.deskCache._add_chooice = self.deskCache._add_chooice or 0
    local user_data = self.deskCache:getUserByUin(Cache.user.uin)
    local gold = user_data.chips
    if self.deskCache._add_chooice ~= 0 and gold > self.deskCache._add_chooice then
        return
    end

    local v = 0
    local chooice = 0
    local btnNum = #self._chipList
    for i = 1 , btnNum do
        local btn = self["btn"..i]
        if gold >= btn.value then
            -- if v < btn.value then
            --     chooice = i
            --     v = btn.value
            -- end
        else
            btn.canTouch = false
        end
    end
    --默认选择最小
    if gold > self.btn1.value then
        v = self.btn1.value
        chooice = 1
    end

    self:chooiceBtn(chooice, v)
end

function LHDAddBtn:chooiceBtn(iChooice,gold)
    gold = gold or 100
    for i = 1, #self._chipList do
        self["btn"..i].chooice = false
        if iChooice ~= i then
            --这个要看之前是不是就不能点击，不能的还是不能
            local bTouch = self["btn"..i].colorvalue == 255
            self["btn"..i]:setTouchEnabled(bTouch)
            self["btn"..i].canTouch = bTouch
            self["btn"..i]:setScale(0.86)
            self["btn"..i]:getChildByName("selectAni"):setVisible(false)
        end
    end

    if gold < 100 then
        self.deskCache._add_chooice = gold
        -- if self.round then
        --     self.round:removeFromParent(true)
        --     self.round = nil
        -- end
        for i = 1, 5 do
            self["btn"..i]:getChildByName("selectAni"):setVisible(false)
        end
        return 
    end
    local btn = self["btn"..iChooice]
    self.deskCache._add_chooice = gold

    if btn == nil then return end
    btn:setScale(1.0)
    btn.canTouch = false
    btn:setTouchEnabled(false)
    -- if self.round == nil then
    --     self.round = cc.Sprite:create(LHD_Games_res.br_add_btn_round)
    --     self.round:setAnchorPoint(0.5,0.5)
    --     self.round:runAction(cc.RepeatForever:create(
    --         cc.Sequence:create(
    --             cc.EaseSineIn:create(cc.ScaleTo:create(2,0.9)),
    --             cc.EaseSineOut:create(cc.ScaleTo:create(2,0.99))
    --         )
    --     ))
    --     self._chipView:addChild(self.round,0)
    -- end

    -- local x,y = btn:getPosition()
    -- self.round:setPosition(x,y)
    btn:getChildByName("selectAni"):setVisible(true)
    btn.chooice = true

end

function LHDAddBtn:test(iChooice,gold)
    local chipList = {100,100,100,100,100}
    Cache.lhdinfo.chip_list = chipList

    self:initBtns()
    self:setVisible(true)
    self._chipView:setVisible(true)
    self._chipListView:setVisible(true)
    for i = 1, #chipList do
        local btn = self["btn"..i]
        btn:setVisible(true)
        local x,y = btn:getPosition()
    end
end

return LHDAddBtn