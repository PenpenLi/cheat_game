--庄家的UI
local LHDDelar = class("LHDDelar",function(paras) 
    return paras.node
end)
LHDDelar.TAG = "LHDDelar"

function LHDDelar:ctor(paras)
    self.winSize = cc.Director:getInstance():getWinSize()
    self:init()
end


function LHDDelar:init()
    self.deskCache = Cache.DeskAssemble:getCache(LHD_MATCHE_TYPE)
    self:clearAll()
    self:initTouch()
    self:initCards()
    self:getChildByName("delar_head"):setVisible(false)
    self:leave()
end

function LHDDelar:clearAll()
    local nameT = {"delar_name", "delar_chip", "delar_name", "user_bg"
        , "delar_head", "delar_bg"}
    for k, v in pairs(nameT) do
        self[v] = self:getChildByName(v)
    end
end


function LHDDelar:initTouch()
    self:getChildByName("bnt_tobe_delar"):getChildByName("lhd_delar_txt"):setVisible(false)
    self:getChildByName("bnt_tobe_delar"):loadTextureNormal(LHD_Games_res.br_game_btn_want_be_delar)
    addButtonEvent(self:getChildByName("bnt_tobe_delar"),function()
        if self.uin == Cache.user.uin then
            qf.event:dispatchEvent(LHD_ET.BR_DELAR_EXIT_REQ)
        else
            qf.event:dispatchEvent(LHD_ET.BR_DELARLIST_SHOW,{isExit = self.uin == Cache.user.uin})
        end
    end)
    addButtonEvent(self:getChildByName("user_bg"),function() 
        if self.uin == nil then return end
        local defaultImg
        if Util:checkSysZhuangUin(self.uin) then
            defaultImg = GameRes.defaultZhuangCircleImg
        end
        qf.event:dispatchEvent(LHD_ET.GAME_SHOW_USER_INFO,{uin=self.uin, defaultImg = defaultImg,showGoldTxt = self.delar_chip:getString()})
    end)
end


function LHDDelar:setNick(nick)
    nick = self.onBody == true and " " or nick

    local txt = self:getChildByName("delar_name")
    local remark_name= Util:getFriendRemark(self.uin,nick)
    txt:setString(remark_name or " ")
    -- txt:setAnchorPoint(0,0.5)
    -- txt:setPosition(cc.p(self:getContentSize().width*0.425,self:getContentSize().height*0.84))
end


function LHDDelar:setGold(gold)
    if (checkint(self.uin) >= 1000 and checkint(self.uin) <= 1010) or checkint(self.uin) == 2000 then
        gold = LHD_Games_txt.system_dealer
    end
    gold = self.onBody == true and " " or gold
    if self.delar_chip == nil then
        local head = self:getChildByName("delar_head")
        self.delar_chip = cc.LabelTTF:create(" ", GameRes.font1, 35)
        self.delar_chip:setAnchorPoint(0,0.5)
        self.delar_chip:setPosition(head:getPositionX()+head:getContentSize().width*0.5+25,head:getPositionY()-head:getContentSize().height*0.5+30)
        self:addChild(self.delar_chip,2)
        self.delar_chip:setColor(cc.c3b(252,205,0))
    end
    self.delar_chip:setString(Util:getFormatString(gold))
    -- self.delar_chip:setAnchorPoint(0,0.5)
end

function LHDDelar:getChipsPosition() 
    -- return cc.p(self:getPositionX()+self.user_bg:getPositionX(),self:getPositionY()+self.user_bg:getPositionY())
    local chips_node = self:getChildByName("chips_node")
    return cc.p(chips_node:getPositionX() + self:getPositionX(), chips_node:getPositionY() + self:getPositionY())
end


---下注
function LHDDelar:bet()
    local delar = self.deskCache:getDelar()
    local chip = Cache.packetInfo:getProMoney(delar.chips)
    self:setGold(chip)
end

