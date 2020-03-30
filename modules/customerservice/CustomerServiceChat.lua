local CustomerServicesChat = class("CustomerServicesChat", CommonWidget.PopupWindow)

CustomerServicesChat.TAG = "CustomerServicesChat"

local targetPlatform = cc.Application:getInstance():getTargetPlatform()

function CustomerServicesChat:ctor(parameters)
    self.winSize = cc.Director:getInstance():getWinSize()
    self.root = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.customerServiceJson)
    self:init(parameters)
    qf.event:dispatchEvent(ET.GLOBAL_HIDE_BROADCASE_LAYOUT)
    self.super.ctor(self, {id=PopupManager.POPUPWINDOW.customerServiceChat, pop_action = self.POPUP_ACTION.LEFT_TO_RIGHT, child=self.root})
end

function CustomerServicesChat:init(parameters)
    local defaultHandler = handler(self, self.onButtonEvent)
    local uiTbl = {
        --tablelist中的item
        {name = "chat_item_myself_txt",         path = "chat_item_myself_txt"},
        {name = "chat_item_myself_img",         path = "chat_item_myself_img"},
        {name = "chat_item_other_img",          path = "chat_item_other_img"},
        {name = "chat_item_other_txt",          path = "chat_item_other_txt"},
        {name = "service_list_item",            path = "service_list_item"},

        --聊天
        {name = "chat_pannel",                path = "chat_pannel"},
        {name = "chat_detail_pannel",         path = "chat_pannel/chat_pannel"},
        {name = "chat_list",                  path = "chat_pannel/chat_pannel/chat_list"},

        --左边客服信息
        {name = "b_AgentView",          path = "chat_pannel/customer_info/b_agent"},
        {name = "not_AgentView",        path = "chat_pannel/customer_info/not_agent"},
        {name = "serviceInfoList",      path = "chat_pannel/customer_info/b_agent/services_info_list"},

        --发送信息相关的
        {name = "sendImageBtn",         path = "chat_pannel/chat_pannel/upload_img_btn", handler = defaultHandler},
        {name = "sendMsgtn",             path = "chat_pannel/chat_pannel/send_btn", handler = defaultHandler},
        {name = "input",                path = "chat_pannel/chat_pannel/input", handler = defaultHandler},
        {name = "closeBtn",                path = "chat_pannel/closeBtn", handler = defaultHandler},
        {name = "placeHolderText",                path = "chat_pannel/chat_pannel/placeHolderText"},

        -- 提示框
        {name = "complainPannel",      path = "complain_pannel"},
        {name = "complainCloseBtn",      path = "complain_pannel/close", handler = defaultHandler},
        {name = "comfirmBtn",      path = "complain_pannel/comfirmBtn", handler = defaultHandler},
        {name = "cancleBtn",      path = "complain_pannel/cancleBtn", handler = defaultHandler},
        {name = "alertText",      path = "complain_pannel/content/text_content/text"},

        -- 时间展示框
        {name = "timeItem",      path = "chat_item_time"},

        -- 跑马灯
        {name = "scrollTextContainer",  path = "chat_pannel/scrollTextContainer"},
        {name = "boardImage",  path = "chat_pannel/board"}
    }

    Util:bindUI(self, self.root, uiTbl)
    self:initComplainPannel()
    cc.SpriteFrameCache:getInstance():addSpriteFramesWithFile(GameRes.image_loading_plist, GameRes.image_loading_png)
    --初始化参数
    self:initData(parameters)
    --先加载缓存数据
    self:refreshChatList()
    --初始化输入框
    self:initInputPannel()
    --监听聊天数据服务
    self:registerChatServerData()
    --更新服务信息
    self:updateServerInfo()
    --播放跑马灯
    if self.forceLinkType == GameConstants.ChatUserType.OFFICIAL then
        self:playBroadCast()
    end
    
    --同步历史数据
    Util:delayRun(1/30, function ( ... )
        Cache.cusChatInfo:syncHistoryMsg(self.forceLinkType == GameConstants.ChatUserType.OFFICIAL and 100 or Cache.user.invite_from)
        Cache.cusChatInfo:clearUnReadMessage(self.forceLinkType)
    end)
end

function CustomerServicesChat:initData(parameters)
    self.lastSendTime = nil
    self.isLoadingItemIng = false
    -- 1是客服 2是代理
    self.forceLinkType = nil
    self.proxy_son_data_id = 0
    if parameters then
        self.forceLinkType = parameters.forceLinkType
        if parameters.data then
            self.proxy_son_info = parameters.data
            Cache.cusChatInfo:updateLastChatProxcyDataId(parameters.data.data_id)
            self.proxy_son_data_id = parameters.data.data_id
        end
    end
end

function CustomerServicesChat:initComplainPannel( ... )
    self.complainPannel:setVisible(false)
    self.alertText:setString(GameTxt.string_custom_7)
    if FULLSCREENADAPTIVE then
        self.complainPannel:setContentSize(cc.size(self.complainPannel:getContentSize().width + self.winSize.width-1920,self.complainPannel:getContentSize().height))
    end
end

function CustomerServicesChat:checkIfShouldSendMessgae( ... )
    -- if not self.lastSendTime then return true end
    -- -- 小于2s则提示
    -- if self.lastSendTime - os.time() > 2 then return true end
    -- qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.send_to_sequence_txt})
    -- return false
    return true
end

