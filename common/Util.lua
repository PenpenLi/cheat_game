
local M = class("M")

M.TAG = "Util"
M.UNIT_TYPE_NONE = 0
M.UNIT_TYPE_K = 1
M.UNIT_TYPE_M = 2

local OPTIONAL_VAL = 1    --数值(optional int32,string...)
local OPTIONAL_MSG = 2    --结构(optional message)
local REPEATED_VAL = 3    --数值数组(repeated int32,string...)
local REPEATED_MSG = 4    --结构数组(repeated message)

function M:ctor()
	-- logd( " --- Util ctor ---" , self.TAG)
    self.data32 = {}
    for i=1,32 do
        self.data32[i]=2^(32-i)
    end
end


function M:getReivewFolder()
    local review_folder= "res/review/"
    return review_folder
end

function M:getHURLByUin( uin )
    if uin == nil then return "" end
    return  HOST_PREFIX..RESOURCE_HOST_NAME .."/cdn/portrait/"..uin;
end

function M:getHURLByUrl(url)
    if url == nil then return "" end
    return HOST_PREFIX ..HOST_NAME .."/media/"..url;
end

function M:getCacheIcon(paras)
    local npath = CACHE_DIR.."head_"..paras.uin..".jpg"
    local sexRes = GameRes.user_default0
    if paras.sex == 1 then sexRes = GameRes.user_default1 end
    if io.exists(npath) then sexRes = npath end
    return sexRes
end

-- 传入DrawNode对象，画圆角矩形
function M:drawNodeRoundRect(drawNode, rect, radius, borderWidth, color, fillColor)
      -- segments表示圆角的精细度，值越大越精细
      local segments    = 100
      local origin      = cc.p(rect.x, rect.y)
      local destination = cc.p(rect.x + rect.width, rect.y - rect.height)
      local points      = {}

      -- 算出1/4圆
      local coef     = math.pi / 2 / segments
      local vertices = {}

      for i=0, segments do
        local rads = (segments - i) * coef
        local x    = radius * math.sin(rads)
        local y    = radius * math.cos(rads)

        table.insert(vertices, cc.p(x, y))
      end

      local tagCenter      = cc.p(0, 0)
      local minX           = math.min(origin.x, destination.x)
      local maxX           = math.max(origin.x, destination.x)
      local minY           = math.min(origin.y, destination.y)
      local maxY           = math.max(origin.y, destination.y)
      local dwPolygonPtMax = (segments + 1) * 4
      local pPolygonPtArr  = {}

      -- 左上角
      tagCenter.x = minX + radius;
      tagCenter.y = maxY - radius;

      for i=0, segments do
        local x = tagCenter.x - vertices[i + 1].x
        local y = tagCenter.y + vertices[i + 1].y

        table.insert(pPolygonPtArr, cc.p(x, y))
      end

      -- 右上角
      tagCenter.x = maxX - radius;
      tagCenter.y = maxY - radius;

      for i=0, segments do
        local x = tagCenter.x + vertices[#vertices - i].x
        local y = tagCenter.y + vertices[#vertices - i].y

        table.insert(pPolygonPtArr, cc.p(x, y))
      end

      -- 右下角
      tagCenter.x = maxX - radius;
      tagCenter.y = minY + radius;

      for i=0, segments do
        local x = tagCenter.x + vertices[i + 1].x
        local y = tagCenter.y - vertices[i + 1].y

        table.insert(pPolygonPtArr, cc.p(x, y))
      end

      -- 左下角
      tagCenter.x = minX + radius;
      tagCenter.y = minY + radius;

      for i=0, segments do
        local x = tagCenter.x - vertices[#vertices - i].x
        local y = tagCenter.y - vertices[#vertices - i].y

        table.insert(pPolygonPtArr, cc.p(x, y))
      end

      if fillColor == nil then
        fillColor = cc.c4f(0, 0, 0, 0)
      end

      drawNode:drawPolygon(pPolygonPtArr, #pPolygonPtArr, fillColor, borderWidth, color)
end


-- 聊天上传头像路径
function M:getChatUploadUrl( ... )
    return Cache.Config:getChatHttpAddress() .. "/open/upload/chat_upload_file"
end

--四舍五入. num, 整数; n, 向第n位取整。 例如输入125，要输出130， 则n要传入2
function M:roundOff(num, n)
    if n > 0 then
        local scale = math.pow(10, n-1)
        return math.floor(num / scale + 0.5) * scale
    elseif n < 0 then
        local scale = math.pow(10, n)
        return math.floor(num / scale + 0.5) * scale
    elseif n == 0 then
        return num
    end
end

--不四舍五入. num, 整数; n, 向第n位取整
function M:roundOff2(num, n)
    if n > 0 then
        local scale = math.pow(10, n-1)
        return math.floor(num / scale) * scale
    elseif n < 0 then
        local scale = math.pow(10, n)
        return math.floor(num / scale) * scale
    elseif n == 0 then
        return num
    end
end

function M:getByteCount( byte )
    local ret = 0
    if byte > 0 and byte <= 127 then
        ret = 1
    elseif byte >= 192 and byte < 223 then
        ret = 2
    elseif byte >= 224 and byte < 239 then
        ret = 3
    elseif byte >= 240 and byte <= 247 then
        ret = 4
    end
    return ret
end
function M:filterEmoji( source )--特殊表情奔溃问题解决方案
    local len = string.len(source)
    if len < 2 then return source end

    local ret_str = ""
    local i = 1
    while i <= len do
        local is_emoji = false
        local byte_1 = string.byte(source, i)
        if byte_1 == 240 then
            local byte_2 = string.byte(source, i + 1)
            if byte_2 == 159 then
                is_emoji = true
            end
        end
        local byte_count = self:getByteCount(byte_1)
        byte_count = byte_count < 1 and 1 or byte_count
        if not is_emoji then
            ret_str = ret_str..string.sub(source, i, i + byte_count - 1)
        end
        i = i + byte_count
    end
    return ret_str
end


--判断是否是中文
function M:isLanguageChinese()
    if GAME_LANG == "cn" or GAME_LANG == "zh_tr" then
        return true
    else
        return false
    end
end

--v, 数值; model, 保留小数点后..位
function M:getFormatUnit(v, model)
    local n = model or 2
    if type(v) ~= "number" then return v end
    local k = self:isLanguageChinese() and 10000 or 1000
    local m = self:isLanguageChinese() and 100000000 or 1000000
    local f = v
    local u = self.UNIT_TYPE_NONE
    if v >= m then
        f = v / m
        u = self.UNIT_TYPE_M
    elseif v >= k then
        f = v / k
        u = self.UNIT_TYPE_K
    end

    if u > self.UNIT_TYPE_NONE then
        local num = f * math.pow(10, n + 1)
        -- num = self:roundOff(num, 2) --四舍五入
        num = self:roundOff2(num, 2)
        f = num / math.pow(10, n + 1)
    end
    return f, u
end

function M:getPreciseDecimal(nNum, n)
    if type(nNum) ~= "number" then
        return nNum;
    end
    n = n or 0;
    n = math.floor(n)
    if n < 0 then
        n = 0;
    end
    local nDecimal = 10 ^ n
    local nTemp = math.floor(nNum * nDecimal);
    local nRet = nTemp / nDecimal;
    return nRet;
end

function M:getFormat(v,model)
    local n = model or 2
    local num, unit = self:getFormatUnit(v, model)
    local str = ""
    if unit == self.UNIT_TYPE_M then
        str = GameTxt.string012
    elseif unit == self.UNIT_TYPE_K then
        str = GameTxt.string011
    end


    return num, str
end



function M:getFormatK(v,model)
    local n = model or 2
    local num, unit = self:getFormatUnit(v, model)
    local str = ""
    if unit == self.UNIT_TYPE_M then
        str = GameTxt.string012
    elseif unit == self.UNIT_TYPE_K then
        str = GameTxt.string011

        if num >=1000 then
            local f   = num/1000 
            local num1 = f * math.pow(10, n + 1)
            num1 = self:roundOff(num1, 2) --四舍五入
            f = num1 / math.pow(10, n + 1) 

            num = f
            str = GameTxt.string013
        end
    end


    return num, str
end

--将一个数字转为为保留dpt个小数位的字符串
function M:NoRoundedOff(v, dpt)
    local vStr = v .. ""
    local idx = string.find(vStr, "%.")

    if dpt == 0 then
        if idx and idx ~= -1 then        
            return string.sub(vStr, 1, idx-1)
        else
            return vStr
        end
    end

    if idx and idx ~= -1 then
        local len = string.len(vStr)
        local _len = len - idx
        if len > idx + dpt then
            vStr = string.sub(vStr, 1, idx + dpt)
        else
            for i = _len+1, dpt do
                vStr = vStr  .. "0"
            end
        end
    else
        vStr = vStr .. "." 
        for i = 1, dpt do
            vStr = vStr .. "0"
        end
    end 
    return vStr
end

--220版本保留两位小数位
function M:getFormatString(v,model)
    if v == nil then return "" end
    if type(v) ~= "number" then
        return v
    end
    --金币少于10万 显示全部
    local maxValue = Cache.packetInfo:isShangjiaBao() and 10000 or 100000
    if v >= maxValue then
        return self:getOldFormatString(v, model)
    end
    
    local dpt = Cache.packetInfo:getDecimalPoint()
    return self:NoRoundedOff(v, dpt)
end

--显示商品价格的 或者不使用服务器给定的小数位
function M:getProductFormatString(v,model)
    if v == nil then return "" end
    if type(v) ~= "number" then
        return v
    end
    --金币少于10万 显示全部
    local maxValue = Cache.packetInfo:isShangjiaBao() and 10000 or 100000
    if v >= maxValue then
        return self:getOldFormatString(v, model)
    end
    return v
end


--220版本之前的显示金币的规则
function M:getOldFormatString(v,model)
    if v == nil then return "" end
    local s,u = self:getFormat(v,model)
    if s == nil then return "" end
    if u == nil then return s..""
    else return s..u end
end


function M:getFormatStringK(v,model)
    local maxValue = Cache.packetInfo:isShangjiaBao() and 10000 or 100000
    if v<maxValue then
      model = model
    else
        model = 0
   end

   return self:getFormatStringKW(v,model)
end

function M:getFormatStringKW(v,model)
    if v == nil then return "" end
    local s,u = self:getFormatK(v,model)
    if s == nil then return "" end
    if u == nil then return s..""
    else return s..u end
end



--[[--返回插入特殊字符后的人民币 数字，88,888,888]]
function M:matchStr(num,letter)
	local appendStr = ""
    local  tempNum = num
    local tempstr = ""
    while tempNum>0 do
        if tempNum<1000 then
            tempstr = (tempNum%1000)..""
            if #appendStr>0 then
                appendStr = tempstr..letter..appendStr
                tempNum = math.floor(tempNum/1000)
            else
                appendStr = tempstr..""..appendStr
                tempNum = math.floor(tempNum/1000)
            end
        else
            if #appendStr == 0 then
                tempstr = (1000+tempNum%1000)..""
                appendStr = appendStr..""..string.sub(tempstr,2,4)
                tempNum = math.floor(tempNum/1000)
            else
                tempstr = (1000+tempNum%1000)..""
                appendStr = string.sub(tempstr,2,4)..letter..appendStr
                tempNum = math.floor(tempNum/1000)
            end
        end
	end
	if #appendStr==0 then
        appendStr = tempNum..""
	end
    return appendStr
end

-- 获取上次 在线的时间（如 几个小时前 几天前 几周前）
function M:formatTimer(lastTimer)
    local curTimerStr=""
    local curTimer = os.time()--秒
    local yearTimer = 12*30*24*3600
    local mothTimer = 30*24*3600--一个月有多少秒
    local weekTimer = 7*24*3600
    local dayTimer = 24*3600--一天多少秒
    local hourTimer = 3600--一小时是多少秒
    local minuteTmier = 60
    local DTimer = curTimer-lastTimer;
    if (math.floor(DTimer/yearTimer))>0 then
         curTimerStr = math.floor(DTimer/yearTimer)..GameTxt.TimerUnitStr[1]
    elseif (math.floor(DTimer/mothTimer))>0 then
        curTimerStr = math.floor(DTimer/mothTimer)..GameTxt.TimerUnitStr[2]
    elseif math.floor(DTimer/weekTimer)>0 then
        curTimerStr = math.floor(DTimer/weekTimer)..GameTxt.TimerUnitStr[3]
    elseif math.floor(DTimer/dayTimer)>0 then
        curTimerStr = math.floor(DTimer/dayTimer)..GameTxt.TimerUnitStr[4]
    elseif math.floor(DTimer/hourTimer)>0 then --小时
        curTimerStr = math.floor(DTimer/hourTimer)..GameTxt.TimerUnitStr[5]
    elseif math.floor(DTimer/minuteTmier)>0 then
        curTimerStr = math.floor(DTimer/minuteTmier)..GameTxt.TimerUnitStr[6]
    else
        curTimerStr = "1"..GameTxt.TimerUnitStr[6]
    end    
    return curTimerStr
end


function M:addNormalTouchEvent(node,func)
    local listener1 = cc.EventListenerTouchOneByOne:create()
    listener1:setSwallowTouches(true)
    listener1:registerScriptHandler(function (touch,event)
        local p = node:getParent()
        while p ~= nil do 
            if p:isVisible() == false then return false end
            p = p:getParent()
        end
        
        if func ~= nil then return func("began",touch,event) end
    end,cc.Handler.EVENT_TOUCH_BEGAN)
    
    listener1:registerScriptHandler(function (touch ,event) 
        if func ~= nil then  func("move",touch,event) end
    end,cc.Handler.EVENT_TOUCH_MOVED)
    
    listener1:registerScriptHandler(function (touch ,event) 
        if func ~= nil then  func("end",touch,event) end
    end,cc.Handler.EVENT_TOUCH_ENDED)
    
    local eventDispatcher = node:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener1,node)
end

--[[]]
function M:delayRun(time,cb,tag)
    local action = cc.Sequence:create(
        cc.DelayTime:create(time),
        cc.CallFunc:create(function () if cb then cb() end end))
    if tag then action:setTag(tag) end
    LayerManager.Global:runAction(action)
end

function M:delayRunForever(time, cb, tag)
    local once = cc.Sequence:create(
        cc.DelayTime:create(time),
        cc.CallFunc:create(function () if cb then cb() end end))
    local action = cc.RepeatForever:create(once)
    if tag then action:setTag(tag) end
    LayerManager.Global:runAction(action)
end

function M:stopDelayRun(tag)
    if LayerManager.Global:getActionByTag(tag) then LayerManager.Global:stopActionByTag(tag) end
end
function M:runOnce( time, listener )
    local handle
    handle = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
        self:stopRun(handle)
        listener()
    end, time, false)
    return handle
end
function M:stopRun( handle )
    if handle then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(handle)
        handle = nil
    end
end

function M:registerKeyReleased(paras)
    Cache.clickNum = 0
    local function onKeyReleased(keyCode, event)
        if keyCode == cc.KeyCode.KEY_BACK and Cache.clickNum == 0 then
            paras.cb()
            Cache.clickNum = 1
            Util:delayRun(0.2,function ()
                Cache.clickNum = 0
            end)
        end
    end
    local listener = cc.EventListenerKeyboard:create()
    listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED )
    local eventDispatcher = paras.self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, paras.self)
    return listener
end


function M:UTF8length(str)
  return #(str:gsub('[\128-\255][\128-\255]',' '))
end

function M:subStringUTF8(s,n) 
    local ret = self:_subStringUTF8(s,n)
    if #ret == self:UTF8length(ret) then  --纯英文
        if #ret > n/2 then return string.sub(ret,1,n/2) end
    end
    return ret
end
function M:getFixName(s,byte)
    if s == nil then return 0 end
    local ret = self:subStringUTF8(s,(byte or 12))
    return ret
    --if ret ~= s then return ret.."..." else return ret end
end

function M:_subStringUTF8(s, n)
  local dropping = string.byte(s, n+1)
  if not dropping then return s end
  if dropping >= 128 and dropping < 192 then
    return self:_subStringUTF8(s, n-1)
  end
  return string.sub(s, 1, n)
end

--获取一个字符串的子字符串
function M:getSubString(str, start_index, end_index)
	end_index = end_index or self:UTF8length(str)
	--将utf8字符映射到表
	local tab = {}
	for uchar in string.gfind(str, "[%z\1-\127\194-\244][\128-\191]*") do 
		tab[#tab+1] = uchar
	end
	--获取子串
	local sub = ""
	for i = 1, #tab do
		if i >= start_index and i <= end_index then
			sub = sub .. tab[i]
		end
	end
	
	return sub
end

--去掉前后空格
function M:stringTrim(str)
	if str == nil then return nil end
	return string.match(str, "%s*(.-)%s*$")
end
function M:getTextureByPath(path)
    return cc.Sprite:create(path):getTexture()
end

--图片转存为jpg格式
function M:convertToJpg(path)
    local image = cc.Image:new()
    image:initWithImageFile(path)
    local format = image:getFileType()
    if format == cc.IMAGE_FORMAT_PNG then   --如果是png格式则转存为jpg
        logd("convert file path="..path, self.TAG)
        --[[
            cocos2d::Image类没有暴露saveImageToJPG方法, 而saveToFile是根据文件后缀名判断存储格式的
            因此先暂时命名为xx.jpg, 处理后再改回来
        ]]
        local temp_name = path..".jpg"
        image:saveToFile(temp_name)
        os.remove(path)
        os.rename(temp_name, path)
    end
end



-- key: 当是url时，extparas中url必须=true(90版本后,key必须为url,一律禁止通过传入uin来获取头像)
-- extparas.add 添加到node上
-- extparas.circle 是圆形图像
-- extparas.default 是指定默认头像
-- 一班的：如果extparas.add存在，可以不要extparas.scale参数
function M:updateUserHead(node, key, sex, extparas)
    if tolua.isnull(node) == true or node == nil then
        return
    end

    -- 默认sex为0
    if key and string.len(key)>3 and "IMG"==string.sub(key,1,3) then
        key=""
    end
    
    local head_image=node
    sex = sex or 0
    -- 获取下载地址
    local url = ""
    if extparas and extparas.url then
        url = key
    else
        url = Util:getHURLByUin(key)
    end

    if not url then
        return
    end
	-- loga("head url = "..url)
    local function addChildToParent(parent, child)
        parent:addChild(child)
        local _sz1 = parent:getContentSize()
        local _sz2 = child:getContentSize()
        child:setPosition(cc.p(_sz1.width/2, _sz1.height/2))
        local _sca = _sz1.width
        if extparas.scale then
            _sca = extparas.scale
        end
        if extparas.addname then
            child:setName(extparas.addname)
        end
        child:setScale(_sca/_sz2.width)
    end

    local setNodeTexture = function (extparas, node, path, fileTexture)
        if extparas then
            if "cc.Sprite" == tolua.type(node) then -- sprite类型
                if extparas.circle then -- 是圆形则node必须是sprite类型
                    node:setTexture(Display:getCircleHead({file=path}):getTexture())
                elseif extparas.sq then -- add方式：则node已经是sprite类型(node = _sprite)
                    node:setTexture(Display:getSqHead({file=path}):getTexture())
                elseif extparas.add then -- add方式：则node已经是sprite类型(node = _sprite)
                    node:setTexture(fileTexture)
                else
                    node:setTexture(fileTexture)
                end
            elseif "ccui.Button" == tolua.type(node) then -- sprite类型
                node:loadTextureNormal(path)
            else -- ImageView类型
                node:loadTexture(path)
            end
            local scale = extparas.scale
            if scale then -- 如果需要进行缩放
                local sz = node:getContentSize()
                node:setScale(scale/sz.width)
            end
            if extparas.scb then -- 成功回调
                extparas.scb("success")
            end
        elseif "cc.Sprite" == tolua.type(node) then -- sprite类型
            node:setTexture(fileTexture)
        else -- ImageView类型
            node:loadTexture(path)
        end
    end

    -- 获取默认头像
    local _default = nil
    if extparas.default ~= nil then
    	_default = extparas.default	--使用指定的默认头像
        head_image.photo_path=_default
    else
		if extparas and extparas.circle then
			_default = GameRes.default_man_icon
			if 1 == sex then
				_default = GameRes.default_girl_icon
			end
        elseif extparas and extparas.sq then
            _default = GameRes.default_sq_man_icon
            if 1 == sex then
                _default = GameRes.default_sq_girl_icon
            end
		else
			_default = GameRes["user_default" .. sex]
		end
        head_image.photo_path=_default
    end
    if extparas.default then
        _default = extparas.default
        head_image.photo_path=_default
    end
    -- 以子节点的方式把下载的头像加载到node上
    if extparas and extparas.add then
        local _sprite
        if extparas.addname then
            _sprite = node:getChildByName(extparas.addname)
        end
        if _sprite == nil then
            _sprite = cc.Sprite:create(_default)
            addChildToParent(node, _sprite)
        end
        node = _sprite
        if extparas.sq then -- add方式：则node已经是sprite类型(node = _sprite)
            node:setTexture(Display:getSqHead({file=_default}):getTexture())
        end
        
    elseif "cc.Sprite" == tolua.type(node) then -- sprite类型
        node:setTexture(_default)
        if extparas and extparas.scale then
            node:setScale(extparas.scale/node:getContentSize().width)
        end
    elseif "ccui.Button" == tolua.type(node) then -- sprite类型
        node:loadTextureNormal(_default)
        if extparas and extparas.scale then
            node:setScale(extparas.scale/node:getContentSize().width)
        end
    else -- ImageView类型
        if not extparas.nodefault then 
            node:loadTexture(_default)
        end
        if extparas and extparas.scale then
            node:setScale(extparas.scale/node:getContentSize().width)
        end
    end
    if key and string.len(key)>3 and "IMG"==string.sub(key,1,3) then
        local img =tonumber(string.sub(key,4,#key))
        if sex==0 then
            img = img <8 and img>0 and img or 1
        else
            img = img <7 and img>0 and img or 1
        end
        path=string.format(GameRes.DefaultHead,sex,img)

        local _sp= cc.Sprite:create(path)
        if not _sp then
             logd("Sprite:create fail. path: " .. path)
            return
         end
        local fileTexture = _sp:getTexture()
        -- cocos底层不够健壮，如果texture为null导致崩溃
        if not fileTexture then
            loge("getTexture fail. path: " .. path)
            return
        end 
        setNodeTexture(extparas, node, path, fileTexture)
        if head_image.updatePhoto then head_image:updatePhoto(path) end
        return
    end

    if url ==nil or string.len(url) == 0 then return end
    local downloadTaskID = qf.downloader:execute(url, 30,
        function (path)
			if not io.exists(path) then return end	--头像图片不存在则不加载. fix_bug_79
            if not extparas.nojpg then
                self:convertToJpg(path) --将头像转存为jpg格式(为解决用户上传png头像, 透明露出默认头像问题)
            end
            local _sp= cc.Sprite:create(path)
            if not _sp then
                 logd("Sprite:create fail. path: " .. path)
                return
             end
            local fileTexture = _sp:getTexture()

            -- cocos底层不够健壮，如果texture为null导致崩溃
            if not fileTexture then
                loge("getTexture fail. path: " .. path)
                return
            end 

            -- cc.Director:getInstance():getTextureCache():reloadTexture(path)
            if not node or tolua.isnull(node) then -- 如果在拉取头像的时候此node被移除
                return 
            end
            if extparas and extparas.pcb then
                if extparas.pcb(extparas.uin) then
                    return
                end
            end
            setNodeTexture(extparas, node, path, fileTexture)
            if head_image.updatePhoto then head_image:updatePhoto(path) end
            downloadTaskID = nil
        end
        , function ()
            if not node or tolua.isnull(node) then -- 如果在拉取头像的时候此node被移除
                return 
            end
            if extparas and extparas.fcb then -- 失败回调
                extparas.fcb("failed")
            end
        end
        , function ()
            if not node or tolua.isnull(node) then -- 如果在拉取头像的时候此node被移除
                return 
            end
            if extparas and extparas.tcb then -- 超时回调
                extparas.tcb("timeout")
            end
        end
    )
    node:registerScriptHandler(function(eventname)
        if eventname == "exit" then -- 还没有执行此任务的时候，node被移除
            qf.downloader:removeTask(downloadTaskID)
            downloadTaskID = nil
        end
    end)
    return downloadTaskID
end
-- 上传头像回调
function M:uploadUserIconCallback(status)
    if "-1" == status then
        Util:runOnce(0.1, function ( ... )
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.upload_user_icon_status_f1})
        end)
    elseif "0" == status then
        Util:runOnce(0.1, function ( ... )
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.upload_user_icon_status_0})
        end)
    elseif "1" == status then
		--头像更新处理要等待服务器广播,用服务器返回的头像url更新相关界面
        Util:runOnce(0.1, function ( ... )
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.head_tip3})
        end)
    end
