--语音识别组件(单例)
--[[
    组件功能:
    1. 封装native接口, 开始/停止/取消语音识别
    2. 记录当前语音识别状态
    3. 根据状态进行用户语音音量监控，映射音量等级
    4. 对语音识别状态改变事件、输入语音音量变化事件进行分发
]]
local M = class("M")

--底层返回的错误码. 此处注意，各平台(ios,android)需统一
M.ERRCODE_TOO_SHORT = 100001           --录音太短
M.ERRCODE_DEVICE_PREMISSION = 100002   --无设备权限
M.ERRCODE_NETWORK_EXECEPTION = 100003  --网络连接异常
M.ERRCODE_UNKNOWN_ERROR = 100004       --未知错误

--语音识别状态
M.STATUS_IDLE = 0           --空闲
M.STATUS_PREPARE = 1        --准备识别
M.STATUS_RECORDING = 2      --正在采集数据
M.STATUS_CONVERTING = 3     --正在识别

--音量检测timer
M.VOLUME_TIMER_TAG = 7000
M.VOLUME_TIMER_INTERVAL = 0.2

--音量最大等级
M.VOLUME_MAX_LEVEL = 5

--语音识别超时设定
M.TIMEOUT_PREPARE = 5       --几秒钟不开始采集数据视为超时
M.TIMEOUT_RECORD = 5        --几秒钟录音未结束视为超时
M.TIMEOUT_CONVERT = 5       --几秒钟没有返回转换结果视为超时

--超时检测timer
M.TIMEOUT_TIMER_TAG = 7001

function M:ctor()
    self.working_status = self.STATUS_IDLE  --识别状态
end

--开始
function M:start()
    self:printLog("[component] start. status = "..self.working_status, "STT")
    if self.working_status ~= self.STATUS_IDLE then
        return false
    else
        local ret = qf.platform:startVoiceRecognition({cb=handler(self, self._voiceRecognitionCallback)})
        if ret == 1 then
            self.working_status = self.STATUS_PREPARE   --设置工作状态
            MusicPlayer:setEffectMute(true)    --音效静音
            self:_countdownTimerStart(self.STATUS_PREPARE, self.TIMEOUT_PREPARE)  --开始超时监控
        else
            return false
        end
    end
end
--停止
function M:finish()
    self:printLog("[component] finish. status = "..self.working_status, "STT")
    if self.working_status == self.STATUS_RECORDING then
        --录音中，停止数据采集开始识别
        self:_stopVolumeMonitor()
        self:_countdownTimerStop()
        qf.platform:finishVoiceRecognition()
    elseif self.working_status == self.STATUS_PREPARE then
        --仍在准备状态, 停止识别, 提示时间太短
        self:cancel()
        qf.event:dispatchEvent(ET.SPEECHTOTEXT_STATUS_NOTIFY, {status = SpeechToTextStatus.STT_ERROR, errcode = SpeechToTextErrorCode.STT_RECORD_TOO_SHORT, text = ""})
    end
    MusicPlayer:setEffectMute(false)    --音效取消静音
end
--取消
function M:cancel()
    self:printLog("[component] cancel. status = "..self.working_status, "STT")
    if self.working_status ~= self.STATUS_IDLE then
        self:_stopVolumeMonitor()       --停止音量监控
        self:_countdownTimerStop()      --停止超时监控
        qf.platform:cancelVoiceRecognition()
        MusicPlayer:setEffectMute(false)    --音效取消静音


        self.working_status= self.STATUS_IDLE
    end
