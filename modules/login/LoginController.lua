
local LoginController = class("LoginController",qf.controller)

LoginController.TAG = "LoginController"
local loginView = import(".LoginView")

--[[
登陆控制器
1.游戏启动时显示该界面
2.使用 xhr拉取最新服务器信息
3.检查最新版本资源，进行热更新，有更新，更新完重启
4.与服务建立连接，发送登陆注册请求，发送拉取config请求
5.跳转到游戏主界面
]]
function LoginController:ctor(parameters)
    self.super.ctor(self)
    self:getcdnURL()
    self.MaxTryTimes = 3
    self.cdnMaxTryTimes = 3 
    self:safeCheckZoneAndPhone()
end

--兼容400版本新增的区号配置与350版本只有手机号配置
function LoginController:safeCheckZoneAndPhone()
    local phone = cc.UserDefault:getInstance():getStringForKey("loginPhone", "")
    local zone =  cc.UserDefault:getInstance():getStringForKey("loginZone", "")
    if phone ~= "" then
        --判断跟之前登录的手机号是不是相同的，相同的就不记录了
        local phoneTable = string.split(phone,"|")
        local modZone = "86"
        local zoneTable = string.split(zone, "|")
        if zone == "" or #zoneTable ~= #phoneTable then
            zoneTable = {}
            for i = 1, #phoneTable do
                zoneTable[i] = modZone
            end
            local allZone = table.concat(zoneTable, "|")
            cc.UserDefault:getInstance():setStringForKey("loginZone",allZone)
            cc.UserDefault:getInstance():flush()
        end
    end
end


function LoginController:getcdnURL()
    loga("===LoginController:getcdnURL")
    -- body
    self.handler_http_req = nil
    self.handler_http_req = cc.XMLHttpRequest:new()
    self.handler_http_req.timeout = 5
    self.handler_scheduler = Util:runOnce(self.handler_http_req.timeout, function( ... )
        if self.handler_http_req then
            self.handler_http_req:abort()
            self.handler_http_req = nil
        end
        RESOURCE_HOST_NAME = HOST_NAME

    end)

    local getCDNInfoEnterFunc = function (response)
        local config_list = json.decode(response)

        Cache.Config:updateServerAllocConfig(config_list)

        if not self.view then
            return
        end

        if Cache.Config.config_list then
            self.view:showLogin(true)
        end
        
        --根据上次登录的状态判断是否连接
        local loginType = cc.UserDefault:getInstance():getStringForKey(SKEY.LOGIN_TYPE, VAR_LOGIN_TYPE_NO_LOGIN)
        --初始默认是游客，自动登录
        if loginType == VAR_LOGIN_TYPE_NO_LOGIN then
            -- self.view:showPanelLayer("null")
            loginType = VAR_LOGIN_TYPE_VISITOR
            cc.UserDefault:getInstance():setStringForKey(SKEY.LOGIN_TYPE, loginType)
        end
        if loginType == "-1" or loginType == "2" or loginType == "3" or loginType == "4" then
            qf.event:dispatchEvent(ET.START_TO_LOGIN)
        end
    end

    local func
    func = function(event)
        Util:stopRun(self.handler_scheduler)
        self.handler_scheduler = nil
        if self.handler_http_req.status == 200 then
            local response = self.handler_http_req.response
            getCDNInfoEnterFunc(response)
        else
            self.cdnMaxTryTimes = self.cdnMaxTryTimes - 1
            if self.cdnMaxTryTimes > 0 then
                Util:runOnce(1.5, function ( ... )
                    self:getcdnURL()
                end)
            else
                local cacheResponse = cc.UserDefault:getInstance():getStringForKey("RESPONSE", "null")
                if cacheResponse ~= "null" then
                    if self.handler_scheduler then
                        Util:stopRun(self.handler_scheduler)
                    end
                    self.handler_scheduler = nil
                    getCDNInfoEnterFunc(cacheResponse)
                end
            end
        end
    end
    --此处设置如果请求不到就一直重复请求cdn
    self.handler_http_req:registerScriptHandler(func)
    local response_type = cc.XMLHTTPREQUEST_RESPONSE_JSON
    self.handler_http_req.responseType = response_type

    Util:safeRequestConfigURL(self.handler_http_req, func)
end

function LoginController:initModuleEvent()

end

function LoginController:removeModuleEvent()

end