function CustomerServicesChat:initInputPannel( ... )
    local setUpEditeBox = function (sender)
        local inputText = cc.EditBox:create(cc.size(self.placeHolderText:getContentSize().width + 30, self.placeHolderText:getContentSize().height), cc.Scale9Sprite:create())
        inputText:setTag(-987654)
        inputText:setFontName(GameRes.font1)
        inputText:setFontColor(cc.c3b(102,147,225))
        inputText:setName("inputText")
        inputText:setFontSize(30)
        inputText:setMaxLength(50)
        inputText:setPlaceholderFontSize(self.placeHolderText:getFontSize())
        inputText:setPlaceHolder(self.placeHolderText:getString())
        inputText:setPlaceholderFontColor(cc.c3b(58,111,174))
        inputText:setInputMode(cc.EDITBOX_INPUT_MODE_ANY) -- cc.EDITBOX_INPUT_MODE_SINGLELINE    --用户可以输入任何文字，换行除外
        inputText:setReturnType(cc.KEYBOARD_RETURNTYPE_SEND)
        inputText:registerScriptEditBoxHandler(handler(self, self.editboxEventHandler))
        inputText:setPosition(cc.p(self.placeHolderText:getContentSize().width/2 + 30, sender:getContentSize().height/2))

        return inputText
    end

    -- ios 这边出入框特殊处理
    if targetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_IPAD then
        self.placeHolderText:setVisible(true)
        self.input:setTouchEnabled(true)
    else
        self.input:setTouchEnabled(false)
        self.placeHolderText:setVisible(false)

        self.inputText = setUpEditeBox(self.input)
        self.inputText:setName("inputText")
        self.input:addChild(self.inputText)
    end
end


function CustomerServicesChat:playBroadCast(content)
    local wordMessage = Cache.wordMsg:getMsgByType(2)
    if self.forceLinkType == GameConstants.ChatUserType.PROXCY then
        if not content then return end
        if content == "" then return end
        wordMessage = {
            [1] = {
                content = content
            }
        }
    end
    self.scrollMessageArr = wordMessage
    self:showScrollMessage(self.scrollMessageArr[1])
end

--全局滚动消息
function CustomerServicesChat:showScrollMessage(message)
    if not message then return end
    self.scrollMessageArr = self.scrollMessageArr or {}
    table.insert(self.scrollMessageArr, message)
    if self.scrollTextContainer:isVisible() then
        return
    end

    local scrollTextPanel = ccui.Layout:create()
    scrollTextPanel:setContentSize(cc.size(self.scrollTextContainer:getContentSize().width,self.scrollTextContainer:getContentSize().height))
    scrollTextPanel:setPosition(cc.p(10,0))
    scrollTextPanel:setClippingEnabled(true)
    scrollTextPanel:setName("scrollTextPanel")
    self.scrollTextContainer:addChild(scrollTextPanel)

    self.scrollTextContainer:setVisible(true)
    self:startScrollMessage()

end

function CustomerServicesChat:startScrollMessage()
    local messageCount = #self.scrollMessageArr
    local scrollTextPanel = self.scrollTextContainer:getChildByName("scrollTextPanel")
    if messageCount > 0 then
        if self.scrollTextContainer:isVisible() then
            local messageContent = self.scrollMessageArr[1]
            -- 代理循环播放 30s，客服按照其他的来
            local delayTime = self.forceLinkType == GameConstants.ChatUserType.OFFICIAL and 1 or 10
            if self.forceLinkType == GameConstants.ChatUserType.OFFICIAL then
                table.remove(self.scrollMessageArr,1)
            end

            local scrollText = ccui.Text:create()
            scrollText:setFontSize(34)
            scrollText:setAnchorPoint(cc.p(0,0.5))
            scrollText:setColor(cc.c3b(255,233,108))
            scrollText:setString(messageContent.content)
            scrollText:setPosition(cc.p(scrollTextPanel:getContentSize().width,scrollTextPanel:getContentSize().height/2))
            scrollTextPanel:addChild(scrollText)

            local moveDistance = scrollText:getContentSize().width + scrollTextPanel:getContentSize().width
            local moveDuration = moveDistance / 200
            self.boardImage:setVisible(true)
            local scrollAction = cc.Sequence:create(
                            cc.MoveBy:create(moveDuration, cc.p(-moveDistance,0)),
                            cc.DelayTime:create(delayTime),
                            cc.CallFunc:create(function() 
                                self:startScrollMessage()
                            end)
                        )
            self.boardImage:runAction(cc.Sequence:create(
                    cc.DelayTime:create(moveDuration + 0.15),
                    cc.CallFunc:create(function ( ... )
                        self.boardImage:setVisible(false)
                    end)
                ))
            scrollText:runAction(scrollAction)
        else
            self.scrollMessageArr = {}
        end
    else
        self.scrollTextContainer:setVisible(false)
        if scrollTextPanel then
            scrollTextPanel:removeFromParent()
        end
    end
end


function CustomerServicesChat:editboxEventHandler( strEventName,sender )
    logd("【CustomerServicesChat】 editboxEventHandler == ", strEventName)
    --编辑开始
    if strEventName == "began" then
        
    --编辑结束        
    elseif strEventName == "return" or strEventName == "ended" then

    --字符改变
    elseif strEventName == "changed" then

    end
end

-- 监听聊天数据服务
function CustomerServicesChat:registerChatServerData( ... )
    qf.event:addEvent(ET.CHAT_MONITOR_EVENT, function (paras)
        if not tolua.isnull(self) then
            self:updateChatList(paras)
        end
    end)
    qf.event:addEvent(ET.UPDATE_CHAT_ITEM, function (paras)
        if not tolua.isnull(self) then
            if paras then
                if paras.sessionInfo and paras.mesgType then
                    self:reloadChatListItem(paras.sessionInfo, paras.mesgType)
                end
                if paras.remove and paras.sessionInfo then
                    self:removeMessageItem(paras.sessionInfo)
                end
            end
        end
    end)
