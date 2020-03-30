local Chip = class("Chip",function()
    return cc.Node:create()
end)

local bLoadChipPlist =  false
local useBigNumCount = 9999999 --超过1000万则用金块

--参数传颜色与数值
function Chip:ctor(paras)
	-- 采用图片的方式
	local path = Chip.getColorPath(paras.color)
	local chipFntPath = path .. "/number.fnt"

    --采用plist方式与直接使用图片方式相比的话 能够明显的降低GL calls
	local pngName = Chip.getColorName(paras.color)
	local chipImg = ccui.ImageView:create()
	if bLoadChipPlist == false then
		bLoadChipPlist = true
		--plist 方式中  图片与字样都包含的情况下 就可以达到 缩减GLcall 如果 
		local plistPath = "game_common/component/chip/chip.plist"
		local pngPath = "game_common/component/chip/chip.png"
		cc.SpriteFrameCache:getInstance():addSpriteFramesWithFile(plistPath, pngPath)
	end

	-- 大于1000万，则丢出金块
	if paras.number > useBigNumCount and type(paras.number) == "number" then
		chipImg:loadTexture(GameRes.chip_big_num_path .. "/chip.png")
		chipFntPath = GameRes.chip_big_num_path .. "/number.fnt"
		-- 天天斗牛特殊处理，暂时没发现怎么统一
		paras.fontScale = 0.65
	else
		chipImg:loadTexture(pngName,ccui.TextureResType.plistType)
	end
	
	Chip.addNumber(chipImg, {number = paras.number, fntPath = chipFntPath, color = paras.color, fontScale = paras.fontScale})
	if paras.scale then
		chipImg:setScale(paras.scale)
	end
	self:addChild(chipImg)
end

local modifyFormatNumber = function (number)
	if number >= 10000 then
		return (number/10000) .. GameTxt.wan_unit
	end
	if number >= 1000 then
		return (number/1000) .. GameTxt.qian_unit
	end
	return number
end

local checkNumberInPList = function (number, color)
	local plistTbl = {
		[CHIPCOLOR.RED] = {100, 3000000},
		[CHIPCOLOR.BLUE] =  {10, 300000},		
		[CHIPCOLOR.PURPLE] =  {50, 9000000},
		[CHIPCOLOR.GREEN] =  {1, 30000},
		[CHIPCOLOR.ORANGE] =  {300, 1500000},
		[CHIPCOLOR.GRAYBLUE] = {100}
	}
	return plistTbl[color] and table.indexof(plistTbl[color], number)
end

function Chip.addNumber(sender, paras)
	if paras.fontScale then
		paras.scale = paras.fontScale
	end
	if checkNumberInPList(paras.number, paras.color) then
		Chip.addNumberImg(sender, paras)
	else
		Chip.addNumberFnt(sender, paras)
	end
end

--在筹码上增加字的图片
function Chip.addNumberImg(sender, paras)
	local colorName = {
		[CHIPCOLOR.RED] = "red",
		[CHIPCOLOR.BLUE] =  "blue",		
		[CHIPCOLOR.PURPLE] = "purple",
		[CHIPCOLOR.GREEN] =  "green",
		[CHIPCOLOR.ORANGE] =  "orange",
		[CHIPCOLOR.GRAYBLUE] = "grayblue"	
	}
	local numImg = ccui.ImageView:create()
	numImg:loadTexture(colorName[paras.color] .. "_" .. paras.number .. ".png", ccui.TextureResType.plistType)
	local pos = paras.pos
	if pos == nil then
		local size = sender:getContentSize()
		local ox, oy = 0, 0 --默认的偏移值
		if paras.number > 100 then
			oy = 3
		end 
		if paras.offset then --根据实际情况给的偏移值
			ox = paras.offset.x or ox
			oy = paras.offset.y or oy			
		end
		pos = cc.p(size.width/2 + ox, size.height/2 + oy)
	end
	if paras.scale then
		numImg:setScale(paras.scale)
	end
	local name = nil
	if paras.name then
		numImg:setName(paras.name)
		name = paras.name
	else
		numImg:setName("number")
		name = "number"
	end
	if sender:getChildByName(name) then
		sender:removeChildByName(name)
	end
	numImg:setPosition(pos)
	sender:addChild(numImg)
end

--在筹码上增加字体 统一处理
function Chip.addNumberFnt(sender, paras)
	local number = paras.number or 0
	local fntPath = paras.fntPath
	local fnt = cc.LabelBMFont:create(number, fntPath)
	local pos = paras.pos
	if pos == nil then
		local size = sender:getContentSize()
		local ox, oy = 0, 5 --默认的偏移值
		if paras.offset then --根据实际情况给的偏移值
			ox = paras.offset.x or ox
			oy = paras.offset.y or oy			
		end
		pos = cc.p(size.width/2 + ox, size.height/2 + oy)
	end

	if paras.scale then
		fnt:setScale(paras.scale)
	end
	local name = nil
	if paras.name then
		fnt:setName(paras.name)
		name = paras.name
	else
		fnt:setName("number")
		name = "number"
	end
	if sender:getChildByName(name) then
		sender:removeChildByName(name)
	end
	if paras.customNumber then
	else
		number = modifyFormatNumber(checknumber(number))
		fnt:setString(number)
	end

	fnt:setPosition(pos)
	sender:addChild(fnt)
end

function Chip.getColorPath(color)
	local path = {
		[CHIPCOLOR.RED] =  GameRes.chip_red_path,
		[CHIPCOLOR.BLUE] =  GameRes.chip_blue_path,		
		[CHIPCOLOR.PURPLE] =  GameRes.chip_purple_path,
		[CHIPCOLOR.GREEN] =  GameRes.chip_green_path,
		[CHIPCOLOR.ORANGE] =  GameRes.chip_orange_path,
		[CHIPCOLOR.GRAYBLUE] = GameRes.chip_grayblue_path
	}
	-- assert(path[color], "the color is invalid!!!")
	-- 2019-04-29 LcGero Modify
	--给个默认值吧
	if not path[color] then
		return path[CHIPCOLOR.GREEN]
	end
	return path[color]
end

function Chip.getColorName(color)
	local name = {
		[CHIPCOLOR.RED] =  "red.png",
		[CHIPCOLOR.BLUE] =  "blue.png",		
		[CHIPCOLOR.PURPLE] =  "purple.png",
		[CHIPCOLOR.GREEN] =  "green.png",
		[CHIPCOLOR.ORANGE] =  "orange.png",
		[CHIPCOLOR.GRAYBLUE] = "grayblue.png"
	}
	-- assert(path[color], "the color is invalid!!!")
	-- 2019-04-29 LcGero Modify
	--给个默认值吧
	if not name[color] then
		return name[CHIPCOLOR.GREEN]
	end
	return name[color]	
end

return Chip