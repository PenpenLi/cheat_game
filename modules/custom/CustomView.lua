--local CustomView = class("CustomView", qf.view)
local CustomView = class("CustomView", CommonWidget.PopupWindow)

CustomView.TAG = "CustomView"

function CustomView:ctor(parameters)
    self.winSize = cc.Director:getInstance():getWinSize()
    self.root = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.custom)
    self:init(parameters)
    self.super.ctor(self, {id=PopupManager.POPUPWINDOW.custom, child=self.root})
    qf.platform:umengStatistics({umeng_key = "Custom"})
end

function CustomView:initWithRootFromJson()
    return GameRes.custom
end

function CustomView:isAdaptateiPhoneX()
    return true
end


function CustomView:init(param)
    self._dataList = {}
    local defaultHandler = handler(self, self.onButtonEvent)
    local uiTbl = {
        {name = "queryBtn",           path = "Panel_custom_frame/Panel_Left/Button_40",         handler = defaultHandler},
        {name = "recordBtn",          path = "Panel_custom_frame/Panel_Left/Button_40_0",       handler = defaultHandler},               
        {name = "Button_close",       path = "Panel_custom_frame/Button_close",                 handler = defaultHandler},
        {name = "inputView",          path = "Panel_custom_frame/Panel_info"},
        {name = "detailView",         path = "Panel_custom_frame/Panel_info_1"},
        {name = "recordView",         path = "Panel_custom_frame/Panel_info_2"},
    }
    Util:bindUI(self, self.root, uiTbl)
    self.btnX = self.recordBtn:getPositionX()
    self.uiViewList = {self.inputView, self.detailView, self.recordView}
    self:initIphoneInputView()
    self:initRecordView()
    self:initDetailView()
    if Cache.customInfo:checkNewCustom() then
        self:onButtonEvent(self.recordBtn)
    else
        self:onButtonEvent(self.queryBtn)
    end
    Util:enlargeCloseBtnClickArea(self.Button_close, defaultHandler)
end

function CustomView:setContentText(str)
    self.contentLabel:setString(str)
    if self.initStr == str then
        self.contentLabel:setColor(self.tipColor)
    else
        self.contentLabel:setColor(self.normalColor)
    end
end

function CustomView:initIphoneInputView()
    local initStr = GameTxt.string_custom_1
    self.initStr = initStr
    local tipColor = cc.c3b(196, 219, 253)
    local normalColor = cc.c3b(102, 147, 225)

    self.tipColor = tipColor
    self.normalColor = normalColor

    self.contentLabel = self.inputView:getChildByName("Label_QQ_0")
    self:setContentText(initStr)

    local editBoxPhone = cc.EditBox:create(cc.size(950, 960), cc.Scale9Sprite:create())
    editBoxPhone:setTag(-987654)  -----  这个虚拟editbox tag 一定要设置成这个数字 因为cocos2dx 底层 CCEditBoxImplIOS有改动  读取这个值。
    editBoxPhone:setFontName(GameRes.font1)
    self.inputView:addChild(editBoxPhone)
    editBoxPhone:setName("editPhoneFrame")
    editBoxPhone:setFontSize(45)
    editBoxPhone:setMaxLength(50)
    local editBoxPos = cc.p(26, 20)
    editBoxPhone:setPosition(editBoxPos)
    editBoxPhone:setColor(cc.c3b(255,0,0))
    editBoxPhone:setAnchorPoint(cc.p(0,0))

    local handler = function(event)
        if event == "began" then
            local cstr = self.contentLabel:getString()
            if cstr == initStr then
                editBoxPhone:setText("")

                self:setContentText("")
            else
                editBoxPhone:setText(cstr)
                editBoxPhone:setVisible(false)
            end
        end
        
        if event == "changed" then
            local str =  editBoxPhone:getText()
            self.contentLabel:setString(str)
            editBoxPhone:setVisible(false)
            self:setContentText(str)
        end
        
        if event == "return" then
           local str =  editBoxPhone:getText()
           editBoxPhone:setText("")
           editBoxPhone:setVisible(true)
           self:setContentText(str)
           
           if str == "" then
               self:setContentText(initStr)
           end
        end

    end

    editBoxPhone:registerScriptEditBoxHandler(handler)

    local okBtn = self.inputView:getChildByName("Button_50")
    addButtonEvent(okBtn, function ()
        local cstr = self.contentLabel:getString()
        if cstr == "" or cstr == initStr then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_custom_2})
            return
        end

        local curtime = socket.gettime()
        if self._lasttime and curtime - self._lasttime <= 1 then
            -- qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_custom_6})
            return
        end
        self._lasttime = curtime
        self:requestAskQes(Cache.user.uin, cstr)
    end)

    self._initStr = initStr
    
    local colorLayer = cc.LayerColor:create(cc.c4b(0, 0, 0, 100))
    colorLayer:setContentSize(cc.size(950, 1000))
    colorLayer:setOpacity(0)
    self.inputView:addChild(colorLayer, 9999)
    colorLayer:setPosition(editBoxPos)
    local maskLayer = cc.LayerColor:create(cc.c4b(255,0,0,100))
    maskLayer:setContentSize(cc.size(950, 500))
    maskLayer:setOpacity(0)
    self.inputView:addChild(maskLayer, 9999)
    maskLayer:setPosition(cc.p(editBoxPos.x, 500 + editBoxPos.y))

    Util:addNormalTouchEvent(maskLayer, function(method, touch, event)
        local loc = touch:getLocation()
        loc = maskLayer:getParent():convertToNodeSpace(loc)
        if method == "began" then
            print(cc.rectContainsPoint(maskLayer:getBoundingBox(), loc))
            if cc.rectContainsPoint(maskLayer:getBoundingBox(), loc) then
                return true
            else
                return false
            end
        end
    end)
