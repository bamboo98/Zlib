local Zlog = require "Zlibs.class.Log"
local math = require "Zlibs.class.math"
local Color = require "Zlibs.class.Color"
local type = require "Zlibs.tool.type"
local string = require "Zlibs.class.string"
local Finger
local api
local obj = {}
local funcValues = {}
local AllPoint = {}
-- 魔术变量接口_插件用
obj._magicValues = funcValues
-- 默认变量
obj.__tag = "Point"
obj.x = -1
obj.y = -1

obj.name = "default"
obj.color = Color.INVALID
obj.offset = Color.INVALID
obj.fuzz = false
obj.destroyed = false
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
        if self.color == Color.INVALID then
            return string.format("%s(%d ,%d)", obj.__tag, self.x, self.y)
        else
            return string.format("%s '%d|%d%s%s%s'", obj.__tag, self.x, self.y,
                                 self.color ~= Color.INVALID and "|" ..
                                     self.color.toString or "",
                                 self.color ~= Color.INVALID and self.offset ~=
                                     Color.INVALID and "-" ..
                                     self.offset.toString or "",
                                 self.fuzz and "|" .. self.fuzz or "")
        end
    else
        return string.format("%s \"%s\" \"%d|%d%s%s%s\"", obj.__tag, self.name,
                             self.x, self.y,
                             self.color ~= Color.INVALID and "|" ..
                                 self.color.toString or "",
                             self.color ~= Color.INVALID and self.offset ~=
                                 Color.INVALID and "-" .. self.offset.toString or
                                 "", self.fuzz and "|" .. self.fuzz or "")
    end
end
function obj:__add(p) return obj:__call(self.x + p.x, self.y + p.y) end
-- 极坐标移动 point-{angle,distance}
function obj:__sub(d)
    return obj:__call(self.x + d[2] * math.cos(d[1]),
                      self.y + d[2] * math.sin(d[1]))
end
-- 求两点距离 point*point
function obj:__mul(p)
    local x, y = self.x - p.x, self.y - p.y
    return math.sqrt(x * x + y * y)
end
-- 求两点方向
function obj:__div(p) return math.atan(p.y - self.y, p.x - self.x) end
-- 取反
function obj:__unm() return obj:__call(-self.x, -self.y) end
-- 相等
function obj:__eq(p) return self.x == p.x and self.y == p.y end

function obj:__call(...)
    local o = {
        x = -1,
        y = -1,

        color = Color.INVALID,
        offset = Color.INVALID,
        fuzz = 100
    }
    setmetatable(o, obj)
    local t = {...}
    if #t == 1 and type(t[1]) == "string" then
        if AllPoint[t[1]] then
            Zlog.warn(
                "点类型出现重名[%s],旧数据将会被新数据覆盖",
                t[1])
            o = AllPoint[t[1]]
        end
        rawset(o, "name", t[1])
        AllPoint[o.name] = o
        return function(data)
            if type(data) == "string" then
                data = string.split(data, "|")
                o.x = tonumber(data[1] or -1)
                o.y = tonumber(data[2] or -1)
                local c = string.split(data[3] or "", "-")
                o.color = c[1] ~= "" and Color(tonumber(c[1])) or Color.INVALID
                o.offset = c[2] and Color(tonumber(c[2])) or Color.INVALID
                o.fuzz = data[4] and tonumber(data[4])
            elseif type(data) == "table" then
                o.x = data.pos and data.pos.x or tonumber(data[1]) or
                          tonumber(data.x) or -1
                o.y = data.pos and data.pos.y or tonumber(data[2]) or
                          tonumber(data.y) or -1
                o.color = data.color and Color(tonumber(data.color)) or
                              Color.INVALID
                o.offset = data.offset and Color(tonumber(data.offset)) or
                               Color.INVALID
                o.fuzz = data.fuzz and tonumber(data.fuzz)
            end
            return o
        end
    else
        local x, y
        if #t == 0 then
            x, y = 0, 0
        elseif #t == 1 and type(t[1]) == "Point" then
            x, y = t[1].x, t[1].y
            -- o.name = t[1].name
            o.color = t[1].color
            o.offset = t[1].offset
            o.fuzz = t[1].fuzz
        elseif #t == 1 and type(t[1]) == "Rect" then
            return t[1].center
        elseif #t == 2 and type(t[1]) == "string" and t[2] == 987654 then
            local data = string.split(t[1], "|")
            x = tonumber(data[1] or -1)
            y = tonumber(data[2] or -1)
            local c = string.split(data[3] or "", "-")
            o.color = c[1] ~= "" and Color(tonumber(c[1])) or Color.INVALID
            o.offset = c[2] and Color(tonumber(c[2])) or Color.INVALID
            o.fuzz = data[4] and tonumber(data[4])
        elseif #t == 2 and type(t[1]) == "table" and t[2] == 987654 then
            local data = t[1]
            x =
                data.pos and data.pos.x or tonumber(data[1]) or tonumber(data.x) or
                    -1
            y =
                data.pos and data.pos.y or tonumber(data[2]) or tonumber(data.y) or
                    -1
            o.color = data.color and Color(tonumber(data.color)) or
                          Color.INVALID
            o.offset = data.offset and Color(tonumber(data.offset)) or
                           Color.INVALID
            o.fuzz = data.fuzz and tonumber(data.fuzz)
        elseif #t == 2 then
            x, y = math.round(t[1]), math.round(t[2])
        else
            Zlog.fatal("[%s]创建时参数传入错误", self.__tag)
        end
        o.x, o.y = math.round(x), math.round(y)
        return o
    end
