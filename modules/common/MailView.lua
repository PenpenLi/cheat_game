local MailView = class("MailView", CommonWidget.PopupWindow)
MailView.TAG = "MailView"
local MailListTime = 0
local ViewTbl  = {
    NoMail = 1,
    MailDetail = 2,
    MailList = 3
}

local MaxShowCnt = 100

--保证每次打开都会重新请求邮件信息
function MailView:ctor(paras)
    self.root = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.mailJson)
    self:init(paras)
    self.super.ctor(self, {id=PopupManager.POPUPWINDOW.mailView, child=self.root})
end

function MailView:init( paras )
    local turnFunc = handler(self, self.changeTab)

    local uiTbl = {
        {name = "noMail",          path = "Panel_box/Panel_36_0"},
        {name = "mailList",        path = "Panel_box/Panel_35"},
        {name = "mailListView",    path = "Panel_box/Panel_35/ListView_63"},
        {name = "mailDetail",      path = "Panel_box/Panel_36"},
        {name = "okBtn",           path = "Panel_box/Panel_36/Panel_38_0/Button_50",  handler = handler(self, self.onButtonEvent)},
        {name = "delBtn",           path = "Panel_box/Panel_36/Panel_38_0/Button_50_0",  handler = handler(self, self.onButtonEvent)},
        {name = "closeBtn",        path = "Button_close",                               handler = handler(self, self.onButtonEvent)},
    }
    Util:bindUI(self, self.root, uiTbl)
    Util:enlargeCloseBtnClickArea(self.closeBtn)
    self._uiOpTbl = {self.mailList, self.noMail, self.mailDetail}

    self:initMailListView()
    self._mailData = Cache.mailInfo._mailList
    self._curDetailData = nil --当前显示的详细信息

    if #self._mailData > 0 then
        self:showPage(ViewTbl.MailList, self._mailData)
    else
        self:showPage(ViewTbl.NoMail)
    end
end

function MailView:showPage(page, args)
    self:stopAllActions()

    for i,v in ipairs(self._uiOpTbl) do
        v:setVisible(false)
    end

    self._curPage = page
    if self._curPage == ViewTbl.NoMail then
        self.noMail:setVisible(true)
    elseif  self._curPage == ViewTbl.MailDetail then
        self.mailDetail:setVisible(true)    
    elseif  self._curPage == ViewTbl.MailList then
        args = Cache.mailInfo:sortMail(args)
        self._mailData = args
        self.mailList:setVisible(true)
    end
    self:refreshView(args)
end

function MailView:onButtonEvent(sender)
    if sender.name == "closeBtn" then
        if self._curPage == ViewTbl.NoMail then
            self:close()
        elseif self._curPage == ViewTbl.MailList then
            self:close()
        elseif self._curPage == ViewTbl.MailDetail then
            -- self:readMail(self._curDetailData.info.id)
            -- self._mailData = Cache.mailInfo:sortMail(self._mailData)
            self:showPage(ViewTbl.MailList, self._mailData)
        end
    elseif sender.name == "okBtn" then
        -- self:readMail(self._curDetailData.info.id)
        self:showPage(ViewTbl.MailList, self._mailData)
    elseif sender.name == "delBtn" then
        qf.event:dispatchEvent(ET.MESSAGE_BOX, {desc= GameTxt.string_mail_1, showClose = true, cbOk = function ( ... )
            self:delMail(self._curDetailData.info.id)
        end})
    end
end

function MailView:readMail(id)
    local callback = function ()
        if tolua.isnull(self) == true or self._mailData == nil then
            return
        end

        --暂时不通过这个id 进行查询要删除哪个邮件, 直接删除对应的邮件
        if self._curDetailData then
            local index = self._curDetailData.index
            self._mailData[index].mRead = 1
        end
    end

    Cache.mailInfo:requestReadMail(id, {callback = callback})
end

function MailView:delMail(id)
    local callback = function(id)
        if tolua.isnull(self) == true or self._mailData == nil then
            return
        end
        --暂时不通过这个id 进行查询要删除哪个邮件, 直接删除对应的邮件
        if self._curDetailData then
            local index = self._curDetailData.index
            table.remove(self._mailData, index)
        end
        if #self._mailData > 0 then
            self:showPage(ViewTbl.MailList, self._mailData)
        else
            self:showPage(ViewTbl.NoMail)
        end
    end
    Cache.mailInfo:requestDelMail(id, {callback = callback})
end

function MailView:initMailListView()
    local itemModel = self.mailListView:getChildByName("Panel_52")
    itemModel:setVisible(true)
    self.mailListView:setItemsMargin(15)
    self.mailListView:setItemModel(itemModel)
    self.mailListView:removeAllChildren(true)
end

function MailView:refreshView(args)
    if self._curPage == ViewTbl.NoMail then
    elseif self._curPage == ViewTbl.MailList then
        self:refreshMailList(args)
    elseif self._curPage == ViewTbl.MailDetail then
        self.mailDetail:setVisible(true)
        self._curDetailData = args
        ccui.Helper:seekWidgetByName(self.mailDetail, "Label_33"):setString(self._curDetailData.info.notiTxt)
        self:setDetailContent(self._curDetailData.info.content)
    end
end


function MailView:check2Signs(content)
    local s1 = string.find(content, "#")
    if s1 == -1 or s1 == nil then
        return false
    end
    local content2 = string.sub(content, s1+1, -1)
    local s2 = string.find(content2, "#")
    if s2 == -1 or s2 == nil then
        return false
    end
    return s1, s1  + s2
