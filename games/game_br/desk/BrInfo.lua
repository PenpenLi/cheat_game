local BrInfo = class("BrInfo")

BrInfo.TAG = "BrInfo"

function BrInfo:updateHistory(m)
    self.history = {}
    if not m then return end
    local index = 1
    for i = m.histo:len() , 1, -1 do
        local info = m.histo:get(i)
        local history = {}
        for j = 1 , info.detail:len() do
            history[j] = {}
            local detail = info.detail:get(j)
            self:_updateProps({"section","odds"},detail,history[j])
        end
        self.history[index] = history
        index = index + 1
    end
end

function BrInfo:getHistoryBySection(section)
    local history = {}
    if #self.history > 0 and section ~= nil then
        for index,info in ipairs(self.history) do
            for _, subInfo in ipairs(info) do
                if subInfo.section == section then
                    history[index] = subInfo
                end
            end
        end
    end
    return history
end

function BrInfo:updateOthers(m)
	if m ~= nil then logd("无座玩家 "..pb.tostring(m)) end
    self.others = {}
    self.others_count = m.count
    local propsTable = {"uin","nick","gender","chips","portrait"}
    for i = 1 , m.players:len() do
        self.others[i] = {}
        self:_updateProps(propsTable,m.players:get(i),self.others[i])
    end
end

function BrInfo:updateDelarList(m)
    self.delars = {}
    self.delars_count = m.count
    self.be_delaring = false
    local propsTable = {"uin","nick","gender","chips","gold", "portrait"}
    for i = 1 , m.players:len() do
        local info = m.players:get(i)
        if info.uin == Cache.user.uin then self.be_delaring = true end
        self.delars[i] = {}
        self:_updateProps(propsTable,info,self.delars[i])
    end
end

function BrInfo:_updateProps( propsTable , src,dest )
    for k,v in pairs(propsTable) do
        dest[v] = src[v]
    end
end

return BrInfo