end

function M:galleryUploadCallBack(status)
    if "-1" == status then
        logd("galleryUploadCallBack -1")
         Util:runOnce(0.1, function ( ... )
              logd("galleryUploadCallBack -1")
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.galleryUploadFail})
        end)
       
    elseif "0" == status then
          Util:runOnce(0.1, function ( ... )
             qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.galleryUploading})
         end)
        Util:runOnce(0.2, function ( ... )

              logd("galleryUploadCallBack 0")
            qf.event:dispatchEvent(ET.GALLERY_UPLOAD,status) -- 上传中
        end)
    elseif "1" == status then
        Util:runOnce(0.1, function ( ... )
          qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.galleryUploadSuc})
        end)
          logd("galleryUploadCallBack 1")

        Util:runOnce(0.2, function ( ... )
            qf.event:dispatchEvent(ET.GALLERY_UPLOAD,status) -- 上传成功
        end)
    end
end

function M:chipsAnimation(paras)
    
    local parent,x,y = cc.Node:create(),paras.x,paras.y
    if paras.scale then
        parent:setScale(paras.scale)
    end
    paras.parent:addChild(parent,10,10)
    local delay = paras.delay or 0
    local tempDelay = delay
    local shadow = cc.Sprite:create(GameRes.login_chip_shadow)
    local node = cc.Node:create()
    local time = 0.07
    local count = 5
    parent:addChild(node)
    shadow:setAnchorPoint(0.5,0)
    shadow:setPosition(x,y)
    parent:addChild(shadow,10)
    
    local img_1
    local img_2
    if paras.type == 1 then --跳动筹码
        img_1 = GameRes.login_chips_1
        img_2 = GameRes.login_chips_2
    elseif paras.type == 2 then --跳动金币
        img_1 = GameRes.login_golds_1
        img_2 = GameRes.login_golds_2
    elseif paras.type == 3 then --跳动金币
        img_1 = GameRes.login_golds_3
        img_2 = GameRes.login_golds_4

    end

    local first = self:_ChipsAnimation(0,parent,img_2,count,time,x-39,y+11)
    local third= self:_ChipsAnimation(0.8,parent,img_2,count,time,x+38,y+13)
    local second = self:_ChipsAnimation(0.4,parent,img_1,count,time,x-3.2,y-4)
    
    local function _chipsAction(chips)
        for k,v in pairs(chips) do
            v:runAction(cc.Sequence:create(
                cc.MoveBy:create(time*k,cc.p(0,k*20)),
                cc.MoveBy:create(time*k,cc.p(0,-k*20)),
                --            cc.CallFunc:create(function() 
                --                MusicPlayer:playMyEffect("CHIP")
                --            end),
                cc.DelayTime:create(((time)*2)*(count-k)+1)
            ))
        end
    end
    
    local countTime = 0.0
    local delayCount = 20.0
    local function updateAction()
        local dev = countTime/delayCount
        if countTime >  delayCount*7 then
        elseif dev == 1 or dev == 5 then
            _chipsAction(first)
        elseif dev == 2 or dev == 6 then
            _chipsAction(second)
        elseif dev == 3 or dev == 7 then
            _chipsAction(third)
        end
        if countTime >= delayCount*5 + tempDelay then
            countTime = countTime >= delayCount*9+tempDelay and 0 or countTime+1 
            tempDelay = tempDelay == 0 and 0 or delay + math.random(-0.5,0.5)*delay
        else
            countTime = countTime + 1
        end 
    end
    
    node:scheduleUpdateWithPriorityLua(updateAction,0)
end

function M:_ChipsAnimation(delaytime,parent,sprite,count,time,x,y)
    local chips = {}
    for i=1,count do
        local _chips = cc.Sprite:create(sprite)
        _chips:setAnchorPoint(0.5,0)
        _chips:setPosition(x,y+i*_chips:getContentSize().height*0.2)
        parent:addChild(_chips,10)
        chips[i] = _chips
    end
    
    return chips
    
