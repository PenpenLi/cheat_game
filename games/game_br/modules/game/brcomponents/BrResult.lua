local BrResult = class("BrResult",function(paras)
    return ccs.GUIReader:getInstance():widgetFromJsonFile(BrRes.brResultJson)
end)

BrResult.TAG = "BrResult"

function BrResult:ctor(paras)
    paras = paras or {}
    self.cb = paras.callBack
    self.winSize = cc.Director:getInstance():getWinSize()
    self:initComponent()
    self:update()
    self:initTouch()
end

local function getDigitalShowStr(score)
    if score == 0 then
        return "0"
    end
    --"." 表示+  " 表示-
    local preFix = score > 0 and "." or "/"
    return preFix .. math.abs(score)
end 

local function getFont(score)
    local font
    if score == 0 then
        font = BrRes.noloseScoreFont
    elseif score > 0 then
        font = BrRes.winScoreFont
    elseif score < 0 then
        font = BrRes.loseScoreFont
    end
    return font 
end

local function setScoreString(node, score)
    local font = getFont(score)
    local str = getDigitalShowStr(score)
    node:setProperty(str, font, 24,34, ",")
end

function BrResult:initComponent()
    local uiTbl = {
        {name = "result_head",           path = "result_head"},
        {name = "specialResult",         path = "center_container/special_result"},
        {name = "heitaoTxt",             path = "center_container/heitao/txt" },               
        {name = "hongtaoTxt",            path = "center_container/hongtao/txt"},
        {name = "meihuaTxt",             path = "center_container/meihua/txt"},
        {name = "fangpianTxt",           path = "center_container/fangpian/txt"},
        {name = "score",                 path = "result_bg/score"},

        {name = "bottomLine",            path = "line_bottom"},
        {name = "topLine",               path = "line_top"}
    }
    Util:bindUI(self, self, uiTbl)
end

function BrResult:update()
    local status = nil
    if Cache.brdesk.br_delar == nil then
        return 
    end


    self:refreshUI()
    self:delayRun(5,function()
        if self.cb then self.cb() end
        self:hide()
    end)
    

end

function BrResult:refreshUI()
    local scoreTbl  
    --我是庄家
    if Cache.brdesk.br_delar.uin == Cache.user.uin then
    --自己已经下注
        scoreTbl = self:getDelarAreaXiaZhu()
    elseif self:checkHadXiaZhu() then
    -- 自己没有下注
        scoreTbl = self:getAreaXiaZhu()
    else
        scoreTbl = {0,0,0,0}
    end
    setScoreString(self.heitaoTxt, scoreTbl[1])
    setScoreString(self.hongtaoTxt, scoreTbl[2])
    setScoreString(self.meihuaTxt, scoreTbl[3])
    setScoreString(self.fangpianTxt, scoreTbl[4])

    local sum = 0
    for i ,v in ipairs(scoreTbl)do
        sum = sum + v
    end

    setScoreString(self.score, sum)

    --显示通杀通赔
    self.specialResult:setVisible(false)
    local tp, ts = Cache.brdesk:getGameResultForSpecial()
    if tp == 1 or ts == 1 then
        self.specialResult:setVisible(true)
        if tp == 1 then
            self.specialResult:loadTexture(BrRes.br_new_result_special_tp)
        end
        if ts == 1 then
            self.specialResult:loadTexture(BrRes.br_new_result_special_ts)
        end
    end


    if sum >= 0 then
        MusicPlayer:playMyEffect("BIGYING")
        self.result_head:loadTexture(BrRes.br_new_result_head_1)
        self.topLine:loadTexture(BrRes.br_result_line_1)
        self.bottomLine:loadTexture(BrRes.br_result_line_1)
    else
        MusicPlayer:playMyEffect("LOSE")
        self.result_head:loadTexture(BrRes.br_new_result_head_2)
        self.topLine:loadTexture(BrRes.br_result_line_2)
        self.bottomLine:loadTexture(BrRes.br_result_line_2)
    end
end

--
function BrResult:checkHadXiaZhu()
    local brMyBet = Cache.brdesk.br_my_bets
    local sum = 0
    for k, v in pairs(brMyBet) do
        sum = sum + v
    end
    return sum > 0
end

--得到四个区域的赢钱与输钱
function BrResult:getAreaXiaZhu()
    local brResult = Cache.brdesk.br_result
    local brMyBet = Cache.brdesk.br_my_bets
    local areaScoreTbl = {0,0,0,0}
    for area, arr in ipairs(brResult) do
        areaScoreTbl[area] = 0
        for i, v in ipairs(arr) do
            if v.uin == Cache.user.uin then --只需要显示自己的值
                areaScoreTbl[area] = Cache.packetInfo:getProMoney(brMyBet[area] * v.odds)
            end
        end
    end
    return areaScoreTbl
