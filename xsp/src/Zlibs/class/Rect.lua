local Zlog = require "Zlibs.class.Log"
local Point = require "Zlibs.class.Point"
local Size = require "Zlibs.class.Size"
-- local Circle = require "Zlibs.class.Circle"
local math = require "Zlibs.class.math"
local type = require "Zlibs.tool.type"
local string = require "Zlibs.class.string"
local obj = {}
local funcValues = {}
local AllRect = {}
local locationMode = -1
local NativeRect = rawget(_G, "Rect")
local api
-- 魔术变量接口_插件用
obj._magicValues = funcValues
-- 默认变量
obj.__tag = "Rect"
obj.name = "default"
obj.x = 0
obj.y = 0
obj.width = 0
obj.height = 0
obj.destroyoyed = false
-- 默认变量结束
-- /////////////////////////////////////////
-- /////////////////////////////////////////
-- 元表设置
function obj:__newindex(k, v)
    rawset(self, k, v)
    Zlog.warn(
        "不建议的操作:设置了[%s]对象中[%s]元素的值为[%s]",
        self.__tag, tostring(k), tostring(v))
end
function obj:__index(k)
    if type(funcValues[k]) == "function" then return funcValues[k](self) end
    return obj[k]
end
function obj:__tostring()
    if self.name == "default" then
        return string.format("%s(%s)", obj.__tag, self.toString)
    elseif locationMode == 1 then
        return string.format("%s \"%s\" \"%d,%d,%d,%d\"", obj.__tag, self.name,
                             self.x, self.y, self.x + self.width - 1,
                             self.y + self.height - 1)
    elseif locationMode == 2 then
        return string.format("%s \"%s\" \"%d,%d,%d,%d\"", obj.__tag, self.name,
                             self.x, self.y, self.width, self.height)
    end
end
-- 并集
function obj:__add(r)
    local r1tl, r1br = self.tl, self.br
    local r2tl, r2br = r.tl, r.br
    return obj:__call(Point(math.min(r1tl.x, r2tl.x), math.min(r1tl.y, r2tl.y)),
                      Size(math.max(r1br.x, r2br.x) - math.min(r1tl.x, r2tl.x),
                           math.max(r1br.y, r2br.y) - math.min(r1tl.y, r2tl.y)))
end
-- 交集
function obj:__sub(r)
    local r1tl, r1br = self.tl, self.br
    local r2tl, r2br = r.tl, r.br
    -- 矩形不相交时返回ZERO
    if not self:isintersect(r) then return obj.ZERO end
    return obj:__call(Point(math.max(r1tl.x, r2tl.x), math.max(r1tl.y, r2tl.y)),
                      Size(math.min(r1br.x, r2br.x) - math.max(r1tl.x, r2tl.x),
                           math.min(r1br.y, r2br.y) - math.max(r1tl.y, r2tl.y)))
end
-- 缩放
function obj:__mul(n)
    local c = self.center
    local s = self.size
    local as = s * n
    return obj:__call(Point(math.round(c.x - as.width / 2),
                            math.round(c.y - as.height / 2)),
                      Size(as.width, as.height))
end
-- 属性叠加
function obj:__div(r)
    return obj:__call(Point(self.x + r.x, self.y + r.y),
                      Size(self.width + r.width, self.height + r.height))
end
-- 相等
function obj:__eq(s)
    return
        self.width == s.width and self.height == s.height and self.x == s.x and
            self.y == s.y