end

function CustomerServicesChat:refreshChatList(bClearUnReadMsg)
    local delayTime = 1/60
    -- 1.切换后台，cocos会暂停，切回来的时候，收到新的消息，再拉取消息需要过程
    -- 2.延迟清除未读消息
    -- 3.关闭，也清除未读消息
    if bClearUnReadMsg then
        delayTime = 0.25
    end

    performWithDelay(self, function ( ... )
        self:updateChatList({bAdd = false, data = Cache.cusChatInfo:getChatDataByType(self.forceLinkType, self.proxy_son_data_id)})
    end, delayTime)
end

function CustomerServicesChat:updateChatList(paras)
    if not paras then return end
    --插入消息
    if not paras.bAdd then
        self.chat_list:removeAllItems()
    end

    if not paras.data then return end
    if #paras.data < 0 then return end
    
    local betweenTime = 1/60
    local addTimeItem = function (chatItemIndex, bAdd)
        -- 新消息过来就增加时间判断
        if paras.bAdd and #self.chat_list:getItems() > 0 then
            -- 先判断旧的消息数据是哪条
            local lastMessage = Cache.cusChatInfo:getLastMessageWhenPush(self.forceLinkType)
            -- 大于十分钟内
            if lastMessage then
                if os.time() - lastMessage.timestamp >= 10*60 then
                    local time = bAdd and 0 or chatItemIndex*betweenTime
                    Util:delayRun(time, function ( ... )
                        local timeItem = self.timeItem:clone()
                        self:updateTimeItemCell(timeItem, lastMessage)
                        self.chat_list:insertCustomItem(timeItem, #self.chat_list:getItems())
                    end)
                    return true
                end
            end
        end
        return false
    end

    local currentTime = os.time()
    local chatItemIndex = 0
    for k,v in ipairs(paras.data) do
        local flag = false
        -- 代理聊天，判断消息来源
        -- 自己的消息也有发给代理和客服的
        if self.forceLinkType == GameConstants.ChatUserType.PROXCY then
            if v.uin == Cache.user.invite_from or (v.uin == Cache.user.uin and v.targetid == Cache.user.invite_from) then
                flag = true
            end
        else
            if Cache.user:isCustomerService(v.uin) or (v.uin == Cache.user.uin and Cache.user:isCustomerService(v.targetid)) then
                flag = true
            end
        end
        local proxy_data_id = v.proxy_data_id or 0
        if self.proxy_son_data_id ~= proxy_data_id then
            flag = false
        end
        local chatTimeMax = 5*24*60*60
        if flag and (currentTime - tonumber(v.timestamp)) <= chatTimeMax then
            if k == 1 then
                local bLoadTimeItem = addTimeItem(chatItemIndex, paras.bAdd)
                if not paras.bAdd and bLoadTimeItem then
                    chatItemIndex = chatItemIndex + 1
                end
            end
            if not paras.bAdd then
                self.isLoadingItemIng = true
                chatItemIndex = chatItemIndex + 1
            end
            --更新列表
            local delayRunTime = paras.bAdd and 0 or chatItemIndex*betweenTime
            Util:delayRun(delayRunTime, function ( ... )
                local item = nil
                local bMyself = v.uin == Cache.user.uin
                -- 消息内容是文本
                if v.msg_type == GameConstants.ChatMsgType.MSG_TEXT then
                    if bMyself then
                        item = self.chat_item_myself_txt:clone()
                    else
                        item = self.chat_item_other_txt:clone()
                    end
                    self:updateTextItemCell(bMyself, item, v, paras.bAdd)
                --消息内容是图片
                elseif v.msg_type == GameConstants.ChatMsgType.MSG_PIC_BRIEF then
                    if bMyself then
                        item = self.chat_item_myself_img:clone()
                    else
                        item = self.chat_item_other_img:clone()
                    end
                    self:updateImageItemCell(bMyself, item, v, paras.bAdd)
                end

                --设置list
                item.session_info = v.session_info
                item:setVisible(true)
                self.chat_list:insertCustomItem(item, #self.chat_list:getItems())
            end)
        end
    end

    Util:delayRun(chatItemIndex*betweenTime, function ( ... )
        self:reloadChatList()
        self:notifyLastReadTimeToServer()
    end)
end

-- 通知服务器客服界面所展示的最后一条代理或者客服发送的消息时间戳
function CustomerServicesChat:notifyLastReadTimeToServer( ... )
    local lastMesg = Cache.cusChatInfo:getLastOtherTargetUserMessage(self.forceLinkType)
    -- 存在空table的情况
    if not lastMesg.sequence then 
        lastMesg = nil 
    end
    Cache.cusChatInfo:notifyLastReadInfoToServer(lastMesg, 1, self.proxy_son_data_id)
end

function CustomerServicesChat:updateTimeItemCell(item, message)
    item:setVisible(true)
    item:getChildByName("text"):setString(Util:getTimeDescription(message.timestamp))
end

function CustomerServicesChat:updateTextItemCell(bMyself, item, message, bAdd)
    local textLenMax = 30 --15个汉字长度
    local textToTopMargin = 30
    local textToBgMargin = 20

    local textContent = item:getChildByName("content")
    local showText = textContent:getChildByName("Label_21")
    local textBg = textContent:getChildByName("msg_bg")
    local headIcon = item:getChildByName("head_icon")
    local status = textContent:getChildByName("status")
    status:setVisible(false)
    -- 测试用的
    local msg = Util:limitStringNumber(message.textInfo.msg, textLenMax)
    showText:setString(msg)

    local removeLoadingAni = function (node, aniName)
        if node:getChildByName(aniName) then
            node:getChildByName(aniName):removeFromParent()
        end
    end

    local addLoadFunc = function (node)
        node:setVisible(true)
        removeLoadingAni(node, "loadingAni")
        local defaultImageFrame = cc.SpriteFrameCache:getInstance():getSpriteFrameByName(string.format(GameRes.image_loading_name, 1))
        local start = cc.Sprite:createWithSpriteFrame(defaultImageFrame)
        start:setScale(0.3)
        start:setName("loadingAni")
        start:setPosition(cc.p(node:getContentSize().width/2, node:getContentSize().height/2))
        local spriteFrames = {}
        for i = 1, 12  do
            spriteFrames[i] = cc.SpriteFrameCache:getInstance():getSpriteFrameByName(string.format(GameRes.image_loading_name, i))
        end
        local animation = cc.Animation:createWithSpriteFrames(spriteFrames, 0.04)
        start:runAction(cc.RepeatForever:create( cc.Animate:create(animation) ) )
        node:addChild(start)
    end

    local sendLoadingFunc = function (node, message)
        addLoadFunc(node)
        -- 发送超时处理
        node:runAction(cc.Sequence:create(
            cc.DelayTime:create(10),
            cc.CallFunc:create(function (sender)
                -- 停止转圈
                removeLoadingAni(node, "loadingAni")
                node:getChildByName("re_send"):setVisible(true)
                Cache.cusChatInfo:updateSendFailMessage(message)
            end)
        ))
    end

    addButtonEvent(status:getChildByName("re_send"), function ( ... )
        Cache.cusChatInfo:resendFailMessage(message.session_info, self.forceLinkType)
        --点击重发，重新转圈
        status:getChildByName("re_send"):setVisible(false)
        sendLoadingFunc(status,message)
    end)
    

    if bMyself then
        if not message.sequence and not message.bLoad then
            -- 如果是重发
            if message.reSend then
                removeLoadingAni(status, "loadingAni")
                status:setVisible(true)
                status:getChildByName("re_send"):setVisible(true)
            else
                sendLoadingFunc(status, message)
            end
        else
            status:setVisible(false)
            removeLoadingAni(status, "loadingAni")
            status:stopAllActions()
        end
    end

    --调整大小
    local textContentSize = showText:getContentSize()
    local textLayoutMargin = showText:getLayoutParameter():getMargin()
    local widthMargin = bMyself and textLayoutMargin.right or textLayoutMargin.left
    local heightMargin = textLayoutMargin.top
    textContent:setContentSize(textContentSize.width + widthMargin + textToBgMargin, textContentSize.height + heightMargin*2)
    textBg:setContentSize(textContentSize.width + widthMargin + textToBgMargin, textContentSize.height + heightMargin*2)
    local itemHeight = textBg:getContentSize().height
    if itemHeight > headIcon:getContentSize().height - 10 then
        itemHeight = itemHeight + textToTopMargin
    end
    if bMyself then
        Util:updateUserHead(headIcon, Cache.user.portrait, Cache.user.sex, {add = true, sq = true, url = true, scale = headIcon:getContentSize().width, circle=false})
    else
        local proxyInfo = Cache.agencyInfo:getPersonalInfo()
        if not Cache.user:isCustomerService(message.uin) and proxyInfo then
            Util:updateUserHead(headIcon, proxyInfo.proxy_portrait, proxyInfo.sex, {add = true, sq = true, url = true, scale = headIcon:getContentSize().width, circle=false})
        end
    end
    if itemHeight > headIcon:getContentSize().height + textBg:getLayoutParameter():getMargin().top then
        item:setContentSize(cc.size(item:getContentSize().width, itemHeight))
    end
end

function CustomerServicesChat:updateImageItemCell(bMyself, item, message, bAdd)
    local picRate = 1
    local imageMaxRate = 2/3

    local picImageInfo = message.picInfo
    local content = item:getChildByName("content")
    local imageBg = content:getChildByName("img_bg")
    local headIcon = item:getChildByName("head_icon")
    local headIconLayout = headIcon:getLayoutParameter():getMargin()
    local imgPlacholder = content:getChildByName("img")
    local loading = content:getChildByName("loading")
    imageBg:setVisible(false)

    -- 刷新item
    local refreshItemWhenLoadImage = function (sizeModel)
        local picImageInfo = {width = sizeModel.width, height = sizeModel.height}
        local rate = sizeModel.width/sizeModel.height
        if sizeModel.width > item:getContentSize().width*imageMaxRate then
            picImageInfo.width = item:getContentSize().width*imageMaxRate
            picImageInfo.height = picImageInfo.width/rate
        end

        if sizeModel.height > self.chat_list:getContentSize().height*imageMaxRate then
            picImageInfo.height = self.chat_list:getContentSize().height*imageMaxRate
            picImageInfo.width = picImageInfo.height*rate
        end
        
        -- local maxWidth = item:getContentSize().width*imageMaxRate
        -- local factor = 1
        -- dump(sizeModel)
        -- dump(maxWidth)
        -- if sizeModel.width > maxWidth then
        --     factor = maxWidth / sizeModel.width
        --     picImageInfo.width = sizeModel.width*factor
        --     picImageInfo.height = sizeModel.height*factor
        -- else
        --     if sizeModel.height > maxWidth then
        --         factor = maxWidth / sizeModel.height
        --         picImageInfo.width = math.max(sizeModel.width*factor, 200)
        --         picImageInfo.height = sizeModel.height*factor
        --     end
        -- end

        content:setContentSize(cc.size(picImageInfo.width, picImageInfo.height))
        imageBg:setContentSize(cc.size(picImageInfo.width, picImageInfo.height))
        
        if picImageInfo.height <= headIcon:getContentSize().height then
            item:setContentSize(cc.size(item:getContentSize().width, headIconLayout.top + headIcon:getContentSize().height))
        else
            item:setContentSize(cc.size(item:getContentSize().width, headIconLayout.top + picImageInfo.height))
        end
        self:reloadChatList()
    end

    -- 加载小图失败
    local imageLoadFailFunc = function ()
        if tolua.isnull(imgPlacholder) == false then
            imgPlacholder:loadTexture(GameRes.customer_chat_loadImage_fail, ccui.TextureResType.plistType)
        end
    end

    local imageLoading = function (node)
        node:setVisible(true)
        loading:setContentSize(cc.size(node:getParent():getContentSize().width, node:getParent():getContentSize().height))
        if node:getChildByName("loadingAni") then
            node:getChildByName("loadingAni"):removeFromParent()
        end
        local defaultImageFrame = cc.SpriteFrameCache:getInstance():getSpriteFrameByName(string.format(GameRes.image_loading_name, 1))
        local start = cc.Sprite:createWithSpriteFrame(defaultImageFrame)
        start:setScale(0.3)
        start:setName("loadingAni")
        start:setPosition(cc.p(node:getContentSize().width/2, node:getContentSize().height/2))
        local spriteFrames = {}
        for i = 1, 12  do
            spriteFrames[i] = cc.SpriteFrameCache:getInstance():getSpriteFrameByName(string.format(GameRes.image_loading_name, i))
        end
        local animation = cc.Animation:createWithSpriteFrames(spriteFrames, 0.04)
        start:runAction(cc.RepeatForever:create( cc.Animate:create(animation) ) )
        node:addChild(start)
    end

    local imgLoadFun = function (node, path, bTouch, url, scale)
        local tempScale = scale
        node:loadTexture(path)
        if node:getContentSize().width > self.chat_list:getContentSize().width *imageMaxRate then
            tempScale = self.chat_list:getContentSize().width *imageMaxRate/node:getContentSize().width
        end
        node:setScale(tempScale)
        refreshItemWhenLoadImage({width = node:getContentSize().width*tempScale, height = node:getContentSize().height*tempScale})
        node:setTouchEnabled(bTouch)
        addButtonEvent(node, function ( ... )
            qf.event:dispatchEvent(ET.SHOW_BIG_HEAD_IMAGE_EVENT, {src_photo = node, url = url})
        end)
        return tempScale
    end

    local loadingRemoveFunc = function (node)
        node:setVisible(false)
        node:stopAllActions()
        node:removeFromParent()
    end

    imgPlacholder:setTouchEnabled(false)
    -- 如果是本地地址
    if picImageInfo.nativePath and not picImageInfo.thumble_url and io.exists(picImageInfo.nativePath) then
        imgLoadFun(imgPlacholder, picImageInfo.nativePath, true, picImageInfo.nativePath, 0.45)
        imageLoading(loading)
    else
        --加载小图
        if picImageInfo.thumble_url and picImageInfo.thumble_url ~= "" then
            if picImageInfo.nativePath and io.exists(picImageInfo.nativePath) then
                loadingRemoveFunc(loading)
                imgLoadFun(imgPlacholder, picImageInfo.nativePath, true, picImageInfo.nativePath, 0.45)
            else
                if Util:getFilePathByUrl(picImageInfo.url) then
                    if tolua.isnull(imgPlacholder) == false then
                        loadingRemoveFunc(loading)
                        imgLoadFun(imgPlacholder, qf.downloader:getFilePathByUrl(picImageInfo.url), true, picImageInfo.url, 1)
                    end
                else
                    qf.downloader:execute(picImageInfo.thumble_url, 10,
                        function(path)
                            if tolua.isnull(imgPlacholder) == false then
                                loadingRemoveFunc(loading)
                                imgLoadFun(imgPlacholder, path, true, picImageInfo.url, 1)
                            end
                        end,
                        function( ... )
                            imageLoadFailFunc()
                        end,
                        function( ... )
                            imageLoadFailFunc()
                        end
                    )
                end
            end
        end
    end
    
    if bMyself then
        Util:updateUserHead(headIcon, Cache.user.portrait, Cache.user.sex, {add = true, sq = true, url = true, scale = headIcon:getContentSize().width, circle=false})
    else
        local proxyInfo = Cache.agencyInfo:getPersonalInfo()
        if not Cache.user:isCustomerService(message.uin) and proxyInfo then
            Util:updateUserHead(headIcon, proxyInfo.proxy_portrait, proxyInfo.sex, {add = true, sq = true, url = true, scale = headIcon:getContentSize().width, circle=false})
        end
    end
end

function CustomerServicesChat:getProxySonBaseInfo( ... )
    local proxyData = nil
    if self.proxy_son_info then
        proxyData = {
            proxy_portrait = self.proxy_son_info.portrait_url,
            nick = self.proxy_son_info.service_nick,
            sex = 2
        }
    end
    return proxyData
end

function CustomerServicesChat:reloadChatList( ... )
    self.chat_list:requestRefreshView()
    performWithDelay(self, function ( ... )
        self.chat_list:jumpToBottom()
    end, 0.02)
end

function CustomerServicesChat:reloadChatListItem(sessionInfo, mesgType)
    if not sessionInfo then return end
    for _,v in pairs(self.chat_list:getItems()) do
        if tostring(v.session_info) == tostring(sessionInfo) then
            if mesgType == GameConstants.ChatMsgType.MSG_PIC_BRIEF then
                local placeHolderImage = v:getChildByName("content"):getChildByName("img")
                local loadingNode = v:getChildByName("content"):getChildByName("loading")
                loadingNode:setVisible(false)
                loadingNode:stopAllActions()
                loadingNode:removeFromParent()
                placeHolderImage:setTouchEnabled(true)
            elseif mesgType == GameConstants.ChatMsgType.MSG_TEXT then
                local status = v:getChildByName("content"):getChildByName("status")
                status:stopAllActions()
                status:setVisible(false)
                status:getChildByName("re_send"):setVisible(false)
                if status:getChildByName("loadingAni") then
                    status:getChildByName("loadingAni"):removeFromParent()
                end
            end
            break
        end
    end
end

function CustomerServicesChat:removeMessageItem(sessionInfo)
    local item = nil
    for _,v in pairs(self.chat_list:getItems()) do
        if tostring(v.session_info) == tostring(sessionInfo) then
            item = v
            break
        end
    end
    local index = self.chat_list:getIndex(item)
    self.chat_list:removeItem(index)
    self:reloadChatList()
end

-- 客服信息
function CustomerServicesChat:updateCustomerInfo( ... )
    Cache.Config:getCustomerServiceInfo(function (data)
        if not data then return end
        if tolua.isnull(self) then return end
        local workTimeStr = string.format(GameTxt.customer_work_time, data.working_time)
        local nickLb = self.not_AgentView:getChildByName("nick")
        local workTimeLb = self.not_AgentView:getChildByName("work_time")
        nickLb:setString("值班经理")
        workTimeLb:setString(workTimeStr)

        local textContent = self.not_AgentView:getChildByName("txt_content")
        local txt = "    非常感谢您使用我们的产品，带给您欢乐是我们努力的方向，请尽情享受，如果您有任何需求和疑问，请在此咨询并给予您宝贵的意见。"
        local contentLabel = textContent:getChildByName("showLable")
        if not textContent:getChildByName("showLable") then
            contentLabel = cc.LabelTTF:create(txt ,GameRes.font1, 34,cc.size(textContent:getContentSize().width,0),cc.TEXT_ALIGNMENT_LEFT, cc.VERTICAL_TEXT_ALIGNMENT_TOP)
            contentLabel:setColor(cc.c3b(50, 80, 135))
            contentLabel:setAnchorPoint(cc.p(0,0))
            contentLabel:setName("showLable")
            textContent:addChild(contentLabel)
        else
            contentLabel:setString(txt)
        end

        -- local textContent = self.b_AgentView:getChildByName("txt_content")
        -- local contentLabel = Util:createRichText({size = cc.size(textContent:getContentSize().width - 10,600), vspace = 10, bIgnore = bIgnore})
        -- local txt = ccui.RichElementText:create(1, cc.c3b(50, 80, 155), 255, "   周大福金浦，诚信第一，福利多多，上桌红包，牌型奖励，温馨提示：请不要在app里面充值。诚信第一，福利多多，上桌红包，牌型奖励，温馨提示：请不要在app里面充值。诚信第一，福利多多，上桌红包，牌型奖励，温馨提示：请不要在app里面充值。诚信第一，福利多多，上桌红包，牌型奖励，温馨提示：请不要在app里面充值。诚信第一，福利多多，上桌红包，牌型奖励，温馨提示：请不要在app里面充值。", GameRes.font1, 34)
        -- contentLabel:pushBackElement(txt)
        -- contentLabel:setAnchorPoint(cc.p(0,0))

        -- textContent:addChild(contentLabel)
        -- local size = contentLabel:getContentSize()
        -- textContent:setPosition(cc.p(size.width/2, size.height/2))
        -- contentLabel:setPosition(cc.p(-size.width/2, -size.height/2))
        -- textContent:setInnerContainerSize(cc.size(size.width, size.height))
        
        local size = contentLabel:getContentSize()
        textContent:setInnerContainerSize(cc.size(size.width, size.height))
        local ssize = textContent:getContentSize()
        if ssize.height > size.height then
            contentLabel:setPosition(cc.p(0, ssize.height - size.height))
        end

    end)
end

-- 代理信息
function CustomerServicesChat:updateServiceList( ... )
    local updateFunc = function (data)
        self:playBroadCast(data.copy_writing)
        self:refreshProxcyInfoList(data)
        if self.proxy_son_info then
            local proxyData = {
                proxy_portrait = self.proxy_son_info.portrait_url,
                nick = self.proxy_son_info.service_nick,
                sex = 2
            }
            self:updateProxyInfo(proxyData)
        else
            self:updateProxyInfo(data)
        end
    end
    local replayBtn = self.b_AgentView:getChildByName("replayBtn")
    replayBtn:getChildByName("red"):setVisible(ModuleManager.global:checkIfHasNewCustomerMsg())

    if Cache.agencyInfo:getPersonalInfo() then
        updateFunc(Cache.agencyInfo:getPersonalInfo())
    else
        -- 刷新代理信息
        Cache.agencyInfo:requestGetAgencyInfo({}, function (data)
            if not tolua.isnull(self) then
                updateFunc(Cache.agencyInfo:getPersonalInfo())
            end
        end)
    end
end

-- 代理基础信息
function CustomerServicesChat:updateProxyInfo(data)
    local quitCommunityBtn = self.b_AgentView:getChildByName("quit_btn")
    quitCommunityBtn:setVisible(Cache.packetInfo:isShangjiaBao())
    if Cache.packetInfo:isShangjiaBao() then
        self.b_AgentView:getChildByName("nick"):setString(data.nick)
    else
        self.b_AgentView:getChildByName("nick"):setString(self.proxy_son_data_id == 0 and "官方客服" or data.nick)
    end
    
    local head = self.b_AgentView:getChildByName("head")
    if data.proxy_portrait and data.proxy_portrait ~= "" then
        Util:updateUserHead(head, data.proxy_portrait, data.sex, {add = true, sq = true, url = true, scale = head:getContentSize().width -10, circle = true})
    end
    
    local textContent = self.b_AgentView:getChildByName("txt_content")
    local txt = data.sign_words or ""
    local contentLabel = textContent:getChildByName("showLable")
    if not textContent:getChildByName("showLable") then
        contentLabel = cc.LabelTTF:create(txt ,GameRes.font1, 34,cc.size(textContent:getContentSize().width,0),cc.TEXT_ALIGNMENT_LEFT, cc.VERTICAL_TEXT_ALIGNMENT_TOP)
        contentLabel:setColor(cc.c3b(50, 80, 135))
        contentLabel:setAnchorPoint(cc.p(0,0))
        contentLabel:setName("showLable")
        textContent:addChild(contentLabel)
    else
        contentLabel:setString(txt)
    end

    local size = contentLabel:getContentSize()
    textContent:setInnerContainerSize(cc.size(size.width, size.height))
    local ssize = textContent:getContentSize()
    if ssize.height > size.height then
        contentLabel:setPosition(cc.p(0, ssize.height - size.height))
    end

    addButtonEvent(self.b_AgentView:getChildByName("replayBtn"), function ( ... )
        self.complainPannel:setVisible(true)
    end)

    addButtonEvent(quitCommunityBtn, function ( ... )
        if Cache.user:isUserQuitCommunitySequeces() == false then
            qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.quit_sequeces_txt})
        else
            -- 退出社区
            qf.event:dispatchEvent(ET.SHOW_COMMON_TIP_WINDOW_EVENT, {type = 2, cb_consure = function ( ... )
                Cache.cusChatInfo:communityRequest(1)
            end, content = GameTxt.community_tips_txt, fontsize = 42, color = cc.c3b(120, 169, 255)})
        end
    end)