end

---发牌通用动画
--@param c1 真正的牌
--@param c2 发的牌
--@param value 发的牌的值,如果不传就没有翻牌动画，有的话就有翻牌动画
--@param parent 牌的父节点
--@param dpoint 牌出来的位置
--@param delay 延时
--
function M:giveCardsAnimation(paras)
    if paras == nil then return end
    local c1,c2,parent,dpoint,value = paras.c1,paras.c2,paras.parent,paras.dpoint,paras.value
    local first = paras.first
    local action,z,delay,atime = paras.action,paras.z,paras.delay,paras.atime
    local scale,position,anchor = c1:getScale(),c1:getPosition(),c1:getAnchorPoint()
    -- logd("发牌--->scale"..scale.."  positionX-->"..c1:getPositionX())
    if c1 == nil or parent == nil or c2 == nil or dpoint == nil then return end
    dpoint = parent:convertToNodeSpace(dpoint)
    
    c2:setPosition(dpoint)
    c2:setScale(scale)
    c2:setLocalZOrder(10)
    c2:setVisible(false)
    atime = atime or 0.5
    action = action or cc.Sequence:create(
        cc.DelayTime:create(delay or 0),
        cc.CallFunc:create(function() 
            MusicPlayer:playMyEffect("FAPAI")
            c2:setVisible(true)
        end),
        cc.EaseOut:create(
            cc.MoveTo:create(atime,cc.p(first:getPositionX(),first:getPositionY())),2
            ),
        cc.DelayTime:create(0.3),
        cc.MoveTo:create(atime,cc.p(c1:getPositionX(),c1:getPositionY())),
        cc.CallFunc:create(function ( sender )
            c2:setLocalZOrder(z or 0)
            c2.value = value
            if value then sender:reverseSelf(nil,value)  end
        end)
    )
    
    c2:runAction(action)
end



--[[
分享图片 , 分享成功后 ， 看需要发送cmd是63给服务器，作为分享奖励
Util:sharePic(function ( ret )
    if ret == 0 then --成功
    elseif ret == 1 then 出错
    elseif ret == 2 then 用户取消
    end
    print(" --- share pic ret ---- "..ret)
end)
]]
function M:sharePic(cb)
    local filename = "textas_snap_"..os.time()..".jpg"
    --local title = 
    local function afterCaptured(succeed, outputFile)  -- outputFile 完整路径
        if succeed then
            qf.platform:sharePic({file=outputFile,cb=cb})
        else
            cclog("Capture screen failed.")
        end
    end
    cc.utils:captureScreen(afterCaptured, filename)
    

end


---[[
--通过输入两个点求两点组成的直线与X轴正半轴之间的角度
--@p1 为原点
--@p2 为处于的点
--]]
function M:getAngle(p1,p2)
    -- logd("两点坐标x1-->"..p1.x.."y1-->"..p1.y.."x2-->"..p2.x.."y2-->"..p2.y)
    if p1.y == p2.y then
        if p1.x <= p2.x then
            return 0
        else
            return 180
        end
    end
    if p1.x == p2.x then
        if p1.y > p2.y then
            return 90
        else
            return 270
        end
    end
    local dis = math.ceil(self:getLong(p1,p2))
    local dy = p1.y - p2.y
    local dx = p2.x - p1.x
    
    local angle = math.atan2(dy,dx)*180/math.pi
    
    return angle
end 
---[[
--通过输入两个点求两点之间的距离
--@p1 为中心点
--@p2 为处于的点
--]]
function M:getLong(p1,p2)
    local dx,dy = p1.x - p2.x,p1.y - p2.y
    local long = math.sqrt(dx*dx+dy*dy) 
    return long
end

function M:showBeautyAction(node,eyeTime)
    if node == nil then return end
    local beauty = node
    local mouse = beauty:getChildByName("mouse")
    local eye = beauty:getChildByName("eye")
    local mouse_animation = beauty:getChildByName("mouse_animation")
    local function _beautyAction(node,time,visibleTime,once,cb)
        if node == nil then return end
        node:setVisible(false)
        local temp = time
        node:runAction(cc.RepeatForever:create(
            cc.Sequence:create(
                cc.CallFunc:create(function() 
                    temp = time + math.random(1,3)
                end),
                cc.DelayTime:create(temp),
                cc.CallFunc:create(function() 
                    node:setVisible(true)
                    if cb then cb() end
                end),
                cc.DelayTime:create(visibleTime),
                cc.CallFunc:create(function() 
                    node:setVisible(false)
                end),
                cc.DelayTime:create(visibleTime),
                cc.CallFunc:create(function() 
                    if once ~= true and temp%2 ~= 1 then
                        node:setVisible(true)
                    end
                end),
                cc.DelayTime:create(visibleTime*0.5),
                cc.CallFunc:create(function() 
                    node:setVisible(false)
                end)
        )))
    end
    _beautyAction(mouse,60,0.4,true,function()
        if mouse_animation == nil then return end 
        mouse_animation:setScale(0)
        mouse_animation:setOpacity(255)
        local tempP = cc.p(mouse_animation:getPositionX(),mouse_animation:getPositionY())
        mouse_animation:runAction(
            cc.Sequence:create(
                cc.CallFunc:create(function() 
                    mouse_animation:setVisible(true)
                end),
                cc.Spawn:create(
                    cc.ScaleTo:create(2,1.5),
                    --cc.MoveBy:create(2,cc.p(50,100)),
                     cc.FadeTo:create(2,0)
                ),
                cc.CallFunc:create(function() 
                    mouse_animation:setVisible(false)
                    mouse_animation:setPosition(tempP)
                end)
            )
        )
    end)
    _beautyAction(eye,eyeTime or 6,0.1,false)

end

function M:getOpenIDAndToken() 
    local openid = cc.UserDefault:getInstance():getStringForKey(SKEY.OPEN_ID,"null");
    local token  = cc.UserDefault:getInstance():getStringForKey(SKEY.TOKEN,"null");
    local ttt = cc.UserDefault:getInstance():getStringForKey(SKEY.LOGIN_TYPE, VAR_LOGIN_TYPE_NO_LOGIN);

    if(openid == "null") then
        return {openid=nil,token=nil}
    else
        local openid2 = ""
        for i=1,#openid do
            openid2 = openid2 .. string.char(string.byte(openid,i)-(i%2==0 and 5 or - 5))
        end
        return {openid=openid2,token=token,type=ttt}
    end
end

function M:setOpenIDAndToken(openid,token,type) 
    
    local _openid = ""
    for i=1,#openid do
        _openid = _openid .. string.char(string.byte(openid,i)+(i%2==0 and 5 or - 5))
    end
    
    cc.UserDefault:getInstance():setStringForKey(SKEY.OPEN_ID,_openid);
    cc.UserDefault:getInstance():setStringForKey(SKEY.TOKEN,token);
    cc.UserDefault:getInstance():setStringForKey(SKEY.LOGIN_TYPE,type.."");
    cc.UserDefault:getInstance():flush();
end

function M:getQufanLoginInfo() 
    local openid = cc.UserDefault:getInstance():getStringForKey(SKEY.OPEN_ID,"null");
    local token  = cc.UserDefault:getInstance():getStringForKey(SKEY.TOKEN,"null");
    local ttt = cc.UserDefault:getInstance():getStringForKey(SKEY.LOGIN_TYPE, VAR_LOGIN_TYPE_NO_LOGIN);
    local code = cc.UserDefault:getInstance():getStringForKey(SKEY.VERIFY_CODE,"null");

    if(openid == "null") then
        return {openid=nil,token=nil}
    else
        local openid2 = ""
        for i=1,#openid do
            openid2 = openid2 .. string.char(string.byte(openid,i)-(i%2==0 and 5 or - 5))
        end
        return {openid=openid2,token=token,type=ttt,code=code}
    end
end

function M:setQufanLoginInfo(openid,token,type,code) 
    
    local _openid = ""
    for i=1,#openid do
        _openid = _openid .. string.char(string.byte(openid,i)+(i%2==0 and 5 or - 5))
    end
    
    cc.UserDefault:getInstance():setStringForKey(SKEY.OPEN_ID,_openid);
    cc.UserDefault:getInstance():setStringForKey(SKEY.TOKEN,token);
    cc.UserDefault:getInstance():setStringForKey(SKEY.LOGIN_TYPE,type.."");
    cc.UserDefault:getInstance():setStringForKey(SKEY.VERIFY_CODE,code or "");
    cc.UserDefault:getInstance():flush();
end

function M:getMiGuToken()

    local token  = cc.UserDefault:getInstance():getStringForKey(SKEY.MIGU_TOKEN,"");
    if token == "" then
        token = tostring(math.random(2000000000))
        cc.UserDefault:getInstance():setStringForKey(SKEY.MIGU_TOKEN,token)
        cc.UserDefault:getInstance():flush()
    end
    
    return token
end

function M:fix2point(v)
    local strv = string.format("%.2f", v)
    return tonumber(strv)
end



function M:binary2int(arg)
    local   nr=0
    for i=1,32 do
        if arg[i] ==1 then
        nr=nr+self.data32[i]
        end
    end
    return  nr
end

function M:int2binary(arg)
    arg = arg >= 0 and arg or (0xFFFFFFFF + arg + 1)
    local   tr={}
    for i=1,32 do
        if arg >= self.data32[i] then
            tr[i]=1
            arg=arg-self.data32[i]
        else
            tr[i]=0
        end
    end
    return   tr
end

function M:binaryAnd(a,b)
    local   op1=self:int2binary(a)
    local   op2=self:int2binary(b)
    local   r={}
    
    for i=1,32 do
        if op1[i]==1 and op2[i]==1  then
            r[i]=1
        else
            r[i]=0
        end
    end
    return  self:binary2int(r)
end

function M:getIntPart(x)
	if x <= 0 then
	   return math.ceil(x);
	end

	if math.ceil(x) == x then
	   x = math.ceil(x);
	else
	   x = math.ceil(x) - 1;
	end
	return x;
end

--获取牌文件名
function M:getCardFileName( value )
    if value == nil then return nil end
    local _ctable = {"r","h","m","f"}
    local i,t = math.modf(value/4)

    i = i + 1
    if i == 14 then i = 1 end

    local c = math.fmod(value,4)
    local ret = nil

    if i < 10 then ret = "poker_".._ctable[(c+1)].."0"..i
    else ret= "poker_".._ctable[(c+1)]..i
    end
    return GameRes[ret]
end

--获取牌的描述.
function M:getCardDescription(value)
    if value == nil then return nil end
    local _ctable = {"红桃","黑桃","梅花","方块"}
    local i,t = math.modf(value/4)

    i = i + 1
    if i == 14 then i = 1 end

    local c = math.fmod(value,4)
    local cardtype = _ctable[(c+1)]
    local cardvalue = ""
    if i == 1 then
        cardvalue = "A"
    elseif i <= 10 then
        cardvalue = tostring(i)
    elseif i == 11 then
        cardvalue = "J"
    elseif i == 12 then
        cardvalue = "Q"
    elseif i == 13 then
        cardvalue = "K"
    end
    return cardtype..cardvalue
end

function M:getFriendRemark(uin,nick,hiding)
    -- 没有好友关系了。所以备注没用了
    if nick then
        return nick, false
    else
        return "", false
    end
end

function M:isAllSpaceStr(str) -- 是否全是空格的字符串
   local haveNotSpaceChar=false
    for var=1, string.len(str)  do
       
       if 32~=string.byte(str, 1) then
           haveNotSpaceChar=true
           break
       end  
  end
     
    if haveNotSpaceChar==true then
       return false
       else
        return true
    end
end


function M:getHidingStatusFromNick(nick) -- 是否全是空格的字符串
   local isHiding=false
    local i, j = string.find(nick, "神秘人")
    if  i and  j then
        isHiding=true
    end

    return isHiding
end


function M:getMySubStr(str,from,to)--按个数截取中英混合字符
     
    logd("from.."..from)
    logd("to.."..to)
    local lenInByte = #str
    logd(" str..".. str)
     logd(" lenInByte..".. lenInByte)
    
    local cur_index=0
    local f_index=0
    local t_index=0 
      local i = 1
      for j=1,lenInByte+1 do
        if i <= lenInByte then
            logd("i.."..i)
            local curByte = string.byte(str, i)
            if curByte>0 and curByte<=127 then
                byteCount = 1
            elseif curByte>=192 and curByte<223 then
                byteCount = 2
            elseif curByte>=224 and curByte<239 then
                byteCount = 3
            elseif curByte>=240 and curByte<=247 then
                byteCount = 4
            end
            logd("curByte.."..curByte)
            logd("byteCount.."..byteCount)
            local char = string.sub(str, 1, 3)
            logd("char.."..char)
            cur_index=cur_index+1
            logd("cur_index:"..cur_index)
            if cur_index==from then
                f_index=i
                logd("f_index.."..f_index)
            end 
            i = i + byteCount
            if  cur_index==to then
                t_index=i-1
                logd("t_index.."..t_index)
            end
        else
            break
        end
    end
   if  f_index>0 and t_index>0 then
    logd("new_str")
      local new_str= string.sub(str, f_index, t_index)
      logd("new_str.."..new_str)
      if new_str then
        return new_str
      end
   end
  return  str
end 


