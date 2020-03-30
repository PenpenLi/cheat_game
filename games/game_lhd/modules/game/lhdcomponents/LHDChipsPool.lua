--押注的筹码池
local IButton = import("..components.IButton")
local UserDisplay = import("..components.user.UserDisplay")

local LHDAniConfig = import("src.games.game_lhd.modules.game.lhdcomponents.animation.LHDAnimationConfig")
local LHDChipsPool = class("LHDChipsPool",function(paras)
    return paras.node
end)

LHDChipsPool.TAG = "LHDChipsPool"

function LHDChipsPool:ctor(paras)
    self.winSize = cc.Director:getInstance():getWinSize()
    self.index = paras.index
    self.parent = paras.parent
    self:init()
    require("src.games.game_lhd.modules.game.lhdcomponents.LHDChips")
    ChipManager:init()  
end

function LHDChipsPool:init()
    self.deskCache = Cache.DeskAssemble:getCache(LHD_MATCHE_TYPE)
    --记录当前筹码池中所有的筹码 形式为一个数组
    self.chips = {}

    --记录筹码索引的table  key为筹码的值， value为一个数组 这个数组里面存的都是索引 这个索引记录当前chip在self.chips中对应的位置
    self.recordChipsIndex = {}
    self:initTxt()
    self:initChipsArea()
    self:initCards()
    self:initTouch()
    self:ready()
end

