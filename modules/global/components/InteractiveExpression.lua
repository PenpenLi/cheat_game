local InteractiveExpression = class("InteractiveExpression",function(paras)
    return cc.Layer:create()
end)

InteractiveExpression.TAG = "InteractiveExpression"

function InteractiveExpression:ctor(paras)
    --self.cb = paras.cb--回调
    self.uin = paras.uin--给谁
    self.gold = paras.gold--价值金币数
    self.pos = paras.pos--基础位置
    self.dir = paras.dir--方向
    self:initUI()
    self.winSize = cc.Director:getInstance():getWinSize()
    if FULLSCREENADAPTIVE then
        self:setPositionX(self.winSize.width/2-1920/2)
    end
end

function InteractiveExpression:initUI()
    self.root = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.InteractiveExpression)
    self:addChild(self.root)
    self.root:setTouchEnabled(true)
    addButtonEvent(ccui.Helper:seekWidgetByName(self.root,"closeP"),function ()
               --self:removeFromParent(true)
               qf.event:dispatchEvent(ET.INTERACTIVE_EXPRESSION_REMOVE)
        end)

    self.faceBg=ccui.Helper:seekWidgetByName(self.root,"bgImg")
    loga(self.pos.x.."         "..self.pos.y.."       "..self.dir.."        "..self.faceBg:getContentSize().width/2)
    
    --计算控件位置
    if self.dir==1 then --上边 
        self.faceBg:setPosition(cc.p(self.pos.x,self.pos.y+self.faceBg:getContentSize().height/2))
    elseif self.dir==2 then --下边 
        self.faceBg:setPosition(cc.p(self.pos.x,self.pos.y-self.faceBg:getContentSize().height/2))
    elseif self.dir==3 then --左边 
        self.faceBg:setPosition(cc.p(self.pos.x-self.faceBg:getContentSize().width/2,self.pos.y))
        loga(self.pos.x-self.faceBg:getContentSize().width/2)
    elseif self.dir==4 then --右边 
        self.faceBg:setPosition(cc.p(self.pos.x+self.faceBg:getContentSize().width/2,self.pos.y))
        loga(self.pos.x+self.faceBg:getContentSize().width/2)
    end
    
    self.connectText=ccui.Helper:seekWidgetByName(self.root,"connectText")--内容
    self.goldText=self.connectText:clone()
    self.goldText:setAnchorPoint(0,0.5)
    self.goldText:setPosition(cc.p(self.goldText:getPositionX()+self.goldText:getContentSize().width,self.goldText:getPositionY()))
    self.goldText:setColor(cc.c3b(216,163,49))
    self.goldText:setString(self.gold.. Cache.packetInfo:getShowUnit())
    self.faceBg:addChild(self.goldText)
    for i=1,5 do 
        addButtonEvent(ccui.Helper:seekWidgetByName(self.root,"facebtn"..i),function ()
            self:clickInteractPhiz(i)
            --self:removeFromParent(true)
        end)
    end
end

function InteractiveExpression:clickInteractPhiz(id)
    local body = {to_uin = self.uin
        , expression_id = id
    } 
    --qf.event:dispatchEvent(ET.INTERACT_PHIZ_NTF,{model={from_uin=Cache.user.uin,to_uin=self.uin,expression_id=id}})
    GameNet:send({cmd=CMD.CMD_INTERACT_PHIZ, body=body, callback=function (rsp)
        if rsp.ret==0 then 
            --qf.event:dispatchEvent(ET.INTERACT_PHIZ_NTF,{model={from_uin=rsp.model.uin,to_uin=rsp.model.to_uin,expression_id=expression_id}})
            --self:setInfoOpacity( )
        else
            qf.event:dispatchEvent(ET.GLOBAL_TOAST, {txt = Cache.Config._errorMsg[rsp.ret]})
        end
    end})
    -- 以下语句可以在此动作（发送互动表情）开始时，移除对方玩家信息的弹框
    --qf.event:dispatchEvent(ET.REMOVE_VIEW_DIALOG, {name="gamer"})
end

return InteractiveExpression