function M:getMySplitStr(str,num)--按个数分割中英混合字符成若干字符 下标从 1开始
    local str_arr={}
    local from=1
    local to=num
    local lenInByte = #str
    local cur_index=0
    local f_index=0
    local t_index=0 
      local i = 1
      for j=1,lenInByte+1 do
        if i <= lenInByte then
            local curByte = string.byte(str, i)
            if curByte>0 and curByte<=127 then
                byteCount = 1
            elseif curByte>=192 and curByte<223 then
                byteCount = 2
            elseif curByte>=224 and curByte<239 then
                byteCount = 3
            elseif curByte>=240 and curByte<=247 then
                byteCount = 4
            end
            cur_index=cur_index+1
            if cur_index==from then
                f_index=i
            end 
            i = i + byteCount
            if  cur_index==to then
                t_index=i-1
            end
            if  f_index>0 and t_index>0 then
              local new_str= string.sub(str, f_index, t_index)
              if new_str then
                table.insert(str_arr,#str_arr+1,new_str)
                loge("new_str"..new_str)
              end
              f_index=0
              t_index=0
              from=to+1
              to=from+num-1
            end
        else
            break
        end
    end
   if f_index>0 and t_index==0 then
     local new_str= string.sub(str, f_index, lenInByte)
     loge("new_str"..new_str)
     if new_str then
        table.insert(str_arr,#str_arr+1,new_str)
     end
   end
  return  str_arr
end

function M:getMySplitStrWithLength(str,len,fontSize)--按长度分割中英混合字符成若干字符 下标从 1开始
     
      local str_arr={}
      local total_len=0
      local lenInByte = #str
      local f_index=1
      local t_index=1 
      local i = 1
      for j=1,lenInByte+1 do
        if i <= lenInByte then
            local curByte = string.byte(str, i)
            if curByte>0 and curByte<=127 then
                byteCount = 1
            elseif curByte>=192 and curByte<223 then
                byteCount = 2
            elseif curByte>=224 and curByte<239 then
                byteCount = 3
            elseif curByte>=240 and curByte<=247 then
                byteCount = 4
            end
            local char = string.sub(str, i, i+byteCount-1)
            local contentLabel = cc.LabelTTF:create(char, GameRes.font1, fontSize)
            local one_length=contentLabel:getContentSize().width
            total_len=total_len+one_length 
            if total_len>len then
                t_index=i-1 
                if  f_index>0 and t_index>0 and t_index>=f_index then
                  local new_str= string.sub(str, f_index, t_index)
                  if new_str then
                    table.insert(str_arr,#str_arr+1,new_str)
                  end
                  f_index=t_index+1
               end   
               total_len=one_length
            end
            i=i+byteCount

        else
            break
        end
    end
   if f_index>0  then
     local new_str= string.sub(str, f_index, lenInByte)
     if new_str then
        table.insert(str_arr,#str_arr+1,new_str)
     end
   end
  return  str_arr
end

--将时间戳转化为时间描述字符串, 2015-12-20 11:25
function M:getTimeDescription(timestamp)
    local date = os.date("*t", timestamp)
    local month = string.format("%02d", date.month)
    local day = string.format("%02d", date.day)
    local hour = string.format("%02d", date.hour)
    local min = string.format("%02d", date.min)
    local time_str = date.year .. "-" .. month .. "-" .. day .. " " .. hour .. ":" ..min
    return time_str
end

function M:getDateDescription(timestamp)
    local date = os.date("*t", timestamp)
    local month = string.format("%02d", date.month)
    local day = string.format("%02d", date.day)
    local time_str = date.year .. "-" .. month .. "-" .. day
    return time_str
end

--将时间戳转化为时间描述字符串, 11:25
function M:getDigitalTime(timestamp)
    local date = os.date("*t", timestamp)
    local hour = string.format("%02d", date.hour)
    local min = string.format("%02d", date.min)
    local time_str = hour .. ":" ..min
    return time_str
end

function M:getDigitalTime2(timestamp)
    local date = os.date("*t", timestamp)
    local hour = string.format("%02d", date.hour)
    local min = string.format("%02d", date.min)
    local sec = string.format("%02d", date.sec)
    local time_str = hour .. ":" ..min .. ":" .. sec
    return time_str
end

function M:getCanUseRemark() --判断有没有修改备注的权限
   return false
end

function M:getChatServerSig( ... )
    local sign = "9IX1(Q*FpM&y^=aECkSjP@lqB4_sfn69"
    local uin = Cache.user.uin or ""
    return QNative:shareInstance():md5(uin .. sign)
end

function M:getWebDesKey( ... )
    return "uXJApKsb"
end

-- des加密参数
function M:encryptString(paras)
    if tonumber(GAME_VERSION_CODE) < 472 then
        return paras
    end
    return string.urlencode(qf.platform:getDesEncryptString({plaintTxt = "" .. paras, key= self:getWebDesKey()}))
end

-- des解密参数
function M:getDesDecryptString(paras)
    if not paras then return nil end
    if tonumber(GAME_VERSION_CODE) < 472 then
        return paras
    end
    return qf.platform:getDesDecryptString({plaintTxt = paras, key= self:getWebDesKey()})
end

--[[
        local OPTIONAL_VAL = 1    --数值(optional int32,string...)
        local OPTIONAL_MSG = 2    --结构(optional message)
        local REPEATED_VAL = 3    --数值数组(repeated int32,string...)
        local REPEATED_MSG = 4    --结构数组(repeated message)
    ]]
function M:getDataType(m)
    if type(m) == "table" then
        if m[1] ~= nil then
            if type(m[1]) == "table" then
                return REPEATED_MSG
            else
                return REPEATED_VAL
            end
        else
            return OPTIONAL_MSG
        end
    else
        return OPTIONAL_VAL
    end
end

-- des解密server_alloc
function M:getDesDecryptStringFromServerAllocRsp(response)
    -- 大于472版本才解密，主要兼容
    if tonumber(GAME_VERSION_CODE) < 472 then
        return response
    end
    -- origin 
    local function _pack(_m,_t)
        for k, v in pairs(_t) do
            local data_type = self:getDataType(v)
            if data_type == OPTIONAL_MSG then
                if _m[k] == nil then
                    _m[k] = {}
                end
                _pack(_m[k], v)
            elseif data_type == REPEATED_MSG then
                for key, value in pairs(v) do
                    _m[k] = {}
                    _pack(_m[k], value)
                end
            elseif data_type == OPTIONAL_VAL then
                _m[k] = self:getDesDecryptString(v)
            elseif data_type == REPEATED_VAL then
                for key, value in pairs(v) do
                    if _m[k] == nil then
                        _m[k] = {}
                    end
                    _m[k][key] = self:getDesDecryptString(value)
                end
            end
        end
    end

    local finalTable = {}
    _pack(finalTable,response)
    return finalTable
end

function M:getRequestConfigURL( ... )
    local info = qf.platform:getRegInfo()
    local MD5_FILE = "md5.txt" --原始md5列表配置文件
    local MD5_FILE_EX = QNative:shareInstance():getUpdatePath().."/md5.txt" --更新md5列表配置文件
    local content
    if not io.exists(MD5_FILE_EX) then
        content = cc.FileUtils:getInstance():getDataFromFile(MD5_FILE)
    else
        content = cc.FileUtils:getInstance():getDataFromFile(MD5_FILE_EX)
    end
    local md5 = QNative:shareInstance():md5(content)  

    local version = tonumber(info.version or 0)
    local device_id = info.device_id
    device_id = string.urlencode(device_id)

    local channel = GAME_CHANNEL_NAME or "CN_MAIN"
    local lang = GAME_LANG
    if qf.platform:isDebugEnv() == true or string.find(channel, "CN") then
        HOST_NAME = HOST_CN_NAME 
    elseif string.find(channel, "HW") then
        HOST_NAME = HOST_HW_NAME
        lang = "hw"
    else
        HOST_NAME = HOST_CN_NAME
    end

    local domainName = Cache.Config:getDomainName()
    if domainName ~= "" then
        HOST_NAME = domainName
    end
    RESOURCE_HOST_NAME = HOST_NAME
    local urlFormat = HOST_PREFIX.."%s/router/server_allocate?uin=%s&os=%s&pkg_name=%s&channel=%s&version=%d&md5=%s&lang=%s" -- 服务器路径
    local url = string.format(urlFormat, HOST_NAME, self:encryptString(device_id), string.upper(info.os), self:encryptString(GAME_PAKAGENAME), self:encryptString(GAME_CHANNEL_NAME), version, md5, lang)
    local originUrl = string.format(urlFormat, HOST_NAME, device_id, string.upper(info.os), GAME_PAKAGENAME, GAME_CHANNEL_NAME, version, md5, lang)
    if self:checkAGGameEnable() then
        urlFormat = HOST_PREFIX.."%s/router/server_allocate?uin=%s&os=%s&pkg_name=%s&channel=%s&version=%d&md5=%s&lang=%s&sub_version=%s" -- 服务器路径
        url = string.format(urlFormat, HOST_NAME, self:encryptString(device_id), string.upper(info.os), self:encryptString(GAME_PAKAGENAME), self:encryptString(GAME_CHANNEL_NAME), version, md5, lang, self:encryptString(self:getResourceVersionCode()))
        originUrl = string.format(urlFormat, HOST_NAME, device_id, string.upper(info.os), GAME_PAKAGENAME, GAME_CHANNEL_NAME, version, md5, lang, self:getResourceVersionCode())
    end
    loga("【Util】 origin url = " .. originUrl)
    return url
end

function M:getResourceVersionCode( ... )
    local currentResourceCode = cc.UserDefault:getInstance():getStringForKey("current-version-codezd", "")
    if currentResourceCode == "" then
        return 0
    end
    return tonumber(currentResourceCode)
end

--由于服务器对请求severloc 进行了对应的限制 对同一个ip的请求 
--在1秒内只进行一次响应, 超过次数将不进行响应. 如果存在 多个地方同时进行这个http请求的情况下
--将使用这次请求的第一次结果直接作为1秒内所有请求通知的结果
function M:safeRequestConfigURL(req, sfunc)
    -- body
    -- 这个函数是作为一个安全请求URL的函数
    -- 就意味着这个函数要控制open 与 send 并且还要对他设置的回调进行相对应的处理
    -- 现在的问题在于如何将一个现成的request获得回调后的处理传给这个正在准备请求的一个关系
    -- 还有一个问题就在于这个请求函数超时了如何通知正在等待的序列呢？
    -- 1.来一个请求 如果当前没有正在请求的request 就将这个请求open && send
    --              如果当前有正在请求的request   就将这个请求放入一个队列中
    --     当request 请求超时的情况下 不需要通知了 自己会做处理的
    --     当request 请求成功的情况下 要告诉这个队列所请求到的值是多少
    if self._safeRequestTbl == nil then
        self._safeRequestTbl = {}
    end

    if self._isRequesting == nil then
        self._isRequesting = false
    end

    if self._cacheRequest ~= nil then
        req.status = self._cacheRequest.status
        req.response = self._cacheRequest.response
        sfunc()
        return
    end

    --等待队列数目为0 或者当前没有正在请求
    if #self._safeRequestTbl == 0 and self._isRequesting == false then
        self._isRequesting = true
        local resetFunc = function ( ... )
            self._isRequesting = false
            self._safeRequestTbl = {}            
        end

        --可以根据这个特性如果当前这个请求超时后， 那么可以认为后续队列里面的请求都将超时
        local scheduler = Util:runOnce(req.timeout, function ( ... )
            resetFunc()
        end)


        local cb = function ( ... )
            --当前没有缓存的情况下 且又收到了成功的返回状态码 这个时候要存到本地缓存中 因为当下载完成后 
            --模块会进行重新require 缓存就会被清空 这个时候需要本地缓存来处理这种情况
            if self._cacheRequest == nil and req.status == 200 then
                cc.UserDefault:getInstance():setStringForKey("RESPONSE", req.response)
            end


            --缓存请求的资源因为可能请求立马会被返回成功，后面的请求不能立即请求，
            --这就导致了必须要使用缓存来处理这种情况，1秒钟之后就要清空然后再请求
            self._cacheRequest = {
                response = req.response,
                status = req.status
            }

            Util:runOnce(1.5, function ( ... )
                self._cacheRequest = nil
            end)


            if req.status == 200 then

            end


            Util:stopRun(scheduler)
            if type(sfunc) == "function" then
                sfunc()
            end


            for i, v in ipairs(self._safeRequestTbl) do
                print(v.req)
                print(tolua.isnull(v.req))
                if v.req ~= nil and tolua.isnull(v.req) == true then
                    v.req.response = req.response
                    v.req.status = req.status
                    if type(v.sfunc) == "function" then
                        v.sfunc()
                    end
                end
            end
            resetFunc()
        end

        print("请求server loc！！！！", socket.gettime())
        req:registerScriptHandler(cb)
        req:open("GET", Util:getRequestConfigURL())
        req:send()
    else
        self._safeRequestTbl[#self._safeRequestTbl + 1] = {req = req, sfunc = sfunc}
    end
end

--超时三次以上才使用备用的json 作为domainname
function M:getBackUpJson()
    local backupJsonUrl = "http://cdn-backup-file.tech111111.com/media/domain.json"
    self.handler_http_backup_req = cc.XMLHttpRequest:new()
    self.handler_http_backup_req.timeout = 5
    self.handler_scheduler = Util:runOnce(self.handler_http_backup_req.timeout, function( ... )
        if self.handler_http_backup_req then
            self.handler_http_backup_req:abort()
            self.handler_http_backup_req = nil
        end
    end)

    self.handler_http_backup_req:registerScriptHandler(function(event)
        Util:stopRun(self.handler_scheduler)
        self.handler_scheduler = nil
        if self.handler_http_backup_req and tolua.isnull(self.handler_http_backup_req) == false and self.handler_http_backup_req.status == 200 then 
            local response = self.handler_http_backup_req.response
            local backupConfigList = json.decode(response)
            loga(">>>>>>server_allocate has change<<<<<<<" .. backupConfigList.name)
            Cache.Config:setDomainName(backupConfigList.name)
        end
    end)

    response_type = cc.XMLHTTPREQUEST_RESPONSE_JSON
    self.handler_http_backup_req.responseType = response_type
    self.handler_http_backup_req:open("GET", backupJsonUrl)
    self.handler_http_backup_req:send()
end

-- 获取验证码和切换验证码配置
function M:getSMSCodeConfig(paras)
    local info = qf.platform:getRegInfo()
    local postDataFormat = "uin=%s&phone_number=%s&channel=%s&version=%d&nation_code=%s&sms_type=%s&send_type=%s" -- 服务器路径
    local send_type = paras.send_type or 0
    --send_type 为 1 表示 校验手机号是否存在与已经注册了
    local postData = string.format(postDataFormat, info.device_id, paras.phone, info.channel, info.version, paras.nation_code, paras.cmdcode,send_type)

    print("====>>>>getSMSCodeConfig<<<<======" .. postData)
    self.handler_http_smscode_req = cc.XMLHttpRequest:new()
    self.handler_http_smscode_req.timeout = 10
    self.handler_SMS_scheduler = Util:runOnce(self.handler_http_smscode_req.timeout, function( ... )
        if self.handler_http_smscode_req then
            self.handler_http_smscode_req:abort()
            self.handler_http_smscode_req = nil
            --接口超时也回调报错
            if paras.callback then
                paras.callback({ret = -1, msg = GameTxt.get_verification_code_failed})
            end
        end
    end)

    self.handler_http_smscode_req:registerScriptHandler(function(event)
        Util:stopRun(self.handler_SMS_scheduler)
        self.handler_SMS_scheduler = nil
        if self.handler_http_smscode_req and tolua.isnull(self.handler_http_smscode_req) == false and self.handler_http_smscode_req.status == 200 then 
            local response = self.handler_http_smscode_req.response
            local responseJson = json.decode(response)
            --切换到Mob短信
            if responseJson.ret == 1 then
                -- qf.platform:getSmsVerificationCode({zone=tostring(paras.nation_code), phone=paras.phone, cb=function(success, message)
                --     if not success then
                --         if paras.callback then
                --             paras.callback({ret = -1, msg = message})
                --         end
                --     else
                --         if paras.callback then
                --             paras.callback({ret = 0, msg = GameTxt.get_verification_code_success_no_phone})
                --         end
                --     end
                -- end})
            --切换到宁波世骆
            else
                if paras.callback then
                    paras.callback(responseJson)
                end
            end
        else
            if paras.callback then
                paras.callback({ret = -1, msg = GameTxt.get_verification_code_failed})
            end
        end
    end)

    response_type = cc.XMLHTTPREQUEST_RESPONSE_JSON
    self.handler_http_smscode_req.responseType = response_type
    self.handler_http_smscode_req:open("POST", Cache.Config:getWebHost() .. "/get_sms_code")
    self.handler_http_smscode_req:send(postData)
end

function M:getResetPWDURL( ... )
    return Cache.Config:getWebHost() .. "/reset_password"
end

function M:getChatLayout(chatPop,content,fontSize,dis_x,dis_y) 
    dis_x=dis_x or  0  
    dis_y=dis_y or  0  
    local posx=0
    if  dis_x>0 then posx=math.abs(dis_x) end
    local layout = ccui.Layout:create() 
    layout:setAnchorPoint(0.0,0.5)
    layout:setClippingEnabled(true) 
    layout:setSize(CCSizeMake(chatPop:getContentSize().width-math.abs(dis_x) , chatPop:getContentSize().height*0.7))
    layout:setPosition(ccp(posx+5, chatPop:getContentSize().height/2+dis_y)) 
    --local arr_str=Util:getMySplitStr(content,11)
    local arr_str=Util:getMySplitStrWithLength(content,layout:getContentSize().width,fontSize)
    local pre_lb=nil
    local _contentLabels={}
    for k,v in pairs(arr_str) do
        local pos_y  = layout:getContentSize().height/2
        if pre_lb then pos_y=pre_lb:getPositionY()-layout:getContentSize().height end
        local contentLabel = cc.LabelTTF:create(v, GameRes.font1, fontSize)
        contentLabel:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
        contentLabel:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
        contentLabel:setAnchorPoint(0.0,0.5)
        contentLabel:setPosition(0,pos_y)
        layout:addChild(contentLabel) 
        table.insert(_contentLabels,#_contentLabels+1,contentLabel)
        pre_lb=contentLabel
    end
    chatPop:addChild(layout)
    local num=#_contentLabels
    for i=1,num-1 do
        for k,v in pairs(_contentLabels) do
          Util:delayRun(1.0*i,function ( )
            if not  tolua.isnull(v) then v:runAction(cc.MoveBy:create(0.2, cc.p(0,layout:getContentSize().height))) end
           end)
         end
     end 
     return layout,num
end

function M:getChatLayoutEx(chatPop,content,fontSize,dis_x,dis_y) 

    local temp = cc.LabelTTF:create(content,GameRes.font1,fontSize)
    --temp:setSystemFontName(GameRes.font1);  
    --temp:setSystemFontSize(fontSize)
    --temp:setString(content)
    local  line_height=temp:getContentSize().height 
    logd("line_height:"..line_height)

    local layout = ccui.Layout:create() 
    layout:setAnchorPoint(0.5,0.5)
    layout:setClippingEnabled(true) 
    layout:setSize(cc.size(chatPop:getContentSize().width-math.abs(dis_x) , line_height))
    layout:setPosition(ccp(chatPop:getContentSize().width/2+dis_x/2, chatPop:getContentSize().height/2+dis_y)) 

    local  line_width= layout:getContentSize().width-30
    local contentLabel = cc.LabelTTF:create(content,GameRes.font1,fontSize,cc.size(line_width,0))
    --contentLabel:setDimensions(CCSizeMake(0,line_width))
    --contentLabel:setSystemFontName(GameRes.font1);  
    --contentLabel:setSystemFontSize(fontSize)
    --contentLabel:setString(content)
    --contentLabel:setWidth(line_width);  
    --contentLabel:setLineBreakWithoutSpace(true);
    --contentLabel:setMaxLineWidth(line_width);
    contentLabel:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    contentLabel:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_TOP)
    contentLabel:setAnchorPoint(0.5,1.0)
    contentLabel:setPosition(layout:getContentSize().width/2,layout:getContentSize().height)

    layout:addChild(contentLabel)

    chatPop:addChild(layout)
    
    local  height=contentLabel:getContentSize().height   logd("height:"..height)
    local  line=math.ceil(height/line_height)  logd("line:"..line)
    for i=1,line-1 do
    Util:delayRun(1.0*(i),function( )
    if not tolua.isnull(contentLabel)   then 
       contentLabel:stopAllActions()
       contentLabel:runAction(cc.MoveBy:create(0.2,cc.p(0,line_height)))
    end
    end)
    end
    return layout,line
end

function M:getPayMethodRes( method_temp )
    --支付方式动态加载
    if method_temp == PAYMETHOD_APPSTORE then                                                   
        return GameRes.pay_item_as, GameRes.pay_item_as_0, GameRes.pay_item_img_as, GameTxt.string_pay_method_as
    elseif method_temp == PAYMETHOD_DUANXIN_YD or method_temp == PAYMETHOD_DUANXIN_LT or 
    method_temp == PAYMETHOD_DUANXIN_DX_AIYOUXI or method_temp == PAYMETHOD_DUANXIN_DX_TIANYI  then
        --短信
    elseif method_temp == PAYMETHOD_ZHIFUBAO or method_temp == PAYMETHOD_SOUSUO then
        return GameRes.pay_item_zfb, GameRes.pay_item_zfb_0, GameRes.pay_item_img_zfb, GameTxt.string_pay_method_zfb
    elseif method_temp == PAYMETHOD_WINXIN then
        return GameRes.pay_item_wx, GameRes.pay_item_wx_0, GameRes.pay_item_img_wx, GameTxt.string_pay_method_wx
    elseif method_temp == PAYMETHOD_BANK then
        return GameRes.pay_item_yl, GameRes.pay_item_yl_0, GameRes.pay_item_img_yl, GameTxt.string_pay_method_yl
    elseif method_temp == PAYMETHOD_QQ then
        
    elseif method_temp == PAYMETHOD_HAIMA2 then
        
    elseif method_temp == PAYMETHOD_KUPAI2 then
        
    end
    return GameRes.pay_item_wx, GameRes.pay_item_wx_0, GameRes.pay_item_img_wx, GameTxt.string_pay_method_wx
end

--获取url对应的图片。如果已经下载下来，则返回文件名。否则返回nil
function M:getFilePathByUrl(url)
    if url == nil or string.len(url) == 0 then 
        return
    end
    local path = qf.downloader:getFilePathByUrl(url)
    if io.exists(path) then
        return path
    end
end

function M:judgeIsBankruptcy()
    local pick_times = Cache.Config:getBankruptcyFetchCount() or 0
    local gold = clone(Cache.user.gold)

    if Cache.DeskAssemble:judgeGameType(JDC_MATCHE_TYPE) then
        local userData = Cache.desk:getUserByUin(Cache.user.uin)
        --如果断线重连特殊情况，玩家正在游戏中则不显示跳动金币（破产）
        if (Cache.desk.status == GameStatus.GAME_STATE_INGAME) and userData then 
            return false 
        end
        
        local myChips = userData and userData.chips or 0
        gold = gold + myChips
    end 

    if pick_times >= Cache.Config.bankrupt_count or gold >= 200 then
        return false
    else
        return true
    end
end

--随机获取格言.
function M:getRandomMotto(motto_list)
    local list = motto_list or GameTxt.gameLoaddingTips001
    math.randomseed(tostring(os.time()):reverse():sub(1, 6))
    local motto = list[math.random(#list)] or ""
    return motto
end

--获取随机位置开始的一组格言
function M:getCycleMotto(motto_list)
    local list = motto_list or GameTxt.gameLoaddingTips001
    local cycle_motto = {}
    math.randomseed(tostring(os.time()):reverse():sub(1, 6))
    local index = math.random(#list)
    for i = index, #list do
        table.insert(cycle_motto, list[i])
    end
    for i = 1, index - 1 do
        table.insert(cycle_motto, list[i])
    end
    return cycle_motto
end

--从服务端获取赛事图片
function M:updateMTTIcon(node, url)
    if url ==nil or string.len(url) == 0 then return end
    local downloadTaskID = qf.downloader:execute(url, 30,
        function (path)
            if not io.exists(path) then return end  --图片不存在则不加载. fix_bug_79
            -- Util:convertToJpg(path) --将头像转存为jpg格式(为解决用户上传png头像, 透明露出默认头像问题)
            local _sp= cc.Sprite:create(path)
            if not _sp then
                logd("Sprite:create fail. path: " .. path)
                return
            end
            local fileTexture = _sp:getTexture()

            -- cocos底层不够健壮，如果texture为null导致崩溃
            if not fileTexture then
                loge("getTexture fail. path: " .. path)
                return
            end 

            if not node or tolua.isnull(node) then -- 如果在拉取图片的时候此node被移除
                return 
            end
            node:loadTexture(path)
            downloadTaskID = nil
        end
        , function ()
            if not node or tolua.isnull(node) then -- 如果在拉取图片的时候此node被移除
                return 
            end
        end
        , function ()
            if not node or tolua.isnull(node) then -- 如果在拉取图片的时候此node被移除
                return 
            end
        end
    )
    node:registerScriptHandler(function(eventname)
        if eventname == "exit" then -- 还没有执行此任务的时候，node被移除
            qf.downloader:removeTask(downloadTaskID)
            downloadTaskID = nil
        end
    end)
    return downloadTaskID
end

function M:getFormatBlindTime(time)
    local time_str = ""
    local m = math.floor(time/60)
    local s = time%60
    if m > 0 then
        if s > 0 then
            time_str = m..GameTxt.mtt_lobby_string_10..s..GameTxt.mtt_lobby_string_11
        else
            time_str = m..GameTxt.mtt_lobby_string_26
        end
    else
        time_str = s..GameTxt.mtt_lobby_string_11
    end
    return time_str
end

function M:getMTTRewardContent(reward)
    local str = ""
    if reward.gold and reward.gold > 0 then
        str = Util:getFormatString(reward.gold)..GameTxt.global_string113
    elseif reward.float_ratio ~= "" and tonumber(reward.float_ratio) > 0 then
        str = GameTxt.mtt_lobby_string_22.."x"..reward.float_ratio.."%"
    end
    if reward.score and reward.score > 0 then
        if str ~= "" then str = str.."、" end
        str = str..reward.score..GameTxt.mtt_lobby_string_12
    end
    if reward.coupon_id and reward.coupon_id > 0 then
        if str ~= "" then str = str.."、" end
        str = str..reward.coupon_name
    end
    if reward.ticket_id and reward.ticket_id > 0 then
        if str ~= "" then str = str.."、" end
        str = str..reward.ticket_name
    end
    return str
end

-- 确认c是否在ab或者ba区间内
function M:checkRange(a,b,c)
    if a >= c and c >= b then
        return true
    elseif b >= c and c >= a then
        return true
    end
    return false
end


local saAsc = string.byte("a")
local szAsc = string.byte("z")
local baAsc = string.byte("A")
local bzAsc = string.byte("Z")
local nineAsc = string.byte("0")
local zeroAsc = string.byte("9")
--确认字符是否数字
function M:checkIsDigit(c)
    return Util:checkRange(zeroAsc, nineAsc, c)
end

--确认字符是否字母
function M:checkIsLetter(c)
    if Util:checkRange(szAsc, saAsc, c) or Util:checkRange(bzAsc, baAsc, c) then
        return true    
    end
    return false
end

--确认字符串中只有数字和字符(与密码输入相关)
function M:checkOnlyDigitAndLetter(str)
    local len = string.len(str)
    local ascV;
    for i = 1, len do
        ascV = string.byte(str, i)
        if Util:checkIsLetter(ascV) or Util:checkIsDigit(ascV) then
        else
            return false
        end
    end
    return true
end

--确认字符串中只有数字(与密码输入相关)
function M:checkOnlyDigit(str)
    local len = string.len(str)
    local ascV;
    for i = 1, len do
        ascV = string.byte(str, i)
        if Util:checkIsDigit(ascV) then
        else
            return false
        end
    end
    return true
end

-- 涉及设置登录密码地方过多 暂时统一起来写在一个函数里面
function M:passWordLimitFunc1(pwd, affirmPwd)
    --1.密码长度限制
    --2.确认是否由字母或数字组成
    if not Util:checkRange(GameConstants.LIMIT_MIN_LEN, GameConstants.LIMIT_MAX_LEN, string.len(pwd)) 
    or not Util:checkOnlyDigitAndLetter(pwd)                                                       
    then
        local txt = string.format(GameTxt.PASSWORDERRORTIP2, GameConstants.LIMIT_MIN_LEN, GameConstants.LIMIT_MAX_LEN)
        qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = txt})
        return true
    end

    --两次密码不一致
    if affirmPwd then
        if pwd ~= affirmPwd then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.PASSWORDERRORTIP1})
            return true
        end
    end
end

-- 暂时将验证码限制为4位数字
function M:pinLimitFunc1(pin)
    if pin and type(pin) == "string" and string.len(pin) == GameConstants.PIN_LEN and Util:checkOnlyDigit(pin) then
        return false
    end
    qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.pin_txt_1})
    return true
end

-- 暂时将安全密码限制为6位数字  
function M:payLimitFunc1(pay)
    if pay and type(pay) == "string" and string.len(pay) == GameConstants.PAY_LEN and Util:checkOnlyDigit(pay) then
        return false
    end
    qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.pin_txt_2})
    return true