end
function obj:__call(...)
    local o = {x = 0, y = 0, width = 0, height = 0}
    setmetatable(o, obj)
    local t = {...}
    if #t == 1 and type(t[1]) == "string" then
        if AllRect[t[1]] then
            Zlog.warn(
                "点类型出现重名[%s],旧数据将会被新数据覆盖",
                t[1])
            o = AllRect[t[1]]
        end
        rawset(o, "name", t[1])
        AllRect[o.name] = o
        return function(data)
            if type(data) == "string" then
                data = string.split(data, ",")
            end
            -- 这里用table.unpack是否为nil来判断是1.9引擎还是2.0引擎(lua5.3的独有函数)
            if locationMode == 2 then
                o.x = data[1]
                o.y = data[2]
                o.width = data[3]
                o.height = data[4]
            elseif locationMode == 1 then
                o.x = data[1]
                o.y = data[2]
                o.width = data[3] - data[1] + 1
                o.height = data[4] - data[2] + 1
            else
                Zlog.fatal "使用此方法创建Rect前请先设置好坐标类型\r设置代码:  require \"Zlibs.class.Rect\".setLocationMode(1或2)\r1代表采用1.9的坐标,后两位表示右下角点的坐标,即x1,y1,x2,y2\r2代表采用2.0的坐标,后两位表示矩形的大小,即x1,y1,width,height"
            end
            return o
        end
    else
        local x, y, w, h
        if #t == 0 then
            x, y, w, h = 0, 0, 0, 0
        elseif #t == 1 and type(t[1]) == "Rect" then
            x, y, w, h = t[1].x, t[1].y, t[1].width, t[1].height
        elseif #t == 1 and type(t[1]) == "Size" then
            x, y, w, h = 0, 0, t[1].width, t[1].height
        elseif #t == 1 and type(t[1]) == "Point" then
            x, y, w, h = t[1].x, t[1].y, 1, 1
        elseif #t == 2 and type(t[1]) == "Point" and type(t[2]) == "Size" then
            x, y, w, h = t[1].x, t[1].y, t[2].width, t[2].height
        elseif #t == 2 and type(t[1]) == "Point" and type(t[2]) == "Point" then
            x, y, w, h = math.min(t[1].x, t[2].x), math.min(t[1].y, t[2].y),
                         math.abs(t[2].x - t[1].x) + 1,
                         math.abs(t[2].y - t[1].y) + 1
        elseif #t == 4 then
            if locationMode == 2 then
                x, y, w, h = ...
            elseif locationMode == 1 then
                x = t[1]
                y = t[2]
                w = t[3] - t[1] + 1
                h = t[4] - t[2] + 1
            else
                Zlog.fatal "使用此方法创建Rect前请先设置好坐标类型\r设置代码:  require \"Zlibs.class.Rect\".setLocationMode(1或2)\r1代表采用1.9的坐标,后两位表示右下角点的坐标,即x1,y1,x2,y2\r2代表采用2.0的坐标,后两位表示矩形的大小,即x1,y1,width,height"
            end
        else
            Zlog.fatal("[%s]创建时参数传入错误", self.__tag)
        end
        o.x, o.y, o.width, o.height = math.round(x), math.round(y),
                                      math.round(math.max(0, w)),
                                      math.round(math.max(0, h))
        return o
    end
end
-- 元表设置结束
-- /////////////////////////////////////////
-- /////////////////////////////////////////
-- 自动变量
function funcValues.randomPoint(self)
    return Point(math.random(self.x, self.x + math.max(0, self.width - 1)),
                 math.random(self.y, self.y + math.max(0, self.height - 1)))
end
-- 获取左上角
function funcValues.tl(self) return Point(self.x, self.y) end
-- 获取右下角
function funcValues.br(self)
    return Point(self.x + self.width, self.y + self.height)
end
-- 获取大小
function funcValues.size(self) return Size(self.width, self.height) end
-- 获取中心点
function funcValues.center(r) return
    Point(r.x + r.width / 2, r.y + r.height / 2) end

-- 获取外接圆
function funcValues.outCircle(self)
    local Circle = require "Zlibs.class.Circle"
    return Circle(self.center, self.tl)
end
-- 获取内接圆
function funcValues.inCircle(self)
    local Circle = require "Zlibs.class.Circle"
    return Circle(self.center, math.min(self.height, self.width) / 2)
end
function funcValues.toString(self)
    if locationMode == 1 then
        return string.format("%d, %d, %d, %d", self.x, self.y,
                             self.x + self.width - 1, self.y + self.height - 1)
    elseif locationMode == 2 then
        return string.format("%d, %d, %d, %d", self.x, self.y, self.width,
                             self.height)
    else
        Zlog.fatal "使用此方法创建Rect前请先设置好坐标类型\r设置代码:  require \"Zlibs.class.Rect\".setLocationMode(1或2)\r1代表采用1.9的坐标,后两位表示右下角点的坐标,即x1,y1,x2,y2\r2代表采用2.0的坐标,后两位表示矩形的大小,即x1,y1,width,height"
    end
end
function funcValues.toTable(self)
    return {self.x, self.y, self.x + self.width - 1, self.y + self.height - 1}
end
function funcValues.toNativeRect(self)
    if _G.type(NativeRect) ~= "userdata" then
        Zlog.fatal(
            "无法获取全局拓展Rect类,转换失败,这可能是运行引擎版本错误造成的,请尝试更换至2.0或更新版本的引擎再运行,或者开启低版本兼容模式")
    end
    return NativeRect(self.x, self.y, self.width, self.height)