function LHDChipsPool:chipsToPool(paras)
    if paras == nil then return end
    if paras.notadd ~= true then 
        self:setChipsCount(paras.value,paras.myself) 
        if paras.odds then 
            local my_bets = self.deskCache:getMyBets()
            local _odds = (paras.odds < 1 and paras.odds > 0) and paras.odds or paras.odds+1
            local my_result_chips = _odds*my_bets[self.index]
            self:setMyselfChips(my_result_chips)
        end 
    end
    local chips = ChipManager:createT(paras.value)
    for k, chip in pairs(chips) do
        local chipsArea = self:getChipsAreas()
        local x = chipsArea:getContentSize().width*(math.random(0,1000)*0.001)
        local y = chipsArea:getContentSize().height*(math.random(0,1000)*0.001)
        local to = cc.p(self:getPositionX() + x + chipsArea:getPositionX(),self:getPositionY() + y + chipsArea:getPositionY())
        local from = self.parent:convertToNodeSpace(paras.from)
        local chip = chip
        local delay = (k - 1 ) * 0.02 >= 1 and 1 or (k - 1 ) * 0.02
        delay = delay > 0.5 and 0.5 or delay
        local callback = function()
            self.parent:addChild(chip)
            local chip2 = ChipManager:getChip(chip.value)
            chip2:setPosition(cc.p(x,y))
            chipsArea:addChild(chip2,2)
            chip2:setVisible(false)
            
            local index = #self.chips+1
            self.chips[index] = chip2
            if paras.noanimation then
                chip2:setVisible(true)
                ChipManager:putChip(chip)
                return 
            end
            if paras.myself == true then
                self.recordChipsIndex[chip.value] = self.recordChipsIndex[chip.value] or {} 
                self.recordChipsIndex[chip.value][#self.recordChipsIndex[chip.value] + 1] = index 
            end
            ChipManager:fly(0,chip,from,to,function() 
                local c = self.chips[index]
                if c ~= nil then 
                    c:setVisible(c.isBeSign ~= true) 
                    c.isBeSign = false
                end
            end)
        end
        self:delayRun(delay,callback)
    end
end

function LHDChipsPool:delayRun(time,cb)
    local action = cc.Sequence:create(
        cc.DelayTime:create(time),
        cc.CallFunc:create(function (  )
            if cb then cb() end
        end)
    )
    self:runAction(action)
end

function LHDChipsPool:getChipsNum()
    return #self.chips
end

function LHDChipsPool:chipsToUser(paras) 
    if paras == nil then return end
    --value 表示飞多少筹码 to 表示飞到哪个位置 all 表示 是否将剩余筹码全部飞到某一个位置
    local value = paras.value
    local to = paras.to

    if paras.all then
        local count = 1

        self:clearChipsCount()
        self:clearMyselfChips()

        for k,v in pairs(self.chips) do
            if v.isBeSign ~= true then
                value = value - v.value
                --飞行表现
                local chipsArea = v:getParent()
                local from = cc.p(self:getPositionX()+v:getPositionX()+chipsArea:getPositionX(),self:getPositionY()+v:getPositionY()+chipsArea:getPositionY())
                local to = self.parent:convertToNodeSpace(to)
                local chip = ChipManager:getChip(v.value)
                self.parent:addChild(chip)
                local delay = (count - 1 ) * 0.02 
                delay = delay > 0.5 and 0.5 or delay
                ChipManager:fly(delay,chip,from,to, paras.cb)

                count = count + 1
            end
            --回收筹码
            ChipManager:putChip(v)
            self.chips[k] = nil
        end
        return
    end

    if value == nil or value == 0 or to == nil then return end
    --给筹码池里面的筹码排序
    self:sortPoolChips()
    local count = 1
    for k,v in pairs(self.chips) do
        if value < ChipManager.minChip then break end
        if value >= v.value then
            self:setChipsCount(-v.value)
            value = value - v.value
            local chipsArea = v:getParent()
            local from = cc.p(self:getPositionX()+v:getPositionX()+chipsArea:getPositionX(),self:getPositionY()+v:getPositionY()+chipsArea:getPositionY())
            local to = self.parent:convertToNodeSpace(to)
            local chip = ChipManager:getChip(v.value)
            ChipManager:putChip(v)
            self.chips[k] = nil
            self.parent:addChild(chip)
            local delay = (count - 1 ) * 0.02 
            delay = delay > 0.5 and 0.5 or delay
            ChipManager:fly(delay,chip,from,to, paras.cb)
            count = count + 1
        end
    end
end

--self.chips_count 百人场下注的总数
--self.myself_count 自己下的注
function LHDChipsPool:setChipsCount(value,myself)
    if value == nil then return end

    self.chips_count = self.chips_count or 0
    self.myself_count = self.myself_count or 0

    self.chips_count = self.chips_count + value
    self:setChipsNum(self.chips_count)
    if myself == true then
        self.myself_count = self.myself_count + value
        self:setMyselfChips(self.myself_count)
    end
    self.deskCache._all_chips[self.index] = self.chips_count --百人场下注的总数
    self.deskCache._my_chips[self.index] = self.myself_count--自己下的注
end

--按价值分割筹码池中的所有筹码
function LHDChipsPool:splitPool(value)
    for k,v in pairs(self.chips) do
        if value < ChipManager.minChip then break end
        if value >= v.value and not ChipManager:getChipDivision(v) then
            value = value - v.value
            ChipManager:setChipDivision(v,true)
        end
    end

    --剩余筹码数没有找到匹配的筹码，将大一号的筹码分割
    if value >= ChipManager.minChip then
        local splite_value = 0
        for i=#self.chips,1,-1 do
            if self.chips[i].value > value and not ChipManager:getChipDivision(self.chips[i]) then
                splite_value = self.chips[i].value
                break
            end
        end

        --loge("分割筹码:"..splite_value)
        --分割筹码成功，继续分发筹码
        if splite_value > 0 and self:splitPoolChip(splite_value) then
            --分割筹码后给筹码池里面的筹码排序
            self:sortPoolChips()
            self:splitPool(value)
        end
    end
end

function LHDChipsPool:clearAllChips()
    self:clearChipsCount()
    if self.chips == nil or #self.chips == 0 then self.chips = {} return end
    for k , v in pairs(self.chips) do
        v:removeFromParent(true)
    end
    self.chips = {}
end

--将下注区域的大筹码切割成小筹码
function LHDChipsPool:splitPoolChip(value)
    local count = 0
    if value >= 1000 and value <= 10000000 then
        count = 10
    elseif value == 100 then
        count = 2
    end
    if count == 0 then return false end
    for i,v in pairs(self.chips) do
        if value == v.value then
            for j=1,count do
                local chipsArea = v:getParent()
                local pos = cc.p(v:getPositionX() + math.random(-20,20), v:getPositionY() + math.random(-20,20))
                local chip2 = ChipManager:getChip(value/count)
                chip2:setPosition(pos)
                chipsArea:addChild(chip2,2)
                chip2:setVisible(true)
                self.chips[#self.chips+1] = chip2
            end
            ChipManager:putChip(v)
            self.chips[i] = nil
            return true
        end
    end
    return false
end

--给筹码池里面的筹码排序
function LHDChipsPool:sortPoolChips()
    local tem_tab = {}
    for k,v in pairs(self.chips) do
        tem_tab[#tem_tab + 1] = v
    end
    table.sort(tem_tab, function (a,b)
        return a.value > b.value
    end)
    self.chips = tem_tab
end

--此方法可能在做过客户端限制后 可能不会调用了
function LHDChipsPool:chipsFallBack(value)
    if not self.recordChipsIndex then return end

    if not self.recordChipsIndex[value] then return end    
    if #self.recordChipsIndex[value] == 0 then return end
    
    local index = self.recordChipsIndex[value][#self.recordChipsIndex[value]]
    self.recordChipsIndex[value][#self.recordChipsIndex[value]] = nil

    if index == nil then return end
    local chip = self.chips[index]
    if chip == nil then return end
    self:setChipsCount(-chip.value,true)
    --isBeSign 表示的是 这个筹码 是不是由客户端导致下注多了的筹码  又将这个筹码撤除了的
    chip.isBeSign = true
    chip:setVisible(false)
end

function LHDChipsPool:initTouch()
    self.frame = self:getChildByName("frame")
    self.frame:setVisible(false)
end

function LHDChipsPool:betAction( ... )
    local user = self.deskCache:getUserByUin(Cache.user.uin)
    if not user then return end
    self.frame:setVisible(true)
    self.frame:runAction(cc.Sequence:create(
        cc.FadeIn:create(0.05),
        cc.DelayTime:create(0.1),
        cc.FadeOut:create(0.05),
        cc.CallFunc:create(function (sender)
            sender:setVisible(false)
        end)
    ))
    local user = self.deskCache:getUserByUin(Cache.user.uin)
    local cacheChips = user.chips
    local cacheLimitChips =  self.deskCache._limit_chips
    if not cacheLimitChips then return end

    --客户端自己下注做动画表现的时候 没有经过服务端校验 容易造成下多了超过自己承载极限的筹码量 所以做一个客户端对应缓存
    --来解决这个bug 
    if self.deskCache:getUpdateByFollowFlag() then
        cacheChips = user.chips
        cacheLimitChips =  self.deskCache._limit_chips
        self.deskCache:setUpdateByFollowFlag(false)
        -- print("update cacheChips", cacheChips)
    else
        if self.lastChips == nil then
            cacheChips = user.chips
            cacheLimitChips =  self.deskCache._limit_chips
        else
            cacheChips = self.lastChips
            cacheLimitChips = self.lastLimitChips    
        end
    end
    local leastGold = Cache.lhdDesk.min_bet_carry
    if leastGold > cacheChips then
        if not Cache.packetInfo:isShangjiaBao() then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = string.format(LHD_Games_txt.LEASTTIP, Util:getFormatString(Cache.packetInfo:getProMoney(leastGold)), Cache.packetInfo:getShowUnit())})
            qf.event:dispatchEvent(ET.SHOP)
        else
            qf.event:dispatchEvent(ET.NO_GOLD_TO_RECHARGE, {tipTxt = string.format(Util:getReviewStatus() and GameTxt.string_room_limit_5 or GameTxt.string_room_limit_4, Util:getFormatString(Cache.packetInfo:getProMoney(leastGold)), Cache.packetInfo:getShowUnit()), confirmCallBack = function ( ... )
                -- 发送退桌
                if Util:getReviewStatus() then
                    qf.event:dispatchEvent(ET.SHOP)
                else
                    qf.event:dispatchEvent(LHD_ET.GAME_LHD_EXIT_EVENT, {guidetochat = true})
                end
            end})
        end
        return
    end
    
    local _limit_chips = cacheLimitChips[self.index]        --当前筹码区内 最大能够放入的筹码
    local _all_chips = self.deskCache._all_chips[self.index]--当前筹码区内 已经有的筹码
    local _add_chips = self.deskCache._add_chooice          --当前选中的筹码

    -- print("index >>>>>>>>", self.index)
    -- print("_limit_chips >>>>>>>>", _limit_chips)
    -- print("_all_chips >>>>>>>>", _all_chips)
    -- print("_add_chips >>>>>>>>", _add_chips)    
    -- print("是否超过了限制的筹码", ((_add_chips / GameConstants.RATE) + _all_chips) > _limit_chips)
    if _limit_chips and _all_chips and ((Cache.packetInfo:getProMoney(_add_chips)) + _all_chips) > _limit_chips then
        if Cache.packetInfo:getProMoney(_add_chips) > ChipManager.minChip and _all_chips - _limit_chips >= ChipManager.minChip then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = LHD_Games_txt.lhd_bet_error3})
        else
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = LHD_Games_txt["lhd_bet_error2_"..self.index]})
        end
    else
        local user = self.deskCache:getUserByUin(Cache.user.uin)

        -- print("当前缓存的筹码为", cacheChips)
        -- print("用户当前的选中筹码为", _add_chips)

        if cacheChips < _add_chips then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.lhd_bet_error1})
            return
        end

        --为客户端做暂时的缓存 自己下注这里完全是客户端的逻辑
        self.lastChips = cacheChips - _add_chips
        
        if self.lastLimitChips == nil then
            self.lastLimitChips = clone(self.deskCache._limit_chips)
        end

        -- self.lastLimitChips[self.index] = _limit_chips -- - _add_chips/GameConstants.RATE

        qf.event:dispatchEvent(LHD_ET.NET_FOLLOW_REQ,{value = _add_chips, index = self.index})
    end
