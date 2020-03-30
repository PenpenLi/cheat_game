
local Useranimation      =  class("Useranimation")
Useranimation.TAG        = "Useranimation"
Useranimation.Chips_width      = 325   --chips长方形长的一半
Useranimation.Chips_height     = 100	 --chips长方形宽的一半

--跟注 
function Useranimation:xiaZhu( model )
	-- body
	local chip  = Cache.packetInfo:getProMoney(model.chip)
	
	local base  = model.base
	local node  = model.node
	local panel = model.panel
	local panel1 = model.panel1
	-- print(node:getChild)

	local sprite       = self:getChipsimg(chip,base,node)
	local node_x       = node:getPositionX()
	local node_y       = node:getPositionY()

	local usericon =node:getChildByName("icon")
	if usericon then
		node_x = node_x +	usericon:getPositionX()	
		node_y = node_y +	usericon:getPositionY()	
	else
		usericon =node:getChildByName("user_info"):getChildByName("icon")
		if usericon then
			node_x = node_x +	usericon:getPositionX()	
			node_y = node_y +	usericon:getPositionY()	
		end
	end
	local userinfo =node:getChildByName("user_info")-- node:getChildByName("icon") 
	if userinfo then
		node_x = node_x +	userinfo:getPositionX()	
		node_y = node_y +	userinfo:getPositionY()	
	end

	local panel_x       = panel:getPositionX()
	local panel_y       = panel:getPositionY()
	local panel1_x       = panel1:getPositionX()
	local panel1_y       = panel1:getPositionY()

	local size          = panel:getContentSize()
	--随机获得扔的区域
	panel1:addChild(sprite,1)
	sprite:setPosition(cc.p(node_x-panel1_x,node_y-panel1_y))
	local rota = math.random(0,60)-30
	local end_x = math.random(0,size.width)
	local end_y = math.random(0,size.height)
	sprite:setRotation(rota)
	local endpos
	if chip<base*10 then
		local dY = 0
		if panel:getName() == "chips_area" then
			dY = -50
		elseif panel:getName() == "chips_area1" then
			dY = -34
		end
		endpos=cc.p(math.random(0-panel1_x+panel_x,0-panel1_x+panel_x+size.width),math.random(0-panel1_y+panel_y,0-panel1_y+panel_y+size.height + dY))
	else
		local randomX=0-panel1_x+panel_x+sprite:getContentSize().width/3
		local randomX1=0-panel1_x+panel_x+size.width-sprite:getContentSize().width/3
		local randomY=0-panel1_y+panel_y+sprite:getContentSize().height/3
		local randomY1=0-panel1_y+panel_y+size.height-sprite:getContentSize().height/3
		if randomX>randomX1 then 
			randomX=math.random(randomX1,randomX)
		else 
			randomX=math.random(randomX,randomX1)
		end
		if randomY>randomY1 then 
			randomY=math.random(randomY1,randomY)
		else 
			randomY=math.random(randomY,randomY1)
		end
		endpos=cc.p(randomX,randomY)
	end
	local move = cc.MoveTo:create(0.6,endpos)
	local ea   = cc.EaseExponentialOut:create(move)
	sprite:runAction(ea)
	if chip>=base*10 then
		MusicPlayer:playMyEffectGames(Zjh_Games_res,"GoldChip")
	else
		MusicPlayer:playMyEffectGames(Zjh_Games_res,"chipsSound")
	end
end
function Useranimation:getEndRandPos()--获得随机筹码落点坐标
	-- body
	local end_x = math.random(0,680)+620
	local end_y=0
	if end_x<700 then
		end_y=460+math.random(0,320)
	elseif end_x>=770 and end_x<1200 then
		end_y=420+math.random(0,160)
	elseif end_x>=1250 then
		end_y=420+math.random(0,360)
	else
		end_y=420+math.random(320,360)
	end
	return cc.p(end_x,end_y)
end

function Useranimation:getDisTime(x1,x2,y1,y2,distime)--根据距离获得时间(distime为速度)
	-- body
	local dis=math.sqrt((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2))
	loga("getDisTime  !!!"..dis/distime)
	return dis/distime
end

