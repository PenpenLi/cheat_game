local ChipNum = class("ChipNum", function(paras)
    return cc.Node:create()
end)

ChipNum.FONT_TYPE_SYSTEM = 0    --系统字
ChipNum.FONT_TYPE_ATLAS = 1     --美术字

function ChipNum:ctor(paras)
    self.num = paras.num
    self.precision = paras.precision or 2
    self.type = ChipNum.FONT_TYPE_SYSTEM    --默认为系统字.为防止产品需求变更，美术字代码保留。
    self:init()
end

function ChipNum:init()
    if self.type == ChipNum.FONT_TYPE_ATLAS then
        self:initAlatsFont()
    else
        self:initSystemFont()
    end
    if self.num ~= nil then
        self:setString(self.num, self.precision)
    end
end

------------------public interface------------------

function ChipNum:setString(number, precision)
    self.num = tonumber(number)
    self.precision = precision or 2
    if self.type == ChipNum.FONT_TYPE_ATLAS then
        self:setAlatsNum(self.num, self.precision)
    else
        self:setSystemFontNum(self.num, self.precision)
    end
end

function ChipNum:setColor(color)
    if self.type == ChipNum.FONT_TYPE_ATLAS then
        self.num_txt:setColor(color)
        self.dot_sprite:setColor(color)
        self.decimal_txt:setColor(color)
        self.unit_txt:setColor(color)
    else
        self.num_txt:setColor(color)
    end
end

function ChipNum:setOpacity(opacity)
    if self.type == ChipNum.FONT_TYPE_ATLAS then
        self.num_txt:setOpacity(opacity)
        self.dot_sprite:setOpacity(opacity)
        self.decimal_txt:setOpacity(opacity)
        self.unit_txt:setOpacity(opacity)
    else
        self.num_txt:setOpacity(opacity)
    end
end


------------------private function------------------

function ChipNum:initSystemFont()
    self.num_txt = cc.LabelTTF:create("0", GameRes.font1, Theme.FontSize.GAME_CHIPS)
    self.num_txt:setAnchorPoint(cc.p(0.5, 0.5))
    self.num_txt:setVisible(false)
    self:addChild(self.num_txt)
end

function ChipNum:setSystemFontNum(number, precision)
    local txt = Util:getOldFormatString(number, precision)
    self.num_txt:setString(txt)
    local size = self.num_txt:getContentSize()
    self.num_txt:setPosition(size.width/2, size.height/2)
    self.num_txt:setVisible(true)
    self:setContentSize(size.width, size.height)
end

function ChipNum:initAlatsFont()
    local height = 0
    local anchorPoint = cc.p(0, 1)
    self.height = 0
    --数字,整数部分
    self.num_txt = cc.LabelAtlas:_create("0", GameRes.playgame_chips_num_altas, 23, 36, string.byte('0'))
    self.num_txt:setAnchorPoint(anchorPoint)
    self.num_txt:setVisible(false)
    self:addChild(self.num_txt)
    height = self.num_txt:getContentSize().height
    self.height = (self.height > height) and self.height or height
    --小数点
    self.dot_sprite = cc.Sprite:create(GameRes.playgame_chips_num_dot)
    self.dot_sprite:setAnchorPoint(anchorPoint)
    self.dot_sprite:setVisible(false)
    self:addChild(self.dot_sprite)
    height = self.dot_sprite:getContentSize().height
    self.height = (self.height > height) and self.height or height
    --数字,小数部分
    self.decimal_txt = cc.LabelAtlas:_create("0", GameRes.playgame_chips_num_altas, 23, 36, string.byte('0'))
    self.decimal_txt:setAnchorPoint(anchorPoint)
    self.decimal_txt:setVisible(false)
    self:addChild(self.decimal_txt)
    height = self.decimal_txt:getContentSize().height
    self.height = (self.height > height) and self.height or height
    --万/亿
    self.unit_txt = cc.Sprite:create(GameRes.playgame_chips_unit_k_altas)
    self.unit_txt:setVisible(false)
    self.unit_txt:setAnchorPoint(anchorPoint)
    self:addChild(self.unit_txt)
    height = self.unit_txt:getContentSize().height
    self.height = (self.height > height) and self.height or height
end

function ChipNum:setAlatsNum(number, precision)
    local num, unit = Util:getFormatUnit(number)
    local int_part,decimal_part = self:_getIntAndDecimalPart(num)

    local x = 0
    local y = self.height
    --整数部分
    self.num_txt:setString(int_part.."")
    self.num_txt:setPosition(x, y)
    self.num_txt:setVisible(true)
    x = x + self.num_txt:getContentSize().width
    --小数部分
    if decimal_part > 0 then
        --小数点
        self.dot_sprite:setPosition(x, y)
        self.dot_sprite:setVisible(true)
        x = x + self.dot_sprite:getContentSize().width
        --小数
        self.decimal_txt:setString(decimal_part.."")
        self.decimal_txt:setPosition(x, y)
        self.decimal_txt:setVisible(true)
        x = x + self.decimal_txt:getContentSize().width
    else
        self.dot_sprite:setVisible(false)
        self.decimal_txt:setVisible(false)
    end

    --万/亿
    if unit == Util.UNIT_TYPE_NONE then
        self.unit_txt:setVisible(false)
    else
        if unit == Util.UNIT_TYPE_K then
            self.unit_txt:setTexture(GameRes.playgame_chips_unit_k_altas)
        else
            self.unit_txt:setTexture(GameRes.playgame_chips_unit_m_altas)
        end
        self.unit_txt:setVisible(true)
        self.unit_txt:setPosition(x, y)
        x = x + self.unit_txt:getContentSize().width
    end

    self:setContentSize(x, self.height)
end

function ChipNum:_getIntAndDecimalPart(x)
    local num_str = x .. ""
    local index = string.find(num_str,"%.")
    if index ~= nil and index > 1 and index < string.len(num_str) then
        local int_str = string.sub(num_str, 1, index - 1)
        local decimal_str = string.sub(num_str, index + 1)
        local int_num, decimal_num = 0, 0
        if int_str ~= nil then
            int_num = tonumber(int_str)
        end
        if decimal_str ~= nil then
            decimal_num = tonumber(decimal_str)
        end
        return int_num, decimal_num
    else
        return x, 0
    end
end

return ChipNum