local BrnnMenu = class("BrnnMenu",function (paras)
    return cc.Layer:create()
end)

--菜单项ID
BrnnMenu.BrnnMenuITEM_BACK = 1      --返回
BrnnMenu.BrnnMenuITEM_HELP = 2      --帮助

--菜单项高度
BrnnMenu.BrnnMenuBG_BrnnMenuITEM_HEIGHT = 141

function BrnnMenu:ctor(paras)
    self._cb = paras.cb
    self.winSize = cc.Director:getInstance():getWinSize()
    self._BrnnMenu_id_list = {}
    self:initBrnnMenuItem()
    --self:initBrnnMenu()
end

--菜单初始化
function BrnnMenu:initBrnnMenu()
    --创建菜单layer
    local BrnnMenu_width = 470
    local BrnnMenu_height = self.BrnnMenuBG_BrnnMenuITEM_HEIGHT * #self._BrnnMenu_id_list + 40
    self:setContentSize(BrnnMenu_width, BrnnMenu_height)
    
    --菜单背景
    local BrnnMenu_bg = cc.Scale9Sprite:create(BrniuniuRes.gamemenu_common_bg, {60, 60}, {350, 47})
    BrnnMenu_bg:setContentSize(BrnnMenu_width, BrnnMenu_height)
    BrnnMenu_bg:setAnchorPoint(0, 0)
    BrnnMenu_bg:setPosition(0, 0)
    self:addChild(BrnnMenu_bg, 1)

    --添加菜单项
    self:addBrnnMenuItem(self._BrnnMenu_id_list[1], 1, 1, BrnnMenu_height)
    self:addBrnnMenuItem(self._BrnnMenu_id_list[2], 7, 2, BrnnMenu_height)
end

--初始化菜单项
function BrnnMenu:initBrnnMenuItem()
    self._BrnnMenu_id_list[1] = self.BrnnMenuITEM_BACK
    self._BrnnMenu_id_list[2] = self.BrnnMenuITEM_HELP
end

--添加菜单项
function BrnnMenu:addBrnnMenuItem(BrnnMenu_id, imgIndex, index, BrnnMenu_height)
    local normal_img = string.format(BrniuniuRes.gamemenu_item_normal, imgIndex)
    local press_img = string.format(BrniuniuRes.gamemenu_item_press, imgIndex, imgIndex)
    local BrnnMenu_item = ccui.Button:create()
    BrnnMenu_item:setTouchEnabled(true)
    BrnnMenu_item:loadTextures(normal_img, press_img, "")
    BrnnMenu_item:setAnchorPoint(0, 0)
    BrnnMenu_item:setPosition(cc.p(14, BrnnMenu_height - 12 - self.BrnnMenuBG_BrnnMenuITEM_HEIGHT * index))   
    BrnnMenu_item:setTag(BrnnMenu_id)
    self:addChild(BrnnMenu_item, 2)
    addButtonEvent(BrnnMenu_item, handler(self, self.itemClick))
end

--菜单项点击
function BrnnMenu:itemClick(sender)
    local BrnnMenu_id = sender:getTag()
    if BrnnMenu_id == self.BrnnMenuITEM_BACK then   --返回
        qf.event:dispatchEvent(BRNN_ET.GAME_BRNN_EXIT_EVENT)
    elseif BrnnMenu_id == self.BrnnMenuITEM_HELP then --帮助
        
    end
    if self._cb then self._cb() end --调用回调
end

--显示菜单
function BrnnMenu:show()
    self:setPosition(30, self.winSize.height)
    self:stopAllActions()
    self:setVisible(true)
    local move_y =  - 30 - self:getContentSize().height
    self:runAction( cc.MoveBy:create(0.1, cc.p(0, move_y)))
end

--隐藏菜单
function BrnnMenu:hide()
    self:setVisible(false)
end


return BrnnMenu