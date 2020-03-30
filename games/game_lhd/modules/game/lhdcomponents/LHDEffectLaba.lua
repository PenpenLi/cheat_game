local LHDEffectLaba = class("LHDEffectLaba", function(paras)
	return ccs.GUIReader:getInstance():widgetFromJsonFile(LHD_Games_res.effctLabaJson)
end)

LHDEffectLaba.TAG = "LHDEffectLaba"

function LHDEffectLaba:ctor(paras)
	self:initComponent()
end

function LHDEffectLaba:initComponent()
    local t = {"Panel_laba", "title", "img_light", "img_gold", "img_star", "img_bug_1", "img_bug_2"
        , "img_bug_3", "img_bug_4", "img_bug_5", "img_bug_6"
    }
    for k, v in pairs(t) do
        self[v] = ccui.Helper:seekWidgetByName(self, v)
    end
end

function LHDEffectLaba:initUI(state, scale)
	local index
	if state == "win" then
		index = 1
		self.title:runAction(cc.MoveBy:create(0, cc.p(50, 70)))
	else
		index = 2
	end

	if scale then
		self.Panel_laba:setScale(scale)
	end

    self.title:loadTexture(LHD_Games_res["br_result_title"..index])
    self.img_light:loadTexture(LHD_Games_res["br_result_light_"..index])
    self.img_gold:loadTexture(LHD_Games_res["br_result_gold_"..index])
    self.img_star:loadTexture(LHD_Games_res["br_result_star_"..index])
    for i=1, 3 do
        self["img_bug_"..i]:loadTexture(LHD_Games_res["br_result_bug_left_"..index])
    end
    for i=4, 6 do
        self["img_bug_"..i]:loadTexture(LHD_Games_res["br_result_bug_right_"..index])
    end

    self:showAnimation()
end

function LHDEffectLaba:showAnimation()
	self.img_light:runAction(cc.Sequence:create(cc.CallFunc:create(function( sender )
            sender:setScale(0)
        end)
        , cc.DelayTime:create(0.60)
        , cc.ScaleTo:create(0.8, 1.5)
        , cc.ScaleTo:create(0.4, 1.0)))
    self.img_gold:runAction(cc.Sequence:create(cc.CallFunc:create(function( sender )
            sender:setScale(0)
        end)
        , cc.DelayTime:create(0.6)
        , cc.ScaleTo:create(0.8, 1.2)
        , cc.ScaleTo:create(0.4, 1.0)))
    self.img_star:runAction(cc.Sequence:create(cc.CallFunc:create(function( sender )
            sender:setScale(0)
        end)
        , cc.DelayTime:create(0.4)
        , cc.ScaleTo:create(0.8, 1.5)
        , cc.ScaleTo:create(0.4, 1.0)))
    self.title:runAction(cc.Sequence:create(cc.CallFunc:create(function( sender )
            sender:setScale(0)
        end)
        , cc.DelayTime:create(0.1)
        , cc.Spawn:create(cc.ScaleTo:create(0.8, 1.3), cc.MoveBy:create(0.1, cc.p(0, 10)))
        , cc.ScaleTo:create(0.4, 1.0)
        , cc.MoveBy:create(0.1, cc.p(0, -10))
        , cc.MoveBy:create(0.08, cc.p(0, 8))
        , cc.MoveBy:create(0.08, cc.p(0, -8))
        , cc.MoveBy:create(0.05, cc.p(0, 4))
        , cc.MoveBy:create(0.05, cc.p(0, -4))))
    self.img_bug_3:runAction(cc.Sequence:create(cc.CallFunc:create(function( sender )
            sender:setScale(0)
        end)
        , cc.DelayTime:create(0.6)
        , cc.ScaleTo:create(0.5, 1.5)
        , cc.ScaleTo:create(0.4, 1.0)))
    self.img_bug_4:runAction(cc.Sequence:create(cc.CallFunc:create(function( sender )
            sender:setScale(0)
        end)
        , cc.DelayTime:create(0.6)
        , cc.ScaleTo:create(0.5, 1.5)
        , cc.ScaleTo:create(0.4, 1.0)))
    self.img_bug_2:runAction(cc.Sequence:create(cc.CallFunc:create(function( sender )
            sender:setScale(0)
        end)
        , cc.DelayTime:create(0.8)
        , cc.ScaleTo:create(0.5, 1.5)
        , cc.ScaleTo:create(0.4, 0.8)))
    self.img_bug_5:runAction(cc.Sequence:create(cc.CallFunc:create(function( sender )
            sender:setScale(0)
        end)
        , cc.DelayTime:create(0.8)
        , cc.ScaleTo:create(0.5, 1.5)
        , cc.ScaleTo:create(0.4, 0.8)))
    self.img_bug_1:runAction(cc.Sequence:create(cc.CallFunc:create(function( sender )
            sender:setScale(0)
        end)
        , cc.DelayTime:create(0.9)
        , cc.ScaleTo:create(0.5, 1.5)
        , cc.ScaleTo:create(0.4, 0.5)))
    self.img_bug_6:runAction(cc.Sequence:create(cc.CallFunc:create(function( sender )
            sender:setScale(0)
        end)
        , cc.DelayTime:create(0.9)
        , cc.ScaleTo:create(0.5, 1.5)
        , cc.ScaleTo:create(0.4, 0.5)))
end

return LHDEffectLaba