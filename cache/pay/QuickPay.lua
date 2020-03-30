--[[
    快捷支付管理
]]

local QuickPay = class("QuickPay")
--[[
    ------------------快捷支付 N种商品----------------------
    需要展示3种商品和1种默认支付方式的快捷支付，规则如下:
    1. 支付方式有默认的优先级，**默认优先级可以配置**
    2. 如果用户上次选择了某种支付方式进行过支付，则该支付方式优先级最高，其余按照默认优先级排序
    3. 按支付方式优先级从高到低、商品金额从小到大排序，遍历各支付方式下的商品列表，找到N种>=需求金额的商品
    4. 如果遍历了所有支付方式，都找不到N种>=需求金额的商品，则在优先级最高的支付方式中找到3种金额最高的商品
    5. 如果N==3，假设已得到商品A, B, C: 其中B为最接近需求金额的商品, 而C的金额要大于A.
    ------------------快捷支付 固定商品----------------------
    百人场上庄，首充，VIP道具，推荐固定的商品。 **推荐商品可配置**
]]

--其他支付方式
PAYMETHOD_OTHER = -1
--支付场景定义
QuickPay.RECOMMEND_SCENE = enum(1,
    "BR_DEALER",    --百人场上庄
    "BR_SITDOWN",   --百人场坐下
    "FIRST_PAY"     --首充
)
--判断金币是否够用，常量定义
QuickPay.JUDGE_ENOUGH = enum(0, 
    "GOLD_ENOUGH",      --金币足够
    "DIAMOND_ENOUGH",   --金币不够，但是钻石足够
    "BOTH_NOT_ENOUGH"   --金币和钻石都不够
)

function QuickPay:ctor()
    --加载配置
    self:_loadConfig()
end

function QuickPay:initInfo()
    --支付方式排序
    self:_orderPaymethod()
end

--从xml中读取配置，异步执行
function QuickPay:_loadConfig()
    --支付方式默认排序: 微信, 支付宝, 银联, 苹果支付, 其他支付方式(用-1表示), 短信
    self.paymethods_default_order = {
            PAYMETHOD_WINXIN, 
            PAYMETHOD_ZHIFUBAO, 
            PAYMETHOD_BANK, 
            PAYMETHOD_APPSTORE, 
            PAYMETHOD_OTHER,
            PAYMETHOD_DUANXIN_YD,
            PAYMETHOD_DUANXIN_LT,
            PAYMETHOD_DUANXIN_DX_AIYOUXI,
            PAYMETHOD_DUANXIN_DX_TIANYI}

    --与场景相关的快捷支付推荐规则
    self.scene_recommend_rules = {
        {scene=QuickPay.RECOMMEND_SCENE.BR_DEALER, levels={2,1,3}},
        {scene=QuickPay.RECOMMEND_SCENE.BR_SITDOWN, levels={2,1,3}},
        {scene=QuickPay.RECOMMEND_SCENE.FIRST_PAY, levels={2,1,3}}
    }
    --TODO: 从xml中读取self.paymethods_order, self.scene_recommend_rules. 
end

--重置支付方式默认排序, 根据支付方式记录，重新排序QuickPay.paymethods_default_order
function QuickPay:_resetPaymethodOrder()
    local default = cc.UserDefault:getInstance():getIntegerForKey(SKEY.DEFAULT_PAYMETHOD, PAYMETHOD_OTHER)
    if default == PAYMETHOD_OTHER then
        return  --没有记录，不需要重新排序
    end

    local paymethods_order = {} --用于临时记录排序
    table.insert(paymethods_order, default) --先将默认支付方式加入排序列表
    for k, v in pairs(self.paymethods_default_order) do
        if v ~= default then
            table.insert(paymethods_order, v)
        end
    end
    self.paymethods_default_order = clone(paymethods_order)
end

