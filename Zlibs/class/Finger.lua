local Zlog = require "Zlibs.class.Log"
local type = require "Zlibs.tool.type"
local math = require "Zlibs.class.math"
local Point = require "Zlibs.class.Point"

local api

local fingers = {true, true, true, true, true, true, true, true, true, true}
local obj = {}

local Finger = setmetatable({}, obj)

-- 默认变量
obj.__tag = "Finger"
obj.id = -1
obj.x = -1
obj.y = -1
obj.centerx = -1
obj.centery = -1

local function getFreeFinger()
    for i = 1, 10 do
        if fingers[i] then
            fingers[i] = false
            return i - 1
        end
    end
    Zlog.error(
        "所有手指都已经被占用,获取空闲手指ID失败,将返回默认ID(0),在某些情况下将会出现触摸操作错误")
    return 0
end

local function freeFinger(id)
    if fingers[id + 1] then
        return false
    else
        fingers[id + 1] = true
        return true
    end
end

local function getDistance(x1, y1, x2, y2)
    return math.sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2))
end

local function getWay(x1, y1, x2, y2, step, way)
    way = way or {{}, {}}
    step = step or 3
    local dis = getDistance(x1, y1, x2, y2)
    local num = math.floor(dis / step)
    local dtx, dty = (x2 - x1) / num, (y2 - y1) / num
    if #way[1] == 0 then
        way[1][1] = x1
        way[2][1] = y1
    end
    for i = 1, num do
        table.insert(way[1], math.round(dtx * i + x1))
        table.insert(way[2], math.round(dty * i + y1))
    end
    return way
end

local function getwaydistance(t)
    local dis = {}
    for i = 0, #t - 1 do
        table.insert(dis, getDistance(t[i].x, t[i].y, t[i + 1].x, t[i + 1].y))
    end
    return dis
end
-- 三次贝塞尔曲线 
local function bezier3funcX(uu, controlP)
    local part0 = controlP[1][1] * uu * uu * uu
    local part1 = 3 * controlP[2][1] * uu * uu * (1 - uu)
    local part2 = 3 * controlP[3][1] * uu * (1 - uu) * (1 - uu)
    local part3 = controlP[4][1] * (1 - uu) * (1 - uu) * (1 - uu)
    return math.round(part0 + part1 + part2 + part3)
end
local function bezier3funcY(uu, controlP)
    local part0 = controlP[1][2] * uu * uu * uu
    local part1 = 3 * controlP[2][2] * uu * uu * (1 - uu)
    local part2 = 3 * controlP[3][2] * uu * (1 - uu) * (1 - uu)
    local part3 = controlP[4][2] * (1 - uu) * (1 - uu) * (1 - uu)
    return math.round(part0 + part1 + part2 + part3)
end

local function getCurveWay(pos, poscount, speed, way)
    if poscount < 3 then Zlog.fatal("生成一条曲线需要至少3个点") end
    way = way or {{}, {}}
    local scale = 0.7 -- 曲线系数,0.1~1,大于1会导致鬼畜,越接近1越圆滑(绕得越远)
    local midpoints = {{}, {}}
    for i = 0, poscount - 1 do
        local nexti = (i + 1) % poscount
        midpoints[1][i] = (pos[i].x + pos[nexti].x) / 2
        midpoints[2][i] = (pos[i].y + pos[nexti].y) / 2
    end

    local extrapoints = {{}, {}}
    for i = 0, poscount - 1 do
        local nexti = (i + 1) % poscount
        if nexti == 0 then nexti = poscount - 1 end
        local backi = (i + poscount - 1) % poscount
        if backi == poscount - 1 then backi = 0 end
        local midinmidx = (midpoints[1][i] + midpoints[1][backi]) / 2
        local midinmidy = (midpoints[2][i] + midpoints[2][backi]) / 2
        local offsetx = pos[i].x - midinmidx
        local offsety = pos[i].y - midinmidy
        local extraindex = 2 * i
        extrapoints[1][extraindex] = midpoints[1][backi] + offsetx
        extrapoints[2][extraindex] = midpoints[2][backi] + offsety
        local addx = (extrapoints[1][extraindex] - pos[i].x) * scale
        local addy = (extrapoints[2][extraindex] - pos[i].y) * scale
        extrapoints[1][extraindex] = pos[i].x + addx
        extrapoints[2][extraindex] = pos[i].y + addy

        local extranexti = (extraindex + 1) % (2 * poscount)
        extrapoints[1][extranexti] = midpoints[1][i] + offsetx
        extrapoints[2][extranexti] = midpoints[2][i] + offsety
        addx = (extrapoints[1][extranexti] - pos[i].x) * scale
        addy = (extrapoints[2][extranexti] - pos[i].y) * scale
        extrapoints[1][extranexti] = pos[i].x + addx
        extrapoints[2][extranexti] = pos[i].y + addy
    end
    local controlPoints = {}
    local dis = getwaydistance(pos)
    for i = 0, poscount - 2 do
        controlPoints[1] = {pos[i].x, pos[i].y}
        local extraindex = 2 * i
        controlPoints[2] = {
            extrapoints[1][extraindex + 1], extrapoints[2][extraindex + 1]
        }
        local extranexti = (extraindex + 2) % (2 * poscount)
        controlPoints[3] = {
            extrapoints[1][extranexti], extrapoints[2][extranexti]
        }
        local nexti = (i + 1) % poscount
        controlPoints[4] = {pos[nexti].x, pos[nexti].y}
        if i == poscount - 2 then
            -- 绘制最后一个点时只需要一个控制点,否则会出现回弯
            controlPoints[3] = controlPoints[4]
        end
        local u = 1
        local dltu = 1 / (dis[i + 1] / 3) * speed
        while u >= 0 do
            local px = bezier3funcX(u, controlPoints)
            local py = bezier3funcY(u, controlPoints)
            u = u - dltu
            -- Zlog.trace("u=%.3f,x=%d,y=%d",u,px,py)
            table.insert(way[1], px)
            table.insert(way[2], py)
        end

    end

    return way