-- 这里注册与服务器相关的的事件，不销毁
--[[
ET.LOGIN_REQUEST_LAST_SERVER = getUID()
ET.NET_GETCONFIG_DONE = getUID()
]]
function LoginController:initGlobalEvent()
	--登陆上一次登陆的服务器
    qf.event:addEvent(ET.LOGIN_REQUEST_LAST_SERVER,handler(self,self.processGetServerInfo))
    qf.event:addEvent(ET.TOOL_TIPS_CLOSE,handler(self, self.toolTipsClose))
	qf.event:addEvent(ET.NET_GETCONFIG_DONE,handler(self,self.processConfigDone))
    qf.event:addEvent(ET.SHOW_LOGIN,handler(self,self.showLogin))
    qf.event:addEvent(ET.LOGIN_NET_GOTO_LOGIN,handler(self,self.processNettoLogin)) --连接成功的回调
    qf.event:addEvent(ET.LOGIN_SIGN_IN,handler(self,self.processSignin))
    qf.event:addEvent(ET.UPDATE_LOGIN_TIMES,handler(self,self.updateLoginTimes))
    qf.event:addEvent(ET.START_TO_LOGIN,handler(self,self.startToLogin))  --这里不是登录,是连接socket
    qf.event:addEvent(ET.LOGIN_NET_DISCONNECT, handler(self, self.onDisconnect))
    qf.event:addEvent(ET.GLOBAL_CANCELLATION, function ( ... )
        -- body  登出消息先不等网络  直接退回登录界面
        self:onDisconnect()
        NetDelayTool:stop()
        if Util:checkUpdatePackage() then
            qf.event:dispatchEvent(ET.NET_CLOSE_AND_CLOSE_CHAT_SERVICE) --关闭聊天服
            Cache.clear()
        end
    end)
    qf.event:addEvent(ET.RESET_PASSWORD, function (paras)
        if self.view then
            self.view:resetPwd(paras)
        end
    end)
end

function LoginController:updateLoginTimes( ... )
    self.tryLoginCount = nil
end

function LoginController:onDisconnect( ... )
    -- body
    -- body
    if not self.view then
        self.view = self:initView({showLoginBtnPannel = true})
    end
    if not Cache.Config.config_list then
        return
    end
    self.view:showLogin(true)
    self.view:showLoginBtnPannel(true)
    qf.event:dispatchEvent(ET.GLOBAL_WAIT_NETREQ,{method="remove", hard = true})
end

function LoginController:startToLogin( ... )
    -- body
    GameNet:start(self.serverList)
end

function LoginController:processGetServerInfo(paras)
    self._startupTime = os.time()
    local info = TB_SERVER_INFO
    local server_status = Util:getDesDecryptString(info.server_status) and Util:getDesDecryptString(info.server_status) .."" or "0"
    if server_status == "1" then --停服状态
        local billboard = Util:getDesDecryptString(info.billboard)
        qf.event:dispatchEvent(ET.GLOBAL_HANDLE_PROMIT,{body = {type = 1,des = billboard},type = 1})
        return
    end
    loga(json.encode(info.server_list))
    self.serverList = clone(info.server_list)
    -- qf.event:dispatchEvent(ET.LOGIN_WAIT_EVENT,{method="hide"})
    self:processNettoLogin()
    --GameNet:start(info.server_list)  --这里不要马上连接，会无限触发重连
    -- GameNet:start({{"192.168.199.113",29001}})
end

-- optional string sign = 1;         // 签名 md5(secret|openid|access_token)
-- optional string openid = 2;       // 微信 openid
-- optional string access_token = 3; // access_token
-- optional string expire_date = 4;  // 过期时间
-- optional string channel = 5;      // channel
-- optional int32 version = 6;       // version
-- optional string os = 7;           // 系统
-- optional string lang = 8;         // language
function LoginController:qqOrFacebookSignin()
    local orginInfo = qf.platform:getRegInfo()
    local ot = Util:getOpenIDAndToken()

    if ot.openid and VAR_LOGIN_TYPE_NO_LOGIN ~= ot.type then -- openid存在并且type不为0时直接登录，否则显示登录界面
        local device_id = orginInfo.device_id
        local body ={}
        body.sign = QNative:shareInstance():md5(UNITY_PAY_SECRET.."|"..ot.openid.."|"..ot.token.."|"..device_id)
        body.openid = ot.openid
        body.access_token = ot.token
        body.expire_date = ___tmpsdkaccountloginDate
        body.channel = orginInfo.channel
        body.version = orginInfo.version
        body.os = orginInfo.os
        body.lang = orginInfo.lang
        body.res_md5 = STRING_UPDATE_FILE_MD5 -- 更新文件列表的md5
        body.device_id = device_id
        body.hot_version = orginInfo.version
        local cmd = Util:isLanguageChinese() and (ot.type == "1" and CMD.QQ_REG or CMD.WX_REG) or CMD.FACEBOOK_REG
        self:_signIn(cmd,body)
    else
        qf.event:dispatchEvent(ET.SHOW_LOGIN)

    end
end

--这里只有游客登录才会走了
function LoginController:processSignin(paras)
    if paras == nil or paras.cmd == nil or paras.body == nil then return end
    local _type = cc.UserDefault:getInstance():getStringForKey(SKEY.LOGIN_TYPE, VAR_LOGIN_TYPE_NO_LOGIN)
    if VAR_LOGIN_TYPE_NO_LOGIN == _type then
        qf.event:dispatchEvent(ET.SHOW_LOGIN)
    else
        return self:_signIn(paras.cmd,paras.body)
    end
