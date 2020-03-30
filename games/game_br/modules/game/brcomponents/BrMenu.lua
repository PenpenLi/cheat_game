local BrMenu = class("BrMenu",function (paras)
    return cc.Layer:create()
end)

--菜单项ID
BrMenu.BrMenuITEM_BACK = 1      --返回
BrMenu.BrMenuITEM_HELP = 2      --帮助

--菜单项高度
BrMenu.BrMenuBG_BrMenuITEM_HEIGHT = 141

function BrMenu:ctor(paras)
    self._cb = paras.cb
    self.winSize = cc.Director:getInstance():getWinSize()
    self._BrMenu_id_list = {}
    self:initBrMenuItem()
    --self:initBrMenu()
end

--菜单初始化
function BrMenu:initBrMenu()
    --创建菜单layer
    local BrMenu_width = 470
    local BrMenu_height = self.BrMenuBG_BrMenuITEM_HEIGHT * #self._BrMenu_id_list + 40
    self:setContentSize(BrMenu_width, BrMenu_height)
    
    --菜单背景
    local BrMenu_bg = cc.Scale9Sprite:create(BrRes.gamemenu_common_bg, {60, 60}, {350, 47})
    BrMenu_bg:setContentSize(BrMenu_width, BrMenu_height)
    BrMenu_bg:setAnchorPoint(0, 0)
    BrMenu_bg:setPosition(0, 0)
    self:addChild(BrMenu_bg, 1)

    --添加菜单项
    self:addBrMenuItem(self._BrMenu_id_list[1], 1, 1, BrMenu_height)
    self:addBrMenuItem(self._BrMenu_id_list[2], 7, 2, BrMenu_height)
end

--初始化菜单项
function BrMenu:initBrMenuItem()
    self._BrMenu_id_list[1] = self.BrMenuITEM_BACK
    self._BrMenu_id_list[2] = self.BrMenuITEM_HELP
end

--添加菜单项
function BrMenu:addBrMenuItem(BrMenu_id, imgIndex, index, BrMenu_height)
    local normal_img = string.format(BrRes.gamemenu_item_normal, imgIndex)
    local press_img = string.format(BrRes.gamemenu_item_press, imgIndex, imgIndex)
    local BrMenu_item = ccui.Button:create()
    BrMenu_item:setTouchEnabled(true)
    BrMenu_item:loadTextures(normal_img, press_img, "")
    BrMenu_item:setAnchorPoint(0, 0)
    BrMenu_item:setPosition(cc.p(14, BrMenu_height - 12 - self.BrMenuBG_BrMenuITEM_HEIGHT * index))   
    BrMenu_item:setTag(BrMenu_id)
    self:addChild(BrMenu_item, 2)
    addButtonEvent(BrMenu_item, handler(self, self.itemClick))
end

--菜单项点击
function BrMenu:itemClick(sender)
    local BrMenu_id = sender:getTag()
    if BrMenu_id == self.BrMenuITEM_BACK then   --返回
        qf.event:dispatchEvent(BR_ET.GAME_BR_EXIT_EVENT)
    elseif BrMenu_id == self.BrMenuITEM_HELP then --帮助
        qf.event:dispatchEvent(BR_ET.GAME_BR_SHOW_HELP)
    end
    if self._cb then self._cb() end --调用回调
end

--显示菜单
function BrMenu:show()
    self:setPosition(30, self.winSize.height)
    self:stopAllActions()
    self:setVisible(true)
    local move_y =  - 30 - self:getContentSize().height
    self:runAction( cc.MoveBy:create(0.1, cc.p(0, move_y)))
end

--隐藏菜单
function BrMenu:hide()
    self:setVisible(false)
end


return BrMenu