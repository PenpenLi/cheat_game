-- 动画基础类
-- 用于做所有播放动画的基类 如果无需添加新的特性 可以直接使用这个类

--可以直接使用Util:playAnimation 来直接播放动画 可以无需手动创建这个Gameanimation这个实例
--只是为了向前兼容所以改成这样了 后续建议直接使用Util:playAnimation来播放动画

local Gameanimation       = class("Gameanimation")
local winSize = cc.Director:getInstance():getOpenGLView():getFrameSize()

function Gameanimation:ctor(paras)
	if paras then
		self._parent_view = paras.view
	end


	if paras and paras.node then
		self.node  = paras.node
	end
end

--播放动画 可以重写 也可以直接增加 如果是与游戏无关的控制参数可以直接在这里配置
--此处最好只由参数来控制 即使是
function Gameanimation:play(paras)

	local armatureDataManager = ccs.ArmatureDataManager:getInstance()
	armatureDataManager:addArmatureFileInfo(paras.anim.res)
	local face = ccs.Armature:create(paras.anim.name)

	local node = nil
	if paras.node ~=nil then
		node = paras.node
	else
		node = self.node
	end

	if paras.create then
		node = cc.Layer:create()
		node:setLocalZOrder(paras.layerOrder)
		self._parent_view:addChild(node)
	end

	if paras.flipx then
		node:setScaleX(-1)
	end

	if tolua.isnull(node)  then return  end 

	node:addChild(face)

	--name
	if paras.name ~= nil then
		face:setName(paras.name)
	else
		--给个默认名字
		face:setName("ani_name")
	end

	--层级
	if paras.order ~= nil then
		face:setZOrder(paras.order)
	end

	--动画的序号
	local index = 0
	if paras.index ~= nil then
		index = paras.index
	elseif paras.anim and paras.anim.index ~= nil then
		index = paras.anim.index
	end

	face:getAnimation():playWithIndex(index)


	--位置
	if paras.position ~= nil then
		face:setPosition(paras.position.x,paras.position.y)
	else
		if not FULLSCREENADAPTIVE then
			face:setPosition(Display.cx/2,Display.cy/2)
		else
			local winSize = cc.Director:getInstance():getWinSize()
			face:setPosition(Display.cx/2 - (winSize.width/2-1920/2),winSize.height/2)
		end
	end

	if paras.posOffset then
		Util:setPosOffset(face, paras.posOffset)
	end


	--设置锚点
	if paras.anchor then
		face:setAnchorPoint(paras.anchor)
	end


	if paras.forever == nil then
		self:setRemoveCallback(face, paras)	
	end

	--设置播放速度
	if paras.speedScale then
		face:getAnimation():setSpeedScale(paras.speedScale)
	end

	--此处可以强制设置回调
	if paras.movementcb then
		face:getAnimation():setMovementEventCallFunc(paras.movementcb)
	end

	--设置指定骨骼隐藏 传入装有骨骼名字的table即可
	if paras.hideBoneList and type(paras.hideBoneList) == "table" then
		for i, v in ipairs(paras.hideBoneList) do
			local bone = face:getBone(v)
			if bone and bone.changeDisplayWithIndex then
				bone:changeDisplayWithIndex(-1,true)
			end
		end
	end

	--缩放
	if paras.scale ~= nil then
		if type(paras.scale) == "table" then
			face:setScaleX(paras.scale.x)
			face:setScaleY(paras.scale.y)
		else
			face:setScale(paras.scale)
		end
	end

	return face
end

--之所以拿出来，是因为下面这段写的有点乱 为保证原来的代码的稳定性 不轻易修改这段 如果有需要，继承的时候就可以重写这个方法即可
function Gameanimation:setRemoveCallback(face, paras)
	face:getAnimation():setMovementEventCallFunc(function ()
		local pnode = face:getParent()
		if paras.time then
			Scheduler:delayCall(paras.time,function()
				if tolua.isnull(face) == false then
					face:removeFromParent()
					if paras.callback then
						paras.callback()				
					end
				end
			end)
		else
			if paras.callback then
				paras.callback()				
			end
			face:removeFromParent()
		end

		if paras.create then
			if paras.time then
				Scheduler:delayCall(paras.time,function()
					if tolua.isnull(pnode) == false then
						pnode:removeFromParent()
					end
				end)
			else
				pnode:removeFromParent()
			end
		end
	end)
end


--同步加载动画资源
--如果采取异步加载可能会导致资源可能找不到的情况
function Gameanimation:preloadAnim(config, cb)
	local index = 1
	for k,v in pairs(config) do
		if v.res ~= nil then
			Scheduler:delayCall((index -1)*1/60, function ( ... )
				ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(v.res)
			end)
			index = index + 1
		end
	end
end

--卸载动画资源
function Gameanimation:unloadAnim(config)
	local index = 1
	for k,v in pairs(config) do
		Scheduler:delayCall((index -1)*1/60, function ( ... )
			if v and type(v) == "table" then
				ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(v.res)
			end
		end)
		index = index + 1
	end
end


return Gameanimation