end

-- 刷新代理联系方式
function CustomerServicesChat:refreshProxcyInfoList(agencyData)
    if not agencyData then return end
    self.serviceInfoList:removeAllItems()
    for _,v in pairs(agencyData.contactInfo) do
        local item = nil
        if v.txt ~= "" then
            item = self.service_list_item:clone()
            local copyBtn = item:getChildByName("copyBtn")
            local imageName = v.cig == 1 and GameRes.customer_wx or GameRes.customer_qq
            item:getChildByName("type"):loadTexture(imageName, ccui.TextureResType.plistType)
            local toastTxt = v.cig == 1 and GameTxt.string_agency_3 or GameTxt.string_agency_4
            addButtonEvent(copyBtn, function ( ... )
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = toastTxt})
                qf.platform:copyTxt({txt = v.txt})
            end)
        end
        if item ~= nil then
            item:setVisible(true)
            self.serviceInfoList:insertCustomItem(item, #self.serviceInfoList:getItems())
        end
    end
end

function CustomerServicesChat:refreshCustomerRad( ... )
    local replayBtn = self.b_AgentView:getChildByName("replayBtn")
    replayBtn:getChildByName("red"):setVisible(ModuleManager.global:checkIfHasNewCustomerMsg())
end

-- 切换服务信息
function CustomerServicesChat:updateServerInfo( ... )
    --判断有没有绑定代理
    if self.forceLinkType == GameConstants.ChatUserType.PROXCY then
        self.b_AgentView:setVisible(true)
        self.not_AgentView:setVisible(false)
        self:updateServiceList()
    else
        self.b_AgentView:setVisible(false)
        self.not_AgentView:setVisible(true)
        self:updateCustomerInfo()
    end
end

function CustomerServicesChat:onButtonEvent(sender)
    if sender.name == "sendImageBtn" then
        self:sendImageMessage()
    elseif sender.name == "sendMsgtn" then
        self:sendText()
    elseif sender.name == "input" then
        self:inputMessage()
    elseif sender.name == "closeBtn" then
        self:close()
    elseif sender.name == "comfirmBtn" then
        self.complainPannel:setVisible(false)
        local replayBtn = self.b_AgentView:getChildByName("replayBtn")
        replayBtn:getChildByName("red"):setVisible(false)
        Cache.cusChatInfo:clearUnReadMessage(1)
        self:close()
        Util:delayRun(0.3, function ( ... )
            qf.event:dispatchEvent(ET.CUSTOM_CHAT, {forceLinkType = GameConstants.ChatUserType.OFFICIAL})
        end)
    elseif sender.name == "cancleBtn" or sender.name == "complainCloseBtn" then
        self.complainPannel:setVisible(false)
    end
end

function CustomerServicesChat:choosePicture( ... )
    local timestamp = os.time()
    local session_info = math.floor(socket.gettime()*1000)
    local path = CACHE_DIR .. "chat_"..Cache.user.uin .. session_info .. ".jpg"
    local nativeParams = {
        cb = function(rsp)
            if rsp == "0" then
                -- 处理完图片就发送本地消息，等待remote返回
                print(" ==== 处理完图片就发送本地消息，等待remote返回 =====")
                -- 安卓这边很奇怪，需要过一帧才能加载
                Util:delayRun(1/30, function ( ... )
                    self:inserUnloadImageMessage(timestamp, session_info, path)
                end)
            elseif rsp == "-1" then
                print(" ==== 不支持的文件格式 =====")
                if targetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_IPAD then
                    qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = "不支持此文件格式"})
                end
            else
                local rspModel = json.decode(rsp)
                self:uploadImageSuccess(rspModel, timestamp, session_info)
            end
        end,
        type = 5,
        path = path,
        uin = Cache.user.uin,
        key = Util:getChatServerSig(),
        url = Util:getChatUploadUrl(),
        edit = 0,
        upload = 2, --调起相册
    }
    qf.platform:selectPhoto(nativeParams)
