local Config = class("Config")

Config.START_SNG_ROOMID = 20001 --SNG场起始roomid

--[[连续登陆奖励]]
Config._dayReward = {}
--[[活动列表]]
Config._activityList = {}
--新每日登录奖励
Config._loginReward = {}

--破产返利配置
Config._bankruptcy_returnList = {}

Config.when_to_share = {}

--[[错误信息]]
Config._errorMsg = {}

--比赛积分名称配置信息
Config.credit_level = {}

-- 商城内广告条
Config._store_activities = {}


--推豹子--
Config._jhroomList = {}
Config._tbzroomList = {}
Config._tbzcustomize_roomlist = {}  -- 推豹子私人订制信息

function Config:ctor ()
    self.ipaddress = ""
    self.phoneCodeConfig = {}
end

function Config:getPhoneCodeConfig( ... )
    if #self.phoneCodeConfig == 0 then
        CSVTool:create(GameRes.phone_country_code)
        self.phoneCodeConfig = CSVTool:getAllData()
    end
    return self.phoneCodeConfig
end

function Config:getIndexByPhoneCode(code)
    local index = -1
    for k, v in pairs(self.phoneCodeConfig) do
        if v['PhoneCode'] and v['PhoneCode'] .. "+" == code then
            index = k
            break
        end
    end
    return index
end

function Config:updateIPAddress(ip)
    -- logi("====== Config:updateIPAddress start ======" .. ip)
    -- logi("\n")
    -- logi("                ip=" .. ip .. "           ")
    -- logi("\n")
    -- logi("====== Config:updateIPAddress end ======")
    if ip and ip ~= "" then
        self.ipaddress = Util:getDesDecryptString(ip)
    end
end

function Config:getIPAddress()
    if self.ipaddress and self.ipaddress ~= "" then
        logi("【Normal】 当前设备ip=" .. self.ipaddress)
        return self.ipaddress
    end
    if TB_SERVER_INFO and TB_SERVER_INFO.client_ip then
        self:updateIPAddress(TB_SERVER_INFO.client_ip)
    end
    logi("【TB_SERVER_INFO】 当前设备ip=" .. self.ipaddress)
    return self.ipaddress
end

function Config:getChatServerIPAddress()
    local ip = ""
    if self.config_list then
        if self.config_list["chat_tcp_server"] then
            ip = Util:getDesDecryptString(self.config_list.chat_tcp_server)
        end
    end
    return ip
end

function Config:getChatHttpAddress( ... )
    local ip = ""
    if self.config_list then
        if self.config_list["chat_web_server"] then
            ip = Util:getDesDecryptString(self.config_list.chat_web_server)
        end
    end
    return ip
end

function Config:getWebHost( ... )
    local host = HOST_PREFIX .. HOST_NAME
    if self.config_list then
        if self.config_list["web_host"] then
            host = Util:getDesDecryptString(self.config_list.web_host)
        end
    end
    return host
end

function Config:getConfigModel()
    return self.configModel
end

