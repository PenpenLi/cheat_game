local Gift = class("Gift",function(paras)
     
      local askfriend=0
      if  paras.ask_friend then
          askfriend=paras.ask_friend
      end
   if askfriend==1 then 
      return cc.Sprite:create(GameRes["gift_wing_envelop"]) 
    else 
        if GameRes["gift_icon_"..paras.id] then
            return cc.Sprite:create(GameRes["gift_icon_"..paras.id])
        else
            return cc.Sprite:create()
        end
   end
end)
Gift.TAG = "Gift"

function Gift:ctor(paras)

       self.addfriend=false
       if  paras.ask_friend then
           if paras.ask_friend==1 then
              self.addfriend=true
            end
       end
    self:setPosition(cc.p(paras.from.x,paras.from.y))
    self.id = paras.id
    self.to = paras.to
    self.to_uin=paras.to_uin
    self.from_uin=paras.from_uin
    self:setLocalZOrder(100)
    self:init()
end

function Gift:init()
    if self.addfriend==true then  self:runAction8()  return  end 
    if tonumber(self.id) > 5 or tonumber(self.id)==2 then
       if self.to_uin==self.from_uin then
         self:runAction6()
       else
          self:runAction7()
        end
    else
         self["runAction"..self.id](self)
    end
end

function Gift:runAction6() 
    self:runAction(cc.Sequence:create(
        cc.MoveTo:create(0.8,self.to),
        cc.ScaleTo:create(0.2,0.8),
        cc.CallFunc:create(function ( sender )
            self:removeFromParent(true)
            logd("---其他礼物动画自己发给自己---")
        end)
    ))
end

function Gift:runAction0() 

    local fileNames = {}
    for i=0,7 do
        fileNames[i+1] = GameRes["gift_0_"..i]
    end
    
    local function last()
        local l = cc.Sprite:create(GameRes["gift_0_8"])
        l:setPosition(self:getContentSize().width/2,self:getContentSize().height/2)
        l:setGlobalZOrder(1)
        l:setOpacity(0)
        self:addChild(l)
        l:runAction(cc.Sequence:create(
            cc.Spawn:create(
            cc.FadeTo:create(1.2,255),cc.RotateBy:create(0.3,45)),
            cc.CallFunc:create(function (  )
                self:removeFromParent(true)
            end)
            ))
    end

    self:runAction(cc.Sequence:create(
        cc.MoveTo:create(0.8,self.to),
        cc.ScaleTo:create(0.2,0.8),
        cc.Animate:create(self:getAnimation(fileNames,0.15)),
        cc.CallFunc:create(function ( sender )
            last()
        end)
        ))


end

function Gift:runAction1() 
    local fileNames = {}
    local time = 1.5
    for i=0,10 do
        fileNames[i+1] = GameRes["gift_1_"..i]
    end

    self:runAction(cc.Sequence:create(
        cc.Spawn:create(
            cc.MoveTo:create(time,self.to),
            cc.RotateBy:create(time,360)
        ),
        cc.Animate:create(self:getAnimation(fileNames,0.11)),
        cc.DelayTime:create(0.5),
        cc.CallFunc:create(function ( sender )
            self:removeFromParent(true)
        end)
        ))
end
function Gift:runAction2() 
    local fileNames = {}
    local time = 1.5
    for i=0,10 do
        fileNames[i+1] = GameRes["gift_2_"..i]
    end
    
    self:runAction(cc.Sequence:create(
        cc.MoveTo:create(time,self.to),
        cc.Animate:create(self:getAnimation(fileNames,0.11)),
        cc.DelayTime:create(0.5),
        cc.CallFunc:create(function ( sender )
            self:removeFromParent(true)
        end)
        ))
end

function Gift:runAction3() 
    local time = 1.5
    self:runAction(cc.Sequence:create(
        cc.MoveTo:create(time,self.to),
        cc.EaseSineOut:create (cc.ScaleTo:create(0.4,2.5)),
        cc.DelayTime:create(0.5),
        cc.CallFunc:create(function ( sender )
            self:removeFromParent(true)
        end)
    ))
end

function Gift:runAction4() 
    local time = 1.5
    self:runAction(cc.Sequence:create(
        cc.MoveTo:create(time,self.to),
        cc.EaseSineOut:create (cc.ScaleTo:create(0.4,2.5)),
        cc.DelayTime:create(0.5),
        cc.CallFunc:create(function ( sender )
            self:removeFromParent(true)
        end)
    ))
end

function Gift:runAction5()
    local time = 1.5
    self:runAction(cc.Sequence:create(
        cc.MoveTo:create(time,self.to),
        cc.FadeTo:create(1.0,0),
        cc.CallFunc:create(function(sender) 
            self:removeFromParent(true)
        end)))
end

function Gift:getAnimation ( fileNames , seq ) 


    local ani = cc.Animation:create()
    for k,v in pairs(fileNames) do
        ani:addSpriteFrameWithFile(v)
    end
    ani:setDelayPerUnit(seq)
    return ani
end

function Gift:runAction7() 
    local time = 1.5
    self:runAction(cc.Sequence:create(
        cc.MoveTo:create(time,self.to),
        cc.EaseSineOut:create(cc.ScaleTo:create(0.4,2.5)),
        --cc.ScaleTo:create(0.2,1.5),
        cc.DelayTime:create(0.5),
        cc.CallFunc:create(function ( sender )
            self:removeFromParent(true)
            logd("---其他礼物动画播放完成---")
        end)
    ))
end

function Gift:runAction8() -- 加好友送信封翅膀的动画
  

  

    local left = cc.Sprite:create(GameRes["gift_wing_left"])
    left:setAnchorPoint(1.0,0.0)
    left:setPosition(left:getContentSize().width/2+5,self:getContentSize().height/2-30)
    left:setGlobalZOrder(1)
    --left:setOpacity(0)
    self:addChild(left)


    local right = cc.Sprite:create(GameRes["gift_wing_right"])
    right:setAnchorPoint(0.0,0.0)
    right:setPosition(self:getContentSize().width-right:getContentSize().width/2-5,self:getContentSize().height/2-30)
    right:setGlobalZOrder(1)
    --right:setOpacity(0)
    self:addChild(right)
   
   local  wing_time=0.1
    local left_action= 
    
      cc.RepeatForever:create(
            cc.Sequence:create(
            cc.RotateTo:create(wing_time,10),
            cc.RotateTo:create(wing_time,0),
            cc.RotateTo:create(wing_time,-10),
            cc.RotateTo:create(wing_time,0)
            ))
          
 


     local right_action= 
    
      cc.RepeatForever:create(
            cc.Sequence:create(
            cc.RotateTo:create(wing_time,-10),
            cc.RotateTo:create(wing_time,0),
            cc.RotateTo:create(wing_time,10),
            cc.RotateTo:create(wing_time,0)
            ))
          
          
    
    left:runAction(left_action)
    right:runAction(right_action)

   
     self:setScale(0.4)
    local time =1.2
    self:runAction(cc.Sequence:create(
        cc.ScaleTo:create(0.1,1.0),
        cc.MoveTo:create(time,self.to),
        cc.DelayTime:create(0.4),
        cc.ScaleTo:create(0.3,0),
        cc.CallFunc:create(function ( sender )
            self:removeFromParent(true)
            logd("---envelop---")
        end)
    ))
end

return Gift