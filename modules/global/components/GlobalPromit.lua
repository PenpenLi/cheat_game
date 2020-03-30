
local GlobalPromit = class("GlobalPromit.lua",function()
    return cc.Node:create()
end)

--[[{type = 2,pkg_status = pkg_status,des = update_prompt},type = 1}
    type 1为停服
    type 2为升级提示
    server_status  服务器状态， 0(正常), 1(停服)
    billboard      停服公告
    pkg_status   是否需要更新，0(不更新), 1(推荐更新), 2(强制更新)
    pkg_url      如果有可用的更新包, 则该字段就会返回更新包的地址
--]]
function GlobalPromit:ctor(paras)
    self.info = paras
    self.cbUpdate = paras.updateGame 

    if paras.typeStr == "maintain" then
        self:initMainTainUI()
    elseif paras.typeStr == "updatePackage" then
        self:initUpdatePackageUI()
    elseif paras.typeStr == "updateAppStorePackage" then
        self:initUpdateAppStorePackageUI(paras)
    else
        self:initUI()
    end
end

function GlobalPromit:initUpdateAppStorePackageUI(paras)
    self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.maintainViewJson)
    self.gui:setAnchorPoint(0.5,0.5)
    self:addChild(self.gui)
    
    ccui.Helper:seekWidgetByName(self.gui,"Panel_21"):setVisible(false)
    ccui.Helper:seekWidgetByName(self.gui,"Button_cancel"):setVisible(false)
    ccui.Helper:seekWidgetByName(self.gui,"Button_ok"):setVisible(false)

    if paras.data then
        local updateBtn = ccui.Helper:seekWidgetByName(self.gui,"Button_update")
        local ignoreBtn = ccui.Helper:seekWidgetByName(self.gui,"Button_ignore")
        -- 强制更新
        if tonumber(Util:getDesDecryptString(paras.data.ios_download_type)) == 2 then
            updateBtn:setVisible(true)
            ignoreBtn:setVisible(false)
            updateBtn:getLayoutParameter():setMargin({left = 0, right = 400, top = 0, bottom = 53})
        -- 建议更新
        else
            updateBtn:setVisible(true)
            ignoreBtn:setVisible(true)
        end
    end

    local desc = self.info.desc
    local callback = self.info.callback
    self:initContentTxt(desc, callback, false, true)

    self.panelBox:getChildByName("Image_15"):getChildByName("Image_title"):loadTexture(GameRes.common_tips_image_name_2, ccui.TextureResType.plistType)
end

function GlobalPromit:initUpdatePackageUI()
    self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.maintainViewJson)
    self.gui:setAnchorPoint(0.5,0.5)
    self:addChild(self.gui)
    
    ccui.Helper:seekWidgetByName(self.gui,"Panel_21"):setVisible(false)
    ccui.Helper:seekWidgetByName(self.gui,"Button_cancel"):setVisible(false)

    local desc = self.info.desc
    local callback = self.info.callback
    self:initContentTxt(desc, callback, true, true)

    self.panelBox:getChildByName("Image_15"):getChildByName("Image_title"):loadTexture(GameRes.common_tips_image_name_1, ccui.TextureResType.plistType)
end

-- 维护公告
function GlobalPromit:initMainTainUI()
    self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.maintainViewJson)
    self.gui:setAnchorPoint(0.5,0.5)
    self:addChild(self.gui)
    
    ccui.Helper:seekWidgetByName(self.gui,"Panel_21"):setVisible(false)
    ccui.Helper:seekWidgetByName(self.gui,"Button_cancel"):setVisible(false)

    local configlist = self.info.configlist
    local callback = self.info.callback
    self:initContentTxt(Util:getDesDecryptString(configlist.server_notice), callback)
end

