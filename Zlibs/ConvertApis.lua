local ConstPoints = {__tag = "Point"}
Point = {}
local ConstSizes = {__tag = "Size"}
Size = {}
local ConstRects = {__tag = "Rect"}
Rect = {}
local ConstColor3Bs = {__tag = "Color3B"}
Color3B = {}
local ConstColor3Fs = {__tag = "Color3F"}
Color3F = {}
local Constxmods = {__tag = "xmod"}
xmod = {}
local ConstUserInfos = {__tag = "UserInfo"}
local UserInfo = {}
local ConstScriptInfos = {__tag = "ScriptInfo"}
local ScriptInfo = {}
local Constscripts = {__tag = "script"}
script = {}
local Constscreens = {__tag = "screen"}
screen = {}
local Consttouchs = {__tag = "touch"}
touch = {}
local Conststorages = {__tag = "storage"}
storage = {}
local Consttasks = {__tag = "task"}
task = {}
local Construntimes = {__tag = "runtime"}
runtime = {}
local ConstUIs = {__tag = "UI"}
UI = {}

local bit = require("Zlibs.Zbit")
local configs = require("Zlibs.ApisConfig")

local function round(n) return math.floor(n + 0.5) end

function print(...)
    local t = {...}
    for k, v in ipairs(t) do
        if type(v) ~= "string" then t[k] = tostring(v) end
    end
    sysLog(table.concat(t, ", "))
end

log = sysLog

local unpack = table.unpack or unpack

function printf(format, ...)
    format = tostring(format)
    local t = {...}
    for k, v in ipairs(t) do
        if type(v) ~= "string" and type(v) ~= "number" then
            t[k] = tostring(v)
        end
    end
    log(string.format(format, unpack(t)))
end

sleep = mSleep

os.netTime = getNetTime

os.milliTime = mTime

local PointMeta = {
    __add = function(self, p)
        if type(p) ~= "table" or tostring(p.__tag) ~= "Point" then
            error("Point类的加法需要同样是Point才可以相加!")
        end
        return Point(self.x + p.x, self.y + p.y)
    end,
    __sub = function(self, p)
        if type(p) ~= "table" or tostring(p.__tag) ~= "Point" then
            error("Point类的减法需要同样是Point才可以相减!")
        end
        return Point(self.x - p.x, self.y - p.y)
    end,
    __mul = function(self, p)
        if type(p) ~= "number" then
            error("Point类的乘法需要和number进行运算!")
        end
        return Point(self.x * p, self.y * p)
    end,
    __div = function(self, p)
        if type(p) ~= "number" then
            error("Point类的除法需要和number进行运算!")
        end
        return Point(self.x / p, self.y / p)
    end,
    __mod = function(self, p)
        if type(p) ~= "number" or p % 1 ~= 0 then
            error("Point类的取余需要和整数进行运算!")
        end
        return Point(self.x % p, self.y % p)
    end,
    __pow = function(self, p)
        if type(p) ~= "number" then
            error("Point类的次方需要和number进行运算!")
        end
        return Point(self.x ^ p, self.y ^ p)
    end,
    __unm = function(self) return Point(-self.x, -self.y) end,
    __eq = function(self, p)
        if type(p) ~= "table" or tostring(p.__tag) ~= "Point" then
            error("Point类的比较需要同样是Point才可以!")
        end
        return self.x == p.x and self.y == p.y
    end,
    __tostring = function(self)
        return "Point(" .. self.x .. ", " .. self.y .. ")"
    end,
    __index = function(self, k) return ConstPoints[k] end
}

setmetatable(Point, {
    __tostring = function(self) return configs.Point end,
    __index = function(self, k) return ConstPoints[k] end,
    __newindex = function(self, k, v)
        if ConstPoints[k] then
            error("你不可以给常量赋值!")
        else
            rawset(self, k, v)
        end
    end,
    __call = function(self, ...)
        local t = {...}
        local x, y
        if #t == 0 then
            x, y = 0, 0
        elseif #t == 1 and type(t[1]) == "table" and tostring(t[1].__tag) ==
            "Point" then
            x, y = t[1].x, t[1].y
        elseif #t == 2 and type(t[1]) == "number" and type(t[2]) == "number" then
            x, y = round(t[1]), round(t[2])
        else
            error(
                "在创建Point对象时参数传入错误!正确例子:Point()或Point(100,100)或Point(Point(100,100)),当前传入参数为:" ..
                    table.concat(t, ", "))
        end
        return setmetatable({x = x, y = y}, PointMeta)
    end
})

ConstPoints.INVALID = Point(-1, -1)
ConstPoints.ZERO = Point(0, 0)

local SizeMeta = {
    __add = function(self, p)
        if type(p) ~= "table" or tostring(p.__tag) ~= "Size" then
            error("Size类的加法需要同样是Size才可以相加!")
        end
        return Size(self.width + p.width, self.height + p.height)
    end,
    __sub = function(self, p)
        if type(p) ~= "table" or tostring(p.__tag) ~= "Size" then
            error("Size类的减法需要同样是Size才可以相减!")
        end
        return Size(self.width - p.width, self.height - p.height)
    end,
    __mul = function(self, p)
        if type(p) ~= "number" then
            error("Size类的乘法需要和number进行运算!")
        end
        return Size(self.width * p, self.height * p)
    end,
    __div = function(self, p)
        if type(p) ~= "number" then
            error("Size类的除法需要和number进行运算!")
        end
        return Size(self.width / p, self.height / p)
    end,
    __mod = function(self, p)
        if type(p) ~= "number" or p % 1 ~= 0 then
            error("Size类的取余需要和整数进行运算!")
        end
        return Size(self.width % p, self.height % p)
    end,
    __pow = function(self, p)
        if type(p) ~= "number" then
            error("Size类的次方需要和number进行运算!")
        end
        return Size(self.width ^ p, self.height ^ p)
    end,
    __unm = function(self) return Size(-self.width, -self.height) end,
    __eq = function(self, p)
        if type(p) ~= "table" or tostring(p.__tag) ~= "Size" then
            error("Size类的比较需要同样是Size才可以!")
        end
        return self.width == p.width and self.height == p.height
    end,
    __tostring = function(self)
        return "Size[" .. self.width .. " x " .. self.height .. "]"
    end,
    __index = function(self, k) return ConstSizes[k] end
}

setmetatable(Size, {
    __tostring = function(self) return configs.Size end,
    __index = function(self, k) return ConstSizes[k] end,
    __newindex = function(self, k, v)
        if ConstSizes[k] then
            error("你不可以给常量赋值!")
        else
            rawset(self, k, v)
        end
    end,
    __call = function(self, ...)
        local t = {...}
        local width, height
        if #t == 0 then
            width, height = 0, 0
        elseif #t == 1 and type(t[1]) == "table" and tostring(t[1].__tag) ==
            "Point" then
            width, height = t[1].x, t[1].y
        elseif #t == 1 and type(t[1]) == "table" and tostring(t[1].__tag) ==
            "Size" then
            width, height = t[1].width, t[1].height
        elseif #t == 2 and type(t[1]) == "number" and type(t[2]) == "number" then
            width, height = round(t[1]), round(t[2])
        else
            error(
                "在创建Size对象时参数传入错误!正确例子:Size()或Size(100,100)或Size(Point(100,100))或Size(Size(100,100)),当前传入参数为:" ..
                    table.concat(t, ", "))
        end
        return setmetatable({width = width, height = height}, SizeMeta)
    end
})

