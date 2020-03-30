

ModuleManager = {}
ModuleManager.rank = nil

local globalModule = import(".global.GlobalController")
local settingModule = import(".setting.SettingController")
local safeBoxModel = import(".safeBox.SafeBoxController")--保险箱
local personalModel = import(".personal.PersonalController")--个人信息
local inviteCodeModel = import(".inviteCode.InviteCodeController")--邀请码 
local loginModule = import(".login.LoginController")
local preloadModule = import(".preload.PreloadController")--预加载控制器

ModuleManager.__moduleTable = {}

function ModuleManager:init ()

    self.global = globalModule.new()
    self.setting = settingModule.new()
    self.safeBox = safeBoxModel.new()
    self.personal = personalModel.new()
    self.inviteCode = inviteCodeModel.new()    
    self.preload = preloadModule.new()--预加载层
    self.login = loginModule.new()

    self.cancelTable = {--除了global层之外其他的都要移除的table
        "game","brniuniugame","texasbrgame", "activity","beauty","friend",
        "main","prize","setting","shop","lobby","sng_lobby",
        "change_userinfo","customize","gamesRecord",
        "sng","chosehall","mtt_lobby", "safeBox", "personal","exchange",
        "inviteCode", "messageBox"
    }

    qf.event:addEvent(ET.MODULE_SHOW,function ( args )
        if args == nil then return end
        self.__moduleTable[args] = true
    end)
    qf.event:addEvent(ET.MODULE_HIDE,function ( args )
        if args == nil then return end
        self.__moduleTable[args] = false
    end)
end

function ModuleManager:judegeIsIngame()
    if self.__moduleTable["game"] 
        or self.__moduleTable["texasbrgame"]
        or self.__moduleTable["brniuniugame"]
        or self.__moduleTable["sng"]
        or self.__moduleTable["texasgame"]
        or self.__moduleTable["game_niuniu"]
        or self.__moduleTable["game_zjn"]
        or self.__moduleTable["kancontroller"]
        or self.__moduleTable["zjhgame"]
        or self.__moduleTable["DDZgame"]
        or self.__moduleTable["baccaratGame"]
        or self.__moduleTable["game_lhd"] then
        return true
    else
        return false
    end
end

--广播不能在游戏内播放 但是由于版本迭代 所以另外弄一个判断是否在游戏中的函数
function ModuleManager:judegeIsIngameWithBorad()
    if self.__moduleTable["kancontroller"] --抢庄牛牛
        or self.__moduleTable["texasbrgame"] --百人炸金花
        or self.__moduleTable["brniuniugame"]--百人牛牛
        or self.__moduleTable["zjhgame"]--扎金花
        or self.__moduleTable["zhajinniugame"]--扎金牛
        or self.__moduleTable["DDZgame"] --斗地主
        or self.__moduleTable["baccaratGame"] --百家乐
        or self.__moduleTable["game_lhd"] then --龙虎斗
        return true
    else
        return false
    end
end

--判断是不是游戏选场大厅
function ModuleManager:judgeInGameHall( ... )
    if self.__moduleTable["zhajinniuhall"] --炸金牛
        or self.__moduleTable["niuniuhall"] --抢庄牛牛
        or self.__moduleTable["zjhhall"] --扎金花
        or self.__moduleTable["DDZhall"]--斗地主
        or self.__moduleTable["BrnnHall"] then--百人牛牛
        return true
    else
        return false
    end
end

function ModuleManager:judgeIsInNormalGame()
    loga("ModuleManager:judgeIsInNormalGame()ModuleManager:judgeIsInNormalGame()")
    if self.__moduleTable["game"]
    or self.__moduleTable["zjhgame"]
    or self.__moduleTable["texasglobal"]
    or self.__moduleTable["tbzgame"]
    or self.__moduleTable["niuniugame"]
    or self.__moduleTable["kancontroller"]
     then
        return true
    else
        return false
    end
end

function ModuleManager:judegeIsInShop()
    return self.__moduleTable ~= nil and self.__moduleTable["shop"] or false
end

--判定是否是将金币转化为筹码的场次
function ModuleManager:judegeIsInChouMaArea()
   if self.__moduleTable["game_lhd"]
    or self.__moduleTable["texasbrgame"]
    or self.__moduleTable["brniuniugame"]
    then
        return true
    else
        return false
    end
end

function ModuleManager:judegeIsInLogin()
    if self.__moduleTable["login"]  then
        return true
    else
        return false
    end
end

function ModuleManager:judegeIsInMain()
    local value = false
    if not self:judegeIsIngameWithBorad() and not self:judegeIsInLogin() and not self:judgeInGameHall() then
        value = true
    end
    return value
end

function ModuleManager:removeByCancellation()
    for k , v in pairs(self.cancelTable) do
        if self[v] then
            self[v]:remove()
        end
    end
end

function ModuleManager:removeSubGameHall( ... )
    local subGameHalls = {
        "zhajinniuhall", --炸金牛
        "niuniuhall", --抢庄牛牛
        "zjhhall", --扎金花
        "DDZhall", --斗地主
        "BrnnHall", --百人牛牛
    }
    for _,v in pairs(subGameHalls) do
        if self[v] then
            self[v]:remove()
        end
        if self.__moduleTable[v] then
            self.__moduleTable[v] = false
        end
    end
end

function ModuleManager:removeSubGames( ... )
    local subGames = {
        "kancontroller", --抢庄牛牛
        "texasbrgame", --百人炸金花
        "brniuniugame",--百人牛牛
        "zjhgame",--扎金花
        "zhajinniugame",--扎金牛
        "DDZgame", --斗地主
        "game_lhd", --龙虎斗
        "baccaratGame" --百家乐
    }
    for _,v in pairs(subGames) do
        if self[v] then
            self[v]:remove()
        end
    end
end

function ModuleManager:removeExistView(safeModules)
    logi("removeExistViewremoveExistViewremoveExistViewremoveExistViewremoveExistView")
    for k,v in pairs(self.__moduleTable) do
        logi(k)
        if v == true and self[k] then
            local bSafe = false
            if safeModules then
                if table.indexof(safeModules, k) ~= -1 then
                    bSafe = true
                end
            end
            if not bSafe then
                self[k]:remove()
            end
        end
    end
    logi("removeExistViewremoveExistViewremoveExistViewremoveExistViewremoveExistView")
    logi(json.encode(self.__moduleTable))
    if self.gameshall then
        self.gameshall:remove()
    end
    self.global:removeExistView()
end