local PreloadView = class("PreloadView",qf.view)

PreloadView.TAG = "PreloadView"

function PreloadView:ctor(paras)
    self.super.ctor(self,paras)
    self.winSize = cc.Director:getInstance():getWinSize()
    self:init()
end

function PreloadView:init()
    local name = {      
        "lobbyViewJson"--  大厅界面json文件        
        ,"agreementViewJson"--  用户协议界面json文件
        ,"passwordViewJson"--  输入密码界面json文件
        ,"searchDeskJson"--  搜索房间json文件
        ,"mainViewJson"--  主界面json文件
        ,"courseReturnJson"--  新手教程返回界面json文件
        ,"courseTipsJson"--  新手教程提示界面json文件
        ,"pcLoginJson" -- pc登录
        ,"globalPromit"-- 公共提示框
        ,"gameViewJson"--  游戏内界面json文件
        ,"gameChatJson"--  聊天信息界面json文件
        ,"exitDialogJson"--  退出游戏界面json文件
        ,"gameLevelUpJson"--  场次升级界面json文件
        ,"userInfoJson"--  个人信息界面json文件
        ,"broadcastJson"--  广播json文件
    }
    local function preloadF()
        if name ~= nil and #name > 0 then
            self:runAction(
                cc.Sequence:create(
                    cc.DelayTime:create(0.2),
                    cc.CallFunc:create(function() 
                        local json = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes[name[#name]])
                        logd("加载文件-->"..name[#name],self.TAG)
                        self:addChild(json)
                        json:removeFromParent(true)
                        name[#name] = nil
                        return preloadF()
                    end)
            ))
        else
            logd("加载文件-->结束",self.TAG)
            qf.event:dispatchEvent(ET.PRELOAD_JSON_END)
        end
    end
    preloadF()
end

function PreloadView:getRoot() 
    return LayerManager.PreloadLayer
end

return PreloadView