
local _MailView = import(".MailView")
local MailView = class("MailView", _MailView)
MailView.TAG = "MailView"

--保证每次打开都会重新请求邮件信息
function MailView:ctor(paras)
    self.root = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.reviewMailJson)
    self:init(paras)
    self.super.super.ctor(self, {id=PopupManager.POPUPWINDOW.mailView, child=self.root})
end

function MailView:setDetailContent(txt)
    if self._rText then
        self._rText:removeFromParent(true)
        self._rText = nil
    end
    local iTurn = string.find(txt, "\n")
    local bIgnore = false
    if iTurn then
        bIgnore = true
    end
    
    local tbl = self:resolveDesc(txt)
    local rText = Util:createRichText({size = cc.size(1180,300), vspace = 5, bIgnore = bIgnore})
    local normalColor = cc.c3b(127, 200, 250)
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

return MailView