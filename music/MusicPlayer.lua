local M = class("MusicPlayer")

M.TAG = "MusicPlayer"


function M:ctor(paras)
   self:init() 
end

function M:init()
    self:preloadMusic()
    self:initSetting()
    self.back_music = GameRes.all_music.LOB_BG
end

function M:setBgMusic(file)

    if  not file then
        self.back_music = GameRes.all_music.LOB_BG
    else
         self.back_music = file
    end
end

function M:isPlayMusic()
    return self.isplay
end

--[[初始化设置信息]]
function M:initSetting()
    local bDefaultValue = true
    if (qf and qf.device and qf.device.platform == "windows") then
        bDefaultValue = false
    end
    self.hasMusic = cc.UserDefault:getInstance():getBoolForKey(SKEY.SETTINGS_MUSIC, bDefaultValue) --是否有背景音乐
    self.hasEffect = cc.UserDefault:getInstance():getBoolForKey(SKEY.SETTINGS_EFFECT, bDefaultValue) --是否有音效

    local platformSet = qf.platform:getMusicSet()
    --self.hasMusic = platformSet == true and self.hasMusic or false
    --self.hasEffect = platformSet == true and self.hasEffect or false
end

--[[预加载音乐]]
function M:preloadMusic()
   self.music_load = "res/"
   local preloadTable = {"BTN","LOB_BG","CHIP","CHIP_FLY","FAPAI"}
   -- for k,v in pairs(preloadTable) do
   --     cc.SimpleAudioEngine:getInstance():preloadMusic(GameRes.all_music.v)
   --     logd("--preload music--"..v,self.TAG)
   -- end
   -- for k, v in pairs(GameRes.all_music) do
   --     self.key[self.name[k]] = self.music_load..v
       
   -- end
end


--背景淡出
function M:backgroundSineOut()
    if self.isSineOut then return end
    self.isSineOut = true
    self.isSineIn = false
    local volume = self:getBackGroundMusicVolume()
    local function sineout()
        if volume <= 0.02 then
            self:stopBackGround()
        end
        if self.isSineOut ~= true or volume <= 0.02 then 
            self:setBackGroundMusicVolume(0)
            self.isSineOut = false
            return 
        end
        --logd("音量++"..volume)
        volume = volume - 0.01 < 0 and 0 or volume - 0.01
        self:setBackGroundMusicVolume(volume)
        return Util:delayRun(0.02,function() 
            sineout()
        end)
    end
    sineout()
end

--背景淡入
function M:backgroundSineIn()
    if self.isSineIn then return end
    self:playBackGround()
    self.isSineIn = true
    self.isSineOut = false
    local volume = 0--self:getBackGroundMusicVolume()
    
    local function sineIn()
        if volume >= 1 then
            self:playBackGround()
        end
        if self.isSineIn ~= true or volume >= 1 then 
            self:setBackGroundMusicVolume(1)
            self.isSineIn = false
            return 
        end
        --logd("音量--->"..volume)
        volume = volume + 0.01
        self:setBackGroundMusicVolume(volume)
        return Util:delayRun(0.02,function() 
            sineIn()
        end)
    end
    sineIn()
end

--[[获取背景音乐音量]]
function M:getBackGroundMusicVolume()
    return cc.SimpleAudioEngine:getInstance():getEffectsVolume()
end



---[[设置背景音乐音量
--  这里只取那一个全局变量的值
--]]
function M:setBackGroundMusicVolume(volume)
    cc.SimpleAudioEngine:getInstance():setMusicVolume(volume)
end

--[[背景]]

--[[播放背景音乐]]
function M:playBackGround()

    if self.hasMusic then 
        if not self.isplay then
            self.isplay =  true
            self:playMusic(self.back_music,true) 
        end
    end
end

--[[停止播放背景音乐]]
function M:stopBackGround()
    self:stopMusic(true)
end
--[[暂停背景音乐]]
function M:pauseBackGround()
    self:pauseMusic()
end
--[[继续背景音乐]]
function M:resumeBackGround()
    self:resumeMusic()
end

--[[播放音效]]
function M:playMyEffect(filename)
    return self:_playEffect(GameRes.all_music[filename])
end

--[[播放音效]]
function M:playMyEffectGames(res,filename)
    return self:_playEffect(res.all_music[filename])
end

--[[播放音效]]
function M:playEffectFile(filename)
    return self:_playEffect(filename)
end

--[[播放筹码音效]]
function M:playChipEffect()
    self.chipCount = self.chipCount or 0
    self.chipCount = self.chipCount + 1
    if self.chipCount <= 1 then
        self:playMyEffect("CHIP")
    elseif self.chipCount == 2 then
        Util:delayRun(0.05,function() 
            self.chipCount = 0
        end)
    else
    
    end
end

    
function M:playMusic(filename, isLoop)
    if not self.hasMusic then return end
    local loopValue = false
    if nil ~= isLoop then
        loopValue = isLoop
    end
    cc.SimpleAudioEngine:getInstance():playMusic(filename, loopValue)
end

function M:stopMusic(isReleaseData)
    local releaseDataValue = false
    self.isplay = nil
    if nil ~= isReleaseData then
        releaseDataValue = isReleaseData
    end
    cc.SimpleAudioEngine:getInstance():stopMusic(releaseDataValue)
end

function M:destroyInstance()
    return cc.SimpleAudioEngine:destroyInstance()
end

function M:_playEffect(filename, isLoop)
    if self.hasEffect == false then return end
    if self.effect_mute == true then return end
    local loopValue = false
    if nil ~= isLoop then
        loopValue = isLoop
    end
    return cc.SimpleAudioEngine:getInstance():playEffect(filename, loopValue)
end

function M:_stopEffect(soundiD)
    -- body
    cc.SimpleAudioEngine:getInstance():stopEffect(soundiD)
end

function M:resumeMusic()
    cc.SimpleAudioEngine:getInstance():resumeMusic()
end

function M:pauseMusic()
    cc.SimpleAudioEngine:getInstance():pauseMusic()
end

--游戏中调用，暂时静音
function M:setEffectMute(mute)
    self.effect_mute = mute
    if (self.effect_mute == true) and (self.hasEffect == true) then
        cc.SimpleAudioEngine:getInstance():stopAllEffects()
    end
end


MusicPlayer = M.new()