end

--客户端处理完图片后，先展示，等数据过来再刷新
function CustomerServicesChat:inserUnloadImageMessage(timestamp, session_info, cachePath)
    if not self:checkIfShouldSendMessgae() then return end
    -- 插入数据
    local data = Cache.cusChatInfo:insertLocalData({
        timestamp = timestamp,
        session_info = session_info,
        msg_type = GameConstants.ChatMsgType.MSG_PIC_BRIEF,
        nativePath = cachePath,
        uin = Cache.user.uin,
        targetid = self.forceLinkType == GameConstants.ChatUserType.PROXCY and Cache.user.invite_from or 100,
        proxy_data_id = self.proxy_son_data_id
    })
    self:updateChatList({bAdd = true, data = {[1] = data}})
    self.lastSendTime = os.time()
end

function CustomerServicesChat:uploadImageSuccess(rsp, timestamp, session_info)
    if not rsp then
        --上传图片失败
        print("【CustomerServicesChat】】 uploadImageSuccess 上传头像失败！")
        return
    end
    if rsp.ret ~= 0 then
        print("【CustomerServicesChat】】 uploadImageSuccess 上传头像失败！ rsp.ret = " .. rsp.ret)
        return
    end
    local data = rsp.ret_data
    --发送图片消息
    Cache.cusChatInfo:sendChatMessage({
        pic_size = data.pic_size,
        height = data.height,
        width = data.width,
        thumb_url = data.thumb_url,
        url = data.url,
        msg_type = GameConstants.ChatMsgType.MSG_PIC_BRIEF,
        timestamp = timestamp,
        session_info = session_info,
        forceLinkType = self.forceLinkType,
        proxy_data_id = self.proxy_son_data_id
    })
