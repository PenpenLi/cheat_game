--[[
    支持多重滤镜的精灵
        Author: Lynn
        Date: 2015/03/01
    使用示例:
        见文档 ShaderSpriteTest.lua
    必要参数:
        path: 图片路径
    可选参数, 用于定义着色器:
        -----------------------
        描边shader:
        outline
            {
                size:  描边大小
                color: 描边颜色
                alpha: 描边透明度
            }
        -------------------
        高斯模糊shader: (暂不支持, TODO)
        blur
            {
                radius: 模糊半径
                sample: 采样率
            }
        -------------------
        灰度shader: (暂不支持, TODO)
        grey
            {
                enabled: 是否开启
            }
        -------------------
        高亮shader:
        bright
            {
                intensity: 亮度 (0 - 1)
            }
        -------------------
    备注: 
        *需要注意: 着色器越多, 滤波占用时间越长, 也就是效率越低
        *Cocos2dx 3.2版本的Node不支持多重滤镜, 本控件采用的方法是先使用一种滤镜渲染到RenderTexture上, 然后继续着色, 渲染到RenderTexture ...
        *考虑到着色效果和应用范围, 默认的顺序是: 描边-->模糊-->灰阶-->高亮, 高亮必须放在最后, 如果要扩展其他滤镜要注意这点
]]

local ShaderSprite = class("ShaderSprite",function (paras)
    return cc.Sprite:create(paras.path)
end)

ShaderSprite.DEBUG = false
ShaderSprite.TAG = "ShaderSprite"
ShaderSprite.VERT_DEFAULT_PATH = "opengl/default.vsh"
ShaderSprite.OUTLINE_FRAGMENT_NAME = "opengl/outline.fsh"
ShaderSprite.OUTLINE_PROGRAM_CACHE_NAME = "QF_SHADERS_OUTLINE"
ShaderSprite.BRIGHT_FRAGMENT_NAME = "opengl/bloom.fsh"
ShaderSprite.BRIGHT_PROGRAM_CACHE_NAME = "QF_SHADERS_BRIGHT"

ShaderSprite.COLOR_WHITE = cc.c3b(255, 255, 255)

function ShaderSprite:ctor(paras)
    if paras ~= nil and (paras.outline ~= nil or paras.bright ~= nil) then
        self:init(paras)
    else
        self:_log("ShaderSprite.ctor() has wrong number of arguments. ")
    end
end