end



--iphoneX  适配设置位置函数
function M:adaptIphoneXPos(node, xpos)
    local wSize = cc.Director:getInstance():getWinSize()
    xpos = xpos or (wSize.width-GameConstants.IX_WINSIZE.width)/2
    if FULLSCREENADAPTIVE then
        node:setPositionX(xpos)
    end
end

function M:setMargin(node, paras)
    local margin = node:getLayoutParameter():getMargin()
    for k, v in pairs(paras) do
        margin[k] = v
    end
    node:getLayoutParameter():setMargin(margin)
end

function M:setPosOffset(node, offset)
    local x, y = node:getPosition()
    local ox = offset.x or 0 
    local oy = offset.y or 0
    node:setPosition(cc.p(x + ox, y + oy))
end

function M:getChildEx(root, name)
    if type(name) == "string" then
        local list = Split(name, "/")
        for i, v in ipairs(list) do
            --fix bug
            --[[
                seekWidgetByName 可能找到的是不符合次序的ui 所以优先按照有次序的去查找
            ]]--
            local _root = root:getChildByName(v)
            if _root then
                root = _root
            else
                root = ccui.Helper:seekWidgetByName(root, v)
            end
            if root == nil then
                print(string.format("%s could not find!!!", name))
                return root
            end
        end
        return root
    elseif type(name) == "number" then
        return ccui.Helper:seekWidgetByTag(root, name)
    end