function LHDDelar:seatDown()
	self.onBody = false
    local delar = self.deskCache:getDelar()
    if delar == nil then return end
    self.uin = delar.uin
    self.sex = delar.sex
    self.nick = delar.nick
    self.chips = delar.chips
    self.portrait = delar.portrait
    self.col_portrait = delar.col_portrait
    self:setNick(self.nick)
    self:setGold(self.chips)

    self:updateHead()
    self.delar_name:setVisible(true)
    self.delar_chip:setVisible(true)
    self.delar_bg:setVisible(true)
    self.user_bg:setVisible(true)
    self.delar_head:setVisible(true)
    if self.uin == Cache.user.uin then 
        -- 庄家列表
        self:getChildByName("bnt_tobe_delar"):loadTextureNormal(LHD_Games_res.br_game_btn_not_want_be_delar)
    end

	-- local bnt_tobe_delar = self:getChildByName("bnt_tobe_delar")
	-- bnt_tobe_delar:loadTextureNormal(LHD_Games_res.lhd_delar_btn, ccui.TextureResType.plistType)
	-- if self.uin == Cache.user.uin then 
 --        local lhd_delar_txt = bnt_tobe_delar:getChildByName("lhd_delar_txt")
 --        lhd_delar_txt:loadTexture(LHD_Games_res.lhd_down_delar_txt, ccui.TextureResType.plistType)
 --    end
end

function LHDDelar:removeDynamicHead( ... )
    local parent = self.delar_head:getParent()
    if parent:getChildByName("dynamic_head") then
        parent:getChildByName("dynamic_head"):removeFromParent()
    end
end


function LHDDelar:leave()
    if true then return end
    self.onBody = true
    self:setNick(" ")
    self:setGold(" ")
    self.uin = nil
    self:clearCards()
    self.delar_name:setVisible(false)
    self.delar_chip:setVisible(false)
    self.delar_bg:setVisible(false)
    self.user_bg:setVisible(false)
    self.delar_head:setVisible(false)
    self:removeDynamicHead()
    self.user_bg:loadTexture(LHD_Games_res.br_game_common_bg)
    self.user_bg:removeAllChildren()
    -- 我要上庄
    self:getChildByName("bnt_tobe_delar"):loadTextureNormal(LHD_Games_res.br_game_btn_want_be_delar)

 --    local bnt_tobe_delar = self:getChildByName("bnt_tobe_delar")
	-- bnt_tobe_delar:loadTextureNormal(LHD_Games_res.lhd_delar_btn, ccui.TextureResType.plistType)
	-- local lhd_delar_txt = bnt_tobe_delar:getChildByName("lhd_delar_txt")
 --    lhd_delar_txt:loadTexture(LHD_Games_res.lhd_up_delar_txt, ccui.TextureResType.plistType)

    self.user_bg:loadTexture(LHD_Games_res.lhd_head_bg, ccui.TextureResType.plistType)
    self.user_bg:setOpacity(85)
end

function LHDDelar:updateHead()
    local user_data = self.deskCache:getDelar()
    if not user_data then return end

    self.portrait = user_data.portrait
    self.col_portrait = user_data.col_portrait
    self.sex = user_data.sex
    local scale = self.delar_head:getContentSize().width
    -- Util:updateUserHead(self.delar_head, self.portrait, self.sex, {add=true, circle=true, url=true})
    self.delar_head:setVisible(true)

    -- logd("portrait>>>>>>>>>", self.portrait)

    local extparas = {add=true, circle=true, url=true}
    if (checkint(self.uin) >= 1000 and checkint(self.uin) <= 1010) or checkint(self.uin) == 2000 then
        extparas.default = GameRes.defaultZhuangCircleImg
    end

    Util:updateUserHead(self.delar_head, self.portrait, self.sex, extparas)
    -- DownloadUtil:downloadAndUpdateUserHead(
    --     self.delar_head
    --     , self.portrait
    --     , self.sex
    --     , {
    --         default=true
    --         , file_suffix=FILE_SUFFIX_NAME.PNG
    --         , circle=true
    --         , to_jpg=true
    --     })
    self:removeDynamicHead()
    -- if self.col_portrait and string.trim(self.col_portrait) ~= "" then
    --     DownloadUtil:downloadAndUpdateDynamicHead(
    --         self.delar_head
    --         , self.col_portrait
    --         , {
    --             cover=true
    --             , circle=true
    --             , auto_play=true
    --         })
    -- end
end


function LHDDelar:initCards() end
function LHDDelar:giveCards(...) end
function LHDDelar:reverseCards(...) end
function LHDDelar:clearCards() end
function LHDDelar:showCardInfo() end
function LHDDelar:hideCardInfo() end
function LHDDelar:ready() end

return LHDDelar