function Config:saveConfig(model)
    self.configModel = model
    self.timestamp = model.timestamp            --时间戳
    self.broadcastCost = model.broadcast_cost
    self.qq_prompt = model.qq_prompt or ""              --“官方Q群”字符串
    self.qq_prompt_last = model.qq_prompt_last or ""    --qq号
    
    self._hasPickBeautyDayReward = model.has_pick_beauty_day_reward --是否领取了美女日常奖励
    self._defaultDelayTime = model.default_delay --超时时间
    self.phoneNum = model.phone --绑定的手机号

    self:initStoreActivities(model.store_activities)

    self.shop_activity_id = model.store_activity.activity_id -- 商城活动id
    self.shop_banner_url = model.store_activity.banner_url -- 商城活动图片url
    self.shop_activity_url = model.store_activity.activity_url -- 商城活动url

    self.bankrupt_count = model.bankrupt_count

    --模块位更新
    self:updateModuleControl(model)
    
    for i=1,model.activity_rewards:len() do
        local item = model.activity_rewards:get(i)
        self._activityList[i] = {}
        self._activityList[i].id = item.id
        self._activityList[i].gold = item.gold
        if item.id == 1 then self._firstFlushGold = item.gold end --首充奖励
        if item.reward_gold_list then 
            self._activityList[i].reward_gold_list = {}
            for j = 1,item.reward_gold_list:len() do
                self._activityList[i].reward_gold_list[j] = item.reward_gold_list:get(j)
            end
        end
    end

    self:copyArray(model.dayreward,self._dayReward)--日常奖励
    for i = 1, model.dayreward:len() do
        local item = model.dayreward:get(i)
        self._dayReward[i] = item
    end
    
    --获取错误信息start
    for i=1,model.error_list:len() do
        local errorInfo = model.error_list:get(i)
        self._errorMsg[errorInfo.id]= errorInfo.desc;
        --local a = "\\"..table.concat({string.byte(s,1,-1)},"\\") 
    end
    self._errorMsg[-200]= GameTxt.nettimeout
    --用户未登陆就不要提示给用户了
    self._errorMsg[14] = ""
    
    if model.daily_rewards_v2 ~= nil then
        -- dump(model.daily_rewards_v2)
        for i=1 ,model.daily_rewards_v2:len() do
            -- logd("cache loginreward list :"..i)
            local reward = model.daily_rewards_v2:get(i)
            self._loginReward[i] = {}
            self._loginReward[i].index = reward.index
            self._loginReward[i].Gifts = {}
            for j=1, reward.items:len() do
                local item =  reward.items:get(j)
                self._loginReward[i].Gifts[j] = {}
                self._loginReward[i].Gifts[j].type = item.type 
                self._loginReward[i].Gifts[j].amount = item.amount
                self._loginReward[i].Gifts[j].desc = item.desc
            end

        end
        -- dump(self._loginReward)
    end
   
    self:updateTimeBox(model.time_box)
    self:updateWhenToShare(model.when_to_share)
    
    --默认头像
    self.hiding_portrait = {}
    if model.hiding_portrait ~= nil and model.hiding_portrait:len() >= 2 then
		self.hiding_portrait[1] = model.hiding_portrait:get(1)
		self.hiding_portrait[2] = model.hiding_portrait:get(2)
    end

    --破产数值
    self.bankrupt_money = model.bankrupt_money

    --破产返利配置
    self:updateBrokeReturn(model.broke_return)

    --比赛积分获得对应的称号配置
    self:saveCreditLevel(model.credit_level)

   -- self:updateCredit_level(model.credit_level)

    --钻石兑换金币的比例
    self.diamond2gold_ratio = model.diamond2gold_ratio

    --破产补助领取次数
    self:setBankruptcyFetchCount(model.fetch_broke_count)

    --是否支持百人场显示
    self.bairen_support = model.bairen_support

    self.isShowAgreementNotice = model.agreement_switch

    --推豹子
    self.tbz_roomList={}
    for i=1,model.tbz_room_conf:len() do
        local roomInfo = model.tbz_room_conf:get(i)
        local r2 = {}
        self:copyFiled({"room_name","room_id","desk_id","banker_min","banker_max","buyin_min","buyin_max","group","seat_limit","player_num","bets","using_password"},roomInfo,r2)
        r2.bets = {}
        for i=1,roomInfo.bets:len() do
            r2.bets[i] = roomInfo.bets:get(i)
        end
        self._tbzroomList[i]= r2
        self.tbz_roomList[r2.room_id]= r2
    end

    --[[   下庄配置    ]]
    self._tbzcustomize_roomlist.banker_quit_mode = {}

    for i = 1, model.banker_quit_mode:len() do
        local item = model.banker_quit_mode:get(i)
        local r2 = {}
        self:copyFiled({"mode","name"},item,r2)
        self._tbzcustomize_roomlist.banker_quit_mode[i] = r2
        if r2.name then
        end
    end

    --抢庄牛牛
    self.bull_fry_room = {}
    self.bull_fry_room.mount = 0
    for i=1,model.bull_fry_room:len() do
        local item = model.bull_fry_room:get(i)
        self.bull_fry_room[item.room_level] = {}
        self.bull_fry_room[item.room_level].room_name = item.room_name
        self.bull_fry_room[item.room_level].base_chip = item.base_chip
        self.bull_fry_room[item.room_level].enter_limit_low = item.enter_limit_low
        self.bull_fry_room[item.room_level].enter_limit_high = item.enter_limit_high
        self.bull_fry_room[item.room_level].online_user_count = item.online_user_count
        self.bull_fry_room[item.room_level].room_level = item.room_level
        self.bull_fry_room[item.room_level].pic_url    = item.pic_url
        self.bull_fry_room[item.room_level].disable    = item.disable
        self.bull_fry_room.mount = self.bull_fry_room.mount + item.online_user_count

    end

    --经典抢庄牛牛
    self.bull_classic_room = {}
    self.bull_classic_room.mount = 0
    for i=1,model.bull_classic_room:len() do
        local item = model.bull_classic_room:get(i)
        self.bull_classic_room[item.room_level] = {}
        self.bull_classic_room[item.room_level].room_name = item.room_name
        self.bull_classic_room[item.room_level].base_chip = item.base_chip
        self.bull_classic_room[item.room_level].enter_limit_low = item.enter_limit_low
        self.bull_classic_room[item.room_level].enter_limit_high = item.enter_limit_high
        self.bull_classic_room[item.room_level].online_user_count = item.online_user_count
        self.bull_classic_room[item.room_level].room_level = item.room_level
        self.bull_classic_room[item.room_level].pic_url    = item.pic_url
        self.bull_classic_room[item.room_level].disable    = item.disable
        self.bull_classic_room[item.room_level].room_color    = item.room_color
        self.bull_classic_room.mount = self.bull_classic_room.mount + item.online_user_count
        self.bull_classic_room[item.room_level].call_score_list = {}
        for i = 1, item.call_score_list:len() do
            local u1 = item.call_score_list:get(i)
            table.insert(self.bull_classic_room[item.room_level].call_score_list,item.call_score_list:get(i))
        end
        -- 设置默认值
        local defaultCallScoreList = {5,10,15,20,25}
        if #self.bull_classic_room[item.room_level].call_score_list == 0 then
            self.bull_classic_room[item.room_level].call_score_list = defaultCallScoreList
        end
    end

    --扎金花
    self.bull_zjh_room = {}
    self.bull_zjh_room.mount = 0
    self.lhd_gift_switch = model.return_gift_switch
    for i=1,model.gold_flower_room:len() do
        local item = model.gold_flower_room:get(i)
        self.bull_zjh_room[item.room_level] = {}
        self.bull_zjh_room[item.room_level].room_name = item.room_name
        self.bull_zjh_room[item.room_level].base_chip = item.base_chip
        self.bull_zjh_room[item.room_level].enter_limit_low = item.enter_limit_low
        self.bull_zjh_room[item.room_level].enter_limit_high = item.enter_limit_high
        self.bull_zjh_room[item.room_level].online_user_count = item.online_user_count
        self.bull_zjh_room[item.room_level].room_level = item.room_level
        self.bull_zjh_room[item.room_level].pic_url    = item.pic_url
        self.bull_zjh_room[item.room_level].disable    = item.disable
        self.bull_zjh_room.mount = self.bull_zjh_room.mount + item.online_user_count
    end

    --斗地主
    self.DDZ_room = {}
    self.DDZ_room.mount = 0
    for i=1,model.fighting_landlords_room:len() do
        local item = model.fighting_landlords_room:get(i)
        self.DDZ_room[item.room_level] = {}
        self.DDZ_room[item.room_level].room_name = item.room_name
        self.DDZ_room[item.room_level].base_chip = item.base_chip
        self.DDZ_room[item.room_level].enter_limit_low = item.enter_limit_low
        self.DDZ_room[item.room_level].enter_limit_high = item.enter_limit_high
        self.DDZ_room[item.room_level].online_user_count = item.online_user_count
        self.DDZ_room[item.room_level].room_level = item.room_level
        self.DDZ_room[item.room_level].pic_url    = item.pic_url
        self.DDZ_room[item.room_level].disable    = item.disable
        self.DDZ_room[item.room_level].room_group = item.room_group
        self.DDZ_room[item.room_level].payment_recommend = item.payment_recommend
        self.DDZ_room.mount = self.DDZ_room.mount + item.online_user_count
    end
    
    --更新子游戲配置
    self:updateSubGameConfig(model)

    -- self:saveConfigErrorMessages(model)

    --提现手续费
    self.draw_fee_rate = 0
    if model.draw_fee_rate then
        self.draw_fee_rate = model.draw_fee_rate
    end

    --轮播图
    self.banner_pic = {}
    for i = 1, model.banner_pic:len() do
        local item = model.banner_pic:get(i)
        self.banner_pic[i] = {}
        self.banner_pic[i].pic_path = item.pic_path
        self.banner_pic[i].pic_index = item.pic_index
        self.banner_pic[i].copy_url = item.copy_url
    end
    
    if not self:checkReplaceCdn() then
        for i, v in ipairs(self.banner_pic) do
            v.pic_path = Util:removeCdnUrl(v.pic_path)
        end
    end

    -- vip等级配置
    self.vip_info = {}
    for i = 1, model.profit_vip_info:len() do
        local item = model.profit_vip_info:get(i)
        self.vip_info[i] = {}
        self.vip_info[i].vip_id = item.vip_id
        self.vip_info[i].vip_recharge = item.vip_recharge
        self.vip_info[i].vip_receive = item.vip_receive
    end

    -- --档位配置信息
    self.reward_info = {}
    for i = 1, model.profit_reward_info:len() do
        local item = model.profit_reward_info:get(i)
        self.reward_info[i] = {}
        self.reward_info[i].reward_id = item.reward_id
        self.reward_info[i].reward_recharge = item.reward_recharge
        self.reward_info[i].reward_coefficient = item.reward_coefficient
        self.reward_info[i].coefficient = item.coefficient
    end

    --钱包信息
    Cache.walletInfo:resolveProto(model)
    Cache.walletInfo:resolveConfigProto(model)