end
-- 自动变量结束
-- /////////////////////////////////////////
-- /////////////////////////////////////////
-- 内部函数

-- 内部函数结束
-- /////////////////////////////////////////
-- /////////////////////////////////////////
-- 成员函数
function obj.get(name) return AllRect[name] end
function obj.destroy(self)
    if type(self) == "string" then self = obj.get(self) end
    AllRect[self.name] = nil
    rawset(self, "destroyoyed", true)
end
-- -- 获取左上角
-- function obj.tl(self) return Point(self.x, self.y) end
-- -- 获取右下角
-- function obj.br(self) return Point(self.x + self.width, self.y + self.height) end
-- -- 获取大小
-- function obj.size(self) return Size(self.width, self.height) end
-- 是否包含点
function obj.contains(self, p)
    if type(p) == "Point" then
        return self.x <= p.x and self.y <= p.y and self.x + self.width - 1 >=
                   p.x and self.y + self.height - 1 >= p.y
    elseif type(p) == "Rect" then
        return self.x <= p.x and self.y <= p.y and self.x + self.width - 1 >=
                   p.x + p.width - 1 and self.y + self.height - 1 >= p.y +
                   p.height - 1
    elseif type(p) == "Circle" then
        local c = p.center
        return c.x - self.x >= p.r and c.y - self.y >= p.r and self.x +
                   self.width - c.x >= p.r and self.y + self.height - c.y >= p.r
    end
end
-- 包含2个矩形的最小矩形
function obj.union(self, r) if type(r) == "Rect" then return self + r end end
-- 取交集
function obj.intersect(self, r) if type(r) == "Rect" then return self - r end end
-- -- 获取中心点
-- function obj.center(r) return Point(r.x + r.width / 2, r.y + r.height / 2) end
-- 矩形是否相交(边与边重合视为相交)
function obj.isintersect(r1, r2)
    return
        r1.x <= r2.x + r2.width - 1 and r1.y <= r2.y + r2.height - 1 and r1.x +
            r1.width - 1 >= r2.x and r1.y + r1.height - 1 >= r2.y
end
-- -- 获取外接圆
-- function obj.outCircle(self)
--     local Circle = require "Zlibs.class.Circle"
--     return Circle(self.center, self.tl)
-- end
-- -- 获取内接圆
-- function obj.inCircle(self)
--     local Circle = require "Zlibs.class.Circle"
--     return Circle(self.center, math.min(self.height, self.width) / 2)
-- end
function obj.setLocationMode(mode) locationMode = mode end
function obj.getLocationMode() return locationMode end
-- function obj.toString(self)
--     if locationMode == 1 then
--         return string.format("%d,%d,%d,%d", self.x, self.y, self.x + self.width,
--                              self.y + self.height)
--     elseif locationMode == 2 then
--         return string.format("%d,%d,%d,%d", self.x, self.y, self.width,
--                              self.height)
--     else
--         Zlog.fatal "使用此方法创建Rect前请先设置好坐标类型\r设置代码:  require \"Zlibs.class.Rect\".setLocationMode(1或2)\r1代表采用1.9的坐标,后两位表示右下角点的坐标,即x1,y1,x2,y2\r2代表采用2.0的坐标,后两位表示矩形的大小,即x1,y1,width,height"
--     end
-- end
-- function obj.toTable(self)
--     return {self.x, self.y, self.x + self.width, self.y + self.height}
-- end
-- function obj.toNativeRect(self)  
--     if _G.type(NativeRect) ~= "userdata" then
--         Zlog.fatal(
--             "无法获取全局拓展Rect类,转换失败,这可能是运行引擎版本错误造成的,请尝试更换至2.0或更新版本的引擎再运行,或者开启低版本兼容模式")
--     end
--     return NativeRect(self.x, self.y, self.width, self.height)
-- end

-- 类初始化函数,因为会循环引用,所以需要单独用函数初始化
function obj._init()
    if not api then api = require "Zlibs.class.api" end
    obj.findSequence = api.findColor
    obj.findMultiSequence = api.findColors
end
-- 成员函数结束
-- /////////////////////////////////////////
-- /////////////////////////////////////////
-- 类初始化
-- rawset(_G,obj.__tag,setmetatable({},obj))
obj.ZERO = obj:__call(Point(0, 0), Size(0, 0))
return setmetatable({}, obj)
-- 类初始化结束
-- /////////////////////////////////////////
-- /////////////////////////////////////////
