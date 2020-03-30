--[[
    平面几何接口
        Author: Lynn
        Date: 2015/02/26
]]
local Geometry = class("Geometry")
function Geometry:ctor()

end

--获取两点间的距离. 返回绝对值.
function Geometry:getPointsDistance(p0, p1)
    local distance = math.sqrt(math.pow((p1.y-p0.y),2)+math.pow((p1.x-p0.x),2))
    return math.abs(distance)
end

return Geometry