end

function M:bindUI(self, root, childTable)
    for _, v in ipairs(childTable) do
        local node = Util:getChildEx(root, v.path)
        if node then
            if v.name then
                node.name = v.name
                self[v.name] = node
            end
            if v.handler then
                if node.setEnabled then
                    node:setEnabled(true)
                end
                if node.setTouchEnabled then
                    node:setTouchEnabled(true)
                end
                if node.getScale then
                    node.scale = node:getScale()
                end
                if type(v.handler) == "function" then
                    addButtonEvent(node, v.handler)
                elseif type(v.handler) == "table" then
                   local list = v.handler
                   addButtonEvent(node, list[1], list[2], list[3], list[4])
                end
            end
            if v.paras then
                node.paras = v.paras
            end
        end
    end
end

function M:bindEventTbl(eventTbl)
    for i, v in ipairs(eventTbl) do
        local eventName, cb = v[1], v[2]
        qf.event:addEvent(eventName, cb)
    end
end

function M:saveImage(node, fileName, scale)
    local s1 = cc.Director:getInstance():getWinSize()
    local s = node:getContentSize()
    scale = scale or 0.5
    node:setVisible(true)
    node:setScale(scale)
    node:setAnchorPoint(cc.p(0,0))
    node:setPosition(cc.p(0,0))
    local jpg = fileName
    local target = cc.RenderTexture:create(s.width*scale, s.height*scale, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
    target:retain()
    target:setPosition(cc.p(s1.width*scale / 2, s1.height*scale / 2))
    target:begin()
    node:visit()
    target:endToLua()
    target:saveToFile(jpg, cc.IMAGE_FORMAT_JPEG, false) -- JPG不支持RGBA，传3参数，第3个参数必须为false
    target:release()
    node:setVisible(false)
end

--向上查找节点所有的直系父节点
function  M:searchUpNode(node, func)
    func = func or function ( ... )
        print("node name: ", node:getName())
        print("node type: ", tolua.type(node))
        print("node zorder: ", node:getLocalZOrder())
        print("node visible: ", node:isVisible())
    end
    while true do
        if node and tolua.isnull(node) == false then
            func(node)
            node = node:getParent()
        else
            break
        end
    end
end

--深度搜索并且打印当前节点的所有子孙节点的名称
function M:lookUpNode(node, callback)
    callback = callback or function (str, nodename, v)
        print(str, nodename, tolua.type(v))
    end

    local _lookup
    _lookup = function (_node, n)
        local str = ""
        for i = 1, n do
            str = str .. "\t"
        end
        for i, v in ipairs(_node:getChildren()) do
            local nodeName = v:getName() or "unknown name"
            callback(str, nodeName, v)
            -- print(str, nodeName, tolua.type(v))
            _lookup(v, n+1)
        end
    end
    if node and tolua.isnull(node) == false then
        _lookup(node, 0)
    end
end


function M:setNodeAndChildrenVisible(node, bvis)
    local callback = function (str, nodename, v)
        v:setVisible(bvis)
    end
    Util:lookUpNode(node, callback)
end


function M:addButtonListEventEx(bntlist,efunc,bfunc,mfunc,cfunc)
    for i, node in ipairs(bntlist) do
        if node.setEnabled then
            node:setEnabled(true)
        end
        if node.setTouchEnabled then
            node:setTouchEnabled(true)
        end
        addButtonEvent(node,efunc,bfunc,mfunc,cfunc)
    end
end

--按照k个字符为1个汉字的规则 至多maxLen个字符 来截取当前的字符串
function M:getSubStringEx(str, k, maxLen)
    local wList = string.utf8List(str)
    local curLen = 0
    local retStr = ""
    for i, v in ipairs(wList) do
        if #v == 1 then
            curLen = curLen + 1
        else
            curLen = curLen + k
        end
        if curLen > maxLen then
            break
        else
            retStr = retStr .. v
        end
    end
    return retStr
end


--根据产品需求 最多显示10个字符 1个汉字两个字符 最多10个字符
function M:showUserName(name)
    --玩家名字统一限制

    local _name = Util:getSubStringEx(name, 2, 10)
    return _name
end


local function setSpriteGray(node,flag, matrixStr)
    local vr = node:getVirtualRenderer()
    local nodeType = tolua.type(node)
    local matrixStr = "CC_PMatrix"
    --TextBMFont 这个控件需要采用MVPMatrix来进行转化位置
    if nodeType == "ccui.TextBMFont" then
        matrixStr = "CC_MVPMatrix"
    end
    local vert_glPosition_str = string.format("gl_Position = %s * a_position; \n", matrixStr)
    -- 默认vert
    local vertShaderByteArray = "\n"..  
        "attribute vec4 a_position; \n" ..  
        "attribute vec2 a_texCoord; \n" ..  
        "attribute vec4 a_color; \n"..  
        "#ifdef GL_ES  \n"..  
        "varying lowp vec4 v_fragmentColor;\n"..  
        "varying mediump vec2 v_texCoord;\n"..  
        "#else                      \n" ..  
        "varying vec4 v_fragmentColor; \n" ..  
        "varying vec2 v_texCoord;  \n"..  
        "#endif    \n"..  
        "void main() \n"..  
        "{\n" ..  
        vert_glPosition_str ..
        "v_fragmentColor = a_color;\n"..  
        "v_texCoord = a_texCoord;\n"..  
        "}"  

    -- 置灰frag
    local flagShaderByteArray = "#ifdef GL_ES \n" ..  
        "precision mediump float; \n" ..  
        "#endif \n" ..  
        "varying vec4 v_fragmentColor; \n" ..  
        "varying vec2 v_texCoord; \n" ..  
        "void main(void) \n" ..  
        "{ \n" ..  
        "vec4 c = texture2D(CC_Texture0, v_texCoord); \n" ..  
        "gl_FragColor.xyz = vec3(0.4*c.r + 0.4*c.g +0.4*c.b); \n"..  
        "gl_FragColor.w = c.w; \n"..  
        "}"  

    -- 移除置灰frag  
    local pszRemoveGrayShader = "#ifdef GL_ES \n" ..  
        "precision mediump float; \n" ..  
        "#endif \n" ..  
        "varying vec4 v_fragmentColor; \n" ..  
        "varying vec2 v_texCoord; \n" ..  
        "void main(void) \n" ..  
        "{ \n" ..  
        "gl_FragColor = texture2D(CC_Texture0, v_texCoord); \n" ..  
        "}" 
    if flag then 
        local glProgram = cc.GLProgram:createWithByteArrays(vertShaderByteArray,flagShaderByteArray)  
        glProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION,cc.VERTEX_ATTRIB_POSITION)  
        glProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR,cc.VERTEX_ATTRIB_COLOR)  
        glProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD,cc.VERTEX_ATTRIB_FLAG_TEX_COORDS)  
        glProgram:link()  
        glProgram:updateUniforms()  
        vr:setGLProgram(glProgram)  
    else 
        local glProgram = cc.GLProgram:createWithByteArrays(vertShaderByteArray,pszRemoveGrayShader)  
        glProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION,cc.VERTEX_ATTRIB_POSITION)  
        glProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR,cc.VERTEX_ATTRIB_COLOR)  
        glProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD,cc.VERTEX_ATTRIB_FLAG_TEX_COORDS)  
        glProgram:link()  
        glProgram:updateUniforms()  
        vr:setGLProgram(glProgram) 
    end 
end

function M:ensureBtn( btn , enable )
    btn:setTouchEnabled( enable )

    setSpriteGray(btn, not enable)
    local children = btn:getChildren()
    for name,child in pairs( children ) do
        setSpriteGray(child, not enable)
    end
end

function M:setSpriteGray(btn, bFrag)
    setSpriteGray(btn, bFrag)
end

--检查是否是系统庄家
function M:checkSysZhuangUin(uin)
    -- 0到10000都是系统庄
    if checkint(uin) > 0 and checkint(uin) < 10000 then
        return true
    end
    return false
end

--过滤特殊字符
function M:filterSpecChars(s)
    local ss = {}
    local k = 1
    while true do
        if k > #s then break end
        local c = string.byte(s,k)
        if not c then break end
        if c<192 then
            if (c>=48 and c<=57) or (c>= 65 and c<=90) or (c>=97 and c<=122) then
                table.insert(ss, string.char(c))
            end
            k = k + 1
        elseif c<224 then
            k = k + 2
        elseif c<240 then
            if c>=228 and c<=233 then
                local c1 = string.byte(s,k+1)
                local c2 = string.byte(s,k+2)
                if c1 and c2 then
                    local a1,a2,a3,a4 = 128,191,128,191
                    if c == 228 then a1 = 184
                    elseif c == 233 then a2,a4 = 190,c1 ~= 190 and 191 or 165
                    end
                    if c1>=a1 and c1<=a2 and c2>=a3 and c2<=a4 then
                        table.insert(ss, string.char(c,c1,c2))
                    end
                end
            end
            k = k + 3
        elseif c<248 then
            k = k + 4
        elseif c<252 then
            k = k + 5
        elseif c<254 then
            k = k + 6
        end
    end
    return table.concat(ss)
end

--获取代理id
function M:getInviteCode( ... )
    local content = qf.platform:getProxyId()
    if content == "" or not content then return 0 end
    if not string.find(content, "proxy_id=") then return 0 end
    local result = string.split(content,"=")
    if #result == 2 then
        local id = result[2]
        if id ~= "" and id then
            qf.platform:print_log(">>>>>>>>>>getInviteCode<<<<<<<<<<" .. id)
            return tonumber(id)
        end
    end
    return 0
end

function M:enlargeCloseBtnClickArea(btn)
    self:enlargeBtnClickArea(btn, 2)
end

--btn必须先绑定事件 如果不绑定那么这个btn就无绑定事件
--注意事项: 扩大点击区域之后，如果原按钮又重新绑定了新的事件 请再调用这句话
--如果不调用 点击的按钮所产生的事件将会是原来的点击功能
function M:enlargeBtnClickArea(btn, scale)
    -- body
    local name = "largeAreaBtn"
    if btn:getChildByName(name) then
        btn:removeChildByName(name)
    end

    local tmpBtn = btn:clone()    
    local csize = tmpBtn:getContentSize()
    tmpBtn:setPosition(cc.p(csize.width/2, csize.height/2))
    tmpBtn:setAnchorPoint(cc.p(0.5, 0.5))
    btn:addChild(tmpBtn, 10)
    scale = scale or 2
    tmpBtn.name = btn.name
    if(type(scale) == "table") then
        tmpBtn:setScaleX(scale.x)
        tmpBtn:setScaleY(scale.y)
    else
        tmpBtn:setScale(scale)
    end

    tmpBtn:setOpacity(0)
    tmpBtn:setName(name)
end

function M:checkNodeExist(node)
    if node and tolua.isnull(node) == false then
        return true
    end
    return false
end

local animctrlInst = nil
function M:addChipSelectAni(sender)
    local config = require("src.common.HallAnimationConfig")
    local tempNode = cc.Node:create()
    local chipArm = self:playAnimation({anim = config.CHIPANI, node = tempNode, position = cc.p(0,0), forever = true}, animctrlInst)
    local size = sender:getContentSize()   
    tempNode:setPosition(cc.p(size.width/2, size.height/2))
    tempNode:setScale(1.0)
    sender:addChild(tempNode)
    tempNode:setName("selectAni")
    tempNode:setVisible(false)
end

function M:addAnimationToSender(sender, paras, animctrl)
    if paras.position == nil then
        local size = sender:getContentSize()
        paras.position = cc.p(size.width/2, size.height/2)
    end

    local face = self:playAnimation(paras, animctrl)
    if paras.showSender == nil then
        sender:setOpacity(0)
        sender:setCascadeOpacityEnabled(false)
    end
    return face
end

function M:playAnimation(paras, ctrl)
    if ctrl == nil then
        self:createAnimInst()
        ctrl = animctrlInst
    end
    local face = ctrl:play(paras)
    return face
end

function M:createAnimInst()
    if animctrlInst == nil then
        animctrlInst = require("src.common.Gameanimation").new()
    end
end

function M:loadAnim(config, bLoad, ctrl)
    self:createAnimInst()
    ctrl = ctrl or animctrlInst
    if bLoad then
        ctrl:preloadAnim(config)
    else
        ctrl:unloadAnim(config)
    end
end


--由于电脑上使用的是2436 这个长度进行的适配
--对于不同型号上的长度 一个具体的数字 应该返回一个适当变化的长度来进行适配
local adaptRate
local winWidth
function M:adaptScreenNumber(number)
    if adaptRate then
        return adaptRate * number
    end
    winWidth = cc.Director:getInstance():getWinSize().width
    adaptRate = winWidth / 2436
    return adaptRate * number 
end