end

--检测是否采用cdn 来进行下载
function Config:checkReplaceCdn()
    local configlist = self.config_list
    if configlist.patch and configlist.patch.patch_url_prefix then
        local idx = string.find(Util:getDesDecryptString(configlist.patch.patch_url_prefix), "cdn-")
        if idx and idx ~= -1 then -- 使用了cdn 将要使用cdn下载
            return true
        end
    end
    return false
end

function Config:updateServerAllocConfig(configList)
    self.config_list = configList

    if not configList or configList.ret ~= 0 then
        RESOURCE_HOST_NAME = HOST_NAME
        return 
    end

    if configList.pay_show_list and Cache.PayManager then--支付列表
        Cache.PayManager.payMethods = Util:getDesDecryptString(configList.pay_show_list)
    end
    if configList.cdn ~= '' and configList.cdn then
        RESOURCE_HOST_NAME = Util:getDesDecryptString(configList.cdn)
    end
    -- if not self.config_list.login_type_list then
    --     self.config_list.login_type_list = {}
    -- end
    if configList.bill_host ~= '' and configList.bill_host then
        HOST_BILL = Util:getDesDecryptString(configList.bill_host)
    end
    self:updateIPAddress(configList.client_ip or "")
    if Cache.user then
        Cache.user.custom_qq = Util:getDesDecryptString(configList.custom_qq)     --客服QQ
        Cache.user.custom_tel = Util:getDesDecryptString(configList.custom_tel)    --客服手机
        Cache.user.custom_url = Util:getDesDecryptString(configList.custom_url)   --客服二维码
    end

    --设置版本信息
    self.versionInfo = {}
    self.versionInfo.new_version = Util:getDesDecryptString(configList.new_version) or "1" --当前版本
    self.versionInfo.down_game_url = Util:getDesDecryptString(configList.down_game_url) or "" --游戏下载页地址
    self.versionInfo.pkg_url = Util:getDesDecryptString(configList.pkg_url) or "" --安装包下载地址