ConstSizes.ZERO = Size(0, 0)
ConstSizes.INVALID = Size(-1, -1)

local RectMeta = {
    __tostring = function(self)
        return "Rect(" .. self.x .. ", " .. self.y .. ")[" .. self.width ..
                   " x " .. self.height .. "]"
    end,
    __index = function(self, k) return ConstRects[k] end
}

setmetatable(Rect, {
    __tostring = function(self) return configs.Rect end,
    __index = function(self, k) return ConstRects[k] end,
    __newindex = function(self, k, v)
        if ConstRects[k] then
            error("你不可以给常量赋值!")
        else
            rawset(self, k, v)
        end
    end,
    __call = function(self, ...)
        local t = {...}
        local width, height
        local x, y
        if #t == 0 then
            x, y, width, height = 0, 0, 0, 0
        elseif #t == 1 and type(t[1]) == "table" and tostring(t[1].__tag) ==
            "Rect" then
            x, y, width, height = t[1].x, t[1].y, t[1].width, t[1].height
        elseif #t == 2 and type(t[1]) == "table" and tostring(t[1].__tag) ==
            "Point" and type(t[2]) == "table" and tostring(t[2].__tag) == "Size" then
            x, y, width, height = t[1].x, t[1].y, t[2].width, t[2].height
        elseif #t == 4 and type(t[1]) == "number" and type(t[2]) == "number" and
            type(t[3]) == "number" and type(t[4]) == "number" then
            x, y, width, height = ...
        else
            error(
                "在创建Rect对象时参数传入错误!当前传入参数为:" ..
                    table.concat(t, ", "))
        end
        return setmetatable({x = x, y = y, width = width, height = height},
                            RectMeta)
    end
})

ConstRects.ZERO = Rect(0, 0, 0, 0)

function ConstRects:tl() return Point(self.x, self.y) end
function ConstRects:br() return Point(self.x + self.width, self.y + self.height) end
function ConstRects:size() return Size(self.width, self.height) end
function ConstRects:contains(p)
    if type(p) ~= "table" or tostring(p.__tag) ~= "Point" then
        error("contains函数参数错误,需要传入Point对象")
    end
    return self.x <= p.x and self.x + self.width >= p.x and self.y <= p.y and
               self.y + self.height >= p.y
end
function ConstRects:union(r)
    if type(r) ~= "table" or tostring(r.__tag) ~= "Rect" then
        error("union函数参数错误,需要传入Rect对象")
    end
    local r1tl, r1br = self:tl(), self:br()
    local r2tl, r2br = r:tl(), r:br()
    return Rect(math.min(r1tl.x, r2tl.x), math.min(r1tl.y, r2tl.y),
                math.max(r1br.x, r2br.x) - math.min(r1tl.x, r2tl.x),
                math.max(r1br.y, r2br.y) - math.min(r1tl.y, r2tl.y))
end
function ConstRects:intersect(r)
    if type(r) ~= "table" or tostring(r.__tag) ~= "Rect" then
        error("intersect函数参数错误,需要传入Rect对象")
    end
    local r1tl, r1br = self:tl(), self:br()
    local r2tl, r2br = r:tl(), r:br()
    if math.min(r1br.x, r2br.x) - math.max(r1tl.x, r2tl.x) <= 0 or
        math.min(r1br.y, r2br.y) - math.max(r1tl.y, r2tl.y) <= 0 then
        return Rect.ZERO
    end
    return Rect(math.max(r1tl.x, r2tl.x), math.max(r1tl.y, r2tl.y),
                math.min(r1br.x, r2br.x) - math.max(r1tl.x, r2tl.x),
                math.min(r1br.y, r2br.y) - math.max(r1tl.y, r2tl.y))
end

local Color3BMeta = {
    __tostring = function(self)
        return string.format("0x%2x%2x%2x", self.r, self.g, self.b)
    end,
    __index = function(self, k) return ConstColor3Bs[k] end
}

setmetatable(Color3B, {
    __tostring = function(self) return configs.Color3B end,
    __index = function(self, k) return ConstColor3Bs[k] end,
    __newindex = function(self, k, v)
        if ConstColor3Bs[k] then
            error("你不可以给常量赋值!")
        else
            rawset(self, k, v)
        end
    end,
    __call = function(self, ...)
        local t = {...}
        local r, g, b
        if #t == 0 then
            r, g, b = 0, 0, 0
        elseif #t == 1 and type(t[1]) == "number" and t[1] >= 0 and t[1] <=
            0xffffff then
            r, g, b = math.floor(t[1] / 0x10000),
                      math.floor(t[1] / 0x100) % 0x100, t[1] % 0x100
        elseif #t == 1 and type(t[1]) == "string" then
            local c = tonumber(t[1], 16)
            if not c or c < 0 or c > 0xffffff then
                error(
                    "在创建Color3B对象时参数传入错误!当前传入参数为:" ..
                        table.concat(t, ", "))
            end
            r, g, b = math.floor(c / 0x10000), math.floor(c / 0x100) % 0x100,
                      c % 0x100
        elseif #t == 3 and type(t[1]) == "number" and type(t[2]) == "number" and
            type(t[3]) == "number" then
            r, g, b = ...
            if r < 0 or r > 0xff or g < 0 or g > 0xff or b < 0 or b > 0xff then
                error(
                    "在创建Color3B对象时参数传入错误!当前传入参数为:" ..
                        table.concat(t, ", "))
            end
        elseif #t == 1 and type(t[1]) == "table" and tostring(t[1].__tag) ==
            "Color3B" then
            r, g, b = t[1].r, t[1].g, t[1].b
        elseif #t == 1 and type(t[1]) == "table" and tostring(t[1].__tag) ==
            "Color3F" then
            r, g, b = round(t[1].r * 0xff), round(t[1].g * 0xff),
                      round(t[1].b * 0xff)
        else
            error(
                "在创建Rect对象时参数传入错误!当前传入参数为:" ..
                    table.concat(t, ", "))
        end
        return setmetatable({r = r, g = g, b = b}, Color3BMeta)
    end
})

function ConstColor3Bs:toInt() return self.r * 0x10000 + self.g * 0x100 + self.b end
function ConstColor3Bs:toString()
    return string.format("0x%2x%2x%2x", self.r, self.g, self.b)
end

local Color3FMeta = {
    __tostring = function(self)
        return string.format("0x%2x%2x%2x", round(self.r * 0xff),
                             round(self.g * 0xff), round(self.b * 0xff))
    end,
    __index = function(self, k) return ConstColor3Fs[k] end
}