--支付方式排序(在游戏启动，或支付成功后，都需要调用该接口调整支付顺序)
function QuickPay:_orderPaymethod()
    --重置支付方式默认排序
    self:_resetPaymethodOrder()
    --当前渠道所有支付方式
    local paymethods = Cache.PayManager:getPayMethods()   
    --获取某种支付方式的排序值
    local function getPayMethodOrder(paymethod)
        for k, v in pairs(self.paymethods_default_order) do
            if v == paymethod then
                return k
            end
        end
        return -1
    end
    local other_pay_order = getPayMethodOrder(PAYMETHOD_OTHER)
    --遍历支付方式, 排序
    local t = {}
    for k, v in pairs(paymethods) do
        local order = getPayMethodOrder(v)
        if order == -1 then
            order = other_pay_order
        end
        table.insert(t, {paymethod = v, order=order})
    end
    table.sort(t, function(a, b)
        return a.order < b.order
    end)
    --得到排序结果. getAllPayMethod() 返回的是这个排序结果, getDefaultPayMethod()返回的是这个排序结果的第一个支付方式
    self.paymethods_inorder = {}
    for k, v in pairs(t) do
        table.insert(self.paymethods_inorder, v.paymethod)
    end
end

--------------------------------支付方式相关接口----------------------------
--设置默认的支付方式，在用户支付成功后调用
function QuickPay:setDefaultPayMethod(method)
    cc.UserDefault:getInstance():setIntegerForKey(SKEY.DEFAULT_PAYMETHOD, method)
    cc.UserDefault:getInstance():flush()
    --重新排序
    self:_orderPaymethod()
end


--获取排序后的所有支付方式
function QuickPay:getAllPayMethod()
    return clone(self.paymethods_inorder)
end

--获取默认的支付方式
function QuickPay:getDefaultPayMethod()
    local paymethods = self:getAllPayMethod()
    if table.getn(paymethods) > 0 then
        return paymethods[1]
    end
end

--获取某一钻石商品对应的支付方式，支付方式经过排序
function QuickPay:getPayMethodsByDiamondNum(num)
    local order_paymethods = self:getAllPayMethod()
    local diamond_paymethods = Cache.PayManager:getPayMethodsByDiamondNum(num)
    local diamond_paymethods_order = {}
    for k, v in pairs(order_paymethods) do
        for key, paymethod in pairs(diamond_paymethods) do
            if paymethod == v then
                table.insert(diamond_paymethods_order, v)
                break
            end
        end
    end
    return diamond_paymethods_order
end

function QuickPay:getPayMethodsByGoldNum(num)
    -- body
    local order_paymethods = self:getAllPayMethod()
    local diamond_paymethods = Cache.PayManager:getPayMethodsByGoldNum(num)
    local diamond_paymethods_order = {}
    for k, v in pairs(order_paymethods) do
        for key, paymethod in pairs(diamond_paymethods) do
            if paymethod == v then
                table.insert(diamond_paymethods_order, v)
                break
            end
        end
    end
    return diamond_paymethods_order
end
--------------------------------钻石推荐----------------------------
--[[
    获取与最小需求相关的钻石支付推荐. 
    paras: gold, 金币需求; count, 推荐个数
    return value: 
        当count==1时, 返回钻石信息 
        当count>1时, 返回钻石信息列表,按照推荐顺序排序,最优先推荐的排在最前
]]
function QuickPay:getRecommendDiamondByRequire(gold, count)
    local all_diamond_info = Cache.PayManager:getDiamondList()
    if count > table.getn(all_diamond_info) then
        return nil  --要求推荐的商品个数小于现有商品个数，参数不合法
    end

    --降序排列
    local sort_diamond_desc = clone(all_diamond_info)
    table.sort(sort_diamond_desc, function(a, b)
        return a.diamond > b.diamond
    end)
    --升序排列
    local sort_diamond_asc = clone(all_diamond_info)
    table.sort(sort_diamond_asc, function(a, b)
        return a.diamond < b.diamond
    end)

    --找到最符合需求的钻石商品
    local match_diamond_info = self:getSuitableDiamondByRequire(gold)
    if match_diamond_info == nil then
        match_diamond_info = sort_diamond_desc[1] --现有商品不能满足需求，推荐金币最多的一种
    end

    --根据需求数量返回商品信息
    if count == 1 then
        return match_diamond_info  --返回商品信息
    else
        --构造商品信息列表. 排序方式说明: 例如钻石数量为 1, 2, 3, 4, 5, 6, min=5, 则排序为5, 6, 4, 3, 2, 1
        local sort_tab = {}
        for k, v in pairs(sort_diamond_asc) do
            if v.diamond >= match_diamond_info.diamond then
                table.insert(sort_tab, v)
            end
        end
        for k, v in pairs(sort_diamond_desc) do
            if v.diamond < match_diamond_info.diamond then
                table.insert(sort_tab, v)
            end
        end
        --取前count个推荐钻石商品
        local recommend_tab = {}
        local num = 0
        for k, v in pairs(sort_tab) do
            table.insert(recommend_tab, v)
            num = num + 1
            if num >= count then
                break
            end
        end
        return recommend_tab
    end
