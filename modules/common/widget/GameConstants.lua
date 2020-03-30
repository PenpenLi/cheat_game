--[[
    牌桌内通用常量整理
]]
local GameConstants = class("GameConstants")
--[[
    不分场次通用布局
]]
GameConstants.LAYOUT_COMMON = {}
GameConstants.LAYOUT_COMMON.DESK_OFFSET = -10   --牌桌中线偏移
GameConstants.LAYOUT_COMMON.DESK_POS_X = 0    --牌桌中线x坐标
GameConstants.LAYOUT_COMMON.TOTAL_CHIPS_TXT_POS = cc.p(0, 761)   --底池位置
--[[
    5人场布局
    if self.seatLimit == 5 then
        self.DESK_CARD_POSY = self.winSize.height*0.52
        self.DESK_CHIPS_RADIO = 0.61
        self:initFiveUser()
    elseif self.seatLimit == 9 then
        self.DESK_CARD_POSY = self.winSize.height*0.5
        self.DESK_CHIPS_RADIO = 0.59
        self:initNineUser()
    end

]]
GameConstants.LAYOUT_5 = {}
GameConstants.LAYOUT_5.DESK_CARDS_POS = cc.p(0,562) --公共牌坐标
GameConstants.LAYOUT_5.DESK_CARD_SEND_Y = 302       --发牌的位置y坐标
GameConstants.LAYOUT_5.DESK_CHIPS_X = 922           --底池筹码x坐标
GameConstants.LAYOUT_5.DESK_CHIPS_Y = 659           --底池筹码y坐标
GameConstants.LAYOUT_5.JACKPOT_CHIPS_Y = 717        --jackpot奖金筹码y坐标
GameConstants.LAYOUT_5.DESK_TXT_POS = cc.p(0, 464)  --桌面文字位置
GameConstants.LAYOUT_5.USER_SCALE = 1.08            --玩家node scale
GameConstants.LAYOUT_5.USER_POS = {{960, 280}       --玩家位置
        , {430, 280}
        , {190, 660}
        , {1730, 660}
        , {1490, 280}
    }


--[[
    9人场布局
]]
GameConstants.LAYOUT_9 = {}
GameConstants.LAYOUT_9.DESK_CARDS_POS = cc.p(0,540) --公共牌坐标
GameConstants.LAYOUT_9.DESK_CARD_SEND_Y = 324       --发牌的位置y坐标
GameConstants.LAYOUT_9.DESK_CHIPS_X = 922           --底池筹码x坐标
GameConstants.LAYOUT_9.DESK_CHIPS_LINE1_Y = 637     --底池筹码第一行
GameConstants.LAYOUT_9.DESK_CHIPS_LINE2_Y = 405     --底池筹码第二行
GameConstants.LAYOUT_9.JACKPOT_CHIPS_Y = 738        --jackpot奖金筹码y坐标
GameConstants.LAYOUT_9.DESK_TXT_POS = cc.p(0, 443)  --桌面文字位置
GameConstants.LAYOUT_9.USER_SCALE = 1               --玩家node scale
GameConstants.LAYOUT_9.USER_POS = {{960, 270}       --玩家位置
        , {430, 270}
        , {140, 460}
        , {200, 790}
        , {540, 920}
        , {1380, 920}
        , {1720, 790}
        , {1780, 460}
        , {1490, 270}
    }
    
--[[
    牌桌组件层级
--]]
GameConstants.DESK_CARD_Z = 1           --桌牌层级: 由0调整到1，使发牌时盖住筹码
GameConstants.DEALER_Z = 0              --庄家标识层级
GameConstants.CHIP_HEAP_Z = 1           --桌面筹码层级
GameConstants.SPECIAL_CARDTYPE_Z = 2    --特殊牌型层级
GameConstants.LOWER_USER_Z = 2          --比用户层级低的层级
GameConstants.USER_LIST_Z = 3           --用户层级
GameConstants.CARDTYPE_HELP_Z = 5       --牌型介绍层级
GameConstants.MOVEING_Z = 8             --运动时组件的层级
GameConstants.WAITZ = 9                 --等待游戏开始提示层级
GameConstants.DIALOG_Z = 10             --弹窗提示层级
GameConstants.DIALOG2_Z = 11             --弹窗提示层级
GameConstants.MENU_ZORDER = 12          --菜单/聊天框等层级



function GameConstants:ctor()
    self.winSize = cc.Director:getInstance():getWinSize()
    self:adjustByResolution()
end

