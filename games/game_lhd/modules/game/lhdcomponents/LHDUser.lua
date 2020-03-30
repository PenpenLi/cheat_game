local LHDUser = class("LHDUser", function(paras)
    return paras.node
end)

local LHDAniConfig =  import("src.games.game_lhd.modules.game.lhdcomponents.animation.LHDAnimationConfig")
LHDUser.VIP_TAG = 8001

function LHDUser:ctor(paras)
    self.winSize = cc.Director:getInstance():getWinSize()
    self.index = paras.index
    self:init()
end

function LHDUser:init()
    self.deskCache = Cache.DeskAssemble:getCache(LHD_MATCHE_TYPE)
    self:getAll()
    self:leave()
    self:initTouch()
end

function LHDUser:initTouch()
    addButtonEvent(self,function() 
        if self.isSeat then
            qf.event:dispatchEvent(LHD_ET.GAME_SHOW_USER_INFO,{uin=self.uin,showGoldTxt = self.chip_str:getString()})
        else
            local is_delar = self.deskCache:isDelarByUin(Cache.user.uin)

            if is_delar then
                qf.event:dispatchEvent(ET.GLOBAL_TOAST,{txt = LHD_Games_txt.br_is_delar_now_tips})
                return
            end
            qf.event:dispatchEvent(LHD_ET.NET_AUTO_SIT_DOWN_REQ,{index = self.index})
        end
    end)
end


function LHDUser:getAll()
    local nameT = {"name_str","chip_str","seat_down", "user_bg", "user_head"}
    for k, v in pairs(nameT) do
        self[v] = self:getChildByName(v)
    end
    if self.name_str then
        self.name_str:getLayoutParameter():setMargin({left = 60, right = 0, top = 5, bottom = 0})
    end
    if self.chip_str then
        self.chip_str:getLayoutParameter():setMargin({left = 54, right = 0, top = 0, bottom = 5})
    end

    self.user_head:setScale(0.95)
end

function LHDUser:bet(bShowResult)
    local user_data = self.deskCache:getUserByUin(self.uin)
    if user_data then
        self:setGold(user_data.chips)
    end
end

function LHDUser:showSelfResult()
    local winChips = Cache.lhdDesk.lhd_total_result[self.uin]
    if winChips > 0 then
        self:showResultAnimation()
    end

    self:winMoneyFly({chips =Cache.packetInfo:getProMoney( winChips)})
end

function LHDUser:winMoneyFly(paras)
    local money = tonumber(paras.chips)
    if money == 0 then return end

    local fnt
    local img
    if money > 0 then
        fnt  = cc.LabelBMFont:create('+'..Util:getFormatString(math.abs(paras.chips)),GameRes.game_common_add_money_fnt)
        img  = cc.Sprite:create(GameRes.game_coomon_win_money_back)
    else
        fnt  = cc.LabelBMFont:create('-'..Util:getFormatString(math.abs(paras.chips)),GameRes.game_common_reduce_money_fnt)
        img  = cc.Sprite:create(GameRes.game_coomon_reduce_money_back)
    end
    -- self.user_head:setVisible(true)
    self:setVisible(true)
    self:addChild(img)
    img:addChild(fnt)
    local high = self:getContentSize().height -20
    local wx = 0
    local bLeft = true
    local fntX = 30
    -- -- 最右边的座位需要右对齐
    if self.index > 3 then
        bLeft = false
    end
    local move
    if bLeft then
        if fnt:getContentSize().width < img:getContentSize().width then
            fntX = fntX + (img:getContentSize().width - 45 - fnt:getContentSize().width)/2
        end
        fnt:setAnchorPoint(0,0.5)
        img:setAnchorPoint(0.5,0.5)
        img:setPosition(self:getContentSize().width/2,self:getContentSize().height/2)
        fnt:setPosition(fntX,img:getContentSize().height/2)
        img:setScale(0.7)
        fnt:setScale(1)
        img:setZOrder(6)
        fnt:setZOrder(6)

        move = cc.MoveTo:create(0.25,cc.p(self:getContentSize().width/2,high))
    else
        if fnt:getContentSize().width < img:getContentSize().width then
            fntX = fntX + (img:getContentSize().width - fnt:getContentSize().width)/2 - 25
        end
        fnt:setAnchorPoint(1,0.5)
        fnt:setAlignment(cc.TEXT_ALIGNMENT_RIGHT)
        img:setAnchorPoint(0.5,0.5)
        img:setPosition(self:getContentSize().width/2,self:getContentSize().height/2)
        fnt:setPosition(img:getContentSize().width - fntX,img:getContentSize().height/2)
        img:setScale(0.7)
        fnt:setScale(1)
        img:setZOrder(6)
        fnt:setZOrder(6)

        move  = cc.MoveTo:create(0.25,cc.p(self:getContentSize().width/2,high))
    end
    
    local delay = cc.DelayTime:create(2)
    local call  = cc.CallFunc:create(function (sender)
        if sender then
            sender:removeFromParent()  
        end
    end)
    local sq   = cc.Sequence:create(move,delay,call)
    img:runAction(sq)
end