end

function LoginController:toolTipsClose( ... )
    self.isloginFail = false
    self.tryTimes = 0
end

function LoginController:_signIn(cmd,body,timeout,isQufan)
    if ModuleManager:judegeIsInMain() and Cache.user.uin and not ModuleManager:judegeIsInLogin() and GameNet.bConnected then
        return
    end
    if not isQufan then
        qf.event:dispatchEvent(ET.LOGIN_WAIT_EVENT,{method="show",txt=GameTxt.login003})
    end
    loga("LoginController:_signIn  Body= " ..tostring(qf.json.encode(body)))
    loga(cmd)
    if cmd == CMD.REG or cmdLogin == CMD.PHONE_LOGIN_PIN then
        body.invite_from = Util:getInviteCode()
        xpcall(
            function()
                body.client_ip = Cache.Config:getIPAddress()
            end,
            function() 
                body.client_ip = Util:getDesDecryptString(TB_SERVER_INFO.client_ip) or ""
            end
        )
    end

    if self.view then
        self.view:showPanelLayer("null")
    end

    local callback = function (rsp)
        loga("登录返回"..rsp.ret)
        if rsp.ret == 1096 or rsp.ret == 1094 or rsp.ret == 1050 then
            if self.isloginFail then
                return
            end
            if rsp.ret == 1096 then
                qf.event:dispatchEvent(ET.LOGIN_WAIT_EVENT,{method="hide"})
                if not self.view then
                    self:getView()
                end
                self.view:showToolsTips(rsp.model.uin)
                self.view:showPanelLayer("LoginTypePannel")
            end

            if rsp.ret == 1050 then
                qf.event:dispatchEvent(ET.LOGIN_WAIT_EVENT,{method="hide"})
                if not self.view then
                    self:getView()
                end
                self.view:showToolsTips2(GameTxt.login009)
                self.view:showPanelLayer("LoginTypePannel")
            end
            if self.view then
                self.view:setVisible(true)
            end
            
            self.isloginFail = true
            self.tryTimes = self.MaxTryTimes
            sdkaccount = cc.UserDefault:getInstance():setBoolForKey(SKEY.SDKACCOUNT_LOGIN, true) -- 默认为true，在这里只是判断之前有没有使用游客账号进行登录过（老版本中游客账号登录后此值为false）
            cc.UserDefault:getInstance():setStringForKey(SKEY.LOGIN_TYPE, VAR_LOGIN_TYPE_NO_LOGIN)
            GameNet:reReg()
            return
        end
        if rsp.ret ~= 0 then
            self.sign_in_ret = rsp.ret
            if rsp.ret ~= -200 then
                cc.UserDefault:getInstance():setStringForKey("loginBody", "")
                cc.UserDefault:getInstance():setStringForKey(SKEY.LOGIN_TYPE, VAR_LOGIN_TYPE_NO_LOGIN)
            end
            if self.view then
                self.view:setVisible(true)
            end
            
            GameNet:reReg()
            return
        end
        if self.view then
            self.view.touchToLogin = false
        end
        self.tryTimes = 0 --重置尝试登陆
        Cache.user:updateCacheByLogin(rsp.model)
        cc.UserDefault:getInstance():setIntegerForKey(SKEY.UIN,Cache.user.uin)
        cc.UserDefault:getInstance():flush()
        local _config = GameNet:getDataBySignedBody(rsp.model.config, CMD.CONFIG)

        if not _config then
            -- 解析失败
            GameNet:reReg()
        elseif xpcall(

            function() 

                Cache.Config:saveConfig(_config.model)
                
            end,
            function() 
                game.uploadError(debug.traceback())
                game.uploadError(" 存储config出错的model-->>"..tostring(_config.model))
            end) 
        then
            self.isloginFail = false
            cc.UserDefault:getInstance():setStringForKey("userState", "hall")
            cc.UserDefault:getInstance():flush()
            qf.event:dispatchEvent(ET.NET_GETCONFIG_DONE)
        else
            -- 保存配置失败/出错
            GameNet:reReg()
        end
    end
    self:refreshSaveBodyData(body)
    GameNet:send({cmd=cmd,body=body,timeout=timeout,callback=callback})
end

--[[
    1.由于会发生覆盖安装，那么对应的版本会不一致，所以要重新刷新下userdefault存储的数据
    2.遍历属性
    3.如果不处理会出现用户版本不能覆盖的问题
]]
function LoginController:refreshSaveBodyData(body)
    local newData = qf.platform:getRegInfo()
    local keyMap = table.keys(newData)
    local ignoreKey = {"uuid"}
    for _,v in pairs(ignoreKey) do
        table.removebyvalue(keyMap, v, true)
    end
    
    local bodyKeyMap = table.keys(body)
    for _,v in pairs(keyMap) do
        for _,value in pairs(bodyKeyMap) do
            if v == value then
                body[value] = newData[value]
            end
        end
    end
