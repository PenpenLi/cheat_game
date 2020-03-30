--[[
    Layer管理器
    1.将一些主要的Layer预加载，添加到主Scene中
    2.主要负责预加载创建
]]

LayerManager = {}
LayerManager.TAG = "layerManager"

local defaultZorder = 0

function LayerManager:init(parameters)
	self._root = parameters

    self.layerConfig = {
        {"PreloadLayer" , defaultZorder},
        {"GameLayer" , defaultZorder},
        {"MainLayer" , defaultZorder},
        {"RewardLayer" , defaultZorder},
        {"LobbyLayer" , defaultZorder},
        {"MTTLobbyLayer" , defaultZorder},
        {"ChoseHallLayer" , defaultZorder},
        {"SNG_LobbyLayer" , defaultZorder},
        {"CustomizeLayer" , defaultZorder},
        {"Activity" , defaultZorder},
        {"Setting" , defaultZorder},
        {"Shop" , defaultZorder},
        {"BroadCastLayer" , 12},
        {"PopupLayer" , 13},    
        {"LoginLayer" , 10},
        {"Global" , 14}
    }
	
    self:initLayers()
	self:registerLayerEvent()
	logd("src.core.layerManager init success !",self.TAG)
end

function LayerManager:initLayers()
    for _,config in ipairs(self.layerConfig) do
        self:addLayer(config[1], config[2])
    end
end

function LayerManager:addLayer(name, zorder)
    local layer = cc.Layer:create()
    if zorder > 0 then
        self._root:addChild(layer, zorder)
    else
        self._root:addChild(layer)
    end
    self[name] = layer
end

function LayerManager:registerLayerEvent()
    -- TODO
end