function GlobalPromit:initContentTxt(desc, callback, bTextCenterLayout, bClose)
    self.panelBox = ccui.Helper:seekWidgetByName(self.gui, "Panel_box")
    local panelInfo = ccui.Helper:seekWidgetByName(self.panelBox, "Panel_info")
    local scrollview = ccui.Helper:seekWidgetByName(panelInfo, "ScrollView_23")
    local contentLabel = cc.LabelTTF:create(desc or "",GameRes.font1,40)
    contentLabel:setColor(cc.c3b(102, 147, 225))
    contentLabel:setAnchorPoint(cc.p(0,0))
    
    scrollview:addChild(contentLabel)
    local ssize = scrollview:getContentSize()
    local size = contentLabel:getContentSize()
    scrollview:setInnerContainerSize(cc.size(scrollview:getContentSize().width, size.height))

    if bTextCenterLayout then
        contentLabel:setVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
        contentLabel:setHorizontalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
    else
        contentLabel:setVerticalAlignment(cc.TEXT_ALIGNMENT_LEFT)
        contentLabel:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    end

    if ssize.width > size.width then
        contentLabel:setDimensions(cc.size(0,0))
    else
        contentLabel:setDimensions(cc.size(ssize.width, 0))
    end

    local contentLabelTxtSizeWidth = ssize.height > size.height and contentLabel:getBoundingBox().width or contentLabel:getContentSize().width
    contentLabel:setPosition(cc.p((scrollview:getContentSize().width - contentLabelTxtSizeWidth)/2, (scrollview:getContentSize().height - contentLabel:getContentSize().height)/2))

    addButtonEvent(ccui.Helper:seekWidgetByName(self.panelBox,"Button_ok"),function (sender)
        if callback then
            callback({status = "confirm"})
        end
        self:setVisible(false)
    end)

    addButtonEvent(ccui.Helper:seekWidgetByName(self.panelBox,"Button_update"),function (sender)
        if callback then
            callback({status = "confirm"})
        end
        self:setVisible(false)
    end)

    addButtonEvent(ccui.Helper:seekWidgetByName(self.panelBox,"Button_ignore"),function (sender)
        if callback then
            callback({status = "ignore"})
        end
        self:setVisible(false)
    end)

    local closeBtn = ccui.Helper:seekWidgetByName(self.panelBox,"Button_cancel")
    addButtonEvent(closeBtn, function (sender)
        if callback then
            callback({status = "close"})
        end
        self:setVisible(false)
    end)
    closeBtn:setVisible(false)
end


