local HongBaoView = class("HongBaoView", CommonWidget.PopupWindow)
HongBaoView.TAG = "HongBaoView"

local ViewConstant = {
    Rule = 1,
    Prize = 2,
    Ani = 3
}

local aniConfig = {
	FANXIAN = {
		name = "NewAnimationbaifenbaifanxian1",
		res = GameRes.RtMoneyAni2,
	}
}

local numMinCanGet = 0.01

function HongBaoView:ctor(parameters)
    self.root = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.hongbaoJson)
    self:init(parameters)
    self.super.ctor(self, {id=PopupManager.POPUPWINDOW.hongbaoView, child=self.root})
end

function HongBaoView:init( parameters )
	local defaultHandler = handler(self, self.onButtonEvent)
    local uiTbl = {

        {name = "ruleView",           path = "ruleView",                  handler = nil},
        {name = "ruleCloseBtn",        path = "ruleView/bg/r_closeBtn", handler = defaultHandler},
        {name = "ruleScroll",        path = "ruleView/bg/ruleScroll", handler = nil},
        {name = "ruleImg",        path = "ruleView/bg/ruleScroll/ruleImg", handler = nil},

        {name = "prizeView",           path = "prizeView",                  handler = nil},
        {name = "okBtn",        path = "prizeView/bg/okBtn", handler = defaultHandler},
        {name = "numberTxt",        path = "prizeView/bg/number", handler = nil},


        {name = "aniView",           path = "aniView",                  handler = nil},
        {name = "aniCloseBtn",        path = "aniView/closeBtn", handler = defaultHandler},
        {name = "openBtn",        path = "aniView/openBtn", handler = defaultHandler},
        {name = "txtImg",        path = "aniView/fImg", handler = nil},
        {name = "ruleBtn",        path = "aniView/ruleBtn", handler = defaultHandler}
    }

    Util:bindUI(self, self.root, uiTbl)
    self:initRuleView()
    local viewTbl = {
        [ViewConstant.Rule] = self.ruleView,
        [ViewConstant.Prize] = self.prizeView,
        [ViewConstant.Ani] = self.aniView
    }
    self._data = parameters.data
    self.viewTbl = viewTbl
    self:showView(ViewConstant.Ani)
end

function HongBaoView:showView(viewNo)
    for k, v in pairs(self.viewTbl) do
        v:setVisible(false)
    end
    
    self.viewTbl[viewNo]:setVisible(true)
    self:refreshView(viewNo)
end

function HongBaoView:refreshInfoTxt()
    local fci = self._data
    local unit = Cache.packetInfo:getShowUnit()
    self.txtImg:getChildByName("totalFlowTxt"):setString(Util:getFormatString(fci.bet_gold) .. unit)
    self.txtImg:getChildByName("yetGetMoneyTxt"):setString(Util:getFormatString(fci.already_get_reward) .. "/" .. Util:getFormatString(fci.total_not_get) .. unit)
end

function HongBaoView:refreshView(viewNo)
    if viewNo == ViewConstant.Rule then
    elseif viewNo == ViewConstant.Prize then
        self:refreshPrizeView()
    elseif viewNo == ViewConstant.Ani then
        self:refreshInfoTxt()
        self:refreshAniView()
    end
end

function HongBaoView:initRuleView( ... )
	local contentSize = self.ruleImg:getContentSize()
	local innerSize = self.ruleScroll:getInnerContainerSize()
    self.ruleScroll:setInnerContainerSize(cc.size(innerSize.width, contentSize.height+ 10))
    local _x = (innerSize.width - contentSize.width)
    self.ruleImg:setPosition(_x, 0)
	Util:setPosOffset(self.ruleScroll, {x = -60})
end

function HongBaoView:onButtonEvent(sender)
	-- print("sender >>>", sender.name)
    if sender.name == "ruleCloseBtn" then
        self:showView(ViewConstant.Ani)
    elseif sender.name == "aniCloseBtn" then
        self:close()
    elseif sender.name == "ruleBtn" then
        self:showView(ViewConstant.Rule)
    elseif sender.name == "openBtn" then
        -- print("openBtn >>>>>>>>>>>>>>")
        self:showView(ViewConstant.Prize)
    elseif sender.name == "okBtn" then
        -- print("okBtn >>>>>>>>>>>>>>>>>>>")
        self:close()
    end
end

function HongBaoView:refreshAniView()
    self:showAni()
end

function HongBaoView:refrehsOpenButton(aniBtn)
    if aniBtn then
        self.openAniBtn = aniBtn
    end
    if self._data.is_recharge == 1 then
        if self._data.wait_get_reward < numMinCanGet then
            self.openAniBtn:initWithFile(GameRes.hongbao_open_disable)
        else
            self.openAniBtn:initWithFile(GameRes.hongbao_open)
        end
    elseif self._data.is_recharge == 0 then
        self.openAniBtn:initWithFile(GameRes.hongbao_go)
    end
end