end
-- 元表设置结束
-- /////////////////////////////////////////
-- /////////////////////////////////////////
-- 自动变量
function funcValues.randomPoint(self) return obj:__call(self.x, self.y) end
function funcValues.pos(self) return obj:__call(self.x, self.y) end
function funcValues.center(self) return obj:__call(self.x, self.y) end
function funcValues.toString(self)
    if self.color == Color.INVALID then
        return string.format("%d,%d", self.x, self.y)
    else
        return string.format("%d|%d%s%s%s", self.x, self.y, self.color ~=
                                 Color.INVALID and "|" .. self.color.toString or
                                 "",
                             self.color ~= Color.INVALID and self.offset ~=
                                 Color.INVALID and "-" .. self.offset.toString or
                                 "", self.fuzz and "|" .. self.fuzz or "")
    end
end
function funcValues.getColor(self) return Color(api.getColorRGB(self.x, self.y)) end
-- 自动变量结束
-- /////////////////////////////////////////
-- /////////////////////////////////////////
-- 内部函数

-- 内部函数结束
-- /////////////////////////////////////////
-- /////////////////////////////////////////
-- 成员函数
function obj.contains(self, p)
    if type(p) ~= "Point" then return false end
    return self == p.center
end
function obj.get(name) return AllPoint[name] end
function obj.destroy(self)
    if type(self) == "string" then self = obj.get(self) end
    AllPoint[self.name] = nil
    rawset(self, "destroyoyed", true)
end
function obj.match(self, fuzz)
    if self.color == Color.INVALID then return false end
    local r, g, b = api.getColorRGB(self.x, self.y)
    if self.offset == Color.INVALID then
        return self.color:matchRGB(r, g, b, fuzz or self.fuzz)
    else
        return self.color:matchRGBByOffset(r, g, b, self.offset)
    end
end

function obj.tap(self) Finger.tap(self) end

function obj.matchTap(self, fuzz)
    if self:match(fuzz) then
        Finger.tap(self)
        return true
    end
    return false
end

-- 类初始化函数,因为会循环引用,所以需要单独用函数初始化
function obj._init()
    if not api then api = require "Zlibs.class.api" end
    if not Finger then Finger = require "Zlibs.class.Finger" end
end
-- 成员函数结束
-- /////////////////////////////////////////
-- /////////////////////////////////////////
-- 类初始化
-- rawset(_G,obj.__tag,setmetatable({},obj))
obj.INVALID = obj:__call(-1, -1)
obj.ZERO = obj:__call(0, 0)
return setmetatable({}, obj)
-- 类初始化结束
-- /////////////////////////////////////////
-- /////////////////////////////////////////