setmetatable(Color3F, {
    __tostring = function(self) return configs.Color3F end,
    __index = function(self, k) return ConstColor3Fs[k] end,
    __newindex = function(self, k, v)
        if ConstColor3Fs[k] then
            error("你不可以给常量赋值!")
        else
            rawset(self, k, v)
        end
    end,
    __call = function(self, ...)
        local t = {...}
        local r, g, b
        if #t == 0 then
            r, g, b = 0, 0, 0
        elseif #t == 1 and type(t[1]) == "number" and t[1] >= 0 and t[1] <=
            0xffffff then
            r, g, b = math.floor(t[1] / 0x10000) / 0xff,
                      math.floor(t[1] / 0x100) % 0x100 / 0xff,
                      t[1] % 0x100 / 0xff
        elseif #t == 1 and type(t[1]) == "string" then
            local c = tonumber(t[1], 16)
            if not c or c < 0 or c > 0xffffff then
                error(
                    "在创建Color3B对象时参数传入错误!当前传入参数为:" ..
                        table.concat(t, ", "))
            end
            r, g, b = math.floor(c / 0x10000) / 0xff,
                      math.floor(c / 0x100) % 0x100 / 0xff, c % 0x100 / 0xff
        elseif #t == 3 and type(t[1]) == "number" and type(t[2]) == "number" and
            type(t[3]) == "number" then
            r, g, b = ...
            if r < 0 or r > 1 or g < 0 or g > 1 or b < 0 or b > 1 then
                error(
                    "在创建Color3B对象时参数传入错误!当前传入参数为:" ..
                        table.concat(t, ", "))
            end
        elseif #t == 1 and type(t[1]) == "table" and tostring(t[1].__tag) ==
            "Color3B" then
            r, g, b = t[1].r / 0xff, t[1].g / 0xff, t[1].b / 0xff
        elseif #t == 1 and type(t[1]) == "table" and tostring(t[1].__tag) ==
            "Color3F" then
            r, g, b = t[1].r, t[1].g, t[1].b
        else
            error(
                "在创建Rect对象时参数传入错误!当前传入参数为:" ..
                    table.concat(t, ", "))
        end
        return setmetatable({r = r, g = g, b = b}, Color3FMeta)
    end
})

function ConstColor3Fs:toInt()
    return round(self.r * 0xff) * 0x10000 + round(self.g * 0xff) * 0x100 +
               round(self.b * 0xff)
end
function ConstColor3Fs:toString()
    return string.format("0x%2x%2x%2x", round(self.r * 0xff),
                         round(self.g * 0xff), round(self.b * 0xff))
end

setmetatable(xmod, {
    __tostring = function(self) return configs.xmod end,
    __index = function(self, k) return Constxmods[k] end,
    __newindex = function(self, k, v)
        if Constxmods[k] then
            error("你不可以给常量赋值!")
        else
            rawset(self, k, v)
        end
    end
})

Constxmods.PLATFORM_IOS = "iOS"
Constxmods.PLATFORM_ANDROID = "Android"
Constxmods.PLATFORM = getOSType() == "android" and xmod.PLATFORM_ANDROID or
                          xmod.PLATFORM_IOS
if not getProduct then
    if getUserID == "null" then
        Constxmods.PRODUCT_CODE = 1
    elseif xmod.PLATFORM == xmod.PLATFORM_IOS and isPrivateMode() == 0 then
        Constxmods.PRODUCT_CODE = 3
    else
        Constxmods.PRODUCT_CODE = 2
    end
else
    if getProduct() == 3 then
        Constxmods.PRODUCT_CODE = 1
    elseif getProduct() == 5 then
        Constxmods.PRODUCT_CODE = 3
    elseif getProduct() == 6 then
        Constxmods.PRODUCT_CODE = 5
    elseif getProduct() == 7 then
        Constxmods.PRODUCT_CODE = 4
    else
        Constxmods.PRODUCT_CODE = 2
    end
end
Constxmods.PRODUCT_CODE_DEV = 1
Constxmods.PRODUCT_CODE_XXZS = 2
Constxmods.PRODUCT_CODE_IPA = 3
Constxmods.PRODUCT_CODE_KUWAN = 4
Constxmods.PRODUCT_CODE_SPIRIT = 5
local PRODUCT_NAMEs = {"DEV", "XXZS", "IPA", "KUWAN", "SPIRIT"}
Constxmods.PRODUCT_NAME = PRODUCT_NAMEs[xmod.PRODUCT_CODE]
Constxmods.VERSION_CODE = tonumber(string.gsub(getEngineVersion(), ".", "")) -- 不确定是否和2.0返回一致
Constxmods.VERSION_NAME = getEngineVersion() -- 不确定是否和2.0返回一致
Constxmods.HANDLER_ON_USER_EXIT = 1
Constxmods.HANDLER_ON_RUNTIME_ERROR = 2
Constxmods.SCREENCAP_POLICY_STANDARD = 0
Constxmods.SCREENCAP_POLICY_AGGRESSIVE = 1
Constxmods.SCREENCAP_POLICY = "screencap_policy"
Constxmods.SCREENCAP_KEEP = "screencap_keep"
local _ORIENTATION_, _KEEP_

function Constxmods.setConfig(key, value)
    if key == xmod.EXPECTED_ORIENTATION then
        screen.init(value)
    elseif key == xmod.SCREENCAP_KEEP then
        screen.keep(value)
    elseif key == xmod.SCREENCAP_POLICY then
        setSysConfig("screencap_policy", value ==
                         xmod.SCREENCAP_POLICY_AGGRESSIVE and "aggresive" or
                         "default")
        setStringConfig("xmodSysConfig_" .. key, value) -- 1true0false
    end
end

function Constxmods.getConfig(key)
    if key == xmod.EXPECTED_ORIENTATION then
        return _ORIENTATION_
    elseif key == xmod.SCREENCAP_KEEP then
        return _KEEP_
    elseif key == xmod.SCREENCAP_POLICY then
        return getStringConfig("xmodSysConfig_" .. key, "default") -- 1true0false
    end
end

function Constxmods.getPublicPath() -- 1.9无法获取具体目录
    --[[
		公共目录路径： 
		- 开发助手 
		Android：/data/data/com.xxscript.idehelper/tengine/public 
		iOS(开发助手版本>=1.0.10)：/var/mobile/Library/XXIDEHelper/xsp/Temp/public 
		iOS(开发助手版本<1.0.10) ：/Library/ApplicationSupport/XXIDEHelper/xsp/Temp/public 
		- 叉叉助手 
		Android： /sdcard/com.xxAssistant/tengine/public 
		iOS(叉叉版本>=2.5.0): /var/mobile/Library/XXAssistant/Lua/Luas/Temp/public 
		iOS(叉叉版本<2.5.0): /Library/ApplicationSupport/XXAssistant/Lua/Luas/Temp/public 
		- IPA精灵 
		IPA精灵：应用文件夹/Documents/Lua/Luas/Temp/public
		]]
    if xmod.PRODUCT_CODE == xmod.PRODUCT_CODE_DEV and xmod.PLATFORM ==
        xmod.PLATFORM_IOS then
        return "/var/mobile/Library/XXIDEHelper/xsp/Temp/public"
    elseif xmod.PRODUCT_CODE == xmod.PRODUCT_CODE_DEV and xmod.PLATFORM ==
        xmod.PLATFORM_ANDROID then
        return "/data/data/com.xxscript.idehelper/tengine/public"
    elseif xmod.PRODUCT_CODE == xmod.PRODUCT_CODE_XXZS and xmod.PLATFORM ==
        xmod.PLATFORM_IOS then
        return "/var/mobile/Library/XXAssistant/Lua/Luas/Temp/public"
    elseif xmod.PRODUCT_CODE == xmod.PRODUCT_CODE_XXZS and xmod.PLATFORM ==
        xmod.PLATFORM_ANDROID then
        return "/sdcard/com.xxAssistant/tengine/public"
    elseif xmod.PRODUCT_CODE == xmod.PRODUCT_CODE_IPA then
        return "[public]" -- 应用文件夹/Documents/Lua/Luas/Temp/public--无法获得应用文件夹名称
    else
        return "[public]"
    end
