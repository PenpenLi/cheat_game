local MailInfo = class("MailInfo")

MailInfo.TAG = "MailInfo"


function MailInfo:ctor() 
    self:init()
end

function MailInfo:init() 
    self._mailList = {}
    self._newMailFlag = 0
end

-- message MailRsp{
--     message sys_notice{
        -- optional string mail_title = 1; //邮件标题
        -- optional string mail_text = 2; //邮件内容
        -- optional string mail_time = 3; //邮件发布时间 用于排序
        -- optional int32 mail_id = 4; // 邮件唯一标示
        -- optional string reserved = 5; // 预留字段(邮件类型) 0:群发邮件 1:代理邮件 2:系统邮件 3:私人邮件
        -- optional int32 mail_status = 6;	// 邮件状态 0：未读 1：已读
--     }
--     repeated SysMail sys_mail = 1;      //邮件广播
-- }
function MailInfo:saveConfig(model)
    local mailList = {}
    if model == nil then
        return
    end
    local mailLen = model.sys_mail:len()
    -- print("saveConfig XXXXXXXXXXXXXX")
    -- printRspModel(model)
    for i = 1, model.sys_mail:len() do
        local data = model.sys_mail:get(i)
        local info = {
            notiTxt = data.mail_title,
            content = data.mail_text,
            time = data.mail_time,
            id = data.mail_id,
            rd = checknumber(data.reserved),
            mRead = data.mail_status
        }
        mailList[mailLen - (i - 1)] = info
    end

    self._mailList = self:sortMail(mailList)
end

function MailInfo:sortMail(mailList)
    table.sort(mailList, function (a, b)
        if a.mRead == b.mRead then
            return a.id > b.id
        else
            return a.mRead < b.mRead
        end
    end)
    return mailList
end

--真正打开的时候才记录到缓存
function MailInfo:checkAgencyMail()
    if self._mailList and #self._mailList > 0 and self._mailList[1].rd == 3 then
        local nId = cc.UserDefault:getInstance():getIntegerForKey(SKEY.AGENT_MAIL_KEY, -1)
        local nnId = self._mailList[1].id
        if nnId > nId then
            return true
        end
    end
end


function MailInfo:requestMailInfo(cb)
    self._mailList = {}
    GameNet:send({cmd = CMD.GET_MAIL_INFO,callback = function(rsp)
        if rsp.ret ~= 0 then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
            return
        end
        -- printRspModel(rsp.model)
        self:saveConfig(rsp.model)
        if cb and type(cb) == "function" then
            cb()
        end
    end})
end


-- cmd = 703  # 删除邮件
-- message DeleteMailReq{
--     optional int32 mail_id = 1;       // 邮件唯一标示
-- }
-- message DeleteMailRsp{
-- }
function MailInfo:requestDelMail(mailID, args)
    print("mailID", checknumber(mailID))
    GameNet:send({cmd=CMD.DEL_MAIL, body={mail_id=checknumber(mailID)},callback = function (rsp)
        -- body
        if rsp.ret ~= 0 then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
            return
        end
        if args and args.callback and type(args.callback) == "function" then
            args.callback(mailID)
        end
    end})
end

-- cmd = 704  # 已读邮件
-- message ReadMailReq{
--     optional int32 mail_id = 1;       // 邮件唯一标示
-- }
-- message ReadMailRsp{
-- }
function MailInfo:requestReadMail(mailID, args)
    print("mailID", checknumber(mailID))
    GameNet:send({cmd=CMD.READ_MAIL, body={mail_id=checknumber(mailID)},callback = function (rsp)
        -- body
        if rsp.ret ~= 0 then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
            return
        end
        print("requestReadMail success！！！")
        if args and args.callback and type(args.callback) == "function" then
            args.callback(mailID)
        end
    end})
end

-- cmd = 699  # 修改未读邮件为已读邮件
-- message ModifyMailReq{
--     optional int32 mail_id = 1;       // 邮件唯一标示
-- }
-- message ModifyMailRsp{
-- }
function MailInfo:requestModifyMail(mailID, args)
    print("mailID requestModifyMail", checknumber(mailID))
    GameNet:send({cmd=CMD.MODIFY_MAIL, body={mail_id=checknumber(mailID)},callback = function (rsp)
        -- body
        if rsp.ret ~= 0 then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
            return
        end

        print("requestModifyMail success！！！")
        if args and args.callback and type(args.callback) == "function" then
            args.callback(mailID)
        end
    end})
end


--检查是否由新的邮件
function MailInfo:checkNewMail()
    return self._newMailFlag == 1
end

function MailInfo:setNewMailFlag(status)
    self._newMailFlag = status
end

function MailInfo:clear( ... )
    self:init() 
end

return MailInfo