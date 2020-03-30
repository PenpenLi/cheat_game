--[[
    贝塞尔曲线计算接口
        Author: Lynn
        Date: 2015/02/25
    包含以下算法:
        获取二次贝塞尔曲线上的点: getBezier2Points
        获取三次贝塞尔曲线上的点: getBezier3Points
        获取三次贝塞尔曲线控制点: getBezierControlPoints
    使用示例:
        local point = CommonAlgorithm.Bezier:getBezier3Points(cc.p(0, 0), cc.p(-10, 60), cc.p(60, 60), cc.p(100, 0), t)
        local p1, p2 = CommonAlgorithm.Bezier:getBezierControlPoints(cc.p(0, 0), cc.p(100, 0), 0.3, cc.p(9.63, 37.8), 0.7, cc.p(58.87, 37.8))
]]
local Bezier = class("Bezier")

Bezier.TAG = "Bezier"
Bezier.DEBUG = false
function Bezier:ctor()

end

--获取二次贝塞尔曲线上点
function Bezier:getBezier2Points(p0, p1, p2, t)
    local x = (1 - t) * (1 - t) * p0.x + 2 * t * (1 - t) * p1.x + t * p2.x;
    local y = (1 - t) * (1 - t) * p0.y + 2 * t * (1 - t) * p1.y + t * p2.y;
    return cc.p(x, y)
end

--获取三次贝塞尔曲线上的点. p0, 起点; p3, 终点; p1, p2, 控制点
function Bezier:getBezier3Points(p0, p1, p2, p3, t)
    local square = t * t;
    local cube = t * square;
    local square2 = (1 - t) * (1 - t);
    local cube2 = square2 * (1 - t);
    
    local x = p0.x * cube2 + 3 * p1.x * t * square2 + 3 * p2.x * square * (1 - t) + p3.x * cube;
    local y = p0.y * cube2 + 3 * p1.y * t * square2 + 3 * p2.y * square * (1 - t) + p3.y * cube;
    return cc.p(x, y)
end

--根据起点、终点和2个采样点，获取三次贝塞尔曲线控制点
function Bezier:getBezierControlPoints(p0, p3, t1, sp1, t2, sp2)
    if Bezier.DEBUG then
        logd("("..p0.x..", "..p0.y.."), ("..p3.x..", "..p3.y.."), "..t1..", ("..sp1.x..", "..sp1.y.."), "..t2.."("..sp2.x..", "..sp2.y..")", self.TAG)
    end
    local a1, b1, c1x, c1y, a2, b2, c2x, c2y;
    --[[
        三次贝塞尔曲线公式:
            B(t) = p0*(1-t)^3  +  3*p1*t*(1-t)^2  +  3*p2*t^2*(1-t)  +  p3*t^3
            其中B用来描述曲线上的点, p0为起始点, p1和p2是控制点, p3是结束点, t为采样因子, t的取值在0~1之间.
        公式变形:
            (3*t*(1-t)^2) * p1  +  (3*t^2*(1-t)) * p2 = B(t) - p0*(1-t)^3 - p3*t^3
        公式简化:
            a = 3*t*(1-t)^2
            b = 3*t^2*(1-t)
            c = B(t)-p0*(1-t)^3-p3*t^3
     
            p1 * a + p2 * b = c
     ]]
    
    -- 第1组采样点
    a1 = 3 * t1 * (1 - t1) * (1 - t1);
    b1 = 3 * (t1 * t1) * (1 - t1);
    c1x = sp1.x - p0.x * (1 - t1) * (1 - t1) * (1 - t1) - p3.x * t1 * t1 * t1;
    c1y = sp1.y - p0.y * (1 - t1) * (1 - t1) * (1 - t1) - p3.y * t1 * t1 * t1;
    -- 第2组采样点
    a2 = 3 * t2 * (1 - t2) * (1 - t2);
    b2 = 3 * (t2 * t2) * (1 - t2);
    c2x = sp2.x - p0.x * (1 - t2) * (1 - t2) * (1 - t2) - p3.x * t2 * t2 * t2;
    c2y = sp2.y - p0.y * (1 - t2) * (1 - t2) * (1 - t2) - p3.y * t2 * t2 * t2;
    
    --[[
        此时得到二元一次方程组:
            p1 * a1 + p2 * b1 = c1
            p1 * a2 + p2 * b2 = c2
        消元法求解方程:
            p2 = (c1 - p1 * a1) / b1
            p1 * a2 + (c1 - p1 * a1) / b1 * b2 = c2
            p1 * a2 * b1 + c1 * b2 - p1 * a1 * b2 = c2 * b1
            p1 * a2 * b1 - p1 * a1 * b2 = c2 * b1 - c1 * b2
            p1 * (a2 * b1 - a1 * b2) = c2 * b1 - c1 * b2
            p1 = (c2 * b1 - c1 * b2) / (a2 * b1 - a1 * b2)
     ]]
    local p1x = (c2x * b1 - c1x * b2) / (a2 * b1 - a1 * b2);
    local p1y = (c2y * b1 - c1y * b2) / (a2 * b1 - a1 * b2);
    local p2x = (c1x - p1x * a1) / b1;
    local p2y = (c1y - p1y * a1) / b1;

    return cc.p(p1x, p1y), cc.p(p2x, p2y)
end

--[[
    计算贝塞尔曲线弧长. 
    p0, 起点; p3, 终点; p1, p2, 控制点; accuracy是计算精度, ∈[3,100], 精度越高计算结果越准确, 相应的计算量也会增大
    **这里没有对贝塞尔曲线做弧线积分, 仅通过将弧线上的采样点相连, 计算出模糊长度. 结果不精确.
]]
function Bezier:getArcLength(p0, p1, p2, p3, accuracy)
    local length = 0
    local step = 1 / accuracy
    local start_point = p0
    for i = 1, accuracy do
        local end_point = (i == accuracy) and p3 or self:getBezier3Points(p0, p1, p2, p3, step * i)
        length = length + CommonAlgorithm.Geometry:getPointsDistance(start_point, end_point)
        start_point = end_point
    end
    return length
end

return Bezier