end

--初始化当前筹码池的四个文本
function LHDChipsPool:initTxt()
    --chips_num 当前总共多少筹码
    --my_chips  自己下了多少筹码
    --bet_tips  筹码提示 如 龙可下注
    --bet_limit 下注限制的最大值   
    local nameT = {"chips_num","my_chips"}
    for k,v in pairs(nameT) do
        self[v] = self:getChildByName(v)
        self[v]:setString(" ")
    end
end

function LHDChipsPool:initChipsArea( ... )
    -- local nameT = {"chips_area_1","chips_area_2","chips_area_3"}
    local nameT = {"chips_area_1"}
    for k,v in pairs(nameT) do
        self[v] = self:getChildByName(v)
    end
end

function LHDChipsPool:getChipsAreas( ... )
    local index = 1
    -- local random = math.random(1,100) --math.floor(math.random(100,300)/100)
    -- if random >= 1 and random < 10 then
    --     index = 3
    -- elseif random >= 10 and random < 80 then
    --     index = 1
    -- elseif random >= 80 and random <= 100 then
    --     index = 2
    -- end

    return self["chips_area_" .. index]
end

function LHDChipsPool:clearLastCache()
    self.lastChips = nil
    self.lastLimitChips = nil
end

-- function LHDChipsPool:clearAll()
--     local txtT = {"chips_num","my_chips","bet_tips","bet_limit"}
--     for k, v in pairs(txtT) do
--         self[v]:setString(" ")
--     end
-- end