--由于editbox 使用过于频繁 
function M:createEditBox(frame, argsTbl)
    if argsTbl == nil or frame == nil or tolua.isnull(frame) == true then
        return
    end
    
    local tag = argsTbl.tag or -987654 -----  这个虚拟editbox tag 一定要设置成这个数字 因为cocos2dx 底层 CCEditBoxImplIOS有改动  读取这个值。
    local offset = argsTbl.offset or {x =0, y= 0}
    local fontcolor = argsTbl.fontcolor or cc.c3b(30, 74, 130)
    local fontname = argsTbl.fontname or GameRes.font1
    local name = argsTbl.name or "editbox"
    local posOffset = argsTbl.posOffset or {x =0, y= 0}
    local fontsize = argsTbl.fontsize or 42
    local placeFontsize = argsTbl.placefontsize or 42
    local placeTxt = argsTbl.placeTxt or ""
    local placeHolderColor = argsTbl.holdColor or cc.c3b(204, 204, 204)
    local retType = argsTbl.retType or cc.KEYBOARD_RETURNTYPE_DONE
    local handler = argsTbl.handler
    local iMode = argsTbl.iMode
    local csize = argsTbl.iSize
    local iFlag = argsTbl.iFlag
    local maxlength = argsTbl.maxLen
    local editbox
    if csize then
        editbox = cc.EditBox:create(csize, cc.Scale9Sprite:create())
    else
        editbox = cc.EditBox:create(cc.size(frame:getContentSize().width + offset.x, frame:getContentSize().height + offset.y), cc.Scale9Sprite:create())
    end

    editbox:setTag(tag)  
    editbox:setFontColor(fontcolor)
    editbox:setFontName(fontname)

    editbox:setName(name)
    -- editbox:setCascadeOpacityEnabled(true)
    editbox:setFontSize(fontsize)
    
    editbox:setPlaceholderFontSize(placeFontsize)
    editbox:setPlaceHolder(placeTxt)
    editbox:setPlaceholderFontColor(placeHolderColor)

    editbox:setPosition(frame:getContentSize().width * 0.5 + posOffset.x, frame:getContentSize().height * 0.5 + posOffset.y)
    editbox:setReturnType(retType)
    if maxlength then
        editbox:setMaxLength(maxlength)
    end
    if handler then
        editbox:registerScriptEditBoxHandler(handler)
    end

    if iMode then
        editbox:setInputMode(iMode)
    end

    if iFlag then
        editbox:setInputFlag(iFlag)
    end

    if not argsTbl.bAlone then
        frame:addChild(editbox)
    end
    
    return editbox
end

--将创建的layer重置到正中心
function M:setLayerToCenter(layer)
    local winSize = cc.Director:getInstance():getWinSize() 
    local designWidth = winSize.width
    local _x = layer:getPositionX()
    local __x = _x + designWidth/2 - 1920/2
    layer:setPositionX(__x)
end

function M:createRichText(paras)
    local lbl_content = ccui.RichText:create()
    if type(paras.bIgnore) == "boolean" then
        lbl_content:ignoreContentAdaptWithSize(paras.bIgnore)
    else
        lbl_content:ignoreContentAdaptWithSize(false)
    end

    if paras.size then
        lbl_content:setContentSize(paras.size)
    end

    if paras.aPoint then
       lbl_content:setAnchorPoint(paras.aPoint)
    end

    if paras.vspace then
        lbl_content:setVerticalSpace(paras.vspace)
    end
    return lbl_content
end

function M:createRedHint(paras)
    print("create HotUpdateMain:initLoadding")
    local sender = paras.sender
    if sender == nil or tolua.isnull(sender) == true then
        return
    end

    local res = GameRes.red_point_image
    local spr = cc.Sprite:create(res)
    spr:setName("redHint")
    local pos = paras.position or cc.p(0, 0)
    spr:setPosition3D(pos)
    paras.sender:addChild(spr)
    spr:setVisible(false)
    return spr
end

function M:removeCdnUrl(url)
    local infos = string.split(url, "//cdn-")
    --确保cdn- 只替换一次 如果有多个cdn-字符串 就按照以前的url使用
    if #infos == 2 then
        return infos[1] .. "//" .. infos[2]
    end
    return url
end

function M:isValidPhone(phone)
    if phone and checknumber(phone) > 0  then
        return string.len(phone .. "") > 0 
    end
    return false
end

function M:downloadImg(imgUrl, node, cnt, maxCnt)
    --进行次数限制 最大次数为maxCnt
    cnt = cnt or 0
    cnt = cnt + 1
    if cnt > maxCnt then
        return
    end
    qf.downloader:execute(imgUrl, 10,
        function(path)
            if tolua.isnull(node) == false then
                node:loadTexture(path)
            end
        end,
        function()
            self:downloadImg(imgUrl, node, cnt, maxCnt)
        end,
        function()
            -- print("img >>>>>>>>>>>>>> timeout!!!")
            self:downloadImg(imgUrl, node, cnt, maxCnt)
        end
    )
end