------------------------------------------------
--  public interface
------------------------------------------------
--设置亮度(只有在定义了高亮shader时有效)
function ShaderSprite:setBright(intensity)
    if self.shaders == nil or #self.shaders == 0 then return end
    local last_shader = self.shaders[#self.shaders]
    if last_shader.name == "bright" then
        self:getGLProgramState():setUniformFloat("intensity", intensity);
        self.shaders[#self.shaders].intensity = intensity
    end
end
--获取亮度(只有在定义了高亮shader时有效)
function ShaderSprite:getBright()
    if self.shaders == nil or #self.shaders == 0 then return -1 end
    local last_shader = self.shaders[#self.shaders]
    if last_shader.name == "bright" and last_shader.intensity ~= nil then
        return last_shader.intensity
    else
        return -1
    end
end

------------------------------------------------
--  private function
------------------------------------------------
function ShaderSprite:init(paras)
    self:_log("ShaderSprite init.", self.shaders)
    self.pixelSize = self:getTexture():getContentSizeInPixels()
    self.contentSize = self:getTexture():getContentSize()
    self.winPixelSize = cc.Director:getInstance():getWinSizeInPixels()
    self.winContentSize = cc.Director:getInstance():getWinSize()

    self.shaders = {}
    --创建 outline shader
    if paras.outline ~= nil then
        self:_log("ShaderSprite with outline")
        if paras.outline.size == nil or paras.outline.color == nil or paras.outline.alpha == nil then
            self:_log("ShaderSprite.new() has wrong number of arguments. Outline shader create failed.")
        else
            local outline_size = paras.outline.size     --描边宽度
            local outline_color = paras.outline.color   --描边颜色
            local texture_size = self.contentSize     --纹理大小
            local foreg_color = ShaderSprite.COLOR_WHITE --前景色 
            local alpha = paras.outline.alpha   --描边透明度
            local index = #self.shaders + 1
            self.shaders[index] = {}
            self.shaders[index].name = "outline"
            self.shaders[index].glprogramState = self:getOutlineGLProgam(outline_size, outline_color, texture_size, foreg_color, alpha)
        end
    end

    --创建 bright shader
    if paras.bright ~= nil then
        self:_log("ShaderSprite with bright")
        if paras.bright.intensity == nil then
            self:_log("ShaderSprite.new() has wrong number of arguments. Bright shader create failed.")
        else
            intensity = (paras.bright.intensity > 1) and 1 or paras.bright.intensity
            intensity = (intensity < 0) and 0 or intensity
            local index = #self.shaders + 1
            self.shaders[index] = {}
            self.shaders[index].name = "bright"
            self.shaders[index].intensity = intensity
            self.shaders[index].glprogramState = self:getBrightGLProgam(size, intensity)
        end
    end
    self:_log("Shader created", self.shaders)

    --开始着色
    self:startShader()
end

 --开始着色
function ShaderSprite:startShader()
    if self.shaders == nil or #self.shaders == 0 then return end
    local last_shader = self.shaders[#self.shaders]
    local num = (last_shader.name == "bright") and (#self.shaders - 1) or #self.shaders
    local texture = self:getTexture()
    local renderTexture = nil
    for i = 1, num do
        --着色一次
        local state = self.shaders[i]
        self:_log("startShader name="..state.name)
        local sprite = cc.Sprite:createWithTexture(texture) --创建临时精灵用于着色
        sprite:setFlippedY(true)    --防止渲染到RenderTexture时出现上下倒置
        sprite:setAnchorPoint(0, 0) --与RenderTexture锚点一致. RenderTexture锚点不可设置.
        sprite:setPosition(0, 0)    --必须设置到左下角，这是3.2版本RenderTexture的一个bug
        sprite:setGLProgramState(state.glprogramState)  --着色

        if renderTexture ~= nil then
            renderTexture:release()
        end
        renderTexture = cc.RenderTexture:create(self.contentSize.width, self.contentSize.height)
        renderTexture:retain()
        renderTexture:setKeepMatrix(true);
        renderTexture:setVirtualViewport(cc.p(0, 0), cc.rect(0, 0, self.winContentSize.width, self.winContentSize.height),
                cc.rect(0, 0, self.winPixelSize.width, self.winPixelSize.height))
        renderTexture:begin()
        sprite:visit()
        renderTexture:endToLua()
        texture = renderTexture:getSprite():getTexture()    --保留texture,用于下次渲染
    end
    if texture ~= nil then
        self:setTexture(texture)
    end
    if renderTexture ~= nil then
        renderTexture:release()
    end
    if last_shader.name == "bright" then
        self:_log("set bright shader")
        self:setGLProgramState(last_shader.glprogramState)  --最终self使用的是bright glProgramState
    end
end

--创建 bright shader
function ShaderSprite:getBrightGLProgam(texture_size, intensity)
    local glprogram = cc.GLProgramCache:getInstance():getGLProgram(ShaderSprite.BRIGHT_PROGRAM_CACHE_NAME)
    if glprogram == nil then
        local vertSource = cc.FileUtils:getInstance():getStringFromFile(ShaderSprite.VERT_DEFAULT_PATH)
        local fragSource = cc.FileUtils:getInstance():getStringFromFile(ShaderSprite.BRIGHT_FRAGMENT_NAME)
        glprogram = cc.GLProgram:createWithByteArrays(vertSource, fragSource)
        cc.GLProgramCache:getInstance():addGLProgram(glprogram, ShaderSprite.BRIGHT_PROGRAM_CACHE_NAME)
    end
    
    local glprogramState = cc.GLProgramState:create(glprogram)
    glprogramState:setUniformFloat("intensity", intensity)
    return glprogramState
end

--创建 outline shader
function ShaderSprite:getOutlineGLProgam(outline_size, outline_color, texture_size, foreground_color, alpha)
    local glprogram = cc.GLProgramCache:getInstance():getGLProgram(ShaderSprite.OUTLINE_PROGRAM_CACHE_NAME)
    if glprogram == nil then
        local vertSource = cc.FileUtils:getInstance():getStringFromFile(ShaderSprite.VERT_DEFAULT_PATH)
        local fragSource = cc.FileUtils:getInstance():getStringFromFile(ShaderSprite.OUTLINE_FRAGMENT_NAME)
        glprogram = cc.GLProgram:createWithByteArrays(vertSource, fragSource)
        cc.GLProgramCache:getInstance():addGLProgram(glprogram, ShaderSprite.OUTLINE_PROGRAM_CACHE_NAME)
    end
    
    local glprogramState = cc.GLProgramState:create(glprogram)
    glprogramState:setUniformFloat("outlineSize", outline_size)
    glprogramState:setUniformVec3("outlineColor", cc.Vertex3F(outline_color.r/255, outline_color.g/255, outline_color.b/255))
    glprogramState:setUniformVec2("textureSize",  cc.vertex2F(texture_size.width, texture_size.height))
    glprogramState:setUniformVec3("foregroundColor", cc.Vertex3F(foreground_color.r/255, foreground_color.g/255, foreground_color.b/255))
    glprogramState:setUniformFloat("outlineAlpha", alpha)

    return glprogramState
end

function ShaderSprite:_log(str, table)
    if ShaderSprite.DEBUG==true then 
        logd(str, self.TAG)
        if table ~= nil then dump(table) end
    end
end

return ShaderSprite