end

function MailView:resolveDesc(content )
    local ctbl = {}
    for i = 1, 2 do
        local s1, s2 = self:check2Signs(content)
        if s1 then
            ctbl[#ctbl + 1] = { desc = string.sub(content, 1, s1-1), k = 1}
            ctbl[#ctbl + 1] = {desc = string.sub(content, s1+1, s2-1), k = 2}
            content = string.sub(content, s2+1, -1)
        else
            ctbl[#ctbl + 1] = {desc = content, k = 1}
            break
        end
    end
    return ctbl
end

function MailView:setDetailContent(txt)
    if self._rText then
        self._rText:removeFromParent(true)
        self._rText = nil
    end
    local iTurn = string.find(txt, "\n")
    local bIgnore = false
    if iTurn then
        -- txt = Util:limitStringNumber(txt, 90)
        bIgnore = true
    end
    
    local tbl = self:resolveDesc(txt)
    local rText = Util:createRichText({size = cc.size(1180,300), vspace = 5, bIgnore = bIgnore})
    local normalColor = cc.c3b(102, 147, 225)
    local keyColor = cc.c3b(255, 225, 23)
    local richDesc = {}
    for i, v in ipairs(tbl) do
        if v.desc ~= "" then
            richDesc[#richDesc + 1] = {
                desc = v.desc,
                color = v.k == 1 and normalColor or keyColor
            }
        end
    end
    for i, v in ipairs(richDesc) do
        local color = v.color
        local desc = v.desc
        local txt = ccui.RichElementText:create(1, color, 255, desc, GameRes.font1, 38)
        rText:pushBackElement(txt)
    end
    local scrollview = ccui.Helper:seekWidgetByName(self.mailDetail, "ScrollView_25")
    self._rText = rText
    scrollview:setVisible(bIgnore)

    if bIgnore then
        rText:setAnchorPoint(cc.p(0.5,0.5))
        local csize = rText:getContentSize()
        local innerSize = scrollview:getInnerContainerSize()
        
        rText:formatText()
        local vsize = rText:getVirtualRendererSize()
        -- dump(vsize)
        local scrollsize = scrollview:getContentSize()
        scrollview:setInnerContainerSize(cc.size(innerSize.width, vsize.height + 10))
        if vsize.height > scrollsize.height then

            rText:setPosition(cc.p(0 + vsize.width/2, vsize.height/2 + 10))
        else
            rText:setPosition(cc.p(0 + vsize.width/2, scrollsize.height - vsize.height/2))
        end
        scrollview:addChild(rText)
    else
        rText:setPosition(cc.p(713, 285))
        self.mailDetail:addChild(rText)
    end
end

function MailView:refreshMailList(args)
    self.mailListView:removeAllChildren()
    self.mailListView:setVisible(true)
    local dOpacity = 255/2
    local function _updateItem(index, info)
        self.mailListView:pushBackDefaultItem()
        local item = self.mailListView:getItem(index-1)
        item:setVisible(true)
        --主题字符限制比较
        local _notiTxt = info.notiTxt
        local titleTxt = item:getChildByName("Label_59")
        local itemBg = item:getChildByName("Image_136")
        local itemIcon = item:getChildByName("logo")
        local yearTxt = item:getChildByName("Label_60")
        titleTxt:setString(_notiTxt)
        -- ScrollView_25
        yearTxt:setString(Util:getDateDescription(info.time) .. " " .. Util:getDigitalTime(info.time))
        itemBg:setTouchEnabled(true)
        itemBg:setEnabled(true)
        addButtonEvent(itemBg, function ()
            self:showPage(ViewTbl.MailDetail, {info = info, index = index})
            self:readMail(info.id)
        end)

        -- if info.mRead == 0 then
        --     yearTxt:setOpacity(dOpacity)
        --     titleTxt:setOpacity(dOpacity)
        --     itemBg:setOpacity(dOpacity)
        --     hourTxt:setOpacity(dOpacity)
        -- end
        titleTxt:getLayoutParameter():setMargin({left = 112, right = 0, top = 45, bottom = 0})
        itemBg:loadTexture(info.mRead == 1 and GameRes.mail_read_bg_name or GameRes.mail_unread_bg_name, ccui.TextureResType.plistType)
        itemIcon:loadTexture(info.mRead == 0 and GameRes.mail_read_icon_name or GameRes.mail_unread_icon_name, ccui.TextureResType.plistType)
        yearTxt:setColor(info.mRead == 0 and cc.c3b(255, 255, 255) or cc.c3b(105, 160, 253))
        titleTxt:setColor(info.mRead == 0 and cc.c3b(255, 255, 255) or cc.c3b(105, 160, 253))
    end
    -- self._mailData = Cache.mailInfo:sortMail(args)
    -- args = self._mailData
    local len = #args
    if len > MaxShowCnt then
        len = MaxShowCnt
    end
    
    --一次加载10条
    local addLen = 10
    local times = math.ceil(len / addLen)
    for i = 1, times do
        local cntT = (i-1) * 10
        performWithDelay(self, function()
            for j = 1, addLen do
                local idx = cntT + j
                if idx > len then
                    break
                end
                _updateItem(idx, args[idx])
            end
        end, 0.3 * (i - 1))
    end
    performWithDelay(self, function ( ... )
        self.mailListView:jumpToTop()
    end, 0.03)
end

return MailView