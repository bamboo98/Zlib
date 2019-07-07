# Zlibs库  
##### Author: 竹子菌  
### [开发手册(在写了)](https://www.yuque.com/zhuzijun/zlibs)
### 将Zlibs导入自己脚本的方法：
- 1.点击右上角绿色‘Clone or download’按钮，选择‘Download Zip’
- 2.解压下载的所有文件，并将xsp/src中的所有文件（除了main.lua)，拷贝进自己的项目src文件夹中
- 3.请认真阅读开发手册
### 如果仅需将2.0引擎的代码转换至1.9引擎运行，请在拷贝所有文件之后，在自己脚本main.lua的开头第一行添加如下代码，无需其他任何操作
#### `require "Zlibs.ConvertApis"`
#### 项目src文件夹可以查看叉叉助手IDE中的`文件-设置工作区路径`其中的工作路径即为自己的项目总文件夹，打开路径后找到自己的项目文件夹，即可找到src源码文件夹
### 类  
Blackboard 行为控制-黑板 `local Blackboard = require "Zlibs.class.Blackboard"`  
Circle 圆 `local Circle = require "Zlibs.class.Circle"`  
Color 颜色 `local Color = require "Zlibs.class.Color"`  
Finger 触摸 `local Finger = require "Zlibs.class.Finger"`  
Http 网络访问 `local Http = require "Zlibs.class.Http"`  
Log 日志 `local ZLog = require "Zlibs.class.Log"`  
math 拓展库 `local math = require "Zlibs.class.math"`  
Point 点 `local Point = require "Zlibs.class.Point"`  
Rect 范围 `local Rect = require "Zlibs.class.Rect"`  
Region 不规则区域 `local Region = require "Zlibs.class.Region"`  
Scene 行为控制-场景 `local Scene = require "Zlibs.class.Scene"`  
Sequence 颜色序列 `local Sequence = require "Zlibs.class.Sequence"`  
Size 尺寸 `local Size = require "Zlibs.class.Size"`  
string 拓展库 `local string = require "Zlibs.class.string"`  
table 拓展库 `local table = require "Zlibs.class.table"`  
Timer 计时器 `local Timer = require "Zlibs.class.Timer"`  
### 工具  
DebugerHelper 调试助手 `require "Zlibs.tool.DebugerHelper"`  
JSON库 `local JSON = require "Zlibs.tool.JSON"`(注意JSON库调用需要使用JSON:decode格式,即冒号:,而非点.)  
RresetColor 预设颜色 `require "Zlibs.tool.RresetColor"`  
type 函数重定义 `local type = require "Zlibs.tool.type"`  
api转换,在叉叉1.9引擎环境运行大部分2.0引擎代码 `require "Zlibs.ConvertApis"`  
ZY库 对接竹云平台 `local ZY = require "Zlibs.tool.ZY"`