end

--发送图片
function CustomerServicesChat:sendImageMessage()
    self:choosePicture()
end

function CustomerServicesChat:sendText( ... )
    local sendMessage = nil
    if self.inputText then
        sendMessage = self.inputText:getText()
    else
        sendMessage = self.placeHolderText:getString()
        if sendMessage == GameTxt.send_input_placeHolder_txt then
            sendMessage = ""
        end
    end
    if not sendMessage then return end
    sendMessage = string.gsub(sendMessage, "\n", "")
    self:sendTextMessage(sendMessage)
    
    if targetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_IPAD then
        self.placeHolderText:setString(GameTxt.send_input_placeHolder_txt)
    else
        self.inputText:setText("")
    end
end

--发送文字
function CustomerServicesChat:sendTextMessage(message)
    if not message then return end
    if not self:checkIfShouldSendMessgae() then return end
    -- 过滤表情
    if message == "" then
        qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = GameTxt.customer_chat_error_txt})
        return 
    end
    local timestamp = os.time()
    local session_info = math.floor(socket.gettime()*1000)
    --自己处理本地发送的数据，然后等待服务器更新
    local data = Cache.cusChatInfo:insertLocalData({
        timestamp = timestamp,
        session_info = session_info,
        msg_type = GameConstants.ChatMsgType.MSG_TEXT,
        msg = message,
        uin = Cache.user.uin,
        targetid = self.forceLinkType == GameConstants.ChatUserType.PROXCY and Cache.user.invite_from or 100,
        proxy_data_id = self.proxy_son_data_id
    })
    self:updateChatList({bAdd = true, data = {[1] = data}})
    --发送文字消息
    Cache.cusChatInfo:sendChatMessage({
        msg = message,
        timestamp = timestamp,
        session_info = session_info,
        msg_type = GameConstants.ChatMsgType.MSG_TEXT,
        forceLinkType = self.forceLinkType,
        proxy_data_id = self.proxy_son_data_id
    })
    self.lastSendTime = os.time()