end

function Constxmods.getPrivatePath() -- 1.9没有私有目录
    return "[public]"
end
function Constxmods.resolvePath(path)
    return string.gsub(path, "[private]", "[public]")
    -- if xmod.PRODUCT_CODE==xmod.PRODUCT_CODE_DEV and xmod.PLATFORM==xmod.PLATFORM_IOS then
    -- 	return string.gsub(path,"[public]","/var/mobile/Library/XXIDEHelper/xsp/Temp/public/")
    -- elseif xmod.PRODUCT_CODE==xmod.PRODUCT_CODE_DEV and xmod.PLATFORM==xmod.PLATFORM_ANDROID then
    -- 	return string.gsub(path,"[public]","/data/data/com.xxscript.idehelper/tengine/public/")
    -- elseif xmod.PRODUCT_CODE==xmod.PRODUCT_CODE_XXZS and xmod.PLATFORM==xmod.PLATFORM_IOS then
    -- 	return string.gsub(path,"[public]","/var/mobile/Library/XXAssistant/Lua/Luas/Temp/public/")
    -- elseif xmod.PRODUCT_CODE==xmod.PRODUCT_CODE_XXZS and xmod.PLATFORM==xmod.PLATFORM_ANDROID then
    -- 	return string.gsub(path,"[public]","/sdcard/com.xxAssistant/tengine/public/")
    -- elseif xmod.PRODUCT_CODE==xmod.PRODUCT_CODE_IPA then
    -- 	return path--应用文件夹/Documents/Lua/Luas/Temp/public/--无法获得应用文件夹名称
    -- else
    -- 	return path
    -- end
end
Constxmods.exit = lua_exit
Constxmods.restart = lua_restart

function Constxmods.setOnEventCallback(event, callback)
    if event == xmod.EVENT_ON_USER_EXIT then
        onBeforeUserExit = callback
    elseif event == xmod.EVENT_ON_RUNTIME_ERROR then
        -- 1.9无法直接实现
        onSpiritErrorExit = callback
        --[[
			需要使用此功能的请把脚本主函数使用pcall调用,出错时调用onSpiritErrorExit函数
		]]
    end
end

local UserInfoMeta = {
    __tostring = function(self)
        return "UserInfo模块,用户id:" .. self.id .. ",付费方式:" ..
                   self.membership .. ",剩余时间:" .. self.expiredTime
    end,
    __index = function(self, k) return ConstUserInfos[k] end
}

setmetatable(UserInfo, {
    __index = function(self, k) return ConstUserInfos[k] end,
    __newindex = function(self, k, v)
        if ConstUserInfos[k] then
            error("你不可以给常量赋值!")
        else
            rawset(self, k, v)
        end
    end,
    __call = function(self)
        local id = getUserID()
        local buyState, validTime, res = getUserCredit()

        return setmetatable({
            id = id,
            membership = buyState,
            expiredTime = validTime
        }, UserInfoMeta), res
    end
})

local ScriptInfoMeta = {
    __tostring = function(self)
        return "ScriptInfo模块,脚本id:" .. self.id
    end,
    __index = function(self, k) return ConstScriptInfos[k] end
}

setmetatable(ScriptInfo, {
    __index = function(self, k) return ConstScriptInfos[k] end,
    __newindex = function(self, k, v)
        if ConstScriptInfos[k] then
            error("你不可以给常量赋值!")
        else
            rawset(self, k, v)
        end
    end,
    __call = function(self)
        local id = getScriptID()

        return setmetatable({id = id}, ScriptInfoMeta), id == -1 and -1 or 0
    end
})

setmetatable(script, {
    __tostring = function(self) return configs.script end,
    __index = function(self, k) return Constscripts[k] end,
    __newindex = function(self, k, v)
        if Constscripts[k] then
            error("你不可以给常量赋值!")
        else
            rawset(self, k, v)
        end
    end
})

Constscripts.getUserInfo = UserInfo
Constscripts.getScriptInfo = ScriptInfo
Constscripts.getBulletinBoard = getCloudContent
Constscripts.getUIData = getUIContent

function getResData(file)
    error("叉叉1.9引擎无法实现获取res目录资源内容功能")
end

--[[
	2.0的IMAGE类在1.9中无法实现,故跳过
]]

setmetatable(screen, {
    __tostring = function(self) return configs.screen end,
    __index = function(self, k) return Constscreens[k] end,
    __newindex = function(self, k, v)
        if Constscreens[k] then
            error("你不可以给常量赋值!")
        else
            rawset(self, k, v)
        end
    end
})
Constscreens.LANDSCAPE_RIGHT = 1
Constscreens.LANDSCAPE_LEFT = 2
Constscreens.PORTRAIT = 3
Constscreens.PRIORITY_DEFAULT = 0x7000
Constscreens.PRIORITY_LEFT_FIRST = 0x1000
Constscreens.PRIORITY_RIGHT_FIRST = 0x1001
Constscreens.PRIORITY_UP_FIRST = 0x2000
Constscreens.PRIORITY_DOWN_FIRST = 0x2010
Constscreens.PRIORITY_HORIZONTAL_FIRST = 0x4000
Constscreens.PRIORITY_VERTICAL_FIRST = 0x4100
Constscreens.MOCK_NONE = 0
Constscreens.MOCK_INPUT = 0x1000
Constscreens.MOCK_INPUT_FIXED = 0x1000
Constscreens.MOCK_INPUT_RELATIVE = 0x3000
Constscreens.MOCK_OUTPUT = 0x10000
Constscreens.MOCK_BOTH = 0x11000

function Constscreens.init(orientation)
    init("0", orientation == Constscreens.PORTRAIT and 0 or orientation)
    _ORIENTATION_ = orientation
end

function Constscreens.getSize()
    local width, height = getScreenSize() -- 统一为竖直（Home 键在下方时）屏幕的宽度和高度。
    --[[
		该函数结果受以下函数影响：
		screen.init
	]]
    local noworientation = xmod.getConfig(xmod.EXPECTED_ORIENTATION)
    if noworientation == screen.PORTRAIT then
        return Size(width, height)
    else
        return Size(height, width)
    end
end

Constscreens.getDPI = getScreenDPI -- 仅安卓适用

function Constscreens.capture()
    error("screen.capture函数无法在1.9引擎实现")
end
function Constscreens.keep(value)
    keepScreen(value)
    _KEEP_ = value
end
function Constscreens.getOrientation()
    local ori = getScreenDirection()
    return ori == 0 and screen.PORTRAIT or ori
end

