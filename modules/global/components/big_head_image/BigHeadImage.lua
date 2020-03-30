
local BigHeadImage = class("BigHeadImage",function (paras)
    return cc.LayerColor:create(cc.c4b(0, 0, 0, 255))
end)

function BigHeadImage:ctor (paras) 
    self.src_photo = paras.src_photo
    self.photo_url = paras.url
    self.gui = ccs.GUIReader:getInstance():widgetFromJsonFile(GameRes.galleryPageViewJson)
    
    self:addChild(self.gui)
    self.photo = ccui.Helper:seekWidgetByName(self.gui,"photo")
    if FULLSCREENADAPTIVE then
        self.gui:setPositionX((cc.Director:getInstance():getWinSize().width-1920)/2)
    end
    self.src_photo.big_head_image=self
    Util:registerKeyReleased({self = self,cb = function ()
      self:close()
    end}) 
    addButtonEvent(self.gui,function ( sender )
        self:close()
    end)
    if paras.url and paras.url ~= "" then
        --url可能不是http，所以判断下是不是本地路径
        if string.starts(paras.url, "http") or not io.exists(paras.url) then
            self.photo:setVisible(false)
            self:showLoadAnimation()
            qf.downloader:execute(paras.url, 10,
                function(path)
                    if tolua.isnull(self) == false then
                        self:showPhoto(path)
                    end
                end,
                function( ... )
                    
                end,
                function( ... )
                    
                end
            )
        else
            self:showPhoto(paras.url)
        end
    else
        self:showPhoto(self.src_photo.photo_path)
    end
end

function BigHeadImage:delayRun(time,cb)
    local action = cc.Sequence:create(
        cc.DelayTime:create(time),
        cc.CallFunc:create(function ( )
            if cb then cb() end
        end)
    )
    self:runAction(action)
end

function BigHeadImage:showLoadAnimation()
    local loadingImage = ccui.ImageView:create(GameRes.global_wait_bg)
    loadingImage:setName("loadingImage")
    loadingImage:setPosition(self:getContentSize().width/2, self:getContentSize().height/2)
    loadingImage:runAction(cc.RepeatForever:create(cc.RotateBy:create(1.5,360)))
    self:addChild(loadingImage)
end

function BigHeadImage:showPhoto(path)
    if path then
        self.photo:loadTexture(path) 
    else
        loge("not photo_path")
    end
    local loadImage = self:getChildByName("loadingImage")
    if loadImage then
        loadImage:stopAllActions()
        loadImage:removeFromParent()
    end
    self.photo:setVisible(true)
    if not self.photo_url then
        local winsize = cc.Director:getInstance():getWinSize() 
        local rate = winsize.height/self.photo:getContentSize().height 
        self.photo:setScale(rate)
    end
end

function BigHeadImage:click ()
    self:close()   
end

function BigHeadImage:close () 
    self.src_photo.big_head_image=nil
    self:removeFromParent(true)   
end
return BigHeadImage