function M:initPhoneCodeDropList(sbtn, itemsize, parent, callback)
    local codeConfigTbl = Cache.Config:getPhoneCodeConfig()
    if self.descZoneTbl == nil then
        local tbl = {}
        for i = 1, #codeConfigTbl do
            tbl[#tbl + 1] = {cty = codeConfigTbl[i].CNName, code = "+" .. codeConfigTbl[i].PhoneCode}
        end
        self.descZoneTbl = tbl
    end

    local _descTbl = self.descZoneTbl
    itemsize.height = 70

    local dx = 8
    local selectColor = cc.c3b(53, 136, 214)
    local unSelectColor = cc.c3b(255, 249, 242)
    local cardlist

    local setSelectItemFunc = function (item, bSelected)
        local title = item:getChildByName("title")
        local subTitle = item:getChildByName("subTitle")
        if bSelected then
            title:setColor(cc.c3b(255,255,255))
            subTitle:setColor(cc.c3b(255,255,255))
        else
            title:setColor(cc.c3b(93,151,217))
            subTitle:setColor(cc.c3b(93,151,217))
        end
    end

    local addFunc = function (i, cardlist)
        local item = cardlist:getItemByIndex(i)

        local t1 = ccui.Text:create(self.descZoneTbl[i].cty, GameRes.font1, 36)
        t1:setName("title")
        t1:setColor(cc.c3b(93,151,217))
        t1:setAnchorPoint(cc.p(0,0.5))
        t1:setPosition(cc.p(20,105 - itemsize.height))
        item:addChild(t1)

        local t2 = ccui.Text:create(self.descZoneTbl[i].code, GameRes.font1, 36)
        t2:setName("subTitle")
        t2:setColor(cc.c3b(93,151,217))
        t2:setAnchorPoint(cc.p(1,0.5))
        t2:setPosition(cc.p(itemsize.width-20,105 - itemsize.height))
        item:addChild(t2)

        if cardlist:getSelectIndex() == i then
            setSelectItemFunc(item, true)
        end

        addButtonEvent(item,function (sender)
            sbtn:getChildByName("num"):setString(_descTbl[i].code)
            setSelectItemFunc(item, true)
            local preSelectItem = cardlist:getItemByIndex(cardlist:getPreSelectIndex())
            setSelectItemFunc(preSelectItem, false)
            cardlist:setVisible(false)
            cardlist:setCursor(i)
            if callback then
                local code = _descTbl[i].code
                zonecode = string.sub(code, 2, #code)
                callback(i, _descTbl, zonecode)
            end
        end)
    end
    local paras = {
        noline = true,
        maskPos = true,
        capInsect = true,
        maxDisplay = 5,
        addLen = 10,
        addFunc = addFunc
    }
    local pageIndex = 1
    local pageCnt = 6
    local pageMax = math.ceil(#_descTbl / pageCnt)

    local firstShowCnt = #_descTbl > pageCnt and pageCnt or pageCnt
    cardlist = CommonWidget.ComboList.new(#_descTbl, firstShowCnt, itemsize, GameRes.new_image_item_normal, GameRes.new_image_item_select, paras)
    parent:addChild(cardlist)
    cardlist:setAutoHide()

    sbtn:setEnabled(true)
    sbtn:setTouchEnabled(true)
    addButtonEvent(sbtn, function ( ... )
        cardlist:setVisible(true)
    end)

    local addPageing = true
    local addPageFunc = function ()
        pageIndex = pageIndex + 1
        for i =  1, pageCnt do
            local curIdx = (pageIndex - 1) * pageCnt + i
            cardlist:addItem(GameRes.new_image_item_normal, GameRes.new_image_item_select)
            addFunc(curIdx, cardlist)
        end
        performWithDelay(cardlist, function ()
            addPageing = true
        end, 0.03)
    end

    cardlist:addInnerScrollViewEventListener(function (sender, eventType)
        if eventType == ccui.ScrollviewEventType.scrollToBottom then
            print(" eventType ScrollviewEventType XXXXX")
            if pageIndex < pageMax and addPageing then
                addPageing = false
                addPageFunc()
            end
        end
    end)
    cardlist:setLocalZOrder(8)
    cardlist:setVisible(false)
    local initIdx = 1
    callback(initIdx, _descTbl, string.sub(_descTbl[initIdx].code, 2, #_descTbl[initIdx].code))
    return cardlist
end

function M:getCObejctFunction(node)
    local mt = getmetatable(node)
    for i, v in pairs(mt) do
        print(i, v)
    end
end

function M:playBetAnimation()
end

-- 将node本地坐标系的坐标 转化为 target本地坐标系的坐标
--lpos 表示的以node锚点为坐标系原点的坐标
function M:convertALocalPosToBLocalPos(node, lpos, target)
    --得到lpos对应的世界坐标 wpos
    local wpos = self:getWorldSpacePos(node, lpos, true)
    -- 将世界坐标 wpos 转化为 以target 锚点为坐标系原点的坐标
    return self:getNodeSpcaePos(target, wpos, false)
end

--世界坐标 是相对于scene节点的坐标
function M:getWorldSpacePos(node,lpos, bAR)
    -- bAR  为 true 表示得到这个node锚点的世界坐标
    -- bAR  为 false 表示得到这个node左下角的世界坐标
    -- 当node的锚点为cc.p(0,0) 时 结果一致
    if bAR then
        return node:convertToWorldSpaceAR(lpos)
    else
        return node:convertToWorldSpace(lpos)
    end
end

-- 得到当前node锚点的世界坐标
function M:getWorldSpaceARPos(node)
    return self:getWorldSpacePos(node, cc.p(0,0), true)
end

function M:getNodeSpcaePos(node, wpos, bAR)
    --bAR 为true 是以这个node的左下角 为坐标系原点 的坐标
    --bAR 为false 是以这个node的锚点 为坐标系原点 的坐标
    --当node的锚点为cc.p(0,0) 时 结果一致
    if bAR then
        return node:convertToNodeSpaceAR(wpos)
    else
        return node:convertToNodeSpace(wpos)
    end
end

--将一段文本按照限制长度来进行限制
function M:limitStringNumber(txt, len)
    local tbl = string.split(txt, "\n")
    local vTbl = {}
    local sTbl = {}
    for _, v in ipairs(tbl) do
        local str = v
        local utfTbl = string.utf8List(str)
        local strTemp = ""
        local strlen = 0
        for i, v2 in ipairs(utfTbl) do
            --判断下汉字是2个字节、其他是1个字节
            if string.byte(v2) > 127 then
                strlen = strlen + 2
            else
                strlen = strlen + 1
            end
            sTbl[#sTbl + 1] = v2
            strTemp = strTemp .. v2
            if strlen >= len or i == #utfTbl then
                vTbl[#vTbl + 1] = strTemp
                strTemp = ""
                strlen = 0
            end
        end
    end
    return table.concat(vTbl, "\n"), vTbl, sTbl
end

--解析协议
--[[
    {attrType, attrName, attrStruct
    }
]]--

function M:resolveProto(protoTbl, model)
    local _resolveProto
    _resolveProto = function (protoTbl, model)
        local retTbl = {}
        for i, ele in ipairs(protoTbl) do
            if type(ele) ==  "table" then
                local attrName = ele[1]
                local attrType = ele[2]
                local attrStruct = ele[3]
                if attrType == "arr" then
                    local arrTbl = {}
                    for i = 1, model[attrName]:len() do
                        local arrEle = model[attrName]:get(i)
                        arrTbl[#arrTbl + 1] = _resolveProto(attrStruct, arrEle)
                    end
                    retTbl[attrName] = arrTbl
                elseif attrType == "msg" then
                    retTbl[attrName] = _resolveProto(attrStruct, arrEle)
                else
                    retTbl[attrName] = model[attrName]
                end
            elseif type(ele) == "string" then
                local attrName = ele
                retTbl[attrName] = model[attrName]
            end
        end
        return retTbl
    end
    return _resolveProto(protoTbl, model)
end

function M:saveUniqueValueByKey(key, value)
    local cmpIndex = 0
    local attrValue =  cc.UserDefault:getInstance():getStringForKey(key, "")
    if attrValue == "" then
        cc.UserDefault:getInstance():setStringForKey(key, value)
    else
        local attrVTbl = string.split(attrValue,"|")
        for i=1,#attrVTbl do
            if attrVTbl[i] == value then
                cmpIndex = i
                table.remove(attrVTbl, i)
            end
        end
        table.insert(attrVTbl, value)
        local allAttr = table.concat(attrVTbl, "|")
        cc.UserDefault:getInstance():setStringForKey(key,allAttr)
    end
    return cmpIndex
end
function M:insertValueByKeyAndIndex(key, value, insIdx)
    --先删除insIdx位置上的值
    if insIdx ~= 0 then
        local attrValue = cc.UserDefault:getInstance():getStringForKey(key, "")
        local attrVTbl = string.split(attrValue,"|")
        table.remove(attrVTbl, insIdx)
        local allAttr = table.concat(attrVTbl, "|")
        cc.UserDefault:getInstance():setStringForKey(key, allAttr)
    end

    local attrValue = cc.UserDefault:getInstance():getStringForKey(key, "")
    if attrValue == "" then
        attrValue = value
    else
        attrValue = attrValue.."|"..value
    end 
    cc.UserDefault:getInstance():setStringForKey(key, attrValue) 
end

local hongbaoBtnName = "hongbaoAni"

function M:addHongBaoBtn(sender, position)
    if sender:getChildByName(hongbaoBtnName) then
        return
    end
    local AnimationConfig = require("src.games.game_hall.modules.main.config.AnimationConfig")
    local img = ccui.ImageView:create(GameRes.agency_qq_img)
    position = position or  cc.p(0, 0)
    img:setPosition(position)
    sender:addChild(img)
    img:setLocalZOrder(1000)
    img:setName(hongbaoBtnName)
    Util:addAnimationToSender(img, {anim = AnimationConfig.HONGBAO, node = img, posOffset = {x  = 0, y= -6}, forever =true})
    img:setEnabled(true)
    img:setTouchEnabled(true)
    addButtonEvent(img, function ( ... )
        qf.event:dispatchEvent(ET.HONGBAO)
    end)
end

function M:removeHongBaoBtn(sender)
    sender:removeChildByName(hongbaoBtnName)
end

local netStrengthName = "netStrength"
function M:addNetStrengthFlag(sender, position, paras)
    if not self:checkWifiNetPackage() then
        return
    end
    if sender:getChildByName(netStrengthName) then
        
    else
        local _node = CommonWidget.NetDelayTip.new(paras)
        position = position or cc.p(0, 0)
        _node:setPosition(position)
        sender:addChild(_node)
        _node:setLocalZOrder(5)
        _node:setName(netStrengthName)
    end
    local _node = sender:getChildByName(netStrengthName)
    _node:refresh(paras)
end

--addButtonEvent 使用的button特效
function M:getButtonAnimFunc(func, anifunc)
    --点击时按钮的效果
    local bfunc = function ( ... )
        anifunc(ccui.TouchEventType.began)
    end

    local mfunc = function ( ... )
        anifunc(ccui.TouchEventType.moved)
    end

    local efunc = function ( ... )
        anifunc(ccui.TouchEventType.ended)
        func( ... )
    end

    local cfunc = function ( ... )
        anifunc(ccui.TouchEventType.canceled)
    end

    return {efunc, bfunc, mfunc, cfunc}
end

--对上面的按钮进行装饰器模式的修改
function M:getButtonScaleAnimFunc(sender, func, scale, escale, scaleFunc)
    local resolveScale = function (scale, mscale)
        local sx, sy = mscale, mscale
        -- dump(scale)
        if scale ~= nil then
            if type(scale) == "number" then
                sx, sy = scale, scale
            elseif type(scale) == "table" then
                sx, sy = scale.x, scale.y
            end
        end
        return sx, sy
    end
    local bScaleX, bScaleY = resolveScale(scale, 1.2)
    local eScaleX, eScaleY = resolveScale(escale, 1.0)

    local anifunc = function (event)
        if event == ccui.TouchEventType.began then
            sender:setScaleX(bScaleX)
            sender:setScaleY(bScaleY)
        elseif event == ccui.TouchEventType.moved then
            -- sender:setScaleX(bScaleX)
            -- sender:setScaleY(bScaleX)
        elseif event == ccui.TouchEventType.ended then
            sender:setScaleX(eScaleX)
            sender:setScaleY(eScaleY)
        elseif event == ccui.TouchEventType.canceled then
            sender:setScaleX(eScaleX)
            sender:setScaleY(eScaleY)
        end
        if scaleFunc then
            scaleFunc(event)
        end
    end

    return self:getButtonAnimFunc(func, anifunc)
end

function M:addButtonScaleAnimFunc(sender, func, scale)
    local list= self:getButtonScaleAnimFunc(sender, func, scale)
    addButtonEvent(sender, list[1], list[2], list[3], list[4])
end

--将按钮上面的文字和按钮同时进行缩放 且保留原有的缩放比例
function M:addButtonScaleAnimFuncWithDScale(sender, func, dScale, scaleChildFunc)
    if sender == nil then
        return
    end
    --最开始的缩放
    local eScale =  {x = sender:getScaleX(), y = sender:getScaleY()}
    if sender.setPressedActionEnabled then
        sender:setPressedActionEnabled(false)
    end

    local getBScale = function (eScale, mscale)
        local bScale = {x = eScale.x + 0.1, y = eScale.y + 0.1}
        if dScale ~= nil then
            if type(dScale) == "number" then
                bScale = {x = eScale.x + dScale, y = eScale.y + dScale}

            elseif type(dScale) == "table" then
                bScale = {x = eScale.x + dScale.x, y = eScale.y + dScale.y}
            end
        end

        return bScale
    end
    local bScale = getBScale(eScale, dScale)
    --点击后的缩放
    -- local dscaleTbl
    -- if scaleChildFunc == nil then
    --     local children = sender:getChildren()

    --     local scaleChildrenTbl = {
    --     } 
    --     for i, v in ipairs(children) do
    --         scaleChildrenTbl[#scaleChildrenTbl + 1] = {
    --             node = v, 
    --             sx = v:getScaleX(),
    --             sy = v:getScaleY()
    --         }
    --     end

    --     local setScaleChild = function (child, scale)
    --         if child.setScaleX then
    --             child:setScaleX(scale.x)
    --             child:setScaleY(scale.y)
    --         elseif child.setScale then
    --             if scale.x == scale.y then
    --                 child:setScale(scale.x)
    --             end
    --         end
    --     end
    --     scaleChildFunc = function (event)
    --         -- print(event)
    --         -- for i, v in ipairs(scaleChildrenTbl) do
    --         --     if event == ccui.TouchEventType.began then
    --         --         setScaleChild(v.node, getBScale({x = v.sx, y = v.sy}))
    --         --     elseif event == ccui.TouchEventType.moved then
    --         --         -- setScaleChild(v.node, {x = v.sx, y = v.sy})
    --         --     elseif event == ccui.TouchEventType.ended then
    --         --         setScaleChild(v.node, {x = v.sx, y = v.sy})
    --         --     elseif event == ccui.TouchEventType.canceled then
    --         --         setScaleChild(v.node, {x = v.sx, y = v.sy})
    --         --     end
    --         -- end
    --     end
    -- end
    local list= self:getButtonScaleAnimFunc(sender, func, bScale, eScale, scaleChildFunc)
    addButtonEvent(sender, list[1], list[2], list[3], list[4])
end

function M:addTangKuangEffect(sender)
    local config = require("src.common.HallAnimationConfig")
    performWithDelay(sender, function ( ... )
        local face = Util:addAnimationToSender(sender, {showSender = true, anim = config.TANKUANG, node = sender, posOffset = cc.p(0,-384)})
    end, 0.6)
    performWithDelay(sender, function ()
        local face = Util:addAnimationToSender(sender, {showSender = true, anim = config.TANKUANG2, node = sender, posOffset = cc.p(0,-384), forever =true})
    end, 2.6)
end

function M:checkVersionCode(versionCode)
    return tonumber(GAME_VERSION_CODE) < versionCode
end

--不能更新安卓包的版本
function M:checkNotUpdatePackage()
    return self:checkVersionCode(440)
end

function M:checkUpdatePackage()
    return not self:checkNotUpdatePackage()
end

--包含wifi 监控信息的包
function M:checkWifiNetPackage()
    return not self:checkVersionCode(460)
end

function M:checkAGGameEnable()
    return not self:checkVersionCode(470)
end

function M:initRecordPhoneDropList(dataTbl, paras)
    local selectColor = cc.c3b(255,255,255)
    local unSelectColor = cc.c3b(68, 118, 176)
    local comlist = CommonWidget.ComboList.new(5, #dataTbl, paras.size, GameRes.new_image_item_normal, GameRes.new_image_item_select, {
        selectFunc = function (paras)
            local txt1= paras.item:getChildByName("code")
            local txt2= paras.item:getChildByName("phone")
            if txt1 then
                if paras.act == "sel" then
                    txt1:setColor(selectColor)
                    txt2:setColor(selectColor)
                else
                    txt1:setColor(unSelectColor)
                    txt2:setColor(unSelectColor)
                end
            end
        end
    })

    if comlist then
        comlist:setLocalZOrder(2)
        comlist:setPosition(paras.pos)
        local callfunc = paras.callfunc
        for i = 1, #dataTbl do
            local item = comlist:getItemByIndex(i)
            local t1 = ccui.Text:create(dataTbl[i].dzone, GameRes.font1, 36)
            t1:setName("code")
            t1:setColor(cc.c3b(68, 118, 176))
            t1:setAnchorPoint(cc.p(0,0.5))
            t1:setPosition(cc.p(26, paras.size.height/2))
            item:addChild(t1)

            local t2 = ccui.Text:create(dataTbl[i].phone, GameRes.font1, 36)
            t2:setName("phone")
            t2:setColor(cc.c3b(68, 118, 176))
            t2:setAnchorPoint(cc.p(0,0.5))
            local phonePos = paras.phonePos or cc.p(175, paras.size.height/2)
            t2:setPosition(phonePos)
            item:addChild(t2)

            local curPhoneTxt = paras.curPhoneTxt
            local itemTxt = t2:getString()
            if curPhoneTxt == itemTxt then
                comlist:setCursor(i)
            end
            addButtonEvent(item,function ( ... )
                local phone = item:getChildByName("phone"):getString()
                local code = item:getChildByName("code"):getString()
                callfunc({phone = phone, code = code, idx = i})
                comlist:setCursor(i)
                comlist:setVisible(false)
            end)
        end
    end
    comlist:setName("RecordPhoneDropList")
    return comlist
end

--message 可以包含换行符号 可以限制宽度 返回包含多个text控件的tbl 已经限制了其宽度
--paras 中的maxLen 表示一行最多的字数
-- 采用二分法来获取最佳长度
function M:createMultiLineText(message, paras)
    local st = socket.gettime()
    local maxLen = paras.maxLen or 100
    local fontsize = paras.fontsize or 36
    local tbl = string.split(message, "\n")
    local textTbl = {}
    local findTheValidLetterIndex 
    findTheValidLetterIndex = function (iStart, iBegin, iEnd, textUI, sTbl)
        if iBegin > iEnd then 
            return -1
        end
        local iMiddle = math.floor((iBegin + iEnd) / 2)
        local str1 = table.concat(sTbl, "", iStart, iMiddle)
        textUI:setString(str1)
        local curWidth = textUI:getContentSize().width
        if curWidth > maxLen then --此时太大了
            return findTheValidLetterIndex(iStart, iBegin, iMiddle - 1, textUI, sTbl)
        elseif curWidth < maxLen then --此时太小了
            local idx = findTheValidLetterIndex(iStart, iMiddle + 1, iEnd, textUI, sTbl)
            if idx ~= -1 then
                return idx
            else
                return iMiddle
            end
        else
            return iMiddle --找到了
        end
    end

    for i, v in ipairs(tbl) do
        local str = v
        local sTbl = string.utf8List(str)
        textUI = ccui.Text:create("", GameRes.font1, fontsize)
        textTbl[#textTbl + 1] = textUI
        local snum = #sTbl
        local iBegin = 1
        local iEnd = snum
        for i = 1, snum do
            if iBegin > iEnd then
                break
            end
            local sEnd = findTheValidLetterIndex(iBegin, iBegin, iEnd, textUI, sTbl)
            textUI:setString(table.concat(sTbl, "", iBegin, sEnd))
            iBegin = sEnd + 1
            if iBegin <= iEnd then
                textUI = ccui.Text:create("", GameRes.font1, fontsize)
                textTbl[#textTbl + 1] = textUI
            end
        end
    end
    print("使用时间：", socket.gettime() - st)
    return textTbl
end

function M:refreshNoMoneyTip(root, paras)

    if  paras.noImgTip == true and paras.restMoney > 0 then
        if paras.showTxt then
            performWithDelay(root, function ( ... )
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = paras.showTxt})
                qf.event:dispatchEvent(ET.SHOP)
            end, 0.2)
        end
        return
    end
    local tip = root:getChildByName("noMoney_tip")
    if tip == nil or tolua.isnull(tip) == true then
        local winSize =  cc.Director:getInstance():getWinSize()
        local node = cc.Node:create()
        root:addChild(node)
        node:setName("noMoney_tip")
        local img = ccui.ImageView:create()
        img:setName("noMoney_Img")
        img:loadTexture(GameRes.no_tip_bg)
        node:addChild(img)
        local diSize = img:getContentSize()
        img:setPosition(cc.p(winSize.width/2,diSize.height/2))
        local txt  = ccui.ImageView:create()
        txt:loadTexture(GameRes.no_tip_txt)
        txt:setName("no_tip_txt")
        img:addChild(txt)
        txt:setPosition(cc.p(1000,diSize.height/2 - 70))
        local btn = ccui.Button:create()
        img:addChild(btn)
        -- img:set
        btn:setTouchEnabled(true)
        btn:loadTextures(GameRes.no_tip_recharge, GameRes.no_tip_recharge, "", 0)
        addButtonEvent(btn, function ( ... )
            qf.event:dispatchEvent(ET.SHOP)
        end)
        btn:setName("shopBtn")
        local btnSize = btn:getContentSize()
        btn:setPosition(cc.p(1200, diSize.height/2 - 70))
        local moneyTxt = cc.LabelBMFont:create("", GameRes.no_tip_number_fnt)
        img:addChild(moneyTxt)
        moneyTxt:setName("moneyTxt")
        moneyTxt:setAnchorPoint(cc.p(0, 0.5))
        moneyTxt:setPosition(880, diSize.height/2 - 70+4)
        tip = node
        node:setLocalZOrder(2)
    end
    tip:setVisible(paras.restMoney > 0)
    if paras.restMoney > 0 then
        self:getChildEx(tip, "noMoney_Img/moneyTxt"):setString(string.format("%d元", paras.restMoney))
        if paras.showTxt then
            performWithDelay(tip, function ( ... )
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = paras.showTxt})
                qf.event:dispatchEvent(ET.SHOP)
            end, 0.2)
        end
        local no_tip_txt = self:getChildEx(tip, "noMoney_Img/no_tip_txt")
        local shopBtn = self:getChildEx(tip, "noMoney_Img/shopBtn")
        local moneyTxt = self:getChildEx(tip, "noMoney_Img/moneyTxt")
        local _x = no_tip_txt:getPositionX()
        local no_tip_txt_size = no_tip_txt:getContentSize()
        local money_txt_size = moneyTxt:getContentSize()
        local shopBtn_size = shopBtn:getContentSize()
        local interval = 30
        local moneyTxtPosX = _x + no_tip_txt_size.width/2 + interval
        local shopBtnX = moneyTxtPosX + money_txt_size.width + interval + shopBtn_size.width/2
        moneyTxt:setPositionX(moneyTxtPosX)
        shopBtn:setPositionX(shopBtnX)
    end
end

function M:isHasReviewed( ... )
    return true--TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW
end

--当前炸金花有两种桌子 蓝色或者红色
--暂时根据底分来判断桌子颜色
function M:checkZJHRedDesk(baseChip)
    return baseChip > 1
end

-- function M:getZJHDeskColor(roomInfo)
--     return 
--     return roomInfo
-- end

--当前炸金花有两种桌子 蓝色或者红色
--暂时根据底分来判断桌子颜色
function M:checkNNBlueDesk(baseChip)
    return baseChip <= 1
end

function M:checkInReviewStatus( ... )
    return true
end

function M:getReviewStatus( ... )
    return not TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW
end

Util = M.new()