function Constscreens.snapshot(path, rect, quality)
    local screensize = screen.getSize()
    local x1, y1, x2, y2
    if rect then
        x1, y1, x2, y2 = rect:tl().x, rect:tl().y, rect:br().x, rect:br().y
    else
        x1, y1 = 0, 0
        x2, y2 = screensize.width - 1, screensize.height - 1
    end
    snapshot(path, x1, y1, x2, y2, quality or 1)
    local f = io.open(path, "r")
    if f then
        f:close()
        return true
    else
        f:close()
        return false
    end
end

function Constscreens.setMockMode(mode)
    if type(mode) ~= "number" then
        error("setMockMode函数传入参数错误")
    end
    Constscreens.MockMode = mode
end

function Constscreens.setMockTransform(transform)
    if type(transform) ~= "function" then
        error("setMockTransform函数传入参数错误")
    end
    Constscreens.Transform = transform
end

function Constscreens.getRGB(...)
    local t = {...}
    local TrRect
    if #t == 1 and type(t[1]) == "table" and tostring(t[1].__tag) == "Point" then
        if screen.Transform and
            (screen.MockMode == screen.MOCK_INPUT or screen.MockMode ==
                screen.MOCK_BOTH) then
            TrRect = screen.Transform(screen.MOCK_INPUT_FIXED,
                                      Rect(t[1].x, t[1].y, 0, 0))
        else
            TrRect = Rect(t[1].x, t[1].y, 0, 0)
        end
    elseif #t == 2 and type(t[1]) == "number" and type(t[2]) == "number" then
        if screen.Transform and
            (screen.MockMode == screen.MOCK_INPUT or screen.MockMode ==
                screen.MOCK_BOTH) then
            TrRect = screen.Transform(screen.MOCK_INPUT_FIXED,
                                      Rect(t[1], t[2], 0, 0))
        else
            TrRect = Rect(t[1], t[2], 0, 0)
        end
    else
        error("getRGB函数参数传入错误!")
    end
    return getColorRGB(TrRect.x, TrRect.y)
end

function Constscreens.getColor(...)
    local t = {...}
    local TrRect
    if #t == 1 and type(t[1]) == "table" and tostring(t[1].__tag) == "Point" then
        if screen.Transform and
            (screen.MockMode == screen.MOCK_INPUT or screen.MockMode ==
                screen.MOCK_BOTH) then
            TrRect = screen.Transform(screen.MOCK_INPUT_FIXED,
                                      Rect(t[1].x, t[1].y, 0, 0))
        else
            TrRect = Rect(t[1].x, t[1].y, 0, 0)
        end
    elseif #t == 2 and type(t[1]) == "number" and type(t[2]) == "number" then
        if screen.Transform and
            (screen.MockMode == screen.MOCK_INPUT or screen.MockMode ==
                screen.MOCK_BOTH) then
            TrRect = screen.Transform(screen.MOCK_INPUT_FIXED,
                                      Rect(t[1], t[2], 0, 0))
        else
            TrRect = Rect(t[1], t[2], 0, 0)
        end
    else
        error("getColor函数参数传入错误!")
    end
    return Color3B(getColor(TrRect.x, TrRect.y))
end

local function Compare_Color(c1, c2, Fuzz, Offest) -- 颜色比较
    if Offest then
        return math.abs(c1.r - c2.r) <= Offest.r and math.abs(c1.g - c2.g) <=
                   Offest.g and math.abs(c1.b - c2.b) <= Offest.b
    end
    return math.abs(c1.r - c2.r) <= 0xff - 0xff * Fuzz / 100 and
               math.abs(c1.g - c2.g) <= 0xff - 0xff * Fuzz / 100 and
               math.abs(c1.b - c2.b) <= 0xff - 0xff * Fuzz / 100
end

local function split(str, delimiter) -- 字符串分割
    if str == nil or str == '' or delimiter == nil then return {} end
    local result = {}
    for match in (str .. delimiter):gmatch("(.-)" .. delimiter) do
        table.insert(result, match)
    end
    return result
end

function Constscreens.matchColor(...)
    local t = {...}
    local getc
    local Fuzz
    if #t >= 3 and type(t[1]) == "number" and type(t[2]) == "number" then
        Fuzz = tonumber(t[4]) or 100
        getc = Constscreens.getColor(t[1], t[2])
        if type(t[3]) == "table" then
            if tostring(t[3].__tag) == "Color3B" then
                return Compare_Color(getc, t[3], Fuzz)
            elseif tostring(t[3].__tag) == "Color3F" then
                return Compare_Color(getc, Color3B(t[3]), Fuzz)
            else
                error("matchColor函数参数传入错误")
            end
        elseif type(t[3]) == "number" then
            return Compare_Color(getc, Color3B(t[3]), Fuzz)
        else
            error("matchColor函数参数传入错误")
        end
    elseif #t >= 2 and type(t[1]) == "table" and tostring(t[1].__tag) == "Point" then
        Fuzz = tonumber(t[3]) or 100
        getc = Constscreens.getColor(t[1])
        if type(t[2]) == "table" then
            if tostring(t[2].__tag) == "Color3B" then
                return Compare_Color(getc, t[2], Fuzz)
            elseif tostring(t[2].__tag) == "Color3F" then
                return Compare_Color(getc, Color3B(t[2]), Fuzz)
            else
                error("matchColor函数参数传入错误")
            end
        elseif type(t[2]) == "number" then
            return Compare_Color(getc, Color3B(t[2]), Fuzz)
        else
            error("matchColor函数参数传入错误")
        end
    else
        error("matchColor函数参数传入错误")
    end
end

function Constscreens.matchColors(...)
    local t = {...}
    local Fuzz = tonumber(t[2]) or 100
    local tbl = {}
    local t1
    if type(t[1]) == "string" then
        t1 = split(t[1], ",")
        if #t1 == 0 then return true end
        local t2
        local c
        for i = 1, #t1 do
            t2 = split(t1[i], "|")
            c = split(t2[3] or "0x000000", "-")
            t1[i] = {
                pos = Point(tonumber(t2[1]) or -1, tonumber(t2[2]) or -1),
                color = tonumber(c[1], 16) or 0,
                offset = c[2] and (tonumber(c[2], 16) or 0) or nil,
                fuzz = tonumber(t2[4]) or Fuzz
            }
        end
    else
        t1 = t[1]
    end
    if type(t1) == "table" then
        local getc
        for i = 1, #t1 do
            getc = Constscreens.getColor(t1[i].pos)
            if not Compare_Color(getc, Color3B(t1[i].color), t1[i].fuzz or Fuzz,
                                 t1[i].offset) then return false end
        end
    else
        error("matchColors函数参数传入错误")
    end
    return true
end

function Constscreens.findImage(rect, image, fuzzness, priority, ignoreColor)
    if type(rect) ~= "table" or tostring(rect.__tag) ~= "Rect" then
        error("findImage函数参数传入错误")
    end
    if type(image) ~= "string" then
        error(
            "findImage函数因1.9引擎限制,只支持res文件夹中的图像,请传入字符串")
    end
    fuzzness = tonumber(fuzzness) or 100
    priority = priority or screen.PRIORITY_DEFAULT
    local x, y = findImageInRegionFuzzy(image, fuzzness, rect.x, rect.y,
                                        rect.x + rect.width,
                                        rect.y + rect.height, ignoreColor)
    if x ~= -1 then return Point(x, y) end
    return Point.INVALID
