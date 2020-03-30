require("src.modules.common.theme.Const")             --定义UI主题常量(字号、颜色等)
local Bezier = import(".algorithm.Bezier")
local Geometry = import(".algorithm.Geometry")


CommonAlgorithm = {}
CommonAlgorithm.Bezier = Bezier.new()
CommonAlgorithm.Geometry = Geometry.new()

CommonWidget = {}
CommonWidget.PopupWindow = import(".widget.PopupWindow")
CommonWidget.BloomNode = import(".widget.BloomNode")
CommonWidget.MeteorNode = import(".widget.MeteorNode")
CommonWidget.ShaderSprite = import(".widget.ShaderSprite")
CommonWidget.CButton = import(".widget.CButton")
CommonWidget.DeviceStatus = import(".widget.DeviceStatus")--电池电量和时间
CommonWidget.Shaker = import(".widget.Shaker")
CommonWidget.ComboList = import(".widget.comboList")
CommonWidget.CustomScrollView = import(".widget.CustomScrollView")
CommonWidget.CustomTabViewCell = import(".widget.CustomTabViewCell")
CommonWidget.NetDelayTip = import(".widget.NetDelayTip")

GameConstants = import(".widget.GameConstants").new()