end

function obj:__newindex(k, v)
    rawset(self, k, v)
    Zlog.warn(
        "不建议的操作:设置了[%s]对象中[%s]元素的值为[%s]",
        self.__tag, tostring(k), tostring(v))
end

function obj:__index(k) return obj[k] end

function obj:__tostring()
    return string.format("%s id = %d , %s ", obj.__tag, self.id,
                         self.x == -1 and "未按下" or
                             ("按下: " .. self.x .. "," .. self.y))
end

function obj:__call()
    local o = setmetatable(
                  {id = -1, x = -1, y = -1, centerx = -1, centery = -1}, obj)
    return o
end

--- obj.down 在x,y点或point点按下手指,返回Finger
-- @param self self
-- @param ...  x,y或point
function obj.down(...)
    local param = {...}
    local self = param[1]
    local t
    if type(self) ~= "Finger" then
        t = param
        self = obj:__call()
    elseif self == Finger then -- 这么用的都是傻逼
        self = obj:__call()
        table.remove(param, 1)
        t = param
    else
        table.remove(param, 1)
        t = param
    end
    -- if type(self)~="Finger" or self==obj then
    --     table.insert(t,self)
    --     self=obj:__call()
    -- end
    if self.id == -1 then self.id = getFreeFinger() end
    if self.x ~= -1 then
        Zlog.error(
            "%s未松开即进行了按下操作,将会自动松开手指再按下,未松开的坐标(%d,%d)",
            tostring(self), self.x, self.y)
        self:up()
    end
    if #t == 1 then
        api.touchDown(self.id, t[1].x, t[1].y)
        self.x, self.y = t[1].x, t[1].y
    elseif #t == 2 then
        api.touchDown(self.id, t[1], t[2])
        self.x, self.y = t[1], t[2]
    end
    Zlog.trace("%d号手指在%d,%d按下", self.id, self.x, self.y)
    return self
end
--- obj.move 将手指移动到x,y或point点,没有按下时会报错
-- @param self self
-- @param ...  x,y或point
function obj.move(self, ...) -- 瞬移,不建议使用
    if self.x == -1 then
        Zlog.fatal("在移动手指之前你必须先按下(down)")
    end
    local t = {...}
    if #t == 1 then
        api.touchMove(self.id, t[1].x, t[1].y)
        self.x, self.y = t[1].x, t[1].y
    elseif #t == 2 then
        api.touchMove(self.id, t[1], t[2])
        self.x, self.y = t[1], t[2]
    end
    return self
end
--- obj.up 在x,y或point或当前按下的位置抬起手指,没有按下时会报错
-- @param self self
-- @param ...  x,y或point或nil
function obj.up(self, ...)
    if self.x == -1 then
        Zlog.fatal("在松开手指之前你必须先按下(down)")
    end
    local t = {...}
    Zlog.trace("%d号手指在%d,%d抬起", self.id, self.x, self.y)
    if #t == 1 then
        api.touchUp(self.id, t[1].x, t[1].y)
        self.x, self.y = -1, -1
    elseif #t == 2 then
        api.touchUp(self.id, t[1], t[2])
        self.x, self.y = -1, -1
    else
        api.touchUp(self.id, self.x, self.y)
        self.x, self.y = -1, -1
    end
    freeFinger(self.id)
    self.id = -1
    self.centerx = -1
    self.centery = -1
    return self