end

--[[----]]
function LoginController:processNettoLogin()
    local loginType = cc.UserDefault:getInstance():getStringForKey(SKEY.LOGIN_TYPE, VAR_LOGIN_TYPE_NO_LOGIN)
    local jsonBody = cc.UserDefault:getInstance():getStringForKey("loginBody", nil)
    local body = {}
    if jsonBody and jsonBody ~= "" then
        body = json.decode(jsonBody)
    end

    if (loginType == VAR_LOGIN_TYPE_PHONE_PIN or loginType == VAR_LOGIN_TYPE_PHONE_PWD) and (not jsonBody or jsonBody == "") then
        cc.UserDefault:getInstance():setStringForKey(SKEY.LOGIN_TYPE, VAR_LOGIN_TYPE_NO_LOGIN)
        cc.UserDefault:getInstance():setStringForKey("loginBody", "")
        cc.UserDefault:getInstance():flush()
        loginType = VAR_LOGIN_TYPE_NO_LOGIN
    end
    -- if loginType == VAR_LOGIN_TYPE_PHONE_REG then
    --     if body.login_type and body.login_type == 1 then
    --         loginType = VAR_LOGIN_TYPE_PHONE_PWD
    --     end
    -- end

    print("loginType >>>>>>>>", loginType)
    self.tryTimes = self.tryTimes or 0
    if loginType then
        local cmdLogin = 0
        if loginType == VAR_LOGIN_TYPE_NO_LOGIN then --更换账户(不自动登录)
            --qf.event:dispatchEvent(ET.SHOW_LOGIN)
			return
        elseif loginType == VAR_LOGIN_TYPE_VISITOR then
            local regInfo = qf.platform:getRegInfo()
            xpcall(
                function()
                    regInfo.client_ip = Cache.Config:getIPAddress()
                end,
                function() 
                    regInfo.client_ip = Util:getDesDecryptString(TB_SERVER_INFO.client_ip) or ""
                end
            )
            
            qf.event:dispatchEvent(ET.LOGIN_SIGN_IN,{cmd = CMD.REG,body=regInfo})
            return
        elseif loginType == VAR_LOGIN_TYPE_WECHAT then
            cmdLogin = CMD.WX_REG
        elseif loginType == VAR_LOGIN_TYPE_PHONE_PWD then
            cmdLogin = CMD.PHONE_LOGIN_PWD
        elseif loginType == VAR_LOGIN_TYPE_PHONE_PIN then --验证码登录按照设置的密码登录
            cmdLogin = CMD.PHONE_LOGIN_PIN
        elseif loginType == VAR_LOGIN_TYPE_PHONE_REG then
            cmdLogin = CMD.PHONE_LOGIN_PIN
        elseif loginType == VAR_LOGIN_TYPE_PHONE_FIND then
            --找回密码
            local jsonBody = cc.UserDefault:getInstance():getStringForKey("findBody", nil)
            if not jsonBody or jsonBody == "" then
                --qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_login_18})
                qf.event:dispatchEvent(ET.GLOBAL_CANCELLATION)
                return
            end
            local body = json.decode(jsonBody)
            self:refreshSaveBodyData(body)
            GameNet:send({cmd=CMD.PHONE_FIND_PWD,body=body,timeout=nil,callback=function(rsp)
                loga("reqUpdatePwd rsp "..rsp.ret)
                
                qf.event:dispatchEvent(ET.GLOBAL_CANCELLATION)
                qf.event:dispatchEvent(ET.GLOBAL_WAIT_NETREQ,{method="remove"})
                
                if rsp.ret ~= 0 then
                    qf.event:dispatchEvent(ET.LOGIN_WAIT_EVENT,{method="hide"})
                    if rsp.ret == 2005 then
                        qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_login_19})
                    else
                        qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_login_20})
                    end
                else
                    qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_login_20})
                    --重新回到登陆界面
                    self.view:showPanelLayer()
                    return
                end
            end})
            return
        elseif loginType == VAR_LOGIN_TYPE_PHONE_SET then
            --设置密码
            local jsonBody = cc.UserDefault:getInstance():getStringForKey("setBody", nil)
            if not jsonBody or jsonBody == "" then
                --qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_login_21})
                qf.event:dispatchEvent(ET.GLOBAL_CANCELLATION)
                return
            end

            local body = json.decode(jsonBody)
            local zoneTemp = body.zone
            body.zone = nil
            self:refreshSaveBodyData(body)
            GameNet:send({cmd=CMD.PHONE_SET_PWD,body=body,timeout=nil,callback=function(rsp)
                loga("reqUpdatePwd rsp "..rsp.ret)
                qf.event:dispatchEvent(ET.GLOBAL_CANCELLATION)
                qf.event:dispatchEvent(ET.GLOBAL_WAIT_NETREQ,{method="remove"})
                if rsp.ret ~= 0 then
                    qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_login_22})
                    return
                else
                    qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_login_23})
                    --self.view:showPanelLayer() 密码设置成功之后自动登录游戏
                    local reg = qf.platform:getRegInfo()
                    self.loginbody = {}
                    self.loginbody.phone = body.phone
                    self.loginbody.passwd = body.passwd
                    self.loginbody.sign = QNative:shareInstance():md5(qf.platform:getKey().."|"..self.loginbody.phone.."|"..self.loginbody.passwd)
                    self.loginbody.channel = reg.channel
                    self.loginbody.version = reg.version
                    self.loginbody.os = reg.os
                    self.loginbody.zone = zoneTemp
                    xpcall(
                        function()
                            self.loginbody.client_ip = Cache.Config:getIPAddress()
                        end,
                        function() 
                            self.loginbody.client_ip = Util:getDesDecryptString(TB_SERVER_INFO.client_ip) or ""
                        end
                    )
                    cc.UserDefault:getInstance():setStringForKey("loginBody", json.encode(self.loginbody))
                    cc.UserDefault:getInstance():setStringForKey(SKEY.LOGIN_TYPE, VAR_LOGIN_TYPE_PHONE_PWD)
                    cc.UserDefault:getInstance():flush()
                    body = self.loginbody
                    body.zone = nil
                    
                    cmdLogin = CMD.PHONE_LOGIN_PWD
                    qf.event:dispatchEvent(ET.LOGIN_WAIT_EVENT,{method="show",txt=GameTxt.login003})
                    if self.view then
                        self.view:showPanelLayer("null")
                    end
                    self:refreshSaveBodyData(body)
                    GameNet:send({cmd=cmdLogin,body=body,timeout=nil,callback=function(rsp)
                        loga("phone send login rsp  +++++++"..rsp.ret)

                        if rsp.ret ~= 0 then
                            if rsp.ret == 1049 then
                                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_login_24})
                            elseif rsp.ret == 2003 then
                                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_login_25})
                            elseif rsp.ret == 2005 then                    
                                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_login_26})
                            elseif rsp.ret == 1022 then
                                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_login_27})
                            elseif rsp.ret == 2004 then
                                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_login_28})
                            else
                                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
                            end

                            qf.event:dispatchEvent(ET.GLOBAL_CANCELLATION)
                            qf.event:dispatchEvent(ET.LOGIN_WAIT_EVENT,{method="hide"})
                            qf.event:dispatchEvent(ET.GLOBAL_WAIT_NETREQ,{method="remove"})
                            cc.UserDefault:getInstance():setStringForKey("loginBody", "")
                            cc.UserDefault:getInstance():setStringForKey(SKEY.LOGIN_TYPE, VAR_LOGIN_TYPE_NO_LOGIN)
                            if self.view then
                                self.view:showPanelLayer()
                            end
                            return
                        end
                        Cache.user:updateCacheByLogin(rsp.model)
                        cc.UserDefault:getInstance():setIntegerForKey(SKEY.UIN,Cache.user.uin)
                        cc.UserDefault:getInstance():flush()
                        local _config = GameNet:getDataBySignedBody(rsp.model.config, CMD.CONFIG)

                        if not _config then
                            -- 解析失败
                            loga("-----------config-------------------config fail")
                            qf.event:dispatchEvent(ET.GLOBAL_CANCELLATION)
                            --GameNet:reReg()
                        elseif xpcall(

                            function() 

                                Cache.Config:saveConfig(_config.model)
                                
                            end,
                            function() 
                                game.uploadError(debug.traceback())
                                game.uploadError(" 存储config出错的model-->>"..tostring(_config.model))
                            end) 
                        then
                            --qf.event:dispatchEvent(ET.NET_GETCONFIG_DONE)
                            loga("rsp.model.login_type = "..rsp.model.login_type.."    rsp.model.is_new_reg_user = "..rsp.model.is_new_reg_user)
                            --if tonumber(rsp.model.login_type) == 16 and tonumber(rsp.model.is_new_reg_user) == 1 then --该条件作废
                            if tonumber(rsp.model.show_passwd_set) == 1 then
                                self.view:showPanelLayer("setPwd")
                                qf.event:dispatchEvent(ET.GLOBAL_CANCELLATION)
                                return
                            else
                                if self.view then
                                    self.view:removeAllScheduler()
                                end
                                
                                local cmpIndex = 0
                                if body.phone then
                                    local phone = cc.UserDefault:getInstance():getStringForKey("loginPhone", "")
                                    local zone =  cc.UserDefault:getInstance():getStringForKey("loginZone", "")
                                    if phone == "" then
                                        phone = body.phone
                                        cc.UserDefault:getInstance():setStringForKey("loginPhone",phone)
                                        cc.UserDefault:getInstance():setStringForKey("loginZone",zoneTemp)
                                    else
                                        --判断跟之前登录的手机号是不是相同的，相同的就不记录了
                                        local phoneTable = string.split(phone,"|")
                                        local zoneTable = string.split(zone, "|")
                                        for i = 1, #phoneTable do
                                            --有相同的，删掉然后再末尾加上最新的
                                            if phoneTable[i] == body.phone then
                                                cmpIndex = i
                                                table.remove(phoneTable, i)
                                                table.remove(zoneTable, i)
                                                break
                                            end
                                        end
                                        --最后一个还不同，就加上
                                        table.insert(phoneTable, body.phone)
                                        local allPhone = table.concat(phoneTable, "|")
                                        cc.UserDefault:getInstance():setStringForKey("loginPhone",allPhone)

                                        table.insert(zoneTable, zoneTemp)
                                        local allZone = table.concat(zoneTable, "|")
                                        cc.UserDefault:getInstance():setStringForKey("loginZone",allZone)
                                    end
                                end
                                if body.passwd then
                                    if cmpIndex ~= 0 then
                                        local userPwd = cc.UserDefault:getInstance():getStringForKey("loginPwd", "")
                                        local pwdTable = string.split(userPwd,"|")
                                        table.remove(pwdTable, cmpIndex)
                                        local allPwd = table.concat(pwdTable, "|")
                                        cc.UserDefault:getInstance():setStringForKey("loginPwd", allPwd)
                                    end

                                    local userPwd = cc.UserDefault:getInstance():getStringForKey("loginPwd", "")
                                    if userPwd == "" then
                                        userPwd = body.passwd
                                    else
                                        userPwd = userPwd.."|"..body.passwd
                                    end 
                                    cc.UserDefault:getInstance():setStringForKey("loginPwd", userPwd)
                                end
                                cc.UserDefault:getInstance():setStringForKey("userState", "hall")
                                cc.UserDefault:getInstance():flush()
                                qf.event:dispatchEvent(ET.NET_GETCONFIG_DONE)
                                return
                            end
                        else
                            -- 保存配置失败/出错
                            --GameNet:reReg()
                        end
                    end})
                    return
                end
            end})
            return
        end

        if not jsonBody or jsonBody == "" then
            if self.view then
                self.view:showPanelLayer("LoginTypePannel")
            end
            if self.view then
                self.view:setVisible(true)
            end
            GameNet:reReg(true)
            return
        end

        --登录
        local body = json.decode(jsonBody)
        if loginType == "5" then --手机注册改下参数
            body.login_type = 1
            --手机注册（增加手机号）
            body.uuid = body.uuid .. "-" .. (body.phone or "")
        elseif loginType == "4" then
            body.login_type = 2
            body.passwd = ""
        end
        if cmdLogin == CMD.REG or cmdLogin == CMD.PHONE_LOGIN_PIN then
            body.invite_from = Util:getInviteCode()
            xpcall(
                function()
                    body.client_ip = Cache.Config:getIPAddress()
                end,
                function() 
                    body.client_ip = Util:getDesDecryptString(TB_SERVER_INFO.client_ip) or ""
                end
            )
        end
        local zoneTemp = body.zone
        if cmdLogin == CMD.PHONE_LOGIN_PWD then
            xpcall(
                function()
                    body.client_ip = Cache.Config:getIPAddress()
                end,
                function() 
                    body.client_ip = Util:getDesDecryptString(TB_SERVER_INFO.client_ip) or ""
                end
            )
            --重新设置
            local tempBoby = {}
            tempBoby.phone = body.phone
            tempBoby.passwd = body.passwd
            tempBoby.sign = body.sign
            tempBoby.channel = body.channel
            tempBoby.version = body.version
            tempBoby.os = body.os
            tempBoby.client_ip = body.client_ip
            body = tempBoby
        end
        qf.event:dispatchEvent(ET.LOGIN_WAIT_EVENT,{method="show",txt=GameTxt.main001})
        if self.view then
            self.view:showPanelLayer("null")
        end

        if cmdLogin ~= CMD.PHONE_LOGIN_PIN then
            body.zone = nil 
        end
        self:refreshSaveBodyData(body)
        GameNet:send({cmd=cmdLogin,body=body,timeout=nil,callback=function(rsp)
            loga("phone send login rsp  ---- "..rsp.ret)
            if rsp.ret ~= 0 then
                --ret == 2003账号已注册，走找回密码流程
                if self.view then
                    self.view:setVisible(true)
                end
                qf.event:dispatchEvent(ET.LOGIN_WAIT_EVENT,{method="hide"})
                if rsp.ret == 1049 then
                    self.tryTimes = self.MaxTryTimes
                    qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_login_24})
                elseif rsp.ret == 2003 then
                    self.tryTimes = self.MaxTryTimes
                    qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_login_25})
                elseif rsp.ret == 2005 then
                    self.tryTimes = self.MaxTryTimes
                    qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_login_26})
                elseif rsp.ret == 1022 then
                    self.tryTimes = self.MaxTryTimes
                    qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_login_27})
                elseif rsp.ret == 2004 then
                    self.tryTimes = self.MaxTryTimes
                    qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_login_28})
                else
                    qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = Cache.Config._errorMsg[rsp.ret]})
                end
                --超过最大次数的时候 消除存储的登录方式与信息
                --已经确认过具体原因的就不再尝试了
                if self.tryTimes == self.MaxTryTimes or (rsp.ret == -200 and loginType == VAR_LOGIN_TYPE_PHONE_REG) then
                    qf.event:dispatchEvent(ET.GLOBAL_CANCELLATION)
                    qf.event:dispatchEvent(ET.LOGIN_WAIT_EVENT,{method="hide"})
                    qf.event:dispatchEvent(ET.GLOBAL_WAIT_NETREQ,{method="remove"})
                    cc.UserDefault:getInstance():setStringForKey("loginBody", "")
                    cc.UserDefault:getInstance():flush()
                    if self.view then
                        self.view:showPanelLayer()
                    end
                    self.tryTimes = 0
                else
                    self.tryTimes = self.tryTimes + 1
                end
                return
            end
            
            qf.event:dispatchEvent(ET.GLOBAL_WAIT_NETREQ,{method="remove"})
            self.tryTimes = 0
            Cache.user:updateCacheByLogin(rsp.model)
            cc.UserDefault:getInstance():setIntegerForKey(SKEY.UIN,Cache.user.uin)
            --如果注册成功，则下次
            if loginType == VAR_LOGIN_TYPE_PHONE_REG then
                cc.UserDefault:getInstance():setStringForKey(SKEY.LOGIN_TYPE, VAR_LOGIN_TYPE_PHONE_PWD)
            end
            cc.UserDefault:getInstance():flush()
            
            local _config = GameNet:getDataBySignedBody(rsp.model.config, CMD.CONFIG)
            if not _config then
                -- 解析失败
                loga("-----------config-------------------config fail")
                qf.event:dispatchEvent(ET.GLOBAL_CANCELLATION)
                --GameNet:reReg()
            elseif xpcall(

                function() 

                    Cache.Config:saveConfig(_config.model)
                    
                end,
                function() 
                    game.uploadError(debug.traceback())
                    game.uploadError(" 存储config出错的model-->>"..tostring(_config.model))
                end) 
            then
                loga("rsp.model.login_type = "..rsp.model.login_type.."    rsp.model.is_new_reg_user = "..rsp.model.is_new_reg_user)
                if tonumber(rsp.model.show_passwd_set) == 1 then
                    self.view:showPanelLayer("setPwd")
                    qf.event:dispatchEvent(ET.GLOBAL_CANCELLATION)
                    return
                else
                    if self.view and tolua.isnull(self.view) == false then
                        self.view:removeAllScheduler()
                    end
                    local cmpIndex = 0
                    if body.phone then
                        local phone = cc.UserDefault:getInstance():getStringForKey("loginPhone", "")
                        local zone =  cc.UserDefault:getInstance():getStringForKey("loginZone", "")
                        if phone == "" then
                            phone = body.phone
                            cc.UserDefault:getInstance():setStringForKey("loginPhone",phone)
                            cc.UserDefault:getInstance():setStringForKey("loginZone",zoneTemp)
                        else
                            --判断跟之前登录的手机号是不是相同的，相同的就不记录了
                            local phoneTable = string.split(phone,"|")
                            local zoneTable = string.split(zone, "|")
                            for i = 1, #phoneTable do
                                --有相同的，删掉然后再末尾加上最新的
                                if phoneTable[i] == body.phone then
                                    cmpIndex = i
                                    table.remove(phoneTable, i)
                                    table.remove(zoneTable, i)
                                    break
                                end
                            end
                            --最后一个还不同，就加上
                            table.insert(phoneTable, body.phone)
                            local allPhone = table.concat(phoneTable, "|")
                            cc.UserDefault:getInstance():setStringForKey("loginPhone",allPhone)

                            table.insert(zoneTable, zoneTemp)
                            local allZone = table.concat(zoneTable, "|")
                            cc.UserDefault:getInstance():setStringForKey("loginZone",allZone)
                        end
                    end
                    if body.passwd then
                        if cmpIndex ~= 0 then
                            local userPwd = cc.UserDefault:getInstance():getStringForKey("loginPwd", "")
                            local pwdTable = string.split(userPwd,"|")
                            table.remove(pwdTable, cmpIndex)
                            local allPwd = table.concat(pwdTable, "|")
                            cc.UserDefault:getInstance():setStringForKey("loginPwd", allPwd)
                        end

                        local userPwd = cc.UserDefault:getInstance():getStringForKey("loginPwd", "")
                        if userPwd == "" then
                            userPwd = body.passwd
                        else
                            userPwd = userPwd.."|"..body.passwd
                        end 
                        cc.UserDefault:getInstance():setStringForKey("loginPwd", userPwd)
                    end
                    if rsp.model.show_promotion == 1 and loginType ~= "2" then --是否展示填入邀请码  0 不展示 1展示 loginType = 2微信登录不做这个判断
                        local function callfunc( ... )
                            -- body
                            cc.UserDefault:getInstance():setStringForKey("userState", "hall")
                            cc.UserDefault:getInstance():flush()

                            qf.event:dispatchEvent(ET.NET_GETCONFIG_DONE)
                        end
                        local function preCall( ... )
                            -- body
                            if self.view and tolua.isnull(self.view) == false then
                                self.view:showPanelLayer("null")
                            end 
                        end
                        --qf.event:dispatchEvent(ET.MAIN_BUTTON_CLICK,{name = "inviteCode", overCb = callfunc, cb = preCall})
                        qf.event:dispatchEvent(ET.INVITE_CODE)
                        if self.view then
                            self.view:setVisible(true)
                        end
                        qf.event:dispatchEvent(ET.LOGIN_WAIT_EVENT,{method="hide"})
                        return 
                    end
                    cc.UserDefault:getInstance():setStringForKey("userState", "hall")
                    cc.UserDefault:getInstance():flush()

                    qf.event:dispatchEvent(ET.NET_GETCONFIG_DONE)
                end
            else
                -- 保存配置失败/出错
                --GameNet:reReg()
            end
        end})
    end