end

function Config:checkIfMustUpdateApp( ... )
    local regInfo = qf.platform:getRegInfo()
    if self.versionInfo.new_version and self.versionInfo.new_version ~= "" then
        if self.versionInfo.down_game_url and self.versionInfo.down_game_url ~= "" then
            --如果server_alloc版本大于本地版本，则提示更新（这里还要提示是建议更新还是强制更新）
            if tonumber(self.versionInfo.new_version) > tonumer(regInfo.version) then
                return true
            end
        end
    end
    return false
end

function Config:getSubGameUpdatePkgConfig(gameName)
    local subGameConfig = {}
    if not self.config_list then return end
    if not self.config_list.patch.son_md5 then return subGameConfig end
    if not self.config_list.patch.son_zip then return subGameConfig end

    local bCnd = false
    if self:checkReplaceCdn() then
        bCnd = true
    end

    -- 【注意】 md5里面记录的是子游戏文件夹目录地址
    for _,v in pairs(self.config_list.patch.son_md5) do
        local info = string.split(Util:getDesDecryptString(v), gameName .. ":")
        if bCnd == false and #info == 2 then
            info[2] = Util:removeCdnUrl(info[2])
        end

        if #info == 2 then
            subGameConfig["md5Url"] = info[2] .. "/md5.txt"
            subGameConfig["patch_url_prefix"] = info[2] .. "/"
            break
        end
    end

    --子游戏子包zip路径
    for _,v in pairs(self.config_list.patch.son_zip) do
        local info = string.split(Util:getDesDecryptString(v), gameName .. ":")
        if #info == 2 then
            subGameConfig["zipUrl"] = info[2]
            break
        end
    end

    return subGameConfig
