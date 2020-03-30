--[[
    服务器发货后，客户端收到钻石，弹出的弹窗
    
    TODO: title_ready 帧事件的时间点；beam素材；diamond number骨骼  
]]
local DiamondPopup = class("DiamondPopup", function(paras)
    return cc.Layer:create()
end)

DiamondPopup.TEXT_ZORDER = 100
DiamondPopup.BLOOM_ZORDER = 100
DiamondPopup.PLUS_GAP = 10

---以下常量与具体的骨骼动画ExportJson相关---
DiamondPopup.ARMATURE_ANIMATION_NAME = "NewAnimation123"    --Animation名字
DiamondPopup.ARMATURE_DIAMOND_BONE = "diamond_num"          --钻石数量的骨骼名字
DiamondPopup.ARMATURE_DIAMONDBG_BONE = "Layer7"          --钻石数量的骨骼名字
DiamondPopup.ARMATURE_TITLE_READY_EVENT = "title_ready"     --帧事件，标题已经弹出
DiamondPopup.ARMATURE_POP_FINISH_EVENT = "pop_finish"       --帧事件，弹框已经展开
DiamondPopup.BLOOM_OFFSET_X = 2                             --流光控件相对于中心点的x偏移，与title位置相关
DiamondPopup.BLOOM_OFFSET_Y = 236                           --流光控件相对于中心点的y偏移，与title位置相关

function DiamondPopup:ctor(paras)
    self.winSize = cc.Director:getInstance():getWinSize()
    self:init(paras)
end

--弹窗初始化
function DiamondPopup:init(paras)
    self:setContentSize(self.winSize)
    self.diamond_num = paras.diamond    --钻石数量
    self.diamond_free = paras.free or 0 --免费赠送的钻石数量
    self.isBygGold = paras.isBygGold --是否是买的金币
    if self.diamond_num ~= nil and self.diamond_num > 0 then
        --先添加流光控件但不播放,由帧事件来触发播放
        self:addTitleBloom()
    end
end

--展示弹窗
function DiamondPopup:show()
    if self.diamond_num ~= nil and self.diamond_num > 0 then
        --钻石数量 >0, 播放弹窗骨骼动画
        self:runAction(cc.Sequence:create(
            cc.DelayTime:create(0.01),
            cc.CallFunc:create(function()
                local armature = self:getArmature()
                armature:setPosition(self.winSize.width/2, self.winSize.height/2)
                self:addChild(armature, 0)
            end)))
    else
        --钻石数量 <=0, 没必要弹窗,直接移除
        self:removeFromParent(true)
    end
end

--获取骨骼动画
function DiamondPopup:getArmature()

    --创建骨骼动画
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(GameRes.global_got_diamond_ani_json)
    local armature = ccs.Armature:create(self.ARMATURE_ANIMATION_NAME)
    armature:getAnimation():setFrameEventCallFunc(handler(self, self.frameEventHander))
    armature:getAnimation():setMovementEventCallFunc(handler(self, self.movementEventHandler))
    armature:getAnimation():playWithIndex(0)

    --获取实际钻石数量节点，调节显示大小及在bone上面的位置
    local diamond_num = self:getDiammondNumber()
    diamond_num:setVisible(false)
    diamond_num:setAnchorPoint(0, 0.5)
    diamond_num:setOpacity(255)
    diamond_num:setScale(2.5)
    diamond_num:setPositionY(270)
    diamond_num:setVisible(false)

    --骨骼蒙皮
    local bone = armature:getBone(self.ARMATURE_DIAMOND_BONE)
    bone:addDisplay(diamond_num, 0)
    bone:changeDisplayWithIndex(0, true)
    bone:setIgnoreMovementBoneData(true)
    bone:setLocalZOrder(self.TEXT_ZORDER)

    if self.isBygGold then
        local bone = armature:getBone(self.ARMATURE_DIAMONDBG_BONE)
        local goldBg=cc.Sprite:create(GameRes.global_got_diamond_ani_buygoldbg)
        goldBg:setScale(0.8)
        bone:addDisplay(goldBg, 0)
    end
    return armature
end