end

function LoginController:processConfigDone()
    loga(" --- get user config success , now go to main game ----",self.TAG)
	logd(" --- get user config success , now go to main game ----",self.TAG)
    qf.event:dispatchEvent(ET.GLOBAL_WAIT_NETREQ,{method="remove",hard=true})
    local callback =  function (model)
        self.isProcessCofnigDone = false
        -- 这里是已经登录成功了-把自己的头像删除重新拉取-防止美女认证成功后头像没改变
        local _url = Util:getHURLByUin(Cache.user.uin)
        local _path = qf.downloader:getFilePathByUrl(_url)
        cc.Director:getInstance():getTextureCache():removeTextureForKey(_path)
        qf.downloader:removeFile(_url)

        local costTime = os.time() - self._startupTime
        Cache.Config._loginRewardCheck = 0 -- 登录奖励校验字段 
        Cache.Config._needJoinAni = false
        Cache.Config._activeNoticeCheak = 0 -- 活动通知校验
        Cache.packetInfo:saveConfig(model)
        
        -- 这里在初始化界面统计
        AnalyseTools:init()
        self:startLoadChatWebSocket()

        -- 登陆检查未完成的订单
        qf.platform:checkUnFinishIAPOrder({
            hostName = HOST_BILL,
            orderSource = "bull"
        })

        PopupManager:removeAllPopup()
        ModuleManager.gameshall:remove()
        ModuleManager.gameshall:show({ani=1, lastview = "loginview"})
        
        self:remove()
        qf.event:dispatchEvent(ET.LOGIN_WAIT_EVENT,{method="hide"})
        qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="hide"})
        qf.event:dispatchEvent(ET.NET_AUTO_INPUT_ROOM)
        Scheduler:delayCall(1/60, function ( ... )
           NetDelayTool:init()
        end, true)
    end

    qf.event:dispatchEvent(ET.NET_USER_INFO_REQ,{uin=Cache.user.uin,
        callback = callback
    })
end

-- 登录成功后连接聊天服务器
function LoginController:startLoadChatWebSocket( ... )
    if Util:checkNotUpdatePackage() then
        return
    end
    --连接聊天服务器
    ChatServer:init()
    ChatServer:startConnect(Cache.Config:getChatServerIPAddress())
    Cache.cusChatInfo:clear()
    Cache.cusChatInfo:startDataMonite()
end

function LoginController:showLogin()
    if self.view == nil then  self.view = self:getView() end
    -- qf.event:dispatchEvent(ET.LOGIN_WAIT_EVENT,{method="hide"})
    qf.event:dispatchEvent(ET.GLOBAL_WAIT_EVENT,{method="hide"})
end

function LoginController:initView(parameters)
    cc.UserDefault:getInstance():setStringForKey("userState", "login")
    qf.event:dispatchEvent(ET.MODULE_SHOW,"login")
    ModuleManager.gameshall:remove()
    local view = loginView.new(parameters)
    if parameters then
        view:setVisible(parameters.showLoginBtnPannel)
    end
    return view
end

function LoginController:remove()
    qf.event:dispatchEvent(ET.MODULE_HIDE,"login")
    self.super.remove(self)
end

return LoginController