end

local PRIORITY_LIST = {
    [screen.PRIORITY_DEFAULT] = {0, 0, 0},
    [bit.bor(bit.bor(screen.PRIORITY_LEFT_FIRST, screen.PRIORITY_UP_FIRST),
             screen.PRIORITY_HORIZONTAL_FIRST)] = {0, 0, 0},
    [bit.bor(bit.bor(screen.PRIORITY_RIGHT_FIRST, screen.PRIORITY_UP_FIRST),
             screen.PRIORITY_HORIZONTAL_FIRST)] = {1, 0, 0},
    [bit.bor(bit.bor(screen.PRIORITY_LEFT_FIRST, screen.PRIORITY_DOWN_FIRST),
             screen.PRIORITY_HORIZONTAL_FIRST)] = {0, 1, 0},
    [bit.bor(bit.bor(screen.PRIORITY_LEFT_FIRST, screen.PRIORITY_UP_FIRST),
             screen.PRIORITY_VERTICAL_FIRST)] = {0, 0, 1},
    [bit.bor(bit.bor(screen.PRIORITY_RIGHT_FIRST, screen.PRIORITY_DOWN_FIRST),
             screen.PRIORITY_HORIZONTAL_FIRST)] = {1, 1, 0},
    [bit.bor(bit.bor(screen.PRIORITY_LEFT_FIRST, screen.PRIORITY_DOWN_FIRST),
             screen.PRIORITY_VERTICAL_FIRST)] = {0, 1, 1},
    [bit.bor(bit.bor(screen.PRIORITY_RIGHT_FIRST, screen.PRIORITY_UP_FIRST),
             screen.PRIORITY_VERTICAL_FIRST)] = {1, 0, 1},
    [bit.bor(bit.bor(screen.PRIORITY_RIGHT_FIRST, screen.PRIORITY_DOWN_FIRST),
             screen.PRIORITY_VERTICAL_FIRST)] = {1, 1, 1}
}

function Constscreens.findColor(rect, color, globalFuzz, priority)
    if type(rect) ~= "table" or tostring(rect.__tag) ~= "Rect" then
        error("findColor函数参数传入错误")
    end

    globalFuzz = tonumber(globalFuzz) or 100
    priority = priority and PRIORITY_LIST[priority] or
                   PRIORITY_LIST[screen.PRIORITY_DEFAULT]
    local t1, TrRect
    if type(color) == "string" then
        t1 = split(color, ",")
        if #t1 == 0 then return true end
        local t2
        local c
        for i = 1, #t1 do
            t2 = split(t1[i], "|")
            c = split(t2[3] or "0x000000", "-")
            t1[i] = {
                pos = Point(tonumber(t2[1]) or -1, tonumber(t2[2]) or -1),
                color = tonumber(c[1], 16) or 0,
                offset = c[2] and (tonumber(c[2], 16) or 0) or nil,
                fuzz = tonumber(t2[4]) or globalFuzz
            }
        end
    elseif type(color) == "number" then
        t1 = {
            {pos = Point.ZERO, color = color, offset = nil, fuzz = globalFuzz}
        }
    elseif type(color) == "table" then
        if tostring(color.__tag) == "Color3B" then
            t1 = {
                {
                    pos = Point.ZERO,
                    color = color:toInt(),
                    offset = nil,
                    fuzz = globalFuzz
                }
            }
        elseif tostring(color.__tag) == "Color3F" then
            t1 = {
                {
                    pos = Point.ZERO,
                    color = color:toInt(),
                    offset = nil,
                    fuzz = globalFuzz
                }
            }
        else
            t1 = color
        end
    else
        error("findColor函数参数传入错误")
    end
    local tr = {}
    for i = 1, #t1 do
        -- 坐标转换
        if screen.Transform and
            (screen.MockMode == screen.MOCK_INPUT or screen.MockMode ==
                screen.MOCK_BOTH) then
            TrRect = screen.Transform(screen.MOCK_INPUT_FIXED,
                                      Rect(t1[i].pos.x, t1[i].pos.y, 0, 0))
        else
            TrRect = Rect(t1[i].pos.x, t1[i].pos.y, 0, 0)
        end
        tr[i] = {
            x = TrRect.x,
            y = TrRect.y,
            color = t1[i].color,
            degree = t1[i].fuzz or globalFuzz,
            offset = t1[i].offset
        }
    end
    -- 范围换算
    if screen.Transform and
        (screen.MockMode == screen.MOCK_INPUT or screen.MockMode ==
            screen.MOCK_BOTH) then
        TrRect = screen.Transform(screen.MOCK_INPUT_FIXED, rect)
    else
        TrRect = rect
    end
    -- 调用找色
    local x, y = findColor({
        TrRect.x, TrRect.y, TrRect.x + TrRect.width, TrRect.y + TrRect.height
    }, tr, globalFuzz, unpack(priority))
    if x == -1 then return Point.INVALID end
    TrRect = Rect(x, y, 0, 0)
    -- 返回值换算
    if screen.Transform and
        (screen.MockMode == screen.MOCK_OUTPUT or screen.MockMode ==
            screen.MOCK_BOTH) then
        TrRect = screen.Transform(screen.MOCK_OUTPUT, TrRect)
    end
    return TrRect:tl()
end