--骨骼动画帧事件
function DiamondPopup:frameEventHander(bone,evt,originFrameIndex,currentFrameIndex)
    if evt == self.ARMATURE_TITLE_READY_EVENT then    --帧事件: title不再有动作
        self:playTitleBloom()       --开始播放流光
    elseif evt == self.ARMATURE_POP_FINISH_EVENT then
        self:addTouchCloseEvent()   --点击以后关闭
    end
end

--骨骼动画动作事件
function DiamondPopup:movementEventHandler(armatureBack, movementType, movementID)
    if movementType == ccs.MovementEventType.complete then
        self:stopTitleBloom()       --停止播放流光
    end
end

--点击关闭弹窗事件
function DiamondPopup:addTouchCloseEvent()
    local eventDispatcher = self:getEventDispatcher()
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(function(touch,event) return true end,cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(function(touch,event) 
            --所有动作完成，移除弹窗
            self:removeFromParent(true)
            --移除骨骼动画缓存
            ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(GameRes.global_got_diamond_ani_json)
        end,cc.Handler.EVENT_TOUCH_ENDED)
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

--添加标题流光效果
function DiamondPopup:addTitleBloom()
    self.bloom = CommonWidget.BloomNode.new({
        image=GameRes.global_got_diamond_title_shape,
        beam=GameRes.global_got_diamond_title_beam,
        create=false,
        move_back=false,
        move_forever=true,
        move_time=1.5
    })
    self.bloom:setPosition(self.winSize.width/2 + self.BLOOM_OFFSET_X, self.winSize.height/2 + self.BLOOM_OFFSET_Y)
    self:addChild(self.bloom, self.BLOOM_ZORDER)
end

--播放标题流光效果
function DiamondPopup:playTitleBloom()
    if self.bloom then
        self.bloom:playAnimation()
    end
end

--停止播放标题流光效果
function DiamondPopup:stopTitleBloom()
    if self.bloom then
        self.bloom:stopAnimation()
        self.bloom:removeFromParent(true)
    end
end

--获取钻石数量node
function DiamondPopup:getDiammondNumber()
    --钻石数量
    local num 
    local numAtlas = GameRes.global_diamond_num_atlas
    local numAtlasBg = GameRes.global_diamond_text
    if self.isBygGold then
        numAtlas = GameRes.global_gold_num_atlas
        numAtlasBg = GameRes.global_gold_text
    end
    num= cc.LabelAtlas:_create(self.diamond_num, numAtlas, 23, 37, string.byte('.'))
    local num_size = num:getContentSize()
    num:setAnchorPoint(0, 0.5)
    
    --免费赠送的钻石
    local plus_symbol = nil
    local plus_symbol_size = cc.size(0, 0)
    local free_num = nil
    local free_num_size = cc.size(0, 0)
    if self.diamond_free > 0 then
        plus_symbol = cc.Sprite:create(GameRes.global_got_diamond_plus_symbol)
        plus_symbol_size = plus_symbol:getContentSize()
        plus_symbol:setAnchorPoint(0, 0.5)
        free_num = cc.LabelAtlas:_create(self.diamond_free, numAtlas, 23, 37, string.byte('.'))
        free_num_size = free_num:getContentSize()
        free_num:setAnchorPoint(0, 0.5)
    end

    --“钻石”文字
    local text = cc.Sprite:create(numAtlasBg)
    local text_size = text:getContentSize()
    text:setAnchorPoint(0, 0.5)
    
    --控件宽高
    local node = cc.Node:create()
    local width = num_size.width + plus_symbol_size.width + free_num_size.width + text_size.width
    local height = text_size.height > num_size.height and text_size.height or num_size.height
    height = height > plus_symbol_size.height and height or plus_symbol_size.height
    node:setContentSize(width, height)
    
    --添加控件
    local x = -width/2
    node:addChild(num)
    num:setPosition(x, height / 2)
    x = x + num_size.width
    if self.diamond_free > 0 then
        node:addChild(plus_symbol)
        plus_symbol:setPosition(x, height / 2)
        x = x + plus_symbol_size.width
        node:addChild(free_num)
        free_num:setPosition(x, height / 2)
        x = x + free_num_size.width
    end
    node:addChild(text)
    text:setPosition(x, height / 2)

    return node
end

return DiamondPopup