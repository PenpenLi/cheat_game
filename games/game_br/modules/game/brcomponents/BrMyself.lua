local BrMyself = class("BrMyself",function(paras) 
    return paras.node
end)
-- local Chat = import("..components.Chat")
BrMyself.TAG = "BrMyself"

function BrMyself:ctor(paras)
    self.winSize = cc.Director:getInstance():getWinSize()
    self:init()
end

function BrMyself:init()
    self.uin = Cache.user.uin
    self.sex = Cache.user.sex
    self.portrait = Cache.user.portrait
    self:updateInfo()
    self:initTouch()
    self:runAction(cc.Sequence:create(
        cc.DelayTime:create(0.5),
        cc.CallFunc:create(function() 
            self:updateHead()
        end)
    ))
    self.myMoneyTxt = ccui.Helper:seekWidgetByName(self, "myself_money")
end


function BrMyself:updateInfo()
	local nick = self:getChildByName("myself_name")
    nick:setString(Cache.user.nick)
    self:getChildByName("img_vip"):setVisible((checkint(Cache.user.vip_days) > 0) and true or false)
    if Cache.brdesk.br_user == nil or Cache.brdesk.br_user[self.uin] == nil then return end
    self:_setGold(Cache.brdesk.br_user[self.uin].chips)
end

function BrMyself:_setGold(gold)
    Cache.brdesk.br_user[self.uin].chips = gold
    Cache.user:updateUserGold(Cache.packetInfo:getProMoney(gold))

    local txt = self.myMoneyTxt
    txt:setString(Util:getFormatString(Cache.packetInfo:getProMoney(gold)))
    qf.event:dispatchEvent(BR_ET.GAME_REFRESH_ADDBTN)
    self:refreshSafeBoxRestNum()
end

-- 刷新金币
function BrMyself:refreshGold(gold)
    if not gold then return end
    self:_setGold(gold)
end

function BrMyself:initTouch()
    addButtonEvent(self:getChildByName("img_head_bg"),function() 
        qf.event:dispatchEvent(ET.GAME_SHOW_USER_INFO,{uin=Cache.user.uin,showGoldTxt = self.myMoneyTxt:getString()})
    end)
    local goldPanel = self:getChildByName("Panel_25")
    goldPanel:getChildByName("myself_add"):setTouchEnabled(false)
    goldPanel:getChildByName("myself_add"):loadTextureNormal(Cache.packetInfo:getGoldImg())

    addButtonEvent(self:getChildByName("Panel_25"),function ( sender )
        qf.platform:umengStatistics({umeng_key = "BR_Shopping_Btn"})--点击上报
        --qf.event:dispatchEvent(ET.GAME_SHOW_SHOP_PROMIT, {gold=100000, ref=UserActionPos.BR_MYSELF_ADD})
        qf.event:dispatchEvent(ET.SHOP)
    end)
end

function BrMyself:initHead( ... )
    self.imgHead = ccui.Helper:seekWidgetByName(self, "head")
    self.imgHead:setVisible(false)
    -- local p = cc.Sprite:create(GameRes.br_default_head_icon)
    -- local cs = self:getContentSize()
    -- local posx, posy = self.imgHead:getPosition()
    -- p:setPosition(posx, posy)
    -- self.imgHead:getParent():addChild(p, 2)
    -- self.user_head = p
end
function BrMyself:updateHead()
    self:initHead()

    local bg = self:getChildByName("img_head_bg")
    Util:updateUserHead(bg, self.portrait, self.sex, {add=true, circle=false, scale=170, url=true, sq= true})
end

function BrMyself:bet()
    local u = Cache.brdesk.br_user[self.uin]
    local chipsGold = u.chips
    if self.uin == Cache.brdesk.br_delar.uin then
        chipsGold = Cache.brdesk.br_delar.chips
    end
    if u then self:_setGold(chipsGold) end
end

function BrMyself:winMoneyFly(paras)
    local money = tonumber(paras.chips)
    if money == 0 then return end
    local headBg = self:getChildByName("img_head_bg")
    local fnt
    local img

    if money > 0 then
        fnt  = cc.LabelBMFont:create('+'..Util:getFormatString(math.abs(paras.chips)),GameRes.game_common_add_money_fnt)
        img  = cc.Sprite:create(GameRes.game_coomon_win_money_back)
    else
        fnt  = cc.LabelBMFont:create('-'..Util:getFormatString(math.abs(paras.chips)),GameRes.game_common_reduce_money_fnt)
        img  = cc.Sprite:create(GameRes.game_coomon_reduce_money_back)
    end
    img:setAnchorPoint(0,0.5)
    fnt:setAnchorPoint(0.5,0.5)
    headBg:addChild(fnt)
    headBg:addChild(img)
    local high = headBg:getContentSize().width + 50
    local wx = 0
    local fntx = 150
    img:setPosition(wx,headBg:getContentSize().height/2)
    fnt:setPosition(wx+fntx,headBg:getContentSize().height/2)

    img:setZOrder(6)
    fnt:setZOrder(6)
    local move  = cc.MoveTo:create(0.25,cc.p(wx,high))
    local delay = cc.DelayTime:create(2)
    local call  = cc.CallFunc:create(function (sender)
        if sender then
            sender:removeFromParent()  
        end
    end)
    local sq   = cc.Sequence:create(move,delay,call)
    img:runAction(sq)

    local move  = cc.MoveTo:create(0.25,cc.p(wx+fntx,high))
    local delay = cc.DelayTime:create(2)
    local call  = cc.CallFunc:create(function (sender)
        if sender then
            sender:removeFromParent()  
        end
    end)
    local sq   = cc.Sequence:create(move,delay,call)
    fnt:runAction(sq)
    if money > 0 then
        qf.event:dispatchEvent(BR_ET.BR_WINMONEY,{node=self, idx = 0, uin = self.uin})
    end
    if not Cache.packetInfo:isShangjiaBao() then
        qf.event:dispatchEvent(ET.REFRESH_NOMONEY_TIP)
    end
