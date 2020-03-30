local Useranimation      =  class("Useranimation")
Useranimation.TAG        = "Useranimation"
Useranimation.Chips_width      = 325   --chips长方形长的一半
Useranimation.Chips_height     = 100	 --chips长方形宽的一半

--跟注 
function Useranimation:xiaZhu( model )
	-- body
	local chip = model.chip
	local base = model.base


	local sprites = {}
	sprites       = self:getChipsimg(sprites,chip,base)
	
	local start_x = 100
	local end_x   = 550

	local start_y = 0
	local end_y   = 190

	local radius_x = 0
	local radius_y = 0
	if not Cache.kandesk.round_count then
		return
	end
	if Cache.kandesk.round_count <=2 then
 		radius_x = Useranimation.Chips_width / (3-Cache.kandesk.round_count)
 		radius_y = Useranimation.Chips_height / (3-Cache.kandesk.round_count)

 		start_x = Useranimation.Chips_width-radius_x
 		end_x   = Useranimation.Chips_width+radius_x

 		start_y = Useranimation.Chips_height -radius_y
 		end_y   = Useranimation.Chips_height+radius_y
	end

	for k,v in pairs(sprites) do
		model.panel:addChild(v)
		v:setPosition(model.x,model.y)
		local m_x  = math.random(start_x,end_x)
		local m_y  = math.random(start_y,end_y)
		local rota = math.random(0,360)
		v:setRotation(rota)
		local move = cc.MoveTo:create(0.6,cc.p(m_x,m_y))
		local ea   = cc.EaseExponentialOut:create(move)
		v:runAction(ea)
	end
end


--绘制桌面筹码 无需动作
function Useranimation:drawChips(model)
	local chip = model.chip
	local base = model.base

	local sprites = {}
	sprites       = self:getChipsimg(sprites,chip,base)
	
	local start_x = 100
	local end_x   = 550

	local start_y = 0
	local end_y   = 190

	local radius_x = 0
	local radius_y = 0
	
	for k,v in pairs(sprites) do
		model.panel:addChild(v)
		local m_x  = math.random(start_x,end_x)
		local m_y  = math.random(start_y,end_y)
		local rota = math.random(0,360)

		v:setPosition(m_x,m_y)		
		v:setRotation(rota)
	end
end

--根据chip创建金币图片返回 图片数组
function Useranimation:getChipsimg(sprites,chips,base)

	local gold_brick_base = base*20
	local gold_coin       = base*5


	if chips >= gold_brick_base then
		local num  = math.modf(chips/gold_brick_base)
		local less = math.modf(chips%gold_brick_base)
		for i=1,num do
			local sprite = cc.Sprite:create(Niuniu_Games_res.gold_brick)
			sprite:setScale(0.8)
			table.insert(sprites,sprite)
		end 

		Useranimation:getChipsimg(sprites,less,base)
	end

	if chips >=gold_coin and chips<gold_brick_base then
		local num  = math.modf(chips/gold_coin)
		local less = math.modf(chips%gold_coin)
		for i=1,num do
			local sprite = cc.Sprite:create(Niuniu_Games_res.gold_diu)
			sprite:setScale(0.8)
			table.insert(sprites,sprite)
		end 

		Useranimation:getChipsimg(sprites,less,base)
	end

	if chips<gold_coin then
		local num  = math.modf(chips/base)
		for i=1,num do
			local sprite = cc.Sprite:create(Niuniu_Games_res.silver_coin)
			sprite:setScale(0.8)
			table.insert(sprites,sprite)
		end 	
	end

	return sprites
end


-- 聊天文字
function Useranimation:getChatNode( paras )
    local chatPop = cc.Sprite:create(paras.image)
   

    local fontSize = 35
    local layout, num = Util:getChatLayoutEx(chatPop, paras.content, fontSize, 10, 0)

    layout:setPosition(260,50)
    if paras.uin == Cache.user.uin then
    	layout:setPosition(240,70)
    end

    chatPop:setPosition(paras.pos.x,paras.pos.y)
    --翻转了
    if paras.rotation == 180 then
    	chatPop:setRotation(paras.rotation)
    	layout:setRotation(paras.rotation)
    	layout:setPosition(220,40)
    end

   	if paras.type and  paras.type == 'kan' then
    	if  paras.index ==1   then
    		layout:setPosition(220,40)
    	end
    	if  paras.index == 4 then
    		layout:setPosition(260,40)
    	end
    	if  paras.index ==2 or paras.index ==3  then
    		layout:setPosition(210,60)
    	end
    end


    if paras.filp then
    	chatPop:setFlipX(true)
    end

    local function getDisAction(scale)
        scale = scale or 1.05
        return cc.Sequence:create(cc.DelayTime:create(num*1.0+0.5)
            , cc.Spawn:create(
                cc.FadeTo:create(1.0, 0),
                cc.ScaleBy:create(0.5,scale))
            , cc.CallFunc:create(function ( sender )
                sender:removeFromParent(true)
            end))
    end
    chatPop:runAction(getDisAction(1.1))
    layout:runAction(getDisAction(1.04))

    return chatPop
end

return Useranimation