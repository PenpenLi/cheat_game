
local SpecialStyle = class("SpecialStyle")

SpecialStyle.TAG = "SpecialStyle"
SpecialStyle.SHOW_TYPE = {6, 7, 8, 9}
--特殊牌型效果中的文字TAG
SpecialStyle._SPECIAL_CHARACTER_TAG = 20150702

local _gameViewNode             --游戏界面JSON
local _cardPosition = {}        --桌子中间5张牌的坐标
local _deskCard = {}            --桌子中间的5张牌

function SpecialStyle:ctor(  )
	
end

function SpecialStyle:clear()
    if _gameViewNode ~= nil and not tolua.isnull(_gameViewNode) then
        _gameViewNode:removeChildByTag(self._SPECIAL_CHARACTER_TAG)
    end
end

function SpecialStyle:_showSpecialStyle(cardType)
    local styleTable = _SPECIAL_STYLE
    logd("GameTxt.string008[cardType+1] 是 :".. GameTxt.string008[cardType+1],self.TAG)
    local specialCard = GameTxt.string008
    if _deskCard[2] == nil then return end
    self.cardWidth = _deskCard[2]:getContentSize().width
    self.cardHeight = _deskCard[2]:getContentSize().height
    local cW = self.cardWidth
    local cH = self.cardHeight
    local node_character = cc.Node:create()
    node_character:setTag(self._SPECIAL_CHARACTER_TAG)
    node_character:setAnchorPoint(0,0)
    _gameViewNode:addChild(node_character,1000)
    local zorder = _gameViewNode:getLocalZOrder()
    _gameViewNode:setLocalZOrder(GameConstants.SPECIAL_CARDTYPE_Z)
    
    local function deleteAllStyle()
        if node_character then
            node_character:runAction(cc.Sequence:create(
                cc.DelayTime:create(4),
                cc.CallFunc:create(function() 
                    node_character:removeFromParent()
                    node_character = nil
                    _gameViewNode:setLocalZOrder(zorder)
                end)
            ))
        end
        for k,v in pairs(_deskCard) do
            v:runAction(cc.Sequence:create(
                cc.DelayTime:create(4),
                cc.CallFunc:create(function() 
                    v:removeAllChildren()
                end)
            ))
        end
    end

    for k,v in pairs(specialCard) do
        if GameTxt.string008[cardType+1] == v then
            
        else
            logd("没有匹配到特殊牌型",self.TAG)    
        end     
    end      	
end

--[[特殊牌型展示]]
function SpecialStyle:showSpecialStyle(cardIndex,deskCard,node)
    local maxCard = -1
    for k,v in pairs(self.SHOW_TYPE) do
        if v == cardIndex then
            maxCard = cardIndex
        end
    end
    if maxCard < 0 then return end

    local temp = {}
    _gameViewNode = node
    _deskCard = deskCard
    _cardPosition = {}          --_cardPosition需要清空一次
    logd("_deskCard的长度是".. #_deskCard,self.TAG)
    logd("特殊牌型展示，最大牌是：" .. GameTxt.string008[maxCard+1],self.TAG)
    for k,v in pairs(_deskCard) do
        logd("特殊牌型展示，传入的牌".. k .."的坐标:(".. v:getPositionX() .. "," .. v:getPositionY() ..")",self.TAG)
        table.insert(temp,v:getPositionX())
    end
    table.sort(temp)
    for k1,v1 in pairs(temp) do
        for k2,v2 in pairs(_deskCard) do
            if v2:getPositionX() == v1 then
                table.insert(_cardPosition,{x = v1,y = v2:getPositionY(),z = v2:getLocalZOrder()})
            end
        end
    end
    for k,v in pairs(_cardPosition) do
        logd("特殊牌型展示，牌".. k .."的坐标:(".. v.x .. "," .. v.y .."),层级:".. v.z,self.TAG)
    end
    self:_showSpecialStyle(maxCard)
end

---[[隐藏显示，设置初始Scale]]       参数:paras的形式:{...}
function SpecialStyle:hideAndScale(paras)
    for k1,v1 in pairs(paras) do
        if type(v1) == "table" then
            for k2,v2 in pairs(v1) do
                v2:setScale(0.01)
                v2:setVisible(false)
            end
        end
    end
end


return SpecialStyle