function GlobalPromit:initUI(paras)
    self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.globalPromit)
    self.gui:setAnchorPoint(0.5,0.5)
    self:addChild(self.gui)
    ccui.Helper:seekWidgetByName(self.gui,"promit_title"):setString(GameTxt.promitTitle)
    ccui.Helper:seekWidgetByName(self.gui,"promit_close_bt"):setVisible(false)
    ccui.Helper:seekWidgetByName(self.gui,"promit_sure"):setVisible(false)
    ccui.Helper:seekWidgetByName(self.gui,"promit_cancel"):setVisible(false)
    ccui.Helper:seekWidgetByName(self.gui,"promit_ok"):setVisible(false)

    if self.info.type == 0 then -- 服务器正常
        if self.info.pkg_status == 1 then -- 是可选升级提示  将关闭按钮显示出来
            ccui.Helper:seekWidgetByName(self.gui,"promit_close_bt"):setVisible(true)
            ccui.Helper:seekWidgetByName(self.gui,"promit_cancel"):setVisible(true)
            ccui.Helper:seekWidgetByName(self.gui,"promit_ok"):setVisible(true)
            addButtonEvent(ccui.Helper:seekWidgetByName(self.gui,"promit_close_bt"),function ( sender )
                self:close()
            end)
            addButtonEvent(ccui.Helper:seekWidgetByName(self.gui,"promit_cancel"),function ( sender )
                self:close()
            end)
            addButtonEvent(ccui.Helper:seekWidgetByName(self.gui,"promit_ok"),function ( sender )
                self:updateGame()
            end)
        elseif self.info.pkg_status == 2 then -- 强制更新
            ccui.Helper:seekWidgetByName(self.gui,"promit_sure"):setVisible(true)
            ccui.Helper:seekWidgetByName(self.gui,"promit_ok"):setVisible(false)
            addButtonEvent(ccui.Helper:seekWidgetByName(self.gui,"promit_sure"),function ( sender )
                self:updateGame()
                local strloading, strloading2 = GameTxt.dingtips, "."
                ccui.Helper:seekWidgetByName(self.gui,"promit_body_tv"):runAction(cc.RepeatForever:create(cc.Sequence:create(
                    cc.DelayTime:create(1.0)
                    ,cc.CallFunc:create(function(sender)
                        strloading2 = #strloading2 > 5 and "." or strloading2.."."
                        sender:setString(strloading..strloading2)
                        end))))
            end)
        end
        ccui.Helper:seekWidgetByName(self.gui,"promit_body_tv"):setString(self.info.des)
        ccui.Helper:seekWidgetByName(self.gui,"promit_title"):setString(GameTxt.newversion)
    elseif self.info.type == 1 then -- 停服操作
        ccui.Helper:seekWidgetByName(self.gui,"promit_sure"):setVisible(true)
        ccui.Helper:seekWidgetByName(self.gui,"promit_body_tv"):setString(self.info.des)
        addButtonEvent(ccui.Helper:seekWidgetByName(self.gui,"promit_sure"), function ( sender )
            self:close()
        end)
    end
end


function GlobalPromit:getSizeFormat(size)
    if size > 1024*1024 then
        return string.format("%.2fMB",size/(1024*1024))
    else
        return string.format("%.1fKB",size/1024)
    end
end

function GlobalPromit:hotupdateInfo()
    local size = self.info.size
    ccui.Helper:seekWidgetByName(self.gui,"promit_title"):setString(GameTxt.newResTile)
    local content = ccui.Helper:seekWidgetByName(self.gui,"promit_body_tv")
    local sureBtn = ccui.Helper:seekWidgetByName(self.gui,"promit_sure")
    local closeBtn = ccui.Helper:seekWidgetByName(self.gui,"promit_close_bt")

    --content:setString("00000 aaa 0000 ")
    if self.info.status == "1" then closeBtn:setVisible(true) end
    content:setString(string.format(GameTxt.newRes,self:getSizeFormat(size)))

    addButtonEvent(sureBtn,function ( fsender )
        sureBtn:setVisible(false)
        ZD:addTask({
                errorcb=function (  )
                    content:setString(GameTxt.newResError)
                    closeBtn:setVisible(true)
                end,
                successcb=function (  )
                    logd(" ---- download success ---- , need restart game !")
                    sureBtn:setVisible(true)
                    content:setString(GameTxt.newResDone)
                    cc.UserDefault:getInstance():setIntegerForKey(RES_VERSION_KEY,self.info.newversion) --设置资源版本号
                    cc.UserDefault:getInstance():flush()
                    addButtonEvent(sureBtn,function ( sender )
                        logd(" ---- 重启游戏 ---- ")
                        qf.platform:restartGame()
                    end)
                end,
                progresscb=function (percent)
                    content:setString(string.format(GameTxt.dingtxt2,percent))
                end,
                zipurl=self.info.zipurl,
                versionurl=self.info.versionurl,
                path=UPDATE_DIR
        })
    end)


    addButtonEvent(closeBtn,function ( sender )
        logd(" ---- 下载失败 --- ， 进入游戏 --")
        self.info.cb()
        self:close()
    end)
end

function GlobalPromit:close()
    if self.cbUpdate then
        self.cbUpdate(0)
    end
end
function GlobalPromit:updateGame()
    if self.cbUpdate then
        self.cbUpdate(1)
    end
end

return GlobalPromit