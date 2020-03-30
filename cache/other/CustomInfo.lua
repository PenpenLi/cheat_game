local CustomInfo = class("CustomInfo")

CustomInfo.TAG = "CustomInfo"


function CustomInfo:ctor() 
    self:init()
end

function CustomInfo:init() 
    self._mailList = {}
    self._newMailFlag = 0
end

function CustomInfo:requestCustomInfo(cb)
    --解析数据
    local resolveData = function (model)
        local datalist = {}
        for i = 1, model.question_list:len() do
            local data = model.question_list:get(i)
            local info = {
                uin = data.uin,
                question = data.question,
                answer = data.answer,
                id = data.id,
                time = data.create_time,
                status = data.status,
            }
            datalist[#datalist + 1] = info
        end
        return datalist
    end


    GameNet:send({cmd = CMD.QES_REQ, body = {uin = Cache.user.uin},callback = function (rsp)
        if rsp.ret ~= 0 then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
            return
        end
        local model = rsp.model
        if model then
            local datalist = resolveData(model)
            cb(datalist)
        end
    end})
end

function CustomInfo:requestAskQes(paras)
    GameNet:send({cmd=CMD.ASK_QES, body={question=paras.question, uin = paras.uin},callback = function (rsp)
        if rsp.ret ~= 0 then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
            return
        end
        if type(paras.cb) == "function" then
            paras.cb()
        end
    end})
end


--检查是否由新的客服通知
function CustomInfo:checkNewCustom()
    return checknumber(self._newCustomFlag) > 0
end


function CustomInfo:setNewCustomFlag(status)
    self._newCustomFlag = status
end

function CustomInfo:clear( ... )
    self:init() 
end

return CustomInfo