--根据分辨率自适配
function GameConstants:adjustByResolution()
    --牌桌中线
    self.LAYOUT_COMMON.DESK_POS_X = self.winSize.width / 2 + self.LAYOUT_COMMON.DESK_OFFSET
    --底池文字x坐标
    self.LAYOUT_COMMON.TOTAL_CHIPS_TXT_POS.x = self.LAYOUT_COMMON.DESK_POS_X
    --公共牌x坐标
    self.LAYOUT_5.DESK_CARDS_POS.x = self.LAYOUT_COMMON.DESK_POS_X
    self.LAYOUT_9.DESK_CARDS_POS.x = self.LAYOUT_COMMON.DESK_POS_X
    --底池筹码x坐标
    self.LAYOUT_5.DESK_CHIPS_X = self.LAYOUT_COMMON.DESK_POS_X
    self.LAYOUT_9.DESK_CHIPS_X = self.LAYOUT_COMMON.DESK_POS_X
    --桌面文字
    self.LAYOUT_5.DESK_TXT_POS.x = self.LAYOUT_COMMON.DESK_POS_X
    self.LAYOUT_9.DESK_TXT_POS.x = self.LAYOUT_COMMON.DESK_POS_X
end

----------------UI校验类型-----------------
GameConstants.CHECKUI_USERS = 0         --校验牌桌上的用户
GameConstants.CHECKUI_SHARE_CARDS = 1   --校验公共牌
GameConstants.CHECKUI_HANDCARDS = 2     --校验玩家本人手牌
GameConstants.CHECKUI_CHIPS = 3         --校验底池筹码
GameConstants.CHECKUI_OTHER_HANDCARDS = 4   --检查所有人其他人的手牌UI，没有就加上
function GameConstants:getUICheckTypeDescription(check_type)
    if check_type == GameConstants.CHECKUI_USERS then
        return "牌桌用户"
    elseif check_type == GameConstants.CHECKUI_SHARE_CARDS then
        return "各公共牌"
    elseif check_type == GameConstants.CHECKUI_HANDCARDS then
        return "本人手牌"
    elseif check_type == GameConstants.CHECKUI_CHIPS then
        return "底池筹码"
    elseif check_type == GameConstants.CHECKUI_OTHER_HANDCARDS then
        return "他人手牌"
    else
        return "未知类型"
    end
end



GameConstants.FORCE_TIME = 100 --while循环量转变为for循环时 设置的最大循环量

----------------金币相关常量-----------------
GameConstants.LEAST_MONEY = 10 	--龙虎斗与百人炸金花 下注资格底线金币
GameConstants.RATE = 1 		--服务器与客户端金币比率 客户端:服务端 = 1:1
GameConstants.UNIT = GameTxt.money_unit      --计量单位 金币
GameConstants.MONEY_UNIT = GameTxt.money_unit      --计量单位 元
----------------密码相关常量-----------------
GameConstants.LIMIT_MIN_LEN = 6
GameConstants.LIMIT_MAX_LEN = 16

----------------电话号码相关常量-----------------
GameConstants.PHONE_LEN = 11     --目前手机号码长度默认为11位 将来如果可能海外不一样进行修改

----------------iphoneX适配 相关常量-----------------
GameConstants.IX_WINSIZE = {width = 1920, height = 1080}

----------------iphoneX适配 相关常量-----------------
GameConstants.PIN_LEN = 4        --目前手机验证码设置为4位长度
GameConstants.PAY_LEN = 6        --目前手机安全密码设置为6位长度
GameConstants.BROADCAST_POS = {x = 50, y = -158}        --跑马灯位置
GameConstants.BROADCAST_INGAME_POS = {x = 50, y = 0}    --游戏内跑马灯位置

GameConstants.BroadCastType = {
    Game = 1,           --游戏牌桌内广播
    Customer = 2,       --客服聊天广播
    Hall = 3            --大厅广播、包括选场
}


---------------玩家状态 相关常量-----------------
GameConstants.PlayStatus = {
    Ready = 1020,           --进桌了，开始准备
    ReadyToStart = 1025,    --准备了坐等开始
    InGame = 1030,          --游戏中
    CallPointing = 1083,    --叫分中
    CallPointOver = 1084,   --叫分结束
    OutCarding = 1085,      --出牌
    OutCardOver = 1086,     --出牌结束
    GameOver = 1087,        --游戏结束
}

GameConstants.GameStatusType = {
    Ready = 0,      --准备中
    InGame = 1,     --游戏中
    CallScore = 10  --叫分中
}

------------- 聊天相关枚举 --------------
GameConstants.ChatMsgType = {
    MSG_TEXT = 0,
    MSG_PIC_BRIEF = 3
}

GameConstants.ChatIDType = {
    ID_SINGLE = 0,
    ID_GROUP_SERVICE = 5
}

GameConstants.ChatUserType = {
    OFFICIAL = 1, --官方客服
    PROXCY = 2, --代理自己
    PROXCY_SUB = 3
}

GameConstants.CORNER = {
    RIGHT_UP = 1,
    RIGHT_DOWN = 2,
    LEFT_DOWN = 3,
    LEFT_UP = 4
}

GameConstants.NIUNIU_DESKCOLOR = {
    BLUE = 1,
    GOLD = 2
}

GameConstants.ZJH_DESKCOLOR = {
    BLUE = 1,
    RED = 2
}
return GameConstants