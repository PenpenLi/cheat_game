local M = class("Display")




function M:getDeskTips(text)
    local ret        = cc.Node:create()
    local count      = string.len(text)
    local txt        = cc.LabelTTF:create(text, "Arial", 36)
    txt:setName("txt")
    local fsize      = txt:getContentSize()
    fsize.width      = fsize.width+50
    fsize.height     = fsize.height+30
    local scale9     = cc.Scale9Sprite:create(Zjh_Games_res.TIPS_BG) 
    scale9:setCapInsets(cc.rect(16,16,284,39))
    scale9:setContentSize(fsize)
    ret:addChild(scale9)
    scale9:setName("scale9")
    
    txt:setAnchorPoint(cc.p(0,0))
    txt:setPosition(25,15)
    scale9:addChild(txt)

    return ret
end

--正在撮合
function M:getCuoheTips(text)
    local ret        = cc.Node:create()
    local count      = string.len(text)
    local font_count = math.modf(count/2)
    local img        = ccui.ImageView:create(Zjh_Games_res.Loading)
    
    local txt        = cc.LabelTTF:create(text, "Arial", 36)
    txt:setName("txt")
    local fsize      = txt:getContentSize()
    fsize.width      = fsize.width+100
    fsize.height     = fsize.height+150
    local scale9     = cc.Scale9Sprite:create(Zjh_Games_res.TIPS_BG) 
    scale9:setCapInsets(cc.rect(16,16,284,39))
    scale9:setContentSize(fsize)
    ret:addChild(scale9)
    scale9:setName("scale9")
    
    txt:setAnchorPoint(cc.p(0,0))
    txt:setPosition(50,15)
    scale9:addChild(txt)
    scale9:addChild(img)
    local imgsize = img:getContentSize()
    img:setAnchorPoint(cc.p(0.5,0.5))
    img:setPosition((fsize.width-imgsize.width)/2+imgsize.width/2,80+imgsize.height/2)
    local rotato  = cc.RotateTo:create(0.5,180)
    local rotato1 = cc.RotateTo:create(0.5,360)
    local sq      = cc.Sequence:create(rotato,rotato1)
    local re     = cc.RepeatForever:create(sq)
    img:runAction(re)
    return ret

end


ZJH_Display = M.new()