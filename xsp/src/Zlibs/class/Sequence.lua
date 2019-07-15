local Zlog = require "Zlibs.class.Log"
local Point = require "Zlibs.class.Point"
local Size = require "Zlibs.class.Size"
local Rect = require "Zlibs.class.Rect"
local Circle = require "Zlibs.class.Circle"
local math = require "Zlibs.class.math"
local type = require "Zlibs.tool.type"
local string = require "Zlibs.class.string"
local obj = {}
local funcValues = {}
local AllSequence = {}
local api
-- version 1:1.9引擎 2:2.0引擎
local version = 1
if table.unpack then version = 2 end
-- 魔术变量接口_插件用
obj._magicValues = funcValues
-- 默认变量
obj.__tag = "Sequence"
obj.name = "default"
-- 点组
obj.point = {}
obj.str = ""

obj.destroyed = false
-- 默认变量结束
-- /////////////////////////////////////////
-- /////////////////////////////////////////
-- 内部函数
local function serializePoint(self)
    local points = self.point
    local str = {}
    for i = 1, #points do str[i] = points[i].toString end
    self.str = table.concat(str, ",")
    return self.str
end
-- 内部函数结束
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
    if type(k) == "number" then return self.point[k] end
    return obj[k]
end
function obj:__tostring()
    return string.format("%s \"%s\" \"%s\"", obj.__tag, self.name, self.str)
end
function obj:__call(name)
    if type(name) ~= "string" then
        Zlog.fatal("请使用字符串作为序列的名称")
    end
    local o = setmetatable({name = name, point = {}, str = ""}, obj)
    if AllSequence[name] then
        Zlog.warn(
            "颜色序列类型出现重名[%s],旧数据将会被新数据覆盖",
            name)
        o = AllSequence[name]
    end
    AllSequence[name] = o
    return function(p) return o:add(p) end
end
-- 元表设置结束
-- /////////////////////////////////////////
-- /////////////////////////////////////////
-- 自动变量
function funcValues.toString(self) return self.str end

-- 自动变量结束
-- /////////////////////////////////////////
-- /////////////////////////////////////////
-- 成员函数
function obj.get(name) return AllSequence[name] end
function obj.destroy(self)
    if type(self) == "string" then self = obj.get(self) end
    self:del()
    AllSequence[self.name] = nil
    rawset(self, "destroyed", true)
end
function obj.serialize(self) return serializePoint(self) end
function obj.del(self)
    for k, v in ipairs(self.point) do v:destroy() end
    self.point = {}
    self:serialize()
    -- serializePoint(self)
end
function obj.add(self, p)
    if type(p) == "string" then p = string.split(p, ",") end
    if type(p) ~= "table" then
        Zlog.fatal(
            "参数传入错误,请传入table或string格式的颜色序列")
    end
    for _, v in ipairs(p) do
        local pos = Point(v, 987654)
        table.insert(self.point, pos)
    end
    self:serialize()
    -- serializePoint(self)
    return self
end
function obj.match(self, fuzz)
    for _, v in ipairs(self.point) do
        if not v:match(fuzz or 100) then return false end
    end
    return true
end
if version == 1 then
    obj.findInRect = function(self, rect, degree, hdir, vdir, priority)
        return api.findColor(rect, self, degree, hdir, vdir, priority)
    end
    obj.findMultiInRect = function(self, rect, degree, hdir, vdir, priority,
                                   limit)
        return api.findColors(rect, self, degree, hdir, vdir, priority, limit)
    end
    obj.findInRange = function(self, range, degree, hdir, vdir, priority)
        return api.findColor(Rect(self.point[1] + (-range),
                                  self.point[1] + range), self, degree, hdir,
                             vdir, priority)
    end
    obj.findInRangeTap = function(self, range, degree, hdir, vdir, priority)
        local p = api.findColor(Rect(self.point[1] + (-range),
                                     self.point[1] + range), self, degree, hdir,
                                vdir, priority)
        if p ~= Point.INVALID then p:tap() end
        return p
    end
    obj.findMultiInRange = function(self, range, degree, hdir, vdir, priority,
                                    limit)
        return api.findColors(Rect(self.point[1] + (-range),
                                   self.point[1] + range), self, degree, hdir,
                              vdir, priority, limit)
    end

elseif version == 2 then
    obj.findInRect = function(self, rect, globalFuzz, priority)
        return api.findColor(rect, self, globalFuzz, priority)
    end
    obj.findMultiInRect = function(self, rect, globalFuzz, priority, limit)
        return api.findColors(rect, self, globalFuzz, priority, limit)
    end
    obj.findInRange = function(self, range, globalFuzz, priority)
        return api.findColor(Rect(self.point[1] + (-range),
                                  self.point[1] + range), self, globalFuzz,
                             priority)
    end
    obj.findInRangeTap = function(self, range, globalFuzz, priority)
        local p = api.findColor(Rect(self.point[1] + (-range),
                                     self.point[1] + range), self, globalFuzz,
                                priority)
        if p ~= Point.INVALID then p:tap() end
        return p
    end
    obj.findMultiInRange = function(self, range, globalFuzz, priority, limit)
        return api.findColors(Rect(self.point[1] + (-range),
                                   self.point[1] + range), self, globalFuzz,
                              priority, limit)
    end
end
function obj.tap(self) if self.point[1] then self.point[1]:tap() end end

function obj.matchTap(self, fuzz)
    if self:match(fuzz) then
        if self.point[1] then self.point[1]:tap() end
        return true
    end
    return false
end
-- 类初始化函数,因为会循环引用,所以需要单独用函数初始化
function obj._init() if not api then api = require "Zlibs.class.api" end end
-- 成员函数结束
-- /////////////////////////////////////////
-- /////////////////////////////////////////
-- 类初始化
-- rawset(_G,obj.__tag,setmetatable({},obj))
return setmetatable({}, obj)
-- 类初始化结束
-- /////////////////////////////////////////
-- /////////////////////////////////////////
