 
---- 存放相关配置项

SERVERIP= nil
SERVERPORT= nil

ENVIROMENT_TYPE = 1 -- 1是生产环境 2是测试环境
--把包发出去的时候 下面一句话要去掉
-- ENVIROMENT_TYPE = cc.UserDefault:getInstance():getIntegerForKey(SKEY.ENVIROMENT_TYPE, ENVIROMENT_TYPE) --是否开启了震动

if ENVIROMENT_TYPE == 1 then
	HOST_PREFIX = "https://"
	HOST_CN_NAME = "dwc.allplay989.com"
	HOST_BILL = "https://unity-pay.allplay989.com"

else
	HOST_PREFIX = "http://" --测试环境下改为https://
	HOST_CN_NAME = "bull.168dw.net"
	HOST_BILL = "http://104.215.192.114:25100"
end
HOST_HW_NAME = "dwc.allplay989.com"

FULLSCREENADAPTIVE = FULLSCREENADAPTIVE or false --iphoneX适配包
FIRST_LOGIN = FIRST_LOGIN or true --判断游戏是不是没有连上服务器过
BOL_AUTO_RE_CONNECT = BOL_AUTO_RE_CONNECT or true -- 标记：被踢下线后返回到登录界面，是否要弹出提示框
GAMERUNFIRSTFORTURNTABLE = GAMERUNFIRSTFORTURNTABLE or true --第一次打开游戏（进入游戏后置为false，暂时用于判断玩家转盘等）
LOCAL_USER_LOG = false

LAST_LOBBY_CHOOICE = LAST_LOBBY_CHOOICE or 1

PF_WINDOWS = PF_WINDOWS or false
UNITY_PAY_SECRET = QNative:shareInstance():getKey()
GAME_BASE_VERSION = GAME_BASE_VERSION or "1.0.0"
GAME_LANG = GAME_LANG or "cn"

SHOCK_SETTING = cc.UserDefault:getInstance():getBoolForKey(SKEY.SETTINGS_SHOCK,true) --是否开启了震动

