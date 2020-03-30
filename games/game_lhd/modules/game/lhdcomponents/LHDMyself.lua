--龙虎斗玩家头像自身的UI
local LHDMyself = class("LHDMyself", function(paras) 
    return paras.node
end)

local UserDisplay = import("..components.user.UserDisplay")
local LHDAniConfig = import("src.games.game_lhd.modules.game.lhdcomponents.animation.LHDAnimationConfig")


LHDMyself.TAG = "LHDMyself"

function LHDMyself:ctor(paras)
    self.winSize = cc.Director:getInstance():getWinSize()
    -- self._parent_view = paras.view
    self:init()

    -- self:getChildByName("img_head_bg"):setOpacity(85)
end

function LHDMyself:updateInfo()
    local nick = self:getChildByName("myself_name")
    nick:setString(Cache.user.nick)
    local _users = self.deskCache:getUserList()
    if _users == nil or _users[self.uin] == nil then return end
    qf.event:dispatchEvent(LHD_ET.GAME_REFRESH_ADDBTN)
    self:_setGold(_users[self.uin].chips)
end

function LHDMyself:updateHead()
    self.user_head:setVisible(true)
    Util:updateUserHead(self.user_head, self.portrait, self.sex, {add=true,circle=false,sq = true,url=true})
end


function LHDMyself:init()
    self.deskCache = Cache.DeskAssemble:getCache(LHD_MATCHE_TYPE)
    self.uin = Cache.user.uin
    self.sex = Cache.user.sex
    self.portrait = Cache.user.portrait
    self.col_portrait = Cache.user.col_portrait
    self:updateInfo()
    self:initTouch()
    self:runAction(cc.Sequence:create(
        cc.DelayTime:create(0.5),
        cc.CallFunc:create(function() 
            self:updateHead()
        end)
    ))
    self:resetWidgetByModuleControll()
    self.user_head = self:getChildByName("head")
end

function LHDMyself:_setGold(gold)
    self.deskCache:updateUserChipsByUin(self.uin, gold)
    --这里和个人信息里面同步数据
    Cache.user:updateUserGold(Cache.packetInfo:getProMoney(gold))
    self:refreshSafeBoxRestNum(gold)
    local txt = self.goldTxt
    txt:setString(Util:getFormatString(Cache.packetInfo:getProMoney(gold)))
    -- self.goldTxt:getParent():requestDoLayout()
end

function LHDMyself:refreshSafeBoxRestNum()
    local safeBoxView = PopupManager:getPopupWindow(PopupManager.POPUPWINDOW.safeBox)
    if safeBoxView and tolua.isnull(safeBoxView) == false then
        safeBoxView:refreshSafeBoxRestNum()
    end
end

function LHDMyself:showResultAnimation(cb)
    local animName = "UserResultAnimation"
    self:hideUserResultAni()


    
    local anim = LHDAniConfig.SELFWIN 
    local movementcb = function (arm, mmType, mmID)
        if mmType == ccs.MovementEventType.loopComplete then
            arm:removeFromParent(true)
        end
    end

    Util:playAnimation({
        anim = anim,
        name = animName,
        position = cc.p(self:getContentSize().width/2,self:getContentSize().height/2),
        node = self,
        movementcb = movementcb,
        posOffset = {x = 20, y = 10},
        scale = {x = 0.9, y = 1}
    })


end

function LHDMyself:hideUserResultAni( ... )
    local animName = "UserResultAnimation"
    if self:getChildByName(animName) then
        self:removeChildByName(animName)
    end
end

function LHDMyself:winMoneyFly(paras)
    local money = tonumber(paras.chips)
    if money == 0 then return end
    local headBg = self.user_head
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
end


function LHDMyself:_getGold( ... )
    -- body
    local txt = self.goldTxt
    
    return txt:getString()
end
-- 刷新金币
function LHDMyself:refreshGold( gold )
    if not gold then return end
    local txt = self.goldTxt
    txt:setString(Util:getFormatString(gold))
    self.goldTxt:getParent():requestDoLayout()
end

function LHDMyself:initTouch()
    addButtonEvent(self,function() 
        qf.event:dispatchEvent(LHD_ET.GAME_SHOW_USER_INFO,{uin=Cache.user.uin,showGoldTxt = self:_getGold()})
    end)
    local goldPanel = self:getChildByName("gold_info")
    goldPanel:getChildByName("img_money"):loadTexture(Cache.packetInfo:getGoldImg())
    goldPanel:getChildByName("myself_add"):setTouchEnabled(false)
    self.goldTxt = goldPanel:getChildByName("myself_money")
    addButtonEvent(goldPanel,function ( sender )
        qf.platform:umengStatistics({umeng_key = "QuickSale1Open"})
        --qf.event:dispatchEvent(ET.GAME_SHOW_SHOP_PROMIT, {gold=100000, ref=UserActionPos.BR_MYSELF_ADD})
        qf.event:dispatchEvent(ET.SHOP)
    end)
end

function LHDMyself:bet()
    local u = self.deskCache:getUserByUin(self.uin)
    if u then self:_setGold(u.chips) end
end

function LHDMyself:showSelfResult()
    local winChips = Cache.lhdDesk.lhd_total_result[self.uin]
    print("winChips >>>>>>>>>", winChips)
    if winChips > 0 then
        self:showResultAnimation()
    end
    self:winMoneyFly({chips = Cache.packetInfo:getProMoney(winChips)})
end

function LHDMyself:showJiFen(score)
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

function LHDMyself:_jifenAction(l)
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


function LHDMyself:getChipsPosition() 
    local money = self:getChildByName("img_head_bg")
    return cc.p(self:getPositionX()+money:getPositionX()+30,self:getPositionY()+money:getPositionY())
end

--根据模块控制UI显隐
function LHDMyself:resetWidgetByModuleControll( ... )
    if TB_MODULE_BIT.BOL_MOUDLE_BIT_PAY then
        local btn_add = self:getChildByName("myself_add")
        btn_add:setVisible(false)
    end
end

function LHDMyself:leave()
    qf.event:dispatchEvent(LHD_ET.LHD_EXIT_REQ, {send=false})
end




--聊天相关 begin
function LHDMyself:emoji(index, Emoji_index)
    self:playEmojiAni({anim = Emoji_index[index].animation,index=Emoji_index[index].index,scale=2})
end

--显示表情
function LHDMyself:playEmojiAni( paras )
    local head = ccui.Helper:seekWidgetByName(self, "img_head_bg")
    paras.node = self
    if paras.position  == nil then
        paras.position = cc.p(head:getContentSize().width/2+35,head:getContentSize().height/2+35)
    end
    paras.order=  5
    local face =  Util:playAnimation(paras)
end

function LHDMyself:showPopChat(model, del)
    del._chat:showPopChatProtocol(model, self, {chatDel = del})
end

function LHDMyself:playShowChatMsg(txt_layer, msg)
    local corner =  GameConstants.CORNER.LEFT_DOWN
	local chatnode = txt_layer:playShowChatMsg(self, self:getChildByName("img_head_bg"), {
        corner = corner,
        -- offset = {x = -47, y = -21},
		msg = msg,
		chatname = "myself"
    })
    self.chatnode = node
end

--聊天相关 end

return LHDMyself