end

function Config:updateSubGameConfig(model)
    if GAME_INSTALL_TABLE['game_niuniu'] then
        Cache.kanconfig:saveKanConfig(model)
    end
    if GAME_INSTALL_TABLE['game_zhajinniu'] then
        Cache.zhajinniuconfig:saveConfig(model)
    end
    if GAME_INSTALL_TABLE['game_zjh'] then
        Cache.zhajinhuaconfig:saveConfig(model)
    end
    if GAME_INSTALL_TABLE['game_ddz'] then
        Cache.DDZconfig:saveConfig(model)
    end
    --龙虎斗房间人数
    self.lhd_player_count = model.lhd_player_count
    --百人场人数
    self.br_player_count = model.br_player_count
    --德州人数
    self.texas_count = model.texas_count
    --抢庄牛牛人数
    self.bull_fight_count = model.bull_fight_count
    --推豹子人数
    self.tbz_count = model.tbz_count
    --斗地主人数
    self.ddz_player_count = self.DDZ_room.mount
end

--更新模块位
function Config:updateModuleControl(model)
    -- self.shop_controll_open = model.modules -- 模块位控制
    local _contrl = model.modules -- 模块位控制
    local function _getContrlBolByBit(_bit)
        return 0 ~= Util:binaryAnd(_contrl, _bit) and true or false
    end
    TB_MODULE_BIT.BOL_MODULE_BIT_STORE = _getContrlBolByBit(TB_MODULE_BIT.MODULE_BIT_STORE)         -- 商城模块
    TB_MODULE_BIT.BOL_MODULE_BIT_EASY_BUY = _getContrlBolByBit(TB_MODULE_BIT.MODULE_BIT_EASY_BUY)   -- 快捷支付
    TB_MODULE_BIT.BOL_MODULE_BIT_KNAPSACK = _getContrlBolByBit(TB_MODULE_BIT.MODULE_BIT_KNAPSACK)   -- 道具
    TB_MODULE_BIT.BOL_MODULE_BIT_ACTIVITY = _getContrlBolByBit(TB_MODULE_BIT.MODULE_BIT_ACTIVITY)   -- 活动
    TB_MODULE_BIT.BOL_MODULE_BIT_REVIEW = _getContrlBolByBit(TB_MODULE_BIT.MODULE_BIT_REVIEW)       -- 审核开关
    TB_MODULE_BIT.BOL_MODULE_BIT_SPECIAL_PAY = _getContrlBolByBit(TB_MODULE_BIT.MODULE_BIT_SPECIAL_PAY) -- 1000、2000元订单隐藏
    TB_MODULE_BIT.BOL_MODULE_BIT_STORE_TAB = _getContrlBolByBit(TB_MODULE_BIT.MODULE_BIT_STORE_TAB) -- 其他页签关闭：金币购买、道具超市、兑换专区
    TB_MODULE_BIT.BOL_MODULE_BIT_STORE_BANNER = _getContrlBolByBit(TB_MODULE_BIT.MODULE_BIT_STORE_BANNER) -- 商城banner（广告条）关闭
    TB_MODULE_BIT.BOL_MODULE_BIT_STORE_EXCHANGE = model.exchange_support == 1 --商城兑换页面控制