-- 修复版的findColors函数,自定义返回值数量(limit参数,默认200),支持hdir,vdir,priority三个参数的全部八种搜索方式
local function RepairFindColors(rect, color, degree, hdir, vdir, priority, limit)
    local allresult = {}
    local oneresult
    limit = limit or 200
    oneresult = findColors(rect, color, degree, hdir, vdir, priority)
    if #oneresult > 0 then
        for i = 1, #oneresult do
            table.insert(allresult, oneresult[i])
            if i >= limit then break end
        end
    end
    if #oneresult == 99 then
        local result99 = oneresult[99]
        if priority == 0 and hdir == 0 then
            oneresult = RepairFindColors(
                            {result99.x + 1, result99.y, rect[3], result99.y},
                            color, degree, hdir, vdir, priority,
                            limit - #allresult)
        elseif priority == 0 and hdir == 1 then
            oneresult = RepairFindColors(
                            {rect[1], result99.y, result99.x - 1, result99.y},
                            color, degree, hdir, vdir, priority,
                            limit - #allresult)
        elseif priority == 1 and vdir == 0 then
            oneresult = RepairFindColors(
                            {result99.x, result99.y + 1, result99.x, rect[4]},
                            color, degree, hdir, vdir, priority,
                            limit - #allresult)
        elseif priority == 1 and vdir == 1 then
            oneresult = RepairFindColors(
                            {result99.x, rect[2], result99.x, result99.y - 1},
                            color, degree, hdir, vdir, priority,
                            limit - #allresult)
        end
        if #oneresult > 0 then
            for i = 1, #oneresult do
                if #allresult >= limit then break end
                table.insert(allresult, oneresult[i])
            end
        end
        if #allresult < limit then
            if priority == 0 and vdir == 0 and result99.y < rect[4] then
                oneresult = RepairFindColors(
                                {rect[1], result99.y + 1, rect[3], rect[4]},
                                color, degree, hdir, vdir, priority,
                                limit - #allresult)
            elseif priority == 0 and vdir == 1 and result99.y > rect[2] then
                oneresult = RepairFindColors(
                                {rect[1], rect[2], rect[3], result99.y - 1},
                                color, degree, hdir, vdir, priority,
                                limit - #allresult)
            elseif priority == 1 and hdir == 0 and result99.x < rect[3] then
                oneresult = RepairFindColors(
                                {result99.x + 1, rect[2], rect[3], rect[4]},
                                color, degree, hdir, vdir, priority,
                                limit - #allresult)
            elseif priority == 1 and hdir == 1 and result99.x > rect[1] then
                oneresult = RepairFindColors(
                                {rect[1], rect[2], result99.x - 1, rect[4]},
                                color, degree, hdir, vdir, priority,
                                limit - #allresult)
            else
                return allresult
            end
            if #oneresult > 0 then
                for i = 1, #oneresult do
                    if #allresult >= limit then break end
                    table.insert(allresult, oneresult[i])
                end
            end
        end
    end
    return allresult
end

function Constscreens.findColors(rect, color, globalFuzz, priority, limit)
    if type(rect) ~= "table" or tostring(rect.__tag) ~= "Rect" then
        error("findColor函数参数传入错误")
    end

    globalFuzz = tonumber(globalFuzz) or 100
    limit = tonumber(limit) or 200
    priority = priority and PRIORITY_LIST[priority] or
                   PRIORITY_LIST[screen.PRIORITY_DEFAULT]
    local hdir, vdir, priority = unpack(priority)
    local t1, TrRect
    if type(color) == "string" then
        t1 = split(color, ",")
        if #t1 == 0 then return true end
        local t2
        local c
        for i = 1, #t1 do
            t2 = split(t1[i], "|")
            c = split(t2[3] or "0x000000", "-")
            t1[i] = {
                pos = Point(tonumber(t2[1]) or -1, tonumber(t2[2]) or -1),
                color = tonumber(c[1], 16) or 0,
                offset = c[2] and (tonumber(c[2], 16) or 0) or nil,
                fuzz = tonumber(t2[4]) or globalFuzz
            }
        end
    elseif type(color) == "number" then
        t1 = {
            {pos = Point.ZERO, color = color, offset = nil, fuzz = globalFuzz}
        }
    elseif type(color) == "table" then
        if tostring(color.__tag) == "Color3B" then
            t1 = {
                {
                    pos = Point.ZERO,
                    color = color:toInt(),
                    offset = nil,
                    fuzz = globalFuzz
                }
            }
        elseif tostring(color.__tag) == "Color3F" then
            t1 = {
                {
                    pos = Point.ZERO,
                    color = color:toInt(),
                    offset = nil,
                    fuzz = globalFuzz
                }
            }
        else
            t1 = color
        end
    else
        error("findColor函数参数传入错误")
    end
    local tr
    for i = 1, #t1 do
        -- 坐标转换
        if screen.Transform and
            (screen.MockMode == screen.MOCK_INPUT or screen.MockMode ==
                screen.MOCK_BOTH) then
            TrRect = screen.Transform(screen.MOCK_INPUT_FIXED,
                                      Rect(t1[i].pos.x, t1[i].pos.y, 0, 0))
        else
            TrRect = Rect(t1[i].pos.x, t1[i].pos.y, 0, 0)
        end
        t1[i] = {
            x = TrRect.x,
            y = TrRect.y,
            color = t1[i].color,
            degree = t1[i].fuzz or globalFuzz,
            offset = t1[i].offset
        }
    end
    -- 范围换算
    if screen.Transform and
        (screen.MockMode == screen.MOCK_INPUT or screen.MockMode ==
            screen.MOCK_BOTH) then
        TrRect = screen.Transform(screen.MOCK_INPUT_FIXED, rect)
    else
        TrRect = rect
    end
    -- 调用找色
    local tbl = RepairFindColors({
        TrRect.x, TrRect.y, TrRect.x + TrRect.width, TrRect.y + TrRect.height
    }, t1, globalFuzz, hdir, vdir, priority, limit)

    if #tbl == 0 then return tbl end
    for i = 1, #tbl do
        TrRect = Rect(tbl[i].x, tbl[i].y, 0, 0)
        -- 返回值换算
        if screen.Transform and
            (screen.MockMode == screen.MOCK_OUTPUT or screen.MockMode ==
                screen.MOCK_BOTH) then
            TrRect = screen.Transform(screen.MOCK_OUTPUT, TrRect)
        end
        tbl[i] = TrRect:tl()
    end

    return tbl
end

setmetatable(touch, {
    __tostring = function(self) return configs.touch end,
    __index = function(self, k) return Consttouchs[k] end,
    __newindex = function(self, k, v)
        if Consttouchs[k] then
            error("你不可以给常量赋值!")
        else
            rawset(self, k, v)
        end
    end
})

Consttouchs.KEY_HOME = 0
Consttouchs.KEY_BACK = 2
Consttouchs.KEY_MENU = 3
Consttouchs.KEY_POWER = 4
-- 下面2个按键的常数值不确定(虽然在1.9没什么卵用)
Consttouchs.KEY_VOLUME_UP = 5
Consttouchs.KEY_VOLUME_DOWN = 6
local KEY_LIST = {
    [Consttouchs.KEY_HOME] = "HOME",
    [Consttouchs.KEY_BACK] = "BACK",
    [Consttouchs.KEY_MENU] = "MENU",
    [Consttouchs.KEY_POWER] = "POWER",
    [Consttouchs.KEY_VOLUME_UP] = "VOLUME_UP",
    [Consttouchs.KEY_VOLUME_DOWN] = "VOLUME_DOWN"
}

function Consttouchs.down(index, ...)
    local t = {...}
    if type(index) ~= "number" then error("down函数传入参数错误") end
    local TrRect
    if type(t[1]) == "table" and tostring(t[1].__tag) == "Point" then
        TrRect = Rect(t[1].x, t[1].y, 0, 0)
    elseif type(t[1]) == "number" and type(t[2]) == "number" then
        TrRect = Rect(t[1], t[2], 0, 0)
    else
        error("down函数传入参数错误")
    end
    if screen.Transform and
        (screen.MockMode == screen.MOCK_INPUT or screen.MockMode ==
            screen.MOCK_BOTH) then
        TrRect = screen.Transform(screen.MOCK_INPUT_FIXED, TrRect)
    end
    local p = TrRect:tl()
    touchDown(index, p.x, p.y)
end

function Consttouchs.move(index, ...)
    local t = {...}
    if type(index) ~= "number" then error("move函数传入参数错误") end
    local TrRect
    if type(t[1]) == "table" and tostring(t[1].__tag) == "Point" then
        TrRect = Rect(t[1].x, t[1].y, 0, 0)
    elseif type(t[1]) == "number" and type(t[2]) == "number" then
        TrRect = Rect(t[1], t[2], 0, 0)
    else
        error("move函数传入参数错误")
    end
    if screen.Transform and
        (screen.MockMode == screen.MOCK_INPUT or screen.MockMode ==
            screen.MOCK_BOTH) then
        TrRect = screen.Transform(screen.MOCK_INPUT_FIXED, TrRect)
    end
    local p = TrRect:tl()
    touchMove(index, p.x, p.y)
end

function Consttouchs.up(index, ...)
    local t = {...}
    if type(index) ~= "number" then error("up函数传入参数错误") end
    local TrRect
    if type(t[1]) == "table" and tostring(t[1].__tag) == "Point" then
        TrRect = Rect(t[1].x, t[1].y, 0, 0)
    elseif type(t[1]) == "number" and type(t[2]) == "number" then
        TrRect = Rect(t[1], t[2], 0, 0)
    else
        error("up函数传入参数错误")
    end
    if screen.Transform and
        (screen.MockMode == screen.MOCK_INPUT or screen.MockMode ==
            screen.MOCK_BOTH) then
        TrRect = screen.Transform(screen.MOCK_INPUT_FIXED, TrRect)
    end
    local p = TrRect:tl()
    touchUp(index, p.x, p.y)
end

function Consttouchs.press(type, longPress) pressKey(KEY_LIST[type], longPress) end

function Consttouchs.doublePress(type)
    if type == Consttouchs.KEY_HOME then
        doublePressHomeKey()
    else
        error("1.9引擎暂不支持双击HOME键以外的其他按键")
    end
end

function Consttouchs.captureTap(count, timeoutMs)
    -- timeout在1.9引擎无效
    local TrRect
    local width, height
    width, height = getScreenSize() -- home在下
    local function captureTap()
        local x, y = catchTouchPoint(count) -- home在下的
        if _ORIENTATION_ == 2 then
            return height - y, x
        elseif _ORIENTATION_ == 1 then
            return y, width - x
        else
            return x, y
        end
    end
    local function captureTaps(count)
        local results = catchTouchPoint(count) -- home在下的
        for i = 1, #results do
            if _ORIENTATION_ == 2 then
                results[i].x, results[i].y = height - results[i].y, results[i].x
            elseif _ORIENTATION_ == 1 then
                results[i].x, results[i].y = results[i].y, width - results[i].x
            end
        end
        return results
    end
    if count then
        local results = captureTaps(count)
        for i = 1, #results do
            TrRect = Rect(results[i].x, results[i].y, 0, 0)
            -- 返回值换算
            if screen.Transform and
                (screen.MockMode == screen.MOCK_OUTPUT or screen.MockMode ==
                    screen.MOCK_BOTH) then
                TrRect = screen.Transform(screen.MOCK_OUTPUT, TrRect)
            end
            results[i] = TrRect:tl()
        end
        return results
    else
        local x, y = captureTap()
        TrRect = Rect(x, y, 0, 0)
        if screen.Transform and
            (screen.MockMode == screen.MOCK_OUTPUT or screen.MockMode ==
                screen.MOCK_BOTH) then
            TrRect = screen.Transform(screen.MOCK_OUTPUT, TrRect)
        end
        return TrRect:tl()
    end
end

setmetatable(storage, {
    __tostring = function(self) return configs.storage end,
    __index = function(self, k) return Conststorages[k] end,
    __newindex = function(self, k, v)
        if Conststorages[k] then
            error("你不可以给常量赋值!")
        else
            rawset(self, k, v)
        end
    end
})

local storageData = {} -- 缓存中的数据

function Conststorages.put(key, value)
    if type(key) ~= "string" then error("put函数参数错误") end
    if type(value) == "boolean" then
        value = "_*_" .. tostring(value) .. "_*_"
    end
    if type(value) ~= "number" or type(value) ~= "string" then
        error("put函数参数错误")
    end
    storageData[key] = value
end

function Conststorages.get(key, value)
    if type(key) ~= "string" then error("put函数参数错误") end
    local ret
    if type(value) == "number" then
        ret = storageData[key] or getNumberConfig(key, value)
        return ret
    elseif type(value) == "string" or type(value) == "boolean" then
        ret = storageData[key] or getStringConfig(key, "_*_EMPTY_*_")
        if ret == "_*_EMPTY_*_" then return value end
        if tostring(ret) == "_*_true_*_" then
            ret = true
        elseif tostring(ret) == "_*_false_*_" then
            ret = false
        end
        return ret
    else
        error("put函数参数错误")
    end
end

function Conststorages.commit()
    for k, v in pairs(storageData) do
        if type(v) == "number" then
            setNumberConfig(k, v)
        elseif type(v) == "string" then
            setStringConfig(k, v)
        end
    end
    return true
end

function Conststorages.undo() storageData = {} end

function Conststorages.purge()
    storageData = {}
    print(
        "警告:1.9引擎不支持清除保存的数据!该操作和storage.undo相同!(来自storage.purge函数)")
end

setmetatable(task, {
    __tostring = function(self) return configs.task end,
    __index = function(self, k) return Consttasks[k] end,
    __newindex = function(self, k, v)
        if Consttasks[k] then
            error("你不可以给常量赋值!")
        else
            rawset(self, k, v)
        end
    end
})

Consttasks.execTimer = setTimer

function Consttasks.execAsync(config, callback, content)
    asyncExec{
        config.type, true, -- 启用新线程
        config.url, config.headers, content, callback
    }
end

setmetatable(runtime, {
    __tostring = function(self) return configs.runtime end,
    __index = function(self, k) return Construntimes[k] end,
    __newindex = function(self, k, v)
        if Construntimes[k] then
            error("你不可以给常量赋值!")
        else
            rawset(self, k, v)
        end
    end
})

function Construntimes.vibrate(durationMs)
    for var = 0, durationMs, 1000 do
        vibrator()
        mSleep(1000)
    end
end

Construntimes.readClipboard = readPasteboard
Construntimes.writeClipboard = writePasteboard
Construntimes.inputText = inputText
Construntimes.launchApp = runApp
Construntimes.killApp = closeApp
Construntimes.isAppRunning = appIsRunning
Construntimes.getForegroundApp = frontAppName
Construntimes.openURL = openURL

Construntimes.android = {}
local Construntimeandroids = {__tag = "runtimeandroid"}

setmetatable(Construntimes.android, {
    __index = function(self, k) return Construntimeandroids[k] end,
    __newindex = function(self, k, v)
        if Construntimeandroids[k] then
            error("你不可以给常量赋值!")
        else
            rawset(self, k, v)
        end
    end
})

Construntimeandroids.getSystemProperty = getSystemProperty

Construntimes.ios = {}
local Construntimeioss = {__tag = "runtimeios"}

setmetatable(Construntimes.ios, {
    __index = function(self, k) return Construntimeioss[k] end,
    __newindex = function(self, k, v)
        if Construntimeioss[k] then
            error("你不可以给常量赋值!")
        else
            rawset(self, k, v)
        end
    end
})

Construntimeioss.resetLockTimer = resetIDLETimer

setmetatable(UI, {
    __tostring = function(self) return configs.UI end,
    __index = function(self, k) return ConstUIs[k] end,
    __newindex = function(self, k, v)
        if ConstUIs[k] then
            error("你不可以给常量赋值!")
        else
            rawset(self, k, v)
        end
    end
})

function ConstUIs.toast(msg, lenth) toast(msg) end
