math.randomseed(os.time())
--init("0",1)

require "Z".init()


local DebugHelper = require "Zlibs.tool.DebugHelper"
local log = require "Zlibs.class.Log"
local Point = require "Zlibs.class.Point"
local Size = require "Zlibs.class.Size"
local Rect = require "Zlibs.class.Rect"
-- 设置Rect类使用的坐标格式为1.9引擎的"x1,y1,x2,y2"
require "Zlibs.class.Rect".setLocationMode(1)
-- 设置Rect类使用的坐标格式为2.0引擎的"x1,y1,width,height"
-- require "Zlibs.class.Rect".setLocationMode(2)
local Color = require "Zlibs.class.Color"
local Circle = require "Zlibs.class.Circle"
local Region = require "Zlibs.class.Region"
local Sequence = require "Zlibs.class.Sequence"
local Finger = require "Zlibs.class.Finger"
-- local Group = require "Zlibs.class.Group"



DebugHelper.checkMemoryUsed()
--local http = require "Zlibs.class.Http"

--local bb=require "Zlibs.class.BlackBoard"

-- Point "测试点" {pos=Point(100,100),color=0x3366ff,offset=0x010101}
-- Point "测试点2" "100|100|0x3366ff-0x010101"
-- print(Point.get "测试点",Point.get "测试点2")
-- Rect "测试区域" {100,100,150,150}
-- Rect "测试区域2" "100,100,150,150"
-- print(Rect.get "测试区域",Rect.get "测试区域2")

-- Sequence "序列1" "100|100|0x3366ff-0x010101,120|101|0x3366ff|95,130|120|0x3366ff-0x010101,80|20|0xffffff|85"

-- print(Sequence.get "序列1")
-- print(Sequence.get "序列1"[2])

--local ZY=require "Zlibs.tool.ZY"
--竹云库初始化
--ZY.init()--具体参数进入文件Zlibs.tool.ZY.lua中设置,自带叉叉init函数的调用
local string= require "Zlibs.class.string"
init("0",0)
local f1=Finger()
f1:tap(456,131)
-- f1:down(622,570)
-- f1:curveMove({Point(335,664),Point(435,964),Point(701,1042),Point(739,1240),Point(445,1315)}
-- ,5,0,1000)
-- f1:up()
-- Finger.tap(456,131)
-- Finger.curveMove({Point(622,570),Point(335,664),Point(435,964),Point(701,1042),Point(739,1240),Point(445,1315)}
-- ,5,0,1000)
-- Finger:tap(456,131)
-- Finger:curveMove({Point(622,570),Point(335,664),Point(435,964),Point(701,1042),Point(739,1240),Point(445,1315)}
-- ,5,0,1000)
-- Finger:tap(456,131)
Finger:simpleMove({Point(622,570),Point(335,664),Point(435,964),Point(701,1042),Point(739,1240),Point(445,1315)}
,5,0,1000)
Finger:curveMove({Point(622,570),Point(335,664),Point(435,964),Point(701,1042),Point(739,1240),Point(445,1315)}
,5,0,1000)