--绘制桌面筹码 无需动作
function Useranimation:drawChips(model)
	local chip = model.chip
	local base = model.base
	local panel = model.panel
	local panel1 = model.panel1

	local panel_x       = panel:getPositionX()
	local panel_y       = panel:getPositionY()
	local panel1_x       = panel1:getPositionX()
	local panel1_y       = panel1:getPositionY()
	local size          = panel:getContentSize()

	local sprites = {}
	sprites=self:getdrawChipsimg(sprites,chip,base,Cache.zjhdesk["chip_list"][(#Cache.zjhdesk["chip_list"])])

	for k,v in pairs(sprites) do
		model.panel1:addChild(v,1)
		local endpos = cc.p(math.random(0-panel1_x+panel_x+sprite:getContentSize().width/3,0-panel1_x+panel_x+size.width-sprite:getContentSize().width/3),math.random(0-panel1_y+panel_y+sprite:getContentSize().height/3,0-panel1_y+panel_y+size.height-sprite:getContentSize().height/3))
		local rota = math.random(0,360)

		v:setPosition(endpos.x,endpos.y)		
		v:setRotation(rota)

	end

end

--根据chip创建金币图片返回 图片数组
function Useranimation:getdrawChipsimg(sprites,chips,base)
	local NowMaxChip=chips
	-- for i=1,20 do
	-- 	if chips<=(10^i) then
	-- 		NowMaxChip=10^(i-1)
	-- 		break
	-- 	end
	-- end
	while(chips>=base)
		do
		if chips>=NowMaxChip then
			sprite=self:getChipsimg(NowMaxChip,base)
			chips=chips-NowMaxChip
			table.insert(sprites,sprite)
		elseif (NowMaxChip/10)>(base*10) then
			NowMaxChip=NowMaxChip/10
		-- elseif chips>=(NowMaxChip/10) and (NowMaxChip/10) >(base*10) then
		-- 	sprite=self:getChipsimg(NowMaxChip/10,base)
		-- 	chips=chips-NowMaxChip/10
		-- 	table.insert(sprites,sprite)
		else
			for i=10,1,-1 do
				if chips>=base*i then
					sprite=self:getChipsimg(base*i,base)
					chips=chips-base*i
					table.insert(sprites,sprite)
					break
				end
			end
		end
	end
	return sprites
end

local function getChouMaString(v)
	if (math.floor(v) < v) and (math.floor(v*10) < (10*v)) then --存在两位小数以上的小数时
		fstr = Util:getFormatString(v)
	else
		fStr = Util:getOldFormatString(v, 1)
	end

	return fStr
end


--根据chip创建金币图片返回 图片数组
function Useranimation:getChipsimg(chips, base, user)
	local blook = false
	local chip_list = clone(Cache.zjhdesk.chip_list) or {200,300,400,500}
	if user ~= nil then
		--为了达到点击筹码 与飞出来的筹码 颜色一致  在看牌的情况要进行特殊处理
		if Cache.zjhdesk._player_info[user._uin].look == 1 then
			blook = true
		end
	end
	if chip_list and blook then
		for i = 1, 4 do
			chip_list[i] = Cache.zjhdesk.chip_list[i] * 2
		end
	end

	local ridx = 1
	chips = chips
	
	if chip == base then
		ridx = 1
	else
		local idx = table.indexof(chip_list, chips)
		if idx then
			ridx = idx + 1
		end
	end

	local fStr = getChouMaString(chips)
	-- fStr = Util:getFormatString(chips)
	-- if (math.floor(chips) < chips) then --包含两位小数
	-- else
	-- 	fStr = Util:getOldFormatString(chips, 1)
	-- end

	local font = cc.LabelBMFont:create(fStr, Zjh_Games_res["chipFnt_" ..  ridx])
	if Util:UTF8length(fStr) <= 3 then
		font:setPosition(cc.p(95,113))
	else
		font:setScale(0.8)
		font:setPosition(cc.p(95,113))
	end

	local res = Zjh_Games_res["Chips_" .. ridx]
	local sprite = cc.Sprite:createWithSpriteFrameName(res)
	sprite:addChild(font)
	sprite:setScale(0.5)
	return 	sprite
end


-- 聊天文字
function Useranimation:getChatNode( paras )
    local chatPop = cc.Sprite:create(paras.image)
   	local fontSize = 35

   	local layout, num

    
   	if paras.dila then
		local  line_width= chatPop:getContentSize().width-30
		local temp = cc.LabelTTF:create(paras.content,GameRes.font1,fontSize,cc.size(line_width,200))
		local  line_height=temp:getContentSize().height 
		layout = ccui.Layout:create() 
		layout:setAnchorPoint(0.5,0.5)
		layout:setSize(cc.size(chatPop:getContentSize().width-10 , line_height))
		layout:setPosition(ccp(chatPop:getContentSize().width/2+10, chatPop:getContentSize().height/2))


		temp:setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
		temp:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
		temp:setAnchorPoint(0.5,0.5)
		temp:setPosition(layout:getContentSize().width/2,layout:getContentSize().height/2)
		layout:addChild(temp) 
		chatPop:addChild(layout)
		num=1
    else
    	layout, num = Util:getChatLayoutEx(chatPop, paras.content, fontSize, 0, 0)
    	layout:setPosition(250,50)
    end
    if paras.uin == Cache.user.uin then
    	layout:setPosition(240,70)
    end



    chatPop:setPosition(paras.pos.x,paras.pos.y)

    --翻转了
    if paras.rotation == 180 then
    	chatPop:setRotation(paras.rotation)
    	layout:setRotation(paras.rotation)
    	layout:setPosition(230,40)
    end
    
    if  paras.pos.y ==500  then
		layout:setPosition(240,70)
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