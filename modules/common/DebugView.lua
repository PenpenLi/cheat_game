local DebugView = class("DebugView", CommonWidget.PopupWindow)
DebugView.TAG = "DebugView"

--保证每次打开都会重新请求邮件信息
function DebugView:ctor(parameters)
    self.root = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.debugViewJson)
    self:init(parameters)
    self.super.ctor(self, {id=PopupManager.POPUPWINDOW.debugView, child=self.root})
end

function DebugView:init( parameters )
    local defaultHandler = handler(self, self.onButtonEvent)
    local uiTbl = {
        {name = "closeBtn", path = "Panel_frame/closeBtn", handler = defaultHandler},
        {name = "sclistView", path = "Panel_frame/ScrollView_39", handler = defaultHandler},
        {name = "scText", path = "Panel_frame/ScrollView_39/Label_10", handler = nil},
    }
    Util:bindUI(self, self.root, uiTbl)
    self.logFileName = "log.txt"
    self.scText:setVisible(true)
    self:testDebugText()
end

function DebugView:splitText(txt)
    local maxCnt = 10
    local resTxtTbl = {}
    local txtCnt = string.len(txt)
    local showCnt = 100
    for i = 1, maxCnt do
        local sBegin = showCnt * (i-1) + 1
        local sEnd = sBegin + showCnt
        if sBegin > txtCnt then
            break
        end
        if sEnd > txtCnt then
            sEnd = -1
        end
        resTxtTbl[i] = string.sub(txt, sBegin, sEnd)
    end
    local resTxt = table.concat(resTxtTbl, "\n")
    return resTxt
end

function DebugView:testDebugText()
    local textTbl = self:getLog()
    local maxNum = 30
    local txtNum = #textTbl
    local begin = txtNum - maxNum 
    begin = begin <= 0 and 0 or begin
    local txtList = {}
    local curIdx = txtNum
    for i = 1, maxNum do
        local showTxt = ""
        for j = curIdx, 1, -1 do
            local curText = self:splitText(textTbl[j])
            showTxt = curText .. "\n" .. showTxt
            if string.len(showTxt) > 1000 or j == 1 then
                txtList[#txtList + 1] = showTxt
                curIdx = j-1
                break
            end
        end
    end

    local totalHeight = 0
    local txtUIList = {}
    local txtHeightList = {}
    for i, v in ipairs(txtList) do
        local tmp =  self.scText:clone()
        txtUIList[#txtUIList + 1] = tmp
        tmp:setText(v)
        self.sclistView:addChild(tmp)
        local size = tmp:getContentSize()
        totalHeight = totalHeight + size.height
        txtHeightList[i] = size.height
    end

    local innerSize = self.sclistView:getInnerContainerSize()
    self.sclistView:setInnerContainerSize(cc.size(innerSize.width, totalHeight))

    local curY = 0
    for i, v in ipairs(txtHeightList) do
        txtUIList[i]:setPositionY(curY)
        curY = curY + v
        txtUIList[i]:setVisible(true)
    end
    self.scText:setVisible(false)
    performWithDelay(self, function ( ... )
        self.sclistView:jumpToBottom()
    end, 0.5)
end

function DebugView:onButtonEvent(sender)
    if sender.name == "closeBtn" then
        self:close()
    end
end

function DebugView:getLog()
    local strTbl = {}
    local path = cc.FileUtils:getInstance():getWritablePath() .. "log/"
    local fileName = path .. self.logFileName
    if io.exists(fileName) then
        local file = io.open(fileName, "r")
        for line in file:lines() do  
            strTbl[#strTbl + 1] = line
        end
        file:close()
    end
    return strTbl
end

return DebugView