end

--ios输入处理
function CustomerServicesChat:inputMessage( ... )
    print(" CustomerServicesChat ===== inputMessage ")
    qf.platform:callInputKeyBoard({
        placeHolderString = "",
        valueString = self.placeHolderText:getString() == GameTxt.send_input_placeHolder_txt and "" or self.placeHolderText:getString(),
        returnType = "done",
        maxLength = 50,
        cb = function (paras)
            local rsp = qf.json.decode(paras)
            if rsp.status == "return" or rsp.status == "done" then
                if rsp.text ~= "" then
                    self.placeHolderText:setString(rsp.text)
                else
                    self.placeHolderText:setString(GameTxt.send_input_placeHolder_txt)
                end
            end
        end
    })
end

function CustomerServicesChat:close(paras)
    Cache.cusChatInfo:clearUnReadMessage(self.forceLinkType)
    qf.event:removeEvent(ET.CHAT_MONITOR_EVENT)
    Cache.user.guidetochat = false
    self.super.close(self,paras)
    qf.event:dispatchEvent(ET.GLOBAL_SHOW_BROADCASE_LAYOUT)
    cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile(GameRes.image_loading_plist)
    cc.SpriteFrameCache:getInstance():removeSpriteFrameByName(GameRes.image_loading_png)
end

function CustomerServicesChat:getRoot() 
    return LayerManager.PopupLayer
end

return CustomerServicesChat