--设置总的下注筹码
function LHDChipsPool:setChipsNum(value)
    if value == nil then return end
    if not Cache.packetInfo:isShangjiaBao() then
        self:getChildByName("bet_all_bg"):setVisible(value > 0)
    end
    if Cache.packetInfo:isRealGold() then
        self.chips_num:setString(value <= 0 and " " or Util:getOldFormatString(tonumber(Util:NoRoundedOff(value, 0))))
    else
        self.chips_num:setString(value <= 0 and " " or Util:getOldFormatString(value))
    end
end

--清空当前筹码池里面的筹码 并且清空当前筹码的设置情况
function LHDChipsPool:clearChipsCount()
    self.recordChipsIndex = {}
    self.chips_count = 0
    self.chips_num:setString(" ")
    self:clearLimitChipsNum()
end

function LHDChipsPool:setMyselfChips(value)
    if value == nil then return end
    self.myself_count = value

    self.my_chips:setString(value > 0 and Util:getOldFormatString(value) or " ")
end

function LHDChipsPool:clearMyselfChips()
    self.myself_count = 0
    self.my_chips:setString(" ")
end

function LHDChipsPool:setLimitChipsNum(value)
    
end

function LHDChipsPool:clearLimitChipsNum()
    self.frame:setVisible(false)
end

function LHDChipsPool:ready()
    self:restTime()
    self:clearAllChips()
    self:clearMyselfChips()
    self.isWinner = false
end 

function LHDChipsPool:hideFrame()
    self.frame:setVisible(false)
end

function LHDChipsPool:showVictory()
    local victoryNode = self:getChildByName("victory")
    self:hideVictory()
    victoryNode:setVisible(true)
    victoryNode:runAction(cc.Sequence:create(
        cc.FadeIn:create(0.25),
        cc.DelayTime:create(0.05),
        cc.FadeOut:create(0.25),
        cc.DelayTime:create(0.05),
        cc.FadeIn:create(0.25),
        cc.DelayTime:create(0.05),
        cc.CallFunc:create(function (sender)
            victoryNode:setVisible(true)
        end)
    ))
end

function LHDChipsPool:hideVictory()
    local victoryNode = self:getChildByName("victory")
    if victoryNode then
        victoryNode:setVisible(false)
        victoryNode:stopAllActions()
    end
end
function LHDChipsPool:_addWinAnimation () end
function LHDChipsPool:initCards() end
function LHDChipsPool:giveCards(...) end
function LHDChipsPool:reverseCards(...) end
function LHDChipsPool:showCardInfo() end
function LHDChipsPool:showResult(...) end
function LHDChipsPool:restTime() end
function LHDChipsPool:betTime() end
return LHDChipsPool