end

function BrMyself:showJiFen(score)
    if score == nil then return end
    local num = cc.LabelAtlas:_create(score,GameRes.jifen_num_img, 32, 36, string.byte('0'))
    local l = cc.Sprite:create(GameRes.jifen_word_img)
    local height = self:getContentSize().height
    local x,y = self:getContentSize().width*0.5 + l:getContentSize().width, height-20
    num:setPosition(x,y)
    l:setPosition(x,y)

    l:setAnchorPoint(1,0.5)
    num:setAnchorPoint(0,0.5)

    self:_jifenAction(l)
    self:_jifenAction(num)
end

function BrMyself:updateResultInfo(bShow)
    local resultNum = self:getChildByName("result_num")
    if bShow == false then
        resultNum:setVisible(bShow)
        self:getChildByName("result_num1"):setVisible(bShow)
        return
    end

    local my_win_chips = Cache.packetInfo:getProMoney(Cache.brdesk.br_result_count.myself)
    if Cache.brdesk.br_delar.uin == Cache.user.uin then
       my_win_chips = -Cache.packetInfo:getProMoney(Cache.brdesk.br_result_count.delar)
    end
	
    -- 显示数值
    local myShowChips = ""
    if my_win_chips >= 0 then
        if my_win_chips == 0 then
            myShowChips = "0"
        else
            myShowChips = string.format("+%s",math.abs(my_win_chips))
        end
        resultNum:setVisible(true)
    else
        resultNum = self:getChildByName("result_num1")
        resultNum:setVisible(true)
        myShowChips = string.format("-%s",math.abs(my_win_chips))
    end
    resultNum:setString(myShowChips)
end

function BrMyself:_jifenAction(l)
    if l == nil then return end
    local height = self:getContentSize().height
    self:addChild(l,10) 
    l:setScale(0)
    l:setOpacity(50)
    l:runAction(cc.Sequence:create(
        cc.DelayTime:create(0.4),
        cc.FadeTo:create(1.2,255)
    ))
    l:runAction(cc.Sequence:create(
        cc.EaseSineOut:create(cc.ScaleTo:create(0.3,1)),
        cc.EaseSineInOut:create(
            cc.MoveBy:create(1.5,cc.p(0,height*0.5))
        ),
        cc.DelayTime:create(0.4),
        cc.Spawn:create(
            cc.ScaleTo:create(1,1.1),
            cc.FadeTo:create(1,0)
        ),
        cc.CallFunc:create(function() 
            l:removeFromParent()
        end)
    ))
end


function BrMyself:getChipsPosition() 
    local money = self:getChildByName("img_head_bg")
    return cc.p(self:getPositionX()+money:getPositionX()+30,self:getPositionY()+money:getPositionY())
end

function BrMyself:refreshSafeBoxRestNum()
    local safeBoxView = PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.safeBox)
    if safeBoxView and tolua.isnull(safeBoxView) == false then
        safeBoxView:refreshSafeBoxRestNum()
    end
end

function BrMyself:leave( ... )
    qf.event:dispatchEvent(BR_ET.BR_EXIT_REQ, {send=false})
end

--聊天相关 begin
function BrMyself:emoji(index, Emoji_index)
    self:playEmojiAni({anim = Emoji_index[index].animation,index=Emoji_index[index].index,scale=2})
end

--显示表情
function BrMyself:playEmojiAni( paras )
    local head = ccui.Helper:seekWidgetByName(self, "img_head_bg")
    paras.node = self
    if paras.position  == nil then
        paras.position = cc.p(head:getContentSize().width/2+35,head:getContentSize().height/2+35)
    end
    local face =  Util:playAnimation(paras)
end

function BrMyself:showPopChat(model, del)
    del._chat:showPopChatProtocol(model, self, {chatDel = del})
end

function BrMyself:playShowChatMsg(txt_layer, msg)
	local chatnode = txt_layer:playShowChatMsg(self, self:getChildByName("img_head_bg"), {
        corner = GameConstants.CORNER.LEFT_DOWN,
        -- offset = {x = -47, y = -21},
		msg = msg,
		chatname = "myself"
    })
    self.chatnode = node
end
--聊天相关 end

return BrMyself