end

--更新config
function Config:updateConfig(model)
    self._hasPickBeautyDayReward = model.has_pick_beauty_day_reward --是否领取了美女日常奖励

    if model.daily_rewards_v2 ~= nil then
        for i=1 ,model.daily_rewards_v2:len() do
            local reward = model.daily_rewards_v2:get(i)
            self._loginReward[i] = {}
            self._loginReward[i].index = reward.index
            self._loginReward[i].Gifts = {}
            for j=1, reward.items:len() do
                local item =  reward.items:get(j)
                self._loginReward[i].Gifts[j] = {}
                self._loginReward[i].Gifts[j].type = item.type 
                self._loginReward[i].Gifts[j].amount = item.amount
                self._loginReward[i].Gifts[j].desc = item.desc
            end
        end
    end

    self:updateTimeBox(model.time_box)
end

---------时间宝箱 start------------
--保存服务器下发的时间宝箱数据
function Config:updateTimeBox(m)
    if m == nil then return end
    self.box_index = m.box_index
	self.max_index = 0
    self.boxConfig = {}
    for i = 1, m.items:len() do
        local info = m.items:get(i)
        self.boxConfig[info.index] = {}
        self:copyFiled({"index", "gold","time_begin","time_end"},info,self.boxConfig[info.index])
        --duration:完成耗时
        self.boxConfig[info.index].duration = self.boxConfig[info.index].time_end - self.boxConfig[info.index].time_begin
		if self.max_index < info.index then self.max_index = info.index end
    end
	logd("时间宝箱领取阶段: "..self.box_index.."/"..self.max_index, "TimeBox")
end

--获取时间宝箱信息
function Config:getTimeBoxInfo()
	if self:judgeTimeboxIndexCorrect(self.box_index) == false then return nil end
	return self.boxConfig[self.box_index]
end

--是否宝箱任务全部完成
function Config:judgeTimeboxIndexCorrect(index)
	if index < 0 or index > self.max_index then
		return false
	else
		return true
	end
end
---------时间宝箱 end------------

function Config:updateWhenToShare(src)
    local keys = {"classic_win_big_blind","bairen_win_chips","bairen_win_over_i_had"}
        for i = 1, #keys do
        Config.when_to_share[keys[i]] = src[keys[i]]
    end 
end

