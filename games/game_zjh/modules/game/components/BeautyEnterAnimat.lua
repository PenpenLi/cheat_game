local BeautyEnterHert = class("BeautyEnterHert",function()
    return cc.Sprite:create(Zjh_Games_res.game_small_heart_img)
end)

function BeautyEnterHert:ctor(paras)
    self.x = paras.x
    self.y = paras.y
    self.pointX = paras.pointX
    self.pointY = paras.pointY
    self.round = paras.round
    self:init()
end

function BeautyEnterHert:init()
    --self:setGlobalZOrder(9)
    self.size = math.random(0.8,1.2)
    self:startForeverAction()
    self:setPosition(cc.p(self.x + self.pointX,self.y + self.pointY))
    local time = math.random(3000,3500)*0.001
    self:runAction(cc.Sequence:create(
        cc.Spawn:create(
            cc.MoveBy:create(time,cc.p(self.x*time,self.y*time)),
            cc.FadeTo:create(time,0)
            ),
        cc.CallFunc:create(
            function() 
                self:removeFromParent(true)
            end
        )
    ))
end

function BeautyEnterHert:startForeverAction()
    local scaleX,scaleY = math.random(0.1,0.4)
    scaleY = math.random(0.6,0.8)--math.random(-1,1) > 0 and 0.5*scaleX or 2 * scaleX
    local scale1 = cc.ScaleBy:create(self.size/0.32,scaleX,scaleY)
    local scale2 = cc.ScaleTo:create(self.size/0.32,self.size,self.size)
    local rotate = cc.RotateBy:create(math.random(3,4),math.random(-1,1) >= 0 and 360 or -360)
    local foreverAction1 = cc.RepeatForever:create(
        cc.Sequence:create(
            scale1,
            scale2
        )
    )
    local foreverAction2 = cc.RepeatForever:create(rotate)
    foreverAction1:setTag(1011)
    foreverAction2:setTag(1012)
    self:runAction(foreverAction1)
    self:runAction(foreverAction2)
end

function BeautyEnterHert:stopForeverAction()
    self:setScale(self.size)
    self:stopActionByTag(1011)
    self:stopActionByTag(1012)
end


local BeautyEnterAnimat = class("BeautyEnterAnimat",function() 
    return cc.Node:create()
end)

function BeautyEnterAnimat:ctor(paras)
    self.winSize = cc.Director:getInstance():getWinSize()
    self.userX = paras.userX
    self.userY = paras.userY
    self:init()
end

function BeautyEnterAnimat:countToPosition(t)--计算心线坐标
    --local tempRandom = math.random(-0.5,0.5)
    local x = (16*(math.sin(t)*math.sin(t)*math.sin(t)) )+self.userX
    local y = (13*math.cos(t)-5*math.cos(2*t) - 2*math.cos(3*t) - math.cos(4*t))+self.userY
--    local destanceX = math.abs(x - self.userX)
--    local destanceY = math.abs(y - self.userY)
--    local proprotion = t%3 == 0 and 0 or t/360--math.random(0,destanceY)*t/(destanceY*360) or math.random(0,destanceX)*t/(destanceX*360)
--    x = x < self.userX and x + destanceX*proprotion or x - destanceX*proprotion
--    y = y < self.userY and y + destanceY*proprotion or y - destanceY*proprotion
   return {x = x,y = y}
--    local x,y
--    local tempX,tempY = 100, 160
--    if t <= 60 then
--        x , y = tempX,tempY*t/60
--    elseif t > 60 and t <= 120 then 
--        x , y = tempX - tempX*(t - 60)/30,tempY
--    elseif t > 120 and t <= 240 then
--        x , y = -tempX,tempY - tempY*(t - 120)/60
--    elseif t > 240 and t <= 300 then
--        x , y = -tempX + tempX*(t - 240)/30, -tempY
--    elseif t > 300 then
--        x , y = tempX,-tempY + tempY*(t - 300)/60
--    end
--    return {x = x+self.userX,y = y+self.userY}
end

function BeautyEnterAnimat:countFromPosition(t)
    t = t - 1
    return {x = math.random(-20,self.winSize.width+20),y = self.winSize.height+math.random(20,3000)}
end

function BeautyEnterAnimat:init()
    local function getPositionAndDirection(t)
         t = t*(20)*math.pi/180
         local result = {}
        result.y = 4*(13*math.cos(t)-5*math.cos(2*t) - 2*math.cos(3*t) - math.cos(4*t))--+self.userY
         result.x = 4*(16*(math.sin(t)*math.sin(t)*math.sin(t)) )--+self.userX
         --logd("x -- >"..result.x.."  y-->"..result.y,"我是计算出来的坐标")
         return result
    end
    
    local bigHeart = cc.Sprite:create(Zjh_Games_res.game_big_heart_img)
    --bigHeart:setGlobalZOrder(9)
    bigHeart:setPosition(self.userX,self.userY)
    bigHeart:setAnchorPoint(0.5,0.5)
    bigHeart:setScale(0.1)
    self:addChild(bigHeart)
    local action1 = cc.EaseSineOut:create(cc.ScaleTo:create(0.2,1,1,10))
    local action2 = cc.EaseSineIn:create(cc.ScaleTo:create(0.1,1,1))
    local action3 = cc.EaseSineIn:create(cc.ScaleTo:create(0.1,1.15,1.05))
    local delayAciont = cc.DelayTime:create(0.5)
    local actionFuc = cc.CallFunc:create(function() 
        for i = 1 , 18 do
            --if i >= 15 or i <= 12 then
                local pAd = getPositionAndDirection(i)
                local _heart = BeautyEnterHert.new({x = pAd.x,y = pAd.y,pointX = self.userX,pointY = self.userY,round = bigHeart:getContentSize().width*0.5})
                self:addChild(_heart)
            --end
        end
    end)
    
    bigHeart:runAction(cc.Sequence:create(
        action1:clone(),
        delayAciont:clone(),
        action3:clone(),
        action2:clone(),
        action3:clone(),
        action2:clone(),
        delayAciont:clone(),
        action3:clone(),
        action2:clone(),
        action3:clone(),
        action2:clone(),
        delayAciont:clone(),
        actionFuc,
        cc.Spawn:create(
            cc.ScaleTo:create(3,1.5),
            cc.FadeTo:create(3,0)
        ),
        cc.CallFunc:create(function() 
            bigHeart:setVisible(false)
        end)
    ))
    self:runAction(cc.Sequence:create(
        cc.DelayTime:create(15),
        cc.CallFunc:create(function() 
            self:removeFromParent(true)
        end)
    ))
end




return BeautyEnterAnimat