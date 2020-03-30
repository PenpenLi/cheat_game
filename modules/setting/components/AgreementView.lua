local AgreementView = class("AgreementView",function(paras) 
    return cc.Layer:create()
end)
AgreementView.TAG = "AgreementView"

local IButton = import(".IButton")

function AgreementView:ctor(paras)
    self.cb = paras.cb
    self:init()
    
end

function AgreementView:init()
    self.root = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.agreementViewJson)
    self:addChild(self.root)
    --self.root:getChildByName("back"):setVisible(false)
    self.root:getChildByName("bg"):setTouchEnabled(true)
    self.back_btn = IButton.new({node = self.root:getChildByName("back")})
    self.root = IButton.new({node = self.root})
    Util:registerKeyReleased({self = self,cb = function ()
        self.cb()
    end})
    self.back_btn:setCallback(function() 
        self.cb()
    end)
    self.root:setCallback(function() 
        self.cb()
    end)
--    local txt = self.root:getChildByName("scrollview"):getChildByName("txt")
--    txt:setString(GameTxt.string711)
end

return AgreementView