end
--- obj.simpleMove 简单直线滑动,可以传入单个目标点或多个目标点连续滑动
-- @param self        self,为nil时为简单滑动模式,自动分配手指并且按下滑动,滑动结束自动抬起手指,不为nil时如果没有按下会自动按下并滑动,滑动结束后不会抬起手指,需要手动up或进行其他操作
-- @param t           滑动路径,单个point或table
-- @param step        滑动每步的最大步长
-- @param delay       滑动每步之间的延迟,毫秒,建议0
-- @param slowlyOnEnd 在滑动快结束的时候额外的线性延迟总时间,毫秒,在滑动最后1/5的步骤或倒数50步时开始减速
function obj.simpleMove(...)
    local param = {...}
    local self = param[1]
    local t, step, delay, slowlyOnEnd
    local simplemode = false
    if type(param[1]) ~= "Finger" then
        simplemode = true
        self = obj.__call()
        t, step, delay, slowlyOnEnd = param[1], param[2] or 4, param[3] or 0,
                                      param[4] or 0
    elseif param[1] == Finger then -- 这么用的都是傻逼
        simplemode = true
        self = obj.__call()
        t, step, delay, slowlyOnEnd = param[2], param[3] or 4, param[4] or 0,
                                      param[5] or 0
    else
        t, step, delay, slowlyOnEnd = param[2], param[3] or 4, param[4] or 0,
                                      param[5] or 0
    end
    if self.id == -1 then
        if type(t) == "Point" then
            self:down(t)
        elseif type(t) == "table" then
            self:down(table.remove(t, 1))
        end
    elseif self.x == -1 then
        Zlog.fatal("在移动手指之前你必须先按下(down)")
    end
    local way
    delay = delay or 0
    if type(t) == "Point" then
        way = getWay(self.x, self.y, t.x, t.y, step, way)
    elseif type(t) == "table" then
        way = getWay(self.x, self.y, t[1].x, t[1].y, step, way)
        for i = 2, #t do
            way = getWay(t[i - 1].x, t[i - 1].y, t[i].x, t[i].y, step, way)
        end
    end
    local slowlynum = math.max(math.floor(#way[1] / 5), 50)
    for i = 1, #way[1] - slowlynum do
        if delay > 0 then api.mSleep(delay) end
        self:move(way[1][i], way[2][i])
    end
    local dta = 0
    local stept = slowlyOnEnd / slowlynum / slowlynum
    for i = #way[1] - slowlynum + 1, #way[1] do
        dta = dta + 1
        api.mSleep(delay + math.round(stept * dta))
        self:move(way[1][i], way[2][i])
    end
    if simplemode then self:up() end
    return self
end
--- obj.curveMove 曲线滑动,平滑经过所有的传入点,如果已经down,需要传入至少2个点,如果没有down,需要传入至少3个点
-- @param self        self为nil时为简单滑动,需要传入至少3个点,滑动结束后会自动抬起手指,不为nil时,滑动结束不会抬起手指,可以进行后续其他的滑动操作
-- @param t           table,滑动经过的点
-- @param speed       滑动速度默认1,越大点之间的间隔越大
-- @param delay       滑动每步的额外延迟,建议0
-- @param slowlyOnEnd 在滑动快结束的时候额外的线性延迟总时间,毫秒,在滑动最后1/5的步骤或倒数50步时开始减速
function obj.curveMove(...)
    local param = {...}
    local self = param[1]
    local t, speed, delay, slowlyOnEnd
    local simplemode = false
    if type(param[1]) ~= "Finger" then
        simplemode = true
        self = obj.__call()
        t, speed, delay, slowlyOnEnd = param[1], param[2] or 1, param[3] or 0,
                                       param[4] or 0
    elseif param[1] == Finger then
        simplemode = true
        self = obj.__call()
        t, speed, delay, slowlyOnEnd = param[2], param[3] or 1, param[4] or 0,
                                       param[5] or 0
    else
        t, speed, delay, slowlyOnEnd = param[2], param[3] or 1, param[4] or 0,
                                       param[5] or 0
    end
    if self.id == -1 then
        if type(t) == "Point" then
            self:down(t)
        elseif type(t) == "table" then
            self:down(table.remove(t, 1))
        end
    elseif self.x == -1 then
        Zlog.fatal("在移动手指之前你必须先按下(down)")
    end
    -- table.insert(t,1,{x=self.x,y=self.y})
    t[0] = {x = self.x, y = self.y}
    local way
    way = getCurveWay(t, #t + 1, speed, way)
    delay = delay or 0
    local slowlynum = math.max(math.floor(#way[1] / 5), 50)
    for i = 1, #way[1] - slowlynum do
        if delay > 0 then api.mSleep(delay) end
        self:move(way[1][i], way[2][i])
    end
    local dta = 0
    local stept = slowlyOnEnd / slowlynum / slowlynum * 2
    for i = #way[1] - slowlynum + 1, #way[1] do
        dta = dta + 1
        api.mSleep(delay + math.round(stept * dta))
        self:move(way[1][i], way[2][i])
    end
    if simplemode then
        api.mSleep(200)
        self:up()
    end
end
--- obj.rockerMove 摇杆式滑动,在首次调用该滑动时,会记录当前点的坐标作为中心坐标,在下次up之前,会始终使用中心坐标作为圆心去滑动
-- @param self  self,需要预先down
-- @param angle 滑动的角度
-- @param r     滑动的半径
function obj.rockerMove(self, angle, r)
    if self.x == -1 then
        Zlog.fatal("在移动手指之前你必须先按下(down)")
    end
    angle = angle % 360
    if self.centerx == -1 then
        -- 记录移动的圆心
        self.centerx, self.centery = self.x, self.y
    end
    local t = Point(self.centerx, self.centery) - {angle, r}
    self:simpleMove(t, 3, 0, 0)
end
--- obj.scaleMoveEnlarge 双指放大,以center为中心,手指移动距离为size的width和height
-- @param center 放大的中心,Point
-- @param size   手指移动距离为Size的width和height
function obj.scaleMoveEnlarge(center, size)
    local p1 = Point(center.x + 0.2 * size.width, center.y + 0.2 * size.height)
    local p2 = Point(center.x - 0.2 * size.width, center.y - 0.2 * size.height)
    local way1, way2
    way1 = getWay(p1.x, p1.y, center.x + size.width, center.y + size.height, 3,
                  way1)
    way2 = getWay(p2.x, p2.y, center.x - size.width, center.y - size.height, 3,
                  way2)
    local step = math.min(#way1[1], #way2[1])
    local f1, f2 = obj.down(nil, p1), obj.down(nil, p2)
    for i = 1, step do
        f1:move(way1[1][i], way1[2][i])
        f2:move(way2[1][i], way2[2][i])
    end
    f1:move(way1[1][#way1[1]], way1[2][#way1[2]])
    f2:move(way2[1][#way2[1]], way2[2][#way2[2]])
    api.mSleep(150)
    f1:up()
    f2:up()
end
--- obj.scaleMoveEnlarge 双指缩小,以center为中心,手指移动距离为size的width和height
-- @param center 缩小的中心,Point
-- @param size   手指移动距离为Size的width和height
function obj.scaleMoveShrink(center, size)
    local p1 = Point(center.x + size.width, center.y + size.height)
    local p2 = Point(center.x - size.width, center.y - size.height)
    local way1, way2
    way1 = getWay(p1.x, p1.y, center.x + 0.2 * size.width,
                  center.y + 0.2 * size.height, 3, way1)
    way2 = getWay(p2.x, p2.y, center.x - 0.2 * size.width,
                  center.y - 0.2 * size.height, 3, way2)
    local step = math.min(#way1[1], #way2[1])
    local f1, f2 = obj.down(nil, p1), obj.down(nil, p2)
    for i = 1, step do
        f1:move(way1[1][i], way1[2][i])
        f2:move(way2[1][i], way2[2][i])
    end
    f1:move(way1[1][#way1[1]], way1[2][#way1[2]])
    f2:move(way2[1][#way2[1]], way2[2][#way2[2]])
    api.mSleep(150)
    f1:up()
    f2:up()
end
--- obj.tap 快速点击
-- @param ... x,y或Point
function obj.tap(...)
    local f = obj.down(...)
    api.mSleep(25)
    f:up()
end
local unpack = table.unpack or unpack

--- obj.hold 在某点按住t毫秒
-- @param ... x,y,t或point,t
function obj.hold(...)
    local t = {...}
    local d = table.remove(t, #t)
    local f = obj.down(unpack(t))
    api.mSleep(d)
    f:up()
end

-- 类初始化函数,因为会循环引用,所以需要单独用函数初始化
function obj._init() if not api then api = require "Zlibs.class.api" end end

return Finger