end
--语音识状态事件
function M:_voiceRecognitionCallback(status, errcode, text)
    self:printLog("[component] entry lua callback function", "STT")
    --设置状态
    if status == SpeechToTextStatus.STT_START_WORK then     --开始采集数据
        self:printLog("[component] callback. 开始采集数据", "STT")
        self.working_status = self.STATUS_RECORDING         --设置工作状态
        qf.event:dispatchEvent(ET.SPEECHTOTEXT_STATUS_NOTIFY, {status = status, errcode = errcode, text = text})
        self:_countdownTimerStart(self.STATUS_RECORDING, self.TIMEOUT_RECORD)  --开始录音阶段的超时监控
        self:_startVolumeMonitor()  --开始音量监控
    elseif status == SpeechToTextStatus.STT_END_WORK then   --数据采集完毕正在识别
        self:printLog("[component] callback. 数据采集完毕正在识别", "STT")
        self.working_status = self.STATUS_CONVERTING        --设置工作状态
        qf.event:dispatchEvent(ET.SPEECHTOTEXT_STATUS_NOTIFY, {status = status, errcode = errcode, text = text})
        self:_stopVolumeMonitor()   --停止音量监控
        self:_countdownTimerStart(self.STATUS_CONVERTING, self.TIMEOUT_CONVERT)  --开始识别阶段的超时监控
    elseif status == SpeechToTextStatus.STT_RESULT then     --得到最终结果
        self:printLog("[component] callback. 得到最终结果", "STT")
        self.working_status = self.STATUS_IDLE              --设置工作状态
        qf.event:dispatchEvent(ET.SPEECHTOTEXT_STATUS_NOTIFY, {status = status, errcode = errcode, text = text})
        self:_stopVolumeMonitor()   --停止音量监控
        self:_countdownTimerStop()  --停止超时监控
    elseif status == SpeechToTextStatus.STT_USER_CANCEL then    --用户取消
        self:printLog("[component] callback. 用户取消", "STT")
        self.working_status = self.STATUS_IDLE              --设置工作状态
        qf.event:dispatchEvent(ET.SPEECHTOTEXT_STATUS_NOTIFY, {status = status, errcode = errcode, text = text})
        self:_stopVolumeMonitor()   --停止音量监控
        self:_countdownTimerStop()  --停止超时监控
    elseif status == SpeechToTextStatus.STT_ERROR then      --返回结果/取消/出错,组件闲置
        self:printLog("[component] callback. 报错", "STT")
        self.working_status = self.STATUS_IDLE              --设置工作状态
        if errcode == self.ERRCODE_TOO_SHORT then
            --错误通知:录音时间太短
            qf.event:dispatchEvent(ET.SPEECHTOTEXT_STATUS_NOTIFY, {status = status, errcode = SpeechToTextErrorCode.STT_RECORD_TOO_SHORT, text = ""})
        elseif errorcode == self.ERRCODE_DEVICE_PREMISSION then
            --错误通知:麦克风无访问权限
            qf.event:dispatchEvent(ET.SPEECHTOTEXT_STATUS_NOTIFY, {status = status, errcode = SpeechToTextErrorCode.STT_DEVICE_PREMISSION, text = ""})
        elseif errorcode == self.ERRCODE_NETWORK_EXECEPTION then
            --错误通知:网络错误
            qf.event:dispatchEvent(ET.SPEECHTOTEXT_STATUS_NOTIFY, {status = status, errcode = SpeechToTextErrorCode.STT_NETWORK_EXECEPTION, text = ""})
        else
            --错误通知:其他错误
            qf.event:dispatchEvent(ET.SPEECHTOTEXT_STATUS_NOTIFY, {status = status, errcode = SpeechToTextErrorCode.STT_UNKONWN_ERROR, text = errcode .. ""})
        end
        self:_stopVolumeMonitor()   --停止音量监控
        self:_countdownTimerStop()  --停止超时监控
    end
    --[[ 以下是为了解决百度语音识别和Cocos2dx调用ios语音库设备冲突问题
        stt收到最终结果. 正常识别结果/用户取消/报错. 此时需要release SimpleAudioEngine实例, 保证下次调用时重新实例化、OpenAL设备状态正常
        如果未到录音状态用户就已经点击了取消，不会引用到AVFoudation.Framework，不会出现设备冲突问题，故不处理]]
    if status == SpeechToTextStatus.STT_RESULT or status == SpeechToTextStatus.STT_USER_CANCEL or status == SpeechToTextStatus.STT_ERROR then
        MusicPlayer:destroyInstance()
    end
end