end

--获取满足条件的最少的钻石商品
function QuickPay:getSuitableDiamondByRequire(gold)
    --根据金币和钻石兑换比值获取最少需要的钻石
    local min_diamond = gold / Cache.Config.diamond2gold_ratio
    --升序排列
    local all_diamond_info = Cache.PayManager:getDiamondList()
    local sort_diamond_asc = clone(all_diamond_info)
    table.sort(sort_diamond_asc, function(a, b)
        return a.diamond < b.diamond
    end)

    --找到合适的钻石商品
    local diamond_info = nil
    for k, v in pairs(sort_diamond_asc) do
        if min_diamond <= v.diamond then
            diamond_info = clone(v)
            break
        end
    end
    
    --如果找不到合适的钻石商品，返回最大额度的
    local no_suitable = false
    local len = table.getn(sort_diamond_asc)
    if diamond_info == nil and len > 0 then
        diamond_info = sort_diamond_asc[len]
        no_suitable = true
    end
    return diamond_info, no_suitable
end


--------------------------------金币推荐----------------------------
-- --[[
--     获取与最小需求相关的金币商品推荐(固定3个)
--     paras: min, 最小需求
-- ]]
-- function QuickPay:getRecommendGoldByRequire(min)
--     local all_gold_info = Cache.PayManager:getGoldInfo()            --所有金币商品
--     local match_gold_info = self:getSuitableGoldInfoByRequire(min)  --最符合需求的金币商品
--     if table.getn(all_gold_info) < 3 then
--         return nil  --要求推荐的商品个数小于现有商品个数，参数不合法
--     end

--     --排序方式说明: 例如金币数量为 1, 2, 3, 4, 5, 6, min=5, count=3, 则排序为5, 4, 6; 如果count=4，则排序为5, 3, 4, 6
--     local match_level = match_gold_info.level
--     local min_level, max_level = 1, table.getn(all_gold_info)
--     local lower_level, higher_level = 0, 0
--     if match_level == min_level then
--         lower_level, higher_level = match_level + 1, match_level + 2
--     elseif match_level ==  max_level then
--         lower_level, higher_level = match_level - 2, match_level - 1
--     else
--         lower_level, higher_level = match_level - 1, match_level + 1
--     end
--     local level_tab = {}
--     table.insert(level_tab, lower_level)
--     table.insert(level_tab, match_level)
--     table.insert(level_tab, higher_level)
    
--     --得到排序后的金币信息
--     local recommend_tab = {}
--     for k, level in pairs(level_tab) do
--         for key, goldInfo in pairs(all_gold_info) do
--             if level == goldInfo.level then
--                 table.insert(recommend_tab, goldInfo)
--                 break
--             end
--         end
--     end
--     return recommend_tab
-- end


--[[
    获取与最小需求相关的金币商品推荐(固定3个)
    paras: min, 最小需求
]]
function QuickPay:getRecommendGoldByRequire(min)
    local all_gold_info = Cache.PayManager:getGoldInfo()            --所有金币商品
    local match_gold_info = self:getSuitableGoldInfoByRequireDaimond(min)  --最符合需求的金币商品
    if table.getn(all_gold_info) < 3 then
        return nil  --要求推荐的商品个数小于现有商品个数，参数不合法
    end

    --排序方式说明: 例如金币数量为 1, 2, 3, 4, 5, 6, min=5, count=3, 则排序为5, 4, 6; 如果count=4，则排序为5, 3, 4, 6
    local match_level = match_gold_info.level
    local min_level, max_level = 1, table.getn(all_gold_info)
    local lower_level, higher_level = 0, 0
    if match_level == min_level then
        lower_level, higher_level = match_level + 1, match_level + 2
    elseif match_level ==  max_level then
        lower_level, higher_level = match_level - 2, match_level - 1
    else
        lower_level, higher_level = match_level - 1, match_level + 1
    end
    local level_tab = {}
    table.insert(level_tab, lower_level)
    table.insert(level_tab, match_level)
    table.insert(level_tab, higher_level)
    
    --得到排序后的金币信息
    local recommend_tab = {}
    for k, level in pairs(level_tab) do
        for key, goldInfo in pairs(all_gold_info) do
            if level == goldInfo.level then
                table.insert(recommend_tab, goldInfo)
                break
            end
        end
    end
    return recommend_tab
