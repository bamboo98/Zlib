--require"Z".init()

local DebugHelper = require "Zlibs.tool.DebugHelper"
local Zlog = require "Zlibs.class.Log"
Zlog.logLevel(Zlog.level.info)
Zlog.info('日志模块加载成功')
local Point = require "Zlibs.class.Point"
Zlog.info(Point(300, 300))
local Size = require "Zlibs.class.Size"
Zlog.info(Size(300, 300))
local Rect = require "Zlibs.class.Rect"
-- 设置Rect类使用的坐标格式为1.9引擎的"x1,y1,x2,y2"
require"Zlibs.class.Rect".setLocationMode(1)
Zlog.info(Rect(0, 0, 300, 300))
-- -- 设置Rect类使用的坐标格式为2.0引擎的"x1,y1,width,height"
-- require "Zlibs.class.Rect".setLocationMode(2)
local Color = require "Zlibs.class.Color"
Zlog.info(Color(0x33ccff))
local Sequence = require "Zlibs.class.Sequence"
Sequence "序列1" "100|100|0x3366ff-0x010101,120|101|0x3366ff|95,130|120|0x3366ff-0x010101,80|20|0xffffff|85"
Zlog.info(Sequence.get "序列1")
DebugHelper.checkMemoryUsed()
--[[ 输出结果 :
[0] Info: 日志模块加载成功
[0] Info: Point(300 ,300)
[0] Info: Size(300 ,300)
[0] Info: Rect(0, 0, 300, 300)
[0] Info: Color(51 ,204 ,255)
[0] Info: Sequence "序列1" "100|100|0x3366ff-0x010101,120|101|0x3366ff|95,130|120|0x3366ff-0x010101,80|20|0xffffff|85"
[0] Info: 当前内存使用:168.163kb
--]]

-- local http = require "Zlibs.class.Http"

-- local bb=require "Zlibs.class.BlackBoard"

-- Point "测试点" {pos=Point(100,100),color=0x3366ff,offset=0x010101}
-- Point "测试点2" "100|100|0x3366ff-0x010101"
-- print(Point.get "测试点",Point.get "测试点2")
-- Rect "测试区域" {100,100,150,150}
-- Rect "测试区域2" "100,100,150,150"
-- print(Rect.get "测试区域",Rect.get "测试区域2")

-- Sequence "序列1" "100|100|0x3366ff-0x010101,120|101|0x3366ff|95,130|120|0x3366ff-0x010101,80|20|0xffffff|85"
-- print(Sequence.get "序列1")
-- Sequence "序列2"{
--     {pos = Point(0, 0), color = 0x181F85},
--     {pos = Point(29, 1), color = 0x00BBFE, fuzz = 90},
--     {pos = Point(103, -4), color = 0x0B6BBE, offset = 0x050505},
--     {pos = Point(65, 9), color = 0x150972}
-- }
-- print(Sequence.get "序列2")
-- print(Sequence.get "序列1")
-- print(Sequence.get "序列1"[2])

-- local ZY=require "Zlibs.tool.ZY"
-- 竹云库初始化
-- ZY.init()--具体参数进入文件Zlibs.tool.ZY.lua中设置,自带叉叉init函数的调用

-- 输出结果: ''
-- DebugHelper.checkMemoryUsed()

-- Sequence "序列1" "100|100|0x3366ff-0x010101,120|101|0x3366ff|95,130|120|0x3366ff-0x010101,80|20|0xffffff|85"
-- -- 输出结果: 'Sequence "序列1" "100|100|0x3366ff-0x010101,120|101|0x3366ff|95,130|120|0x3366ff-0x010101,80|20|0xffffff|85"'
-- print(Sequence.get "序列1")
-- Sequence "序列2"{
--     {pos = Point(0, 0), color = 0x181F85},
--     {pos = Point(29, 1), color = 0x00BBFE, fuzz = 90},
--     {pos = Point(103, -4), color = 0x0B6BBE, offset = 0x050505},
--     {pos = Point(65, 9), color = 0x150972}
-- }
-- -- 输出结果: 'Sequence "序列2" "0|0|0x181f85,29|1|0x00bbfe|90,103|-4|0x0b6bbe-0x050505,65|9|0x150972"'
-- print(Sequence.get "序列2")