--开始音量监控
function M:_startVolumeMonitor()
    self:_stopVolumeMonitor()
    --获取音量,并做事件分发
    local action = cc.RepeatForever:create(cc.Sequence:create(
        cc.DelayTime:create(self.VOLUME_TIMER_INTERVAL),
        cc.CallFunc:create(function() 
            -- local volume = self:_getVoiceVolume()
            -- qf.event:dispatchEvent(ET.SPEECHTOTEXT_VOLUME_NOTIFY, {volume = volume})
        end)))
    action:setTag(self.VOLUME_TIMER_TAG)
    LayerManager.Global:runAction(action)
end

--停止音量监控
function M:_stopVolumeMonitor()
    if LayerManager.Global:getActionByTag(self.VOLUME_TIMER_TAG) then 
        LayerManager.Global:stopActionByTag(self.VOLUME_TIMER_TAG)
    end
end

--开始计时
function M:_countdownTimerStart(status, time)
    self:_countdownTimerStop()
    self.countdown_time = time
    self.countdown_status = status
    self.countdown_second = 0
    self:printLog("[component] 开始计时 "..status..", "..time, "STT")
    local action = cc.RepeatForever:create(cc.Sequence:create(
        cc.DelayTime:create(1),
        cc.CallFunc:create(function()
            self.countdown_second = self.countdown_second + 1
            self:printLog("[component] 时间监控: 当前时间["..self.countdown_second.."s], 超时设定["..self.countdown_time.."s]", "STT")
            if self.countdown_second > self.countdown_time then
                --超时
                self:_processTimeOut(self.countdown_status, self.countdown_time)
            end
            if self.countdown_status == self.STATUS_RECORDING then
                --计时
                qf.event:dispatchEvent(ET.SPEECHTOTEXT_STATUS_NOTIFY, {status=SpeechToTextStatus.STT_RECORD_SEC, errcode=self.countdown_second})
            end
        end)))
    action:setTag(self.TIMEOUT_TIMER_TAG)
    LayerManager.Global:runAction(action)
end

--停止计时
function M:_countdownTimerStop()
    self:printLog("[component] 停止计时", "STT")
    if LayerManager.Global:getActionByTag(self.TIMEOUT_TIMER_TAG) then 
        LayerManager.Global:stopActionByTag(self.TIMEOUT_TIMER_TAG)
    end
end

--超时处理
function M:_processTimeOut(status, time)
    self:_countdownTimerStop()
    self:printLog("[component] 超时. working_status="..self.working_status..", status="..status..", time="..time, "STT")
    if status == self.STATUS_PREPARE and self.working_status == self.STATUS_PREPARE then
        --准备超时，到时后仍未开始数据采集
        qf.event:dispatchEvent(ET.SPEECHTOTEXT_STATUS_NOTIFY, {status = SpeechToTextStatus.STT_ERROR, errcode = SpeechToTextErrorCode.STT_START_TIMEOUT})
    elseif status == self.STATUS_RECORDING and self.working_status == self.STATUS_RECORDING then
        --录音超时，到时后仍然没有停止录音
        qf.event:dispatchEvent(ET.SPEECHTOTEXT_STATUS_NOTIFY, {status = SpeechToTextStatus.STT_ERROR, errcode = SpeechToTextErrorCode.STT_REC_TIMEOUT})
    elseif status == self.STATUS_CONVERTING and self.working_status == self.STATUS_CONVERTING then
        --转换超时，到时后仍未得到转换结果
        qf.event:dispatchEvent(ET.SPEECHTOTEXT_STATUS_NOTIFY, {status = SpeechToTextStatus.STT_ERROR, errcode = SpeechToTextErrorCode.STT_CONVERT_TIMEOUT})
    end
end

--获取音量并映射到 0~VOLUME_MAX_LEVEL
function M:_getVoiceVolume()
    local volume = 0
    if self.working_status ~= self.STATUS_RECORDING then
        volume = 0
    else
        --ios平台音量 0~100
        local vol = qf.platform:getVoiceRecognitionVolume()
        if vol >= 50 then
            volume = 5
        elseif vol >= 40 then
            volume = 4
        elseif vol >= 30 then
            volume = 3
        elseif vol > 20 then
            volume = 2
        elseif vol > 10 then
            volume = 1
        else
            volume = 0
        end
    end
    return volume
end

function M:printLog(str, tag)
    logd(str, tag)
end

SpeechToText = M.new()