end

--得到庄家四个区域的赢钱与输钱 包括总数 
function BrResult:getDelarAreaXiaZhu()
    local brResult = Cache.brdesk.br_result
    local areaScoreTbl = {0,0,0,0}
    for area, arr in ipairs(brResult) do
        areaScoreTbl[area] = 0
        for i, v in ipairs(arr) do
            if v.uin == Cache.brdesk.br_delar.uin then --只需要显示自己的值
                areaScoreTbl[area] = -Cache.packetInfo:getProMoney(v.chips)
            end
        end
    end
    return areaScoreTbl
end

function BrResult:initUI(status)
    --显示通杀通赔
    self.specialResult:setVisible(false)
    local tp, ts = Cache.brdesk:getGameResultForSpecial()
    if tp == 1 or ts == 1 then
        self.specialResult:setVisible(true)
        if tp == 1 then
            self.specialResult:loadTexture(BrRes.br_new_result_special_tp)
        end
        if ts == 1 then
            self.specialResult:loadTexture(BrRes.br_new_result_special_ts)
        end
    end

    local _my, _delar = "", ""
    -- 我是庄、或者我没有参与
    -- if next(Cache.brdesk.self_result) == nil then
    --    self.title:setVisible(false)
    --    self.specialResult:setVisible(false)
    --    self.mySelfInfo:setVisible(false)
    --    --self.specialResult:setPositionY(148)
    --    self.delarInfo:setPositionY(56)
    -- else
    --     self.title:setVisible(true)
    --     --self.specialResult:setVisible(true)
    --     self.mySelfInfo:setVisible(true)
    --     self.specialResult:setPositionY(101)
    --     self.delarInfo:setPositionY(103)
    -- end

    if status == 1 then
        MusicPlayer:playMyEffect("BIGYING")
        -- self.title:loadTexture(BrRes.br_result_head_1)
        -- self.topLine:loadTexture(BrRes.br_result_line_1)
        -- self.bottomLine:loadTexture(BrRes.br_result_line_1)
    elseif status == 2 then
        MusicPlayer:playMyEffect("LOSE")
        -- self.title:loadTexture(BrRes.br_result_head_2)
        -- self.topLine:loadTexture(BrRes.br_result_line_2)
        -- self.bottomLine:loadTexture(BrRes.br_result_line_2)
    end

    --Cache.brdesk.br_result_count.myself记录自己赢的筹码数, Cache.brdesk.br_result_count.delar记录庄家输的筹码数
    local my_win_chips, dealer_win_chips = Cache.brdesk:getMyAndDelarWinChips()
	my_win_chips = Cache.packetInfo:getProMoney(my_win_chips)
	dealer_win_chips = Cache.packetInfo:getProMoney(dealer_win_chips)
    if my_win_chips >= 0 then
        if my_win_chips == 0 then
            _my = "0"
        else
            _my = string.format("%s", Util:getFormatString(my_win_chips))
        end
        self.mySelfInfo:getChildByName("result_img"):loadTexture(BrRes.br_result_1)
    else
        _my = string.format("%s", Util:getFormatString(math.abs(my_win_chips)))
        self.mySelfInfo:getChildByName("result_img"):loadTexture(BrRes.br_result_2)
    end

    if dealer_win_chips >= 0 then
        if dealer_win_chips == 0 then
            _delar = "0"
        else
            _delar = string.format("%s",Util:getFormatString(dealer_win_chips))
        end
        self.delarInfo:getChildByName("result_img"):loadTexture(BrRes.br_result_1)
    else
        _delar = string.format("%s",Util:getFormatString(math.abs(dealer_win_chips)))
        self.delarInfo:getChildByName("result_img"):loadTexture(BrRes.br_result_2)
    end
    self.delarInfo:getChildByName("num"):setString(_delar)
    self.mySelfInfo:getChildByName("num"):setString(_my)

    qf.event:dispatchEvent(ET.SHARE_CHECK_SHOW,{})--检查是否达到分享的条件 
end

function BrResult:delayRun(time,cb)
    local action = cc.Sequence:create(
        cc.DelayTime:create(time),
        cc.CallFunc:create(function (  )
            if cb then cb() end
        end)
    )
    self:runAction(action)
end


function BrResult:initTouch()
    addButtonEvent(self,function() 
        if self.cb then self.cb() end
        self:hide()
    end)
end

function BrResult:hide()
    self:removeFromParent(true)
end   

return BrResult