function LHDUser:checkLeft()
    return self.index <= 3
end

function LHDUser:showResultAnimation(cb)
    local animName = "UserResultAnimation"
    self:hideUserResultAni()

    local anim = LHDAniConfig.USERWIN 
    local movementcb = function (arm, mmType, mmID)
        if mmType == ccs.MovementEventType.complete then
            arm:removeFromParent(true)
        end
    end

    Util:playAnimation({
        anim = anim,
        name = animName,
        position = cc.p(self.user_head:getContentSize().width/2,self.user_head:getContentSize().height/2),
        node = self.user_head,
        movementcb = movementcb,
        scale = 1.1
    })
end

function LHDUser:hideUserResultAni( ... )
    local animName = "UserResultAnimation"
    if self.user_head:getChildByName(animName) then
        self.user_head:removeChildByName(animName)
    end
end

function LHDUser:refreshGold(gold)
    if not gold then return end
    self:setGold(gold)
end

function LHDUser:update(info)
    
end

function LHDUser:setNickTxt(nick)
    local remark_name= Util:getFriendRemark(self.uin,nick)
    self.name_str:setString(remark_name)
    self.name_str:setAnchorPoint(0.5, 0.5)
    self.name_str:setPositionX(self:getContentSize().width / 2)
end

function LHDUser:setGold(gold)
    self.chip_str:setString(Util:getFormatString(Cache.packetInfo:getProMoney(gold)))
end



function LHDUser:removeDynamicHead( ... )
    local parent = self.user_head:getParent()
    if parent:getChildByName("dynamic_head") then
        parent:getChildByName("dynamic_head"):removeFromParent()
    end
end


function LHDUser:getChipsPosition() 
    return cc.p(self:getPositionX()+self.user_bg:getPositionX(),self:getPositionY()+self.user_bg:getPositionY())
end

function LHDUser:seatDown(someone)
    self.isSeat = true
    self.seat_down:setVisible(false)
    self.user_head:setVisible(true)
    self.uin = someone.uin
    self.sex = someone.sex
    self.nick = Util:showUserName(someone.nick)
    self.chips = someone.chips
    self:setGold(self.chips)
    self:setNickTxt(self.nick)
    self:updateHead()
end

function LHDUser:leave()
    self.isSeat = false
    self.uin = nil
    self.name_str:setString(" ")
    self.chip_str:setString(" ")
    self.seat_down:setVisible(true)
    self.user_head:setVisible(false)
    self:removeDynamicHead()
    self.user_bg:setScale(1)
    -- self.user_bg:loadTexture(LHD_Games_res.lhd_head_bg, ccui.TextureResType.plistType)
    self.user_bg:removeAllChildren()
    self.user_bg:setOpacity(0)
end

function LHDUser:updateHead()
    local user_data = self.deskCache:getUserByUin(self.uin)
    if not user_data then return end

    self.portrait = user_data.portrait
    self.col_portrait = user_data.col_portrait

    self.user_head:setVisible(true)
    Util:updateUserHead(self.user_head, self.portrait, self.sex, {add=true, circle=false, scale=self.user_head:getContentSize().width, url=true,sq = true})
    -- DownloadUtil:downloadAndUpdateUserHead(
    --     self.user_head
    --     , self.portrait
    --     , self.sex
    --     , {
    --         default=true
    --         , circle=true
    --         , scale=160
    --         , file_suffix=FILE_SUFFIX_NAME.PNG
    --         , to_jpg=true
    --     })

    -- self:removeDynamicHead()
    -- if self.col_portrait and string.trim(self.col_portrait) ~= "" then
    --     DownloadUtil:downloadAndUpdateDynamicHead(
    --         self.user_head
    --         , self.col_portrait
    --         , {
    --             cover=true
    --             , scale=160
    --             , circle=true
    --             , auto_play=true
    --         })
    -- end
end





-- self:playEmojiAni({anim=Chat.Emoji_index[num].animation,index=Chat.Emoji_index[num].index,scale=2})
--显示表情
function LHDUser:playEmojiAni( paras )
    paras.node = self
    local head = self.user_head
    if paras.position  == nil then
        paras.position = cc.p(head:getContentSize().width/2+19,head:getContentSize().height/2+35)
    end

    if paras.order == nil then
        paras.order = 5
    end

    local face =  Util:playAnimation(paras)
end


function LHDUser:emoji(index, Emoji_index)
    self:playEmojiAni({anim = Emoji_index[index].animation,index=Emoji_index[index].index,scale=2})
end

function LHDUser:playShowChatMsg(txt_layer, msg)
    local corner =  GameConstants.CORNER.LEFT_DOWN
    if self.index > 3 then
        corner = GameConstants.CORNER.RIGHT_DOWN
    end

	local chatnode = txt_layer:playShowChatMsg(self, self.user_bg, {
        corner = corner,
        -- offset = {x = -47, y = -21},
		msg = msg,
		chatname = "chat_" .. self.index
    })
    self.chatnode = node
end


function LHDUser:showPopChat(model, del)
    del._chat:showPopChatProtocol(model, self, {chatDel = del})
end

return LHDUser