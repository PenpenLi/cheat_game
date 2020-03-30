local ChatTxtLayer = class("ChatTxtLayer",function(paras)
    return cc.Layer:create()
end)


local function getCornerTbl(corner)
    local configTbl = {
        {-1, -1},
        {-1, 1},
        {1, 1},
        {1, -1},
    }
    return configTbl[corner]
end


function ChatTxtLayer:createChatTxtNode()
    local imgTextrue = "ui/chat2/chat_say_model.png"
    node = cc.Node:create()
    node:setLocalZOrder(3)
    node:setName(nodename)
    node:setPosition(cc.p(0, 0))
    local img = ccui.ImageView:create()
    img:loadTexture(imgTextrue)
    img:setScale9Enabled(true)
    img:setCapInsets(cc.rect(72, 10, 350, 6))
    img:setName("img")
    img:setAnchorPoint(cc.p(0,0))
    node:addChild(img)
    local txtColor = cc.c3b(63, 22, 5)
    local text = ccui.Text:create("", GameRes.font1, 36)
    text:setColor(txtColor)
    node:addChild(text)
    text:setName("msg")
    return node
end


function ChatTxtLayer:ctor(paras)
    self.parent_view = paras.view
end 


function ChatTxtLayer:refreshNotiMsg(root, paras)
    local corner = paras.corner or GameConstants.CORNER.LEFT_DOWN
    local chatlayer = paras.chatlayer
    local chatname = paras.chatname
    local tbl = getCornerTbl(corner)
    local x, y = tbl[1], tbl[2]
    --得到聊天的位置
    local getRealPosition = function ()
        local position = paras.position
        if chatlayer ~= nil and chatname then
            position = Util:convertALocalPosToBLocalPos(root, position, chatlayer)
        end
        return position
    end
    local nodename = "notiNode"
    local realPosition  = getRealPosition()
    if chatlayer ~= nil and chatname ~= nil then
        root = chatlayer
        nodename = chatname
    end

    local chatnode = root:getChildByName(nodename)
    if chatnode ~= nil then
        chatnode:removeFromParent()
    end
    -- chatnode:removeFromParent()
    -- if chatnode == nil then
    chatnode = self:createChatTxtNode()
    root:addChild(chatnode)
    chatnode:setName(nodename)
    -- end
    
    chatnode:setPosition(realPosition)
    
    local text = Util:getChildEx(chatnode, "msg")
    local img = Util:getChildEx(chatnode, "img")
    img:setScaleX(x)
    img:setScaleY(y)
    text:setString(paras.msg)
    local tsize = text:getContentSize()
    local imgSize = cc.size(tsize.width + 73, 99)
    img:setContentSize(imgSize)
    if y < 0 then
        text:setPosition(cc.p((imgSize.width/2+2)*x, (imgSize.height/2 + 10)*y))
    else
        text:setPosition(cc.p((imgSize.width/2+2)*x, (imgSize.height/2+15)*y))
    end
    chatnode:stopAllActions()
    chatnode:setOpacity(255)
    chatnode:setVisible(true)
    return chatnode
end


function ChatTxtLayer:playShowChatMsg(sender, userbg, paras)
    local corner =  paras.corner or GameConstants.CORNER.LEFT_DOWN
    local offset = paras.offset or {x = -47, y = -21}
    local tbl = getCornerTbl(corner)
    local x, y = tbl[1], tbl[2]
    local user_size = userbg:getContentSize()
    local position = {x = userbg:getPositionX() + x*(user_size.width/2 + offset.x) , y = userbg:getPositionY() + y*(user_size.height/2 + offset.y)}
    local node = self:refreshNotiMsg(sender, {msg = paras.msg, position = position, corner = corner, chatlayer = self, chatname = paras.chatname})
	local fadeout    = cc.Sequence:create(cc.FadeOut:create(1.0),cc.Hide:create())
	node:runAction(fadeout)
end


return ChatTxtLayer