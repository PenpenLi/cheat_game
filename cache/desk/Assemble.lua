--[[
    牌桌缓存数据汇总
--]]

local Assemble = class("Assemble")

--游戏类型
Assemble.game_type = ""

--[[ 设置游戏类型 ]]
function Assemble:setGameType(t)
    self.game_type = t
end

--[[ 获取游戏类型 ]]
function Assemble:getGameType()
    return self.game_type
end

--[[ 清除游戏类型 ]]
function Assemble:clearGameType()
    self.game_type = ""
end

--[[ 判断游戏类型 ]]
function Assemble:judgeGameType(t)
    return t == self.game_type
end


--[[ 获取数据缓存 ]]
function Assemble:getCache(game_type)
    game_type = game_type or self.game_type
    if game_type == JDC_MATCHE_TYPE then
        return Cache.desk
    elseif game_type == BRC_MATCHE_TYPE then
        return Cache.brdesk
    elseif game_type == SNG_MATCHE_TYPE then
        return Cache.sngDesk
    elseif game_type == MTT_MATCHE_TYPE then
        return Cache.mttDesk
    elseif game_type == GAME_TBZ then
       return Cache.tbzdesk 
    elseif game_type == GAME_NIU_ZHA then
       return Cache.zhajinniudesk 
    elseif game_type == GAME_NIU_KAN then
        return Cache.kandesk
    elseif game_type == GAME_ZJH then
        return Cache.zjhdesk
    elseif game_type == LHD_MATCHE_TYPE then
        return Cache.lhdDesk
    elseif game_type == BRNN_MATCHE_TYPE then
        return Cache.BrniuniuDesk
    elseif game_type == GAME_DDZ then
        return Cache.DDZDesk 
    elseif game_type == BJL_MATCHE_TYPE then
        return nil
    end
    return {}
end

function Assemble:getBgMusicByGameType()
    game_type = game_type or self.game_type
    if game_type == BRC_MATCHE_TYPE then
        return BrRes.all_music.BACKGROUND
    elseif game_type == GAME_DDZ then
        return string.format(DDZ_Res.all_music.gameMusic,Cache.DDZDesk.musicType) 
    end
    return GameRes.all_music.LOB_BG
end

return Assemble