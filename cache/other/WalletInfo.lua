--钱包记录展示类
local WalletInfo = class("WalletInfo")

WalletInfo.TAG = "WalletInfo"


function WalletInfo:ctor() 
    self:init()
end

function WalletInfo:getDateList( ... )
    -- body
    return self._datelist
end

function WalletInfo:getDetailList( ... )
    -- body
    return self._detailDataList
end

function WalletInfo:initTestData()
    -- body
end

function WalletInfo:init()
    -- self._detailDataList = {
    --    {typename = "全部",  name = "", queryId = 0, descTbl = {}},
    --    {typename = "充值",  name = "充值状态:",  queryId = 1, descTbl = {
    --         { typename = "全部", queryId = 0},
    --         { typename = "充值成功", queryId = 1},
    --         { typename = "充值失败",queryId = 2},
    --         { typename = "等待确认", queryId = 3}
    --     }},
    --    {typename = "提现",  name = "提现状态:",  queryId = 2, descTbl = {
    --        { typename = "全部", queryId = 0},
    --        { typename = "提现成功", queryId = 1},
    --        { typename = "待打款", queryId = 2}
    --     }},
    --    {typename = "玩牌",  name = "玩法:",  queryId = 3, descTbl = {
    --        { typename = "全部", queryId = 0}, 
    --        { typename = "百人炸金花", queryId = 1},
    --        { typename = "百人牛牛", queryId = 2},
    --        { typename = "抢庄牛牛", queryId = 3}, 
    --        { typename = "龙虎斗", queryId = 4},
    --        { typename = "炸金花", queryId = 5}
    --     }},
    --    {typename = "上下分",  name = "上下分状态:",  queryId = 4, descTbl = {
    --        {typename = "全部", queryId = 0},
    --        {typename = "上分 - 代理充值", queryId = 1},
    --        {typename = "下分 - 提现至代理", queryId = 2}
    --     }},
    --    {typename = "保险箱",  name = "存/取状态:",  queryId = 5, descTbl = {
    --        {typename = "全部", queryId = 0}, 
    --        {typename = "存入", queryId = 1}, 
    --        {typename = "取出", queryId = 2},
    --     }},
    -- }
    
    -- self._datelist = {
    --     {typename = "全部", queryId = 7},
    --     {typename = "今天", queryId = 0},
    --     {typename = "昨天", queryId = 1},
    --     {typename = "前天", queryId = 2}
    -- }
end

function WalletInfo:resolveProto(model)
    -- body
    local timeinfo = {"day_req", "day_time", "day_show"}
    local timelist = {"time_list", "arr", timeinfo}
    
    local walletinfo = {"wallet", "wallet_show_txt"}
    local walletlist = {"wallet_list", "arr", walletinfo}
    local typeinfo = {"type", "type_show", "type_show_1", walletlist}
    local typelist = {"type_list", "arr", typeinfo}

    local protoTbl = {
        timelist, typelist
    }
    --解析协议
    local rTbl = Util:resolveProto(protoTbl, model)
    self:convertToClientData(rTbl)
end

function WalletInfo:resolveConfigProto(model)
    --其他
    local roomid_info = {"room_id", "room_name", "is_play"}
    local room_list = {"room_list", "arr", roomid_info}

    --支付
    local bill_info = {"bill_type", "bill_name"}
    local bill_list = {"bill_list", "arr", bill_info}

    --提现
    local state_info = {"bill_state", "state_name"}
    local state_list = {"state_list", "arr", state_info}

    local protoTbl = {
        room_list,
        bill_list,
        state_list
    }

    local rTbl = Util:resolveProto(protoTbl, model)
    self.configTbl = rTbl
end

function WalletInfo:getOtherInfo(id)
    local cTbl = self.configTbl.room_list
    for i, v in ipairs(cTbl) do
        if v.room_id == id then
            return v.room_name
        end
    end
    return ""
end

function WalletInfo:checkIsGame(id)
    local cTbl = self.configTbl.room_list
    for i, v in ipairs(cTbl) do
        if v.room_id == id and v.is_play == 1 then
            return true
        end
    end
    return false
end

function WalletInfo:getPayInfo(id)
    local cTbl = self.configTbl.bill_list
    for i, v in ipairs(cTbl) do
        if v.bill_type == id then
            return v.bill_name
        end
    end
    return ""
end

function WalletInfo:getRechargeInfo(id)
    local cTbl = self.configTbl.state_list
    for i, v in ipairs(cTbl) do
        if v.bill_state == id then
            return v.state_name
        end
    end
    return ""
end

function WalletInfo:convertToClientData(data)
    local datelist = {}
    for i, v in ipairs(data.time_list) do
        datelist[i] = {typename = v.day_show, queryId = v.day_req}
    end
    self._datelist = datelist

    local detailDataList = {}
    for i1, v1 in ipairs(data.type_list) do
        local temp = {}
        temp.typename = v1.type_show
        temp.name = v1.type_show_1
        temp.queryId = v1.type
        local descTbl = {}
        for i2, v2 in ipairs(v1.wallet_list) do
            descTbl[#descTbl + 1] = {
                typename = v2.wallet_show_txt,
                queryId = v2.wallet
            }

        end
        temp.descTbl = descTbl
        detailDataList[#detailDataList + 1] = temp
    end
    self._detailDataList = detailDataList
end

function WalletInfo:getData()
end

function WalletInfo:saveData()
end

function WalletInfo:getDetailDataByQueryId(queryId)
    for i, v in ipairs(self._detailDataList) do
        if v.queryId == queryId then
            return v
        end
    end
end

return WalletInfo