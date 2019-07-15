local Zlog = require "Zlibs.class.Log"
local Point = require "Zlibs.class.Point"
local Size = require "Zlibs.class.Size"
local math = require "Zlibs.class.math"
local type = require "Zlibs.tool.type"
-- local Rect = require "Zlibs.class.Rect"
local obj = {}
local funcValues = {}

-- 魔术变量接口_插件用
obj._magicValues = funcValues
-- 默认变量
obj.__tag = "Circle"
obj.x = -1
obj.y = -1
obj.r = 0
-- 默认变量结束
-- /////////////////////////////////////////
-- /////////////////////////////////////////
-- 元表设置
function obj:__newindex(k, v)
    rawset(self, k, v)
    Zlog.warn(
        "不建议的操作:设置了[%s]对象中[%s]元素的值为[%s]",
        self._tag, tostring(k), tostring(v))
end
function obj:__index(k)
    if type(funcValues[k]) == "function" then return funcValues[k](self) end
    return obj[k]
end
function obj:__tostring()
    return string.format("%s(%s ,%d)", obj.__tag,
                         tostring(Point(self.x, self.y)), self.r)
end
function obj:__add(r) return obj:__call(self.x, self.y, self.r + r) end
function obj:__sub(r) return obj:__call(self.x, self.y, self.r - r) end
function obj:__mul(n) return obj:__call(self.x, self.y, self.r * n) end
function obj:__div(n) return obj:__call(self.x, self.y, self.r / n) end
-- 相等
function obj:__eq(s) return self.r == s.r and self.x == s.x and self.y == s.y end
function obj:__call(...)
    local o = {}
    local t = {...}
    local x, y, r
    if #t == 0 then
        x, y, r = 0, 0, 0
    elseif #t == 1 and type(t[1]) == "Circle" then
        x, y, r = t[1].x, t[1].y, t[1].r
    elseif #t == 2 and type(t[1]) == "Point" and type(t[2]) == "number" then
        x, y, r = t[1].x, t[1].y, t[2]
    elseif #t == 2 and type(t[1]) == "Point" and type(t[2]) == "Point" then
        x, y, r = t[1].x, t[1].y, t[1] * t[2]
    elseif #t == 3 then
        x, y, r = ...
    else
        Zlog.fatal("[%s]创建时参数传入错误", self.__tag)
    end
    o.x, o.y, o.r = math.round(x), math.round(y), math.max(0, r)
    return setmetatable(o, obj)
end
-- 元表设置结束
-- /////////////////////////////////////////
-- /////////////////////////////////////////
-- 自动变量
function funcValues.randomPoint(self)
    local a = math.random(1, 36000) / 100
    local d = math.random(0, self.r * 100) / 100
    return self.center - {a, d}
end
--- obj.center 获取圆心,返回Point类
-- @param self self
function funcValues.center(self) return Point(self.x, self.y) end
--- obj.outRect 获取外切正方形
-- @param self self
function funcValues.outRect(self)
    local Rect = require "Zlibs.class.Rect"
    return Rect(self.center, Size(self.r * 2))
end
--- obj.inRect 获取内切正方形
-- @param self self
function funcValues.inRect(self)
    local Rect = require "Zlibs.class.Rect"
    return Rect(self.center, Size(self.r * 1.14121))
end
-- 自动变量结束
-- /////////////////////////////////////////
-- /////////////////////////////////////////
-- 内部函数

-- 内部函数结束
-- /////////////////////////////////////////
-- /////////////////////////////////////////
-- 成员函数
--- obj.contains 是否包含某个点/范围/圆,需要完全包括才算,接受重合
-- @param self self
-- @param p    Point/Rect/Circle
function obj.contains(self, p)
    if type(p) == "Point" then
        return p * self.center <= self.r
    elseif type(p) == "Rect" then
        local l = self.r * self.r
        local sc = self.center
        return l >= math.abs((sc.x - p.x) * (sc.y - p.y)) and l >=
                   math.abs((sc.x - p.x) * (p.y + p.height - sc.y)) and l >=
                   math.abs((p.x + p.width - sc.x) * (sc.y - p.y)) and l >=
                   math.abs((p.x + p.width - sc.x) * (p.y + p.height - sc.y))
    elseif type(p) == "Circle" then
        return self.r >= (self.center * p.center + p.r)
    end
end
-- 成员函数结束
-- /////////////////////////////////////////
-- /////////////////////////////////////////
-- 类初始化
-- rawset(_G,obj.__tag,setmetatable({},obj))
obj.ZERO = obj:__call(0, 0, 0)
return setmetatable({}, obj)
-- 类初始化结束
-- /////////////////////////////////////////
-- /////////////////////////////////////////
