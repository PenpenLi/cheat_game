--[[
-- User类的动画
--]]
local M = {}
local m_instance
local function new( o )
	o = o or {}
	setmetatable(o, {__index = M})
	return o
end
local function getInstance( ... )
	if not m_instance then
		m_instance = new()
	end
	return m_instance
end
M.winWordColor = cc.c3b(255,202,14)
-- 积分动画
function M:getJiFenAction(label, args)
    if not label then return end

    local offsetY = args.offsetY
    label:setScale(0)
    label:setOpacity(50)
    local action1 = cc.Sequence:create(cc.DelayTime:create(0.4)
    	, cc.FadeTo:create(1.2,255))
   	local action2 = cc.Sequence:create(cc.EaseSineOut:create(cc.ScaleTo:create(0.3,1))
   		, cc.EaseSineInOut:create(cc.MoveBy:create(1.5,cc.p(0, offsetY)))
   		, cc.DelayTime:create(0.4)
   		, cc.Spawn:create(cc.ScaleTo:create(1,1.1),cc.FadeTo:create(1,0))
   		, cc.CallFunc:create(function(sender) 
            sender:removeFromParent()
        end))
    return label:runAction(cc.Spawn:create(action1, action2))
end
-- win文本动画
function M:getWinWordAction(args)
    local pos = args.pos
    local l = args.label
    
    l:setAnchorPoint(0.5,0)
    l:setVisible(false)
    l:runAction(cc.Sequence:create(cc.DelayTime:create(0.8)
    	, cc.CallFunc:create(function(sender) 
    			sender:setVisible(true)
    		end)
    	, cc.MoveBy:create(0.5, pos)
    	, cc.DelayTime:create(1.5)
        , cc.CallFunc:create(function(sender) 
        		sender:removeFromParent(true) 
                if args.cb then args.cb() end
        	end)))
    return 0.8 + 0.5
end

-- 计算玩家位置是在哪个方位
-- kind =1经典场 2百人场
-- total =5 5人场 =9 9人场
-- return 0 左下角 1左侧 2左上角 3上边 4右上角 5右边 6右下角 7下边
M.DIRECTION_LEFT_BOTTOM = 0
M.DIRECTION_LEFT = 1
M.DIRECTION_LEFT_TOP = 2
M.DIRECTION_TOP = 3
M.DIRECTION_RIGHT_TOP = 4
M.DIRECTION_RIGHT = 5
M.DIRECTION_RIGHT_BOTTOM = 6
M.DIRECTION_BOTTOM = 7
function M:getDirectionByIndex( kind, index, total )
    if 1 == kind then -- 经典场
        if 1 == index then return 7 end
        if 2 == index then return 0 end
        if 5 == total then -- 5人桌
            if 3 == index then return 1 end
            if 4 == index then return 5 end
            if 5 == index then return 6 end
        elseif 9 == total then -- 9人桌
            if 3 == index or 4 == index then return 1 end
            if 5 == index then return 2 end
            if 6 == index then return 4 end
            if 7 == index or 8 == index then return 5 end
            if 9 == index then return 6 end
        end
    elseif 2 == kind then -- 百人场
        return 0
    end
    return 0
end

-- win的收缩动作
function M:getVictoryPopAction( callBack )
    local popAction = cc.Sequence:create(
        cc.Spawn:create(
            cc.EaseSineIn:create(cc.ScaleTo:create(0.4, 1)),
            cc.FadeIn:create(0.4))
        , cc.Spawn:create(
            cc.EaseSineOut:create(cc.ScaleTo:create(0.4, 0.8)),
            cc.FadeOut:create(0.4))
        , cc.Spawn:create(
            cc.EaseSineIn:create(cc.ScaleTo:create(0.4, 1)),
            cc.FadeIn:create(0.4))
        , cc.DelayTime:create(0.4)
        , cc.CallFunc:create(function( sender )
            if callBack then callBack(sender) end
        end))
    
    return popAction
end

-- 开牌、倒计时相关动画
function M:getTimeCountAndCardBgAnimation(index)
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(LHD_Games_res.result_animation)
    local armature = ccs.Armature:create("NewAnimation0410lhd01")
    local function animationEvent(armatureBack,movementType,movementID)
        if movementType == ccs.MovementEventType.complete then
            armature:removeFromParent(true)
            -- ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(LHD_Games_res.result_animation)
        end
    end
    armature:getAnimation():setMovementEventCallFunc(animationEvent)
    armature:getAnimation():playWithIndex(index)
    return armature
end

-- pk
function M:getPKAnimationData()
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(LHD_Games_res.result_pk_animation)
    local armature = ccs.Armature:create("NewAnimation20190429juedou")
    local function animationEvent(armatureBack,movementType,movementID)
        if movementType == ccs.MovementEventType.complete then
            armature:removeFromParent(true)
            -- ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(LHD_Games_res.result_pk_animation)
        end
    end
    armature:getAnimation():setMovementEventCallFunc(animationEvent)
    armature:getAnimation():playWithIndex(0)
    return armature
end

--奖池输赢、玩家输赢动画
function M:getResultAnimationData(index)
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(LHD_Games_res.result_chipspool_animation)
    local armature = ccs.Armature:create("NewAnimation20190429win")
    local function animationEvent(armatureBack,movementType,movementID)
        if movementType == ccs.MovementEventType.complete then
            armature:removeFromParent(true)
            -- ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(LHD_Games_res.result_chipspool_animation)
        end
    end
    armature:getAnimation():setMovementEventCallFunc(animationEvent)
    armature:getAnimation():playWithIndex(index)
    return armature
end

function M:getResultSelfAnimationData()
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(LHD_Games_res.result_selfwin_animation)
    local armature = ccs.Armature:create("NewAnimation20190509zjiwin")
    local function animationEvent(armatureBack,movementType,movementID)
        if movementType == ccs.MovementEventType.loopComplete then
            armature:removeFromParent(true)
            -- ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(LHD_Games_res.result_chipspool_animation)
        end
    end
    armature:getAnimation():setMovementEventCallFunc(animationEvent)
    armature:getAnimation():playWithIndex(0)
    return armature
end

function M:removeAllAnimationData( ... )
    -- ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(LHD_Games_res.result_chipspool_animation)
    -- ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(LHD_Games_res.result_pk_animation)
    -- ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(LHD_Games_res.result_animation)
    -- ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(LHD_Games_res.vip_ani_standup_json)
end

local UserDisplay = getInstance()
return UserDisplay