--jackpot奖池信息缓存
function Config:updateJackpotInfo(model)
    self.classic_jackpot_reward = {}    --经典场胜利牌型奖
    self.classic_jackpot_accident = {}  --经典场至尊失手奖
    self.br_jackpot_reward = {}    --百人场胜利牌型奖

    if model == nil or model.classic_jackpot_conf == nil or model.bairen_jackpot_conf == nil then return end

    --[[    经典场    ]]
    for i = 1, model.classic_jackpot_conf:len() do 
        local item = model.classic_jackpot_conf:get(i)
        if item.reward_type == 1 then
            self.classic_jackpot_reward[item.card_type] = item.percentage
        elseif item.reward_type == 2 then
            self.classic_jackpot_accident[item.card_type] = item.percentage
        end
    end
    --[[    百人场    ]]
    for i = 1, model.bairen_jackpot_conf:len() do
        local item = model.bairen_jackpot_conf:get(i)
        self.br_jackpot_reward[item.card_type] = item.percentage
    end
end

--获取经典场至尊牌型奖
function Config:getJackpotClassicReward(card_type)
    return self.classic_jackpot_reward[card_type] or 0
end

--获取经典场至尊失手奖
function Config:getJackpotClassicAccident(card_type)
    return self.classic_jackpot_accident[card_type] or 0
end

--获取百人场至尊牌型奖
function Config:getJackpotBrReward(card_type)
    if not self.br_jackpot_reward then return 0 end
    return self.br_jackpot_reward[card_type] or 0
end

------------------------------破产返利----------------------
function Config:updateBrokeReturn(config)
    if config == nil then return end
    self._bankruptcy_returnList = {}
    for i = 1, config:len() do
        local v = config:get(i)
        local item = {} 
        self:copyFiled({"min","max","percent"}, v, item)
        self._bankruptcy_returnList[i] = item
    end
end

function Config:getBrokeReturn(diamond)
    for k,v in pairs(self._bankruptcy_returnList) do
        if diamond > v.min and diamond <= v.max then
            local percent = tonumber(v.percent)
            return math.floor(diamond*percent)
        end
    end
    return 0
end

--保存破产可领取补助次数
function Config:setBankruptcyFetchCount( count )
    self.fetch_count = count
end

--获取破产可领取补助次数
function Config:getBankruptcyFetchCount()
    return self.fetch_count
end

--更新错误code-list
function Config:saveConfigErrorMessages(model)
    if model == nil or model.error_code_list == nil then return end
    for k,v in pairs(model.error_code_list) do
        self._errorMsg[v.code] = v.desc
    end
end

---保存比赛积分获得的昵称信息
function Config:saveCreditLevel(creditlevel)
    self.credit_level = {}
    local filename = {
        "m",
        "n",
        "color"
    }
    for i=1,creditlevel:len() do
        local data = creditlevel:get(i)
        local copydata = {}
        self:copyFiled(filename,data,copydata)
        table.insert(self.credit_level,copydata)
    end
    table.sort(self.credit_level, function(a, b)
            return a.m < b.m
    end)

end


function Config:updateCredit_level(config)
    self.credit_level = {}
    if config == nil then return end
    for i = 1, config:len() do
        local v = config:get(i)
        local item = {} 
        self:copyFiled({"m","n","color"}, v, item)
        self.credit_level[i] = item
    end
    table.sort(self.credit_level, function(a, b)
            return a.m < b.m
    end)
end

function Config:initStoreActivities( model )
    self._store_activities = {}
    for i = 1, model:len() do
        local t = model:get(i)

        table.insert(self._store_activities
            , {activity_id = t.activity_id
            , banner_url = t.banner_url
            , activity_url = t.activity_url
            })
    end
end

function Config:getStoreActivities( ... )
    return self._store_activities
end

--获取积分对应的称号
function Config:getTitleByCreditScore(score)
    if self.credit_level == nil or table.getn(self.credit_level) <= 0 then return "" end
    local len = table.getn(self.credit_level)
    local title = ""
    if score >= 0 then
        for i = len, 1, -1 do
            local data = self.credit_level[i]
            if score >= data.m then
                title = data.n
                break
            end
        end
    else
        for i=1, len do
            local data = self.credit_level[i]
            if score <= data.m then
                title = data.n
                break
            end
        end
    end
    return title