-- DebugHelper.checkMemoryUsed()

-- init("0",0)
-- local f1=Finger()
-- f1:tap(456,131)
-- -- f1:down(622,570)
-- -- f1:curveMove({Point(335,664),Point(435,964),Point(701,1042),Point(739,1240),Point(445,1315)}
-- -- ,5,0,1000)
-- -- f1:up()
-- -- Finger.tap(456,131)
-- -- Finger.curveMove({Point(622,570),Point(335,664),Point(435,964),Point(701,1042),Point(739,1240),Point(445,1315)}
-- -- ,5,0,1000)
-- -- Finger:tap(456,131)
-- -- Finger:curveMove({Point(622,570),Point(335,664),Point(435,964),Point(701,1042),Point(739,1240),Point(445,1315)}
-- -- ,5,0,1000)
-- -- Finger:tap(456,131)
-- Finger:simpleMove({Point(622,570),Point(335,664),Point(435,964),Point(701,1042),Point(739,1240),Point(445,1315)}
-- ,5,0,1000)
-- Finger:curveMove({Point(622,570),Point(335,664),Point(435,964),Point(701,1042),Point(739,1240),Point(445,1315)}
-- ,5,0,1000)

-- local Blackboard= require "Zlibs.class.Blackboard"
-- local Scene= require "Zlibs.class.Scene"

-- local b1=Blackboard "黑板1"
-- local s1=b1:createScene "场景1"

-- local s2=s1:createchild "场景1的子场景"

-- s1.trigger=function(Blackboard,scene)
--     return Blackboard.a<5
-- end

-- s1.behavior=function(Blackboard,scene)
--     scene.count = (scene.count or 0)+1
--     Blackboard.a = Blackboard.a+1
--     print("s1被触发,已经触发了"..scene.count.."次")
-- end

-- s2.trigger=function(Blackboard,scene)
--     return Blackboard.a==3
-- end
-- s2.behavior=function(Blackboard,scene)
--     scene.count = (scene.count or 0)+1
--     Blackboard.a = Blackboard.a+1
--     print("s2被触发,已经触发了"..scene.count.."次")
-- end

-- b1.a=1

-- s1.runcount=1--设置s1在触发之后会运行1次behavior--0则不会运行,-1则会一直循环运行,默认为1
-- --如果在循环执行中,behavior返回值为false,则会终止循环,也就是说如果要使循环生效,需要behavior返回true,不然至多只会运行1次(无返回值等同false)
-- s1.cuttime=1000--设置s1在触发之后的场景切换最大时间为1000ms,在1000ms内会一直尝试检测s1的子场景和s1本身能否再被触发
-- --(如果是一直循环调用的,不建议设置此项(默认为0),有造成爆栈的风险)
-- s1:run()
-- local Point={}
-- local mt={}
-- setmetatable(Point,mt)

-- function mt:__call(...)
--     local t={...}
--     local x,y=0,0
--     if #t==1 then
--         x,y=t[1].x,t[1].y
--     elseif #t==2 then
--         x,y=...--x,y=unpack(t)
--     end
--     return setmetatable({x=x,y=y},mt)
-- end

-- function mt:__tostring()
--     return string.format("Point(%d, %d)",self.x,self.y)
-- end

-- Point.ZERO=Point(0,0)
-- Point.INVALID=Point(-1,-1)

-- local point = Point(100, 200)
-- -- 输出结果: 'point = Point(100, 200)'
-- print('point = ' .. tostring(point))
-- print(tostring(Point.ZERO))
-- print(tostring(Point.INVALID))

-- local ZY=require "Zlibs.tool.ZY"

-- ZY.init()

-- ZY.getCG "主界面"

-- local sq=Sequence.get
-- if sq "左上设置按钮":match(95)  and sq "左侧玩家名牌":match(95) then
--     Point.get "进入作战":tap()
-- else
--     sq "左上返回按钮":matchTap(95)
-- end