function HongBaoView:showAni()
    if self.aniView:getChildByName("ani") then
        return
    end

    local bDontGet = true
    local _showList = {
        self.aniCloseBtn,
        self.txtImg,
        self.ruleBtn
    }
    for i, v in ipairs(_showList) do
        v:setVisible(false)
    end

    self.openBtn:setVisible(false)
    local face = Util:addAnimationToSender(self.aniView, {anim = aniConfig.FANXIAN, name = "ani", node = self.aniView, forever = true})
    local ani = face:getAnimation()
    ani:setMovementEventCallFunc(function ( ... )
        ani:gotoAndPlay(35)
    end)

    ani:setFrameEventCallFunc(function (bone,evt,originFrameIndex,currentFrameIndex)
        if evt == "anniuShow" then
            local boneData = bone:getBoneData()
            local renderNode = bone:getDisplayRenderNode()
            if renderNode then
                if renderNode.initWithFile then
                    self:refrehsOpenButton(renderNode)
                end
            end
        end
    end)

    face:setName("ani")

    performWithDelay(self, function ( ... )
        for i, v in ipairs(_showList) do
            v:setVisible(true)
        end
        self.openBtn:setVisible(true)
        self.openBtn:setOpacity(0)
        self.openBtn:setEnabled(true)
        self.openBtn:setTouchEnabled(true)
        addButtonEvent(self.openBtn, function ( ... )
            dump(self._data)
            if self._data.is_recharge == 1 then
                if self._data.wait_get_reward < numMinCanGet then
                    return
                else
                    Cache.hongbaoInfo:getFirstRecharge(function (data)
                        local is_recharge = self._data.is_recharge
                        self._data = data
                        self._data.is_recharge = is_recharge
                        self:refrehsOpenButton()
                        self:refreshInfoTxt()
                        self.numberTxt:setString(Util:getFormatString(data.get_reward_this_time))
                        self:showView(ViewConstant.Prize)
                        if data.first_recharge_flag  == 0 then
                            Cache.user.first_recharge_flag = data.first_recharge_flag
                            qf.event:dispatchEvent(ET.REFRESH_HONGBAO_BTN)
                        end
                    end)
                end
            elseif self._data.is_recharge == 0 then
                self:close()
                qf.event:dispatchEvent(ET.SHOP)
            end
        end)
    end, 25/60)

    if bDontGet then
        self.openBtn:loadTextureNormal(GameRes.hongbao_open_disable)
        self.openBtn:setEnabled(false)
    end

    -- local goldBg=cc.Sprite:create(GameRes.hongbao_open_disable)
    -- goldBg:setScale(0.8)
    -- face:getBone("fanxinadizuo"):addDisplay(goldBg, 0)
    -- face:getBone("fanxiananniu1"):addDisplay(goldBg, 0)
    -- performWithDelay(self, function( ... )
    --     print("]]]]]]]]]]]", tolua.type(goldBg:getParent()))
    -- end, 0.2)

    -- face:getBone("fanxiananniu1"):setIgnoreMovementBoneData(true)

    -- changeDisplayWithIndex(-1,true)
    --由于动画中没有添加对应的帧事件
    --只能通过延时来处理
    -- local id 
    -- id = schedule(self.root, function ()
    --     local ok = self:replaceBtnBone(face, GameRes.hongbao_open_disable)
    --     if ok then
    --         self.root:stopActionByTag(id:getTag())
    --     end
    -- end, 0.03)
    -- id:setTag(1001)
end

function HongBaoView:refreshPrizeView( ... )
    local bg = self.prizeView:getChildByName("bg")
    local tip1 = bg:getChildByName("tip1")
    local tip2 = bg:getChildByName("tip2")
    local csize = self.numberTxt:getContentSize()
    local npos = self.numberTxt:getPosition3D()
    local x1 = npos.x - csize.width/2 - 5
    local x2 = npos.x + csize.width/2 + 5
    tip1:setPositionX(x1)
    tip2:setPositionX(x2)
end

function HongBaoView:replaceBtnBone(face, img)
    local bone = face:getBone("fanxiananniu1")
    if bone then
        local boneData = bone:getBoneData()
        local renderNode = bone:getDisplayRenderNode()
        if renderNode then
            renderNode:initWithFile(img)
            return true
        end
    end
end

function HongBaoView:testBoneData(face)
    local bone = face:getBone("fanxiananniu1")
    print("bone >>>>", tolua.type(bone))
    if bone then
        local boneData = bone:getBoneData()
        -- Util:getCObejctFunction(boneData)
        local dData = boneData:getDisplayData(0)
        -- Util:getCObejctFunction(dData)

        local renderNode = bone:getDisplayRenderNode()
        print("bone", renderNode)
        print("type ", bone:getDisplayRenderNodeType())
        -- changeDisplayToTexture
        if renderNode then
            print("renderNode >>>>>>>", renderNode)
            renderNode:initWithFile(GameRes.hongbao_open_disable)
        end
    end
end

return HongBaoView