end

function Config:getBrSupport()
    return self.bairen_support == 1
end

--请求在线人数
function Config:getOnlineNumber(callback)
    GameNet:send({cmd = CMD.GET_ONLINE_NUMBER,callback = function(rsp)
        if rsp.ret ~= 0 then
            return
        end
        local m = rsp.model
        --目前暂时这些游戏
        self.bull_classic_room.mount =m.bull_fight_count
        self.bull_fry_room.mount = m.bull_fry_count
        self.bull_zjh_room.mount = m.gold_flower_count
        self.lhd_player_count = m.long_hu_dou_count
        self.br_player_count = m.br_gold_flower_count
        self.ddz_player_count = m.fighting_landlords_count

        self.gold_flower_room = {}
        self.bull_fight_room = {}
        self.bull_zjn_room = {}
        self.bull_ddz_room = {}
        for i = 1, m.bull_fight_room:len() do             --获取抢庄牛牛
            local item = m.bull_fight_room:get(i)
            item.online_user_count = item.online_user_count
            self.bull_fight_room[i] = item
        end

        for i = 1, m.gold_flower_room:len() do             --获取扎金花
            local item = m.gold_flower_room:get(i)
            item.online_user_count = item.online_user_count
            self.gold_flower_room[i] = item
        end

        for i = 1, m.bull_fry_room:len() do                --获取扎金牛
            local item = m.bull_fry_room:get(i)
            item.online_user_count = item.online_user_count
            self.bull_zjn_room[i] = item
        end

        for i = 1, m.fighting_landlords_room:len() do      --获取斗地主
            local item = m.fighting_landlords_room:get(i)
            item.online_user_count = item.online_user_count
            self.bull_ddz_room[i] = item
        end
        callback()
    end})
end

function Config:updateCustomerServiceInfo(model)
    if not model then return end
    self.customerServiceInfo = {}
    local filename = {
        "nick", "working_time", "copy_writing", "title", "welcome_words"
    }
    for _,v in pairs(filename) do
        self.customerServiceInfo[v] = model[v]
    end
end

-- 获取客服信息接口
function Config:getCustomerServiceInfo(callback)
    if not self.customerServiceInfo then
        GameNet:send({cmd = CMD.QUERY_CHAT_INFO, callback = function (rsp)
            if rsp.ret ~= 0 then
                callback()
                return
            end
            self:updateCustomerServiceInfo(rsp.model)
            if callback then
                callback(self.customerServiceInfo)
            end
        end})
    else
        if callback then
            callback(self.customerServiceInfo)
        end
    end
end

--domainName  每次登陆游戏 都要进行请求 请求之后如果成功就使用这个domainName
--由于config 会重置 所以只能作为接口使用 不能直接存储数据
function Config:setDomainName(domainName)
    cc.UserDefault:getInstance():setStringForKey(SKEY.DOMAIN_NAME, domainName);
    cc.UserDefault:getInstance():flush();
end

function Config:getDomainName()
    local domainName = cc.UserDefault:getInstance():getStringForKey(SKEY.DOMAIN_NAME, "")
    return domainName
end

---------------------Common Method--------------------
------------------------------------------------------
function Config:copyFiled(p,s,d)
    for k,v in pairs(p) do
        d[v] = s[v]
    end
end

function Config:copyTable(keyTable,src,desc) 
    for i = 1, src:len() do
        local item = src:get(i)
        desc[i] = {}
        for key , v in pairs(keyTable) do
            desc[i][v] = item[v]
        end
    end
end

function Config:copyArray(src,desc)
    --logd(src:len(),"")
    for i = 1, src:len() do
        desc[i] = src:get(i)
    end 
end

--返回登陆时将一些缓存清空
function Config:resetSomeStatus()
    self.shopConfig = nil
    self.exchangeConfig = nil
end

return Config