end

function CustomView:refreshInputView()
    self.contentLabel:setString(self._initStr)
end

local recordData = {
    [1] = {time = "199305215", status = "已经回复", detail = "XxxxxxxxxxxxxxxxxxC"},
    [2] = {time = "129305215", status = "已经回复", detail = "XxxxxxxxxxxxxxxxxxC"},
    [3] = {time = "149305215", status = "已经回复", detail = "XxxxxxxxxxxxxxxxxxC"},
}

function CustomView:refreshRecordView()
    self._dataList = {}
    Cache.customInfo:requestCustomInfo(function (data)
        self._dataList = data
        if tolua.isnull(self) == false then
            self:refreshRecordViewEx()
        end
    end)
end

function CustomView:refreshRecordViewEx()
    local listview = self.recordView:getChildByName("ListView_95")
    listview:removeAllChildren()
    local function _updateItem(index, info)
        listview:pushBackDefaultItem()
        local item = listview:getItem(index-1)
        item:setVisible(true)
        --主题字符限制比较
        local timeTxt = item:getChildByName("Label_98")
        timeTxt:setString(Util:getDateDescription(info.time))
        local statusTxt = item:getChildByName("Label_98_0")
        local statusContent = ""
        local color = cc.c3b(0,0,0)
        print(info.status)
        if info.status == 0 then
            statusContent = GameTxt.string_custom_4
            color = cc.c3b(255,0,0)
        elseif info.status == 1 then
            statusContent = GameTxt.string_custom_5
            color = cc.c3b(102, 147, 225)
        end

        statusTxt:setString(statusContent)
        statusTxt:setColor(color)

        item:getChildByName("Image_101"):setTouchEnabled(true)
        addButtonEvent(item:getChildByName("Image_101"), function ()
            self:showView(self.detailView)
            self:refrehsDetailView(info.question, info.answer)
        end)
    end

    local len = #self._dataList
    for i = 1, len do
        _updateItem(i, self._dataList[i])
    end
end

function CustomView:initRecordView()
    local item = self.recordView:getChildByName("item")
    local listview = self.recordView:getChildByName("ListView_95")
    listview:setItemModel(item)
    item:setVisible(false)
end

function CustomView:initDetailView()
    addButtonEvent(ccui.Helper:seekWidgetByName(self.detailView, "Button_72"), function ()
        self:showView(self.recordView)
    end)
end

function CustomView:refrehsDetailView(question, answer)
    ccui.Helper:seekWidgetByName(self.detailView, "Label_103"):setString(question)
    ccui.Helper:seekWidgetByName(self.detailView, "Label_102"):setString(answer)
end

function CustomView:onButtonEvent(sender)
    if sender.name == "queryBtn" then
        self:showView(self.inputView)
        self:refreshButton(sender.name)
        self:refreshInputView()
    elseif sender.name == "recordBtn" then
        self:showView(self.recordView)
        self:refreshButton(sender.name)
        self:refreshRecordView()
    elseif sender.name == "Button_close" then
        self:close()
    end
end

function CustomView:showView(view)
    for i, v in ipairs(self.uiViewList) do
        v:setVisible(false)
    end
    view:setVisible(true)
end

function CustomView:refreshButton(name)
    self.queryBtn:setBright(name ~= "queryBtn")
    self.queryBtn:setTouchEnabled(name ~= "queryBtn")
    self.recordBtn:setBright(name ~= "recordBtn")
    self.recordBtn:setTouchEnabled(name ~= "recordBtn")
    self.queryBtn:getChildByName("Image_45"):loadTexture(GameRes.custom_image_1, 0)
    self.recordBtn:getChildByName("Image_45"):loadTexture(GameRes.custom_image_2, 0)
    self.queryBtn:setPositionX(self.btnX)
    self.recordBtn:setPositionX(self.btnX)
    local ox = 3
    if name == "queryBtn" then
        self.queryBtn:getChildByName("Image_45"):loadTexture(GameRes.custom_image_3, 0)
        self.queryBtn:setPositionX(self.btnX+ox)
    elseif name == "recordBtn" then
        self.recordBtn:getChildByName("Image_45"):loadTexture(GameRes.custom_image_4, 0)
        self.recordBtn:setPositionX(self.btnX+ox)
    end
end

function CustomView:requestAskQes(uin, question)
    local paras = {
        question = question,
        uin = uin,
        cb = function ( ... )
            if tolua.isnull(self) == false then
                self:setContentText(self.initStr)
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.string_custom_3})
            end
        end
    }
    Cache.customInfo:requestAskQes(paras)
end

function CustomView:getRoot() 
    return LayerManager.PopupLayer
end

return CustomView