
local HeadImage = class("HeadImage",function (paras) 
    return paras.node
end)

function HeadImage:ctor (paras) 
    self.big_head_image=nil
    self.photo_path=nil
end
function HeadImage:isme()
    loge("isme")
end
function HeadImage:setPhotoPath(photo_path) 
    self.photo_path=photo_path
end
function HeadImage:updatePhoto(photo_path) 
    self.photo_path=photo_path
    if  photo_path and cc.Sprite:create(photo_path):getTexture() then
       -- loge("updatePhoto"..photo_path) 
        if self.big_head_image then
            self.big_head_image.has_loaded=true
            self.big_head_image.photo:setVisible(true)
            self.big_head_image.photo:loadTexture(photo_path)
            local winsize = cc.Director:getInstance():getWinSize()
            local rate=winsize.height/self.big_head_image.photo:getContentSize().height
            self.big_head_image.photo:setScale(rate)
        end 
    end  
end

return HeadImage