end

--[[
    获取与场景相关的金币支付推荐. 
    parameters: scene: 支付场景; paymethod: 支付方式
    return value: 金币信息.
]]

function QuickPay:getRecommendGoldByScene(scene)
    --找到场景相关的推荐配置
    local recommend_levels = nil
    for k,v in pairs(self.scene_recommend_rules) do
        if v.scene == scene then
            recommend_levels = clone(v.levels)
        end
    end
    if recommend_levels == nil then 
        return   --找不到支付配置
    end

    --按推荐等级找到金币信息
    local all_gold_info = Cache.PayManager:getGoldInfo()
    local recommend_tab = {}
    for key, level in pairs(recommend_levels) do
        for k, goldInfo in pairs(all_gold_info) do
            if goldInfo.level == level then
                table.insert(recommend_tab, goldInfo)
            end
        end
    end

    return recommend_tab
end

--获取满足条件的最少的金币商品
function QuickPay:getSuitableGoldInfoByRequire(min)
    local all_gold_info = Cache.PayManager:getGoldInfo()
    local sort_gold_info = clone(all_gold_info)
    --将金币价格从少到多排序
    table.sort(sort_gold_info, function(a, b)
        return a.amount < b.amount
    end)
    --找到能兑换的金币商品
    local goldinfo = nil
    for k, v in pairs(sort_gold_info) do
        if v.amount >= min then
            goldinfo = clone(v)
            break
        end
    end
    --如果找不到合适的金币商品，返回最大额度的
    local no_suitable = false
    local len = table.getn(sort_gold_info)
    if goldinfo == nil and len > 0 then
        goldinfo = sort_gold_info[len]
        no_suitable = true
    end
    return goldinfo, no_suitable
end


--获取满足条件的最少的金币商品
function QuickPay:getSuitableGoldInfoByRequireDaimond(min)
    local all_gold_info = Cache.PayManager:getGoldInfo()
    local sort_gold_info = clone(all_gold_info)
    --将金币价格从少到多排序
    table.sort(sort_gold_info, function(a, b)
        return a.amount < b.amount
    end)
    --找到能兑换的金币商品
    local goldinfo = nil
    local tmp      = nil 
    for k, v in pairs(sort_gold_info) do
        if v.price <= min then
            tmp = clone(v)
        else
            break
        end
    end
    goldinfo = tmp

    --如果找不到合适的金币商品，返回最大额度的
    local no_suitable = false
    local len = table.getn(sort_gold_info)
    if goldinfo == nil and len > 0 then
        goldinfo = sort_gold_info[len]
        no_suitable = true
    end
    return goldinfo, no_suitable
end

--------------------------------其他判定接口----------------------------
--[[
    判断用户是否可以购买某商品.
    参数: gold, 商品所需的金币
    返回值: 见QuickPay.JUDGE_ENOUGH定义
]]
function QuickPay:isMoneyEnough(gold)
    local result = QuickPay.JUDGE_ENOUGH.BOTH_NOT_ENOUGH
    if Cache.user.gold >= gold then
        result = QuickPay.JUDGE_ENOUGH.GOLD_ENOUGH
    else
        --获取满足条件的最少的金币商品
        local goldInfo, no_suitable = self:getSuitableGoldInfoByRequire(gold)
        --判断用户的钻石是否够买这个金币商品
        if no_suitable == false and goldInfo.price <= Cache.user.diamond or Cache.user.diamond/goldInfo.price*goldInfo.amount>=gold  then
            result = QuickPay.JUDGE_ENOUGH.DIAMOND_ENOUGH
        end
    end
    return result
end

return QuickPay



