local Config={}

Config.Point=[[
类Point : 坐标
实现2.0引擎Point类的所有功能
支持+、-、*、/、==和取反等基本运算。
]]
Config.Size=[[
类Size : 尺寸
实现2.0引擎Size类的所有功能
支持+、-、*、/、==和取反等基本运算。
]]
Config.Rect=[[
类Rect : 矩形
实现2.0引擎Rect类的所有功能
]]
Config.Color3B=[[
类Color3B : 颜色值(整型)
实现2.0引擎Color3B类的所有功能
]]
Config.Color3F=[[
类Color3F : 颜色值(浮点型)
实现2.0引擎Color3F类的所有功能
]]
Config.xmod=[[
xmod — 综合模块
实现2.0引擎xmod类的大部分功能
(下面是没有完全实现的)

xmod.PRODUCT_CODE--极少部分情况下会无法正确获取到小精灵的识别码
[文件目录相关]
xmod.getPublicPath--部分情况会无法正确获取,返回[public]
xmod.getPrivatePath--1.9引擎没有私有目录,返回[public]
xmod.resolvePath--适配了1.9引擎,会把[private]转化为[public],并且不会返回具体目录(具体目录在1.9引擎下无效)
xmod.setOnEventCallback--1.9引擎限制,xmod.EVENT_ON_RUNTIME_ERROR的回调没有直接实现,
    需要使用此功能的请把脚本主函数使用pcall调用,出错时调用onSpiritErrorExit函数,并传入errMsg
]]
Config.script=[[
script — 脚本控制模块
实现2.0引擎script类的大部分功能
(下面是没有完全实现的)

script.getResData--1.9引擎下无法获取,抛出error,请不要使用
]]
Config.screen=[[
screen — 界面图像模块
实现2.0引擎screen类的大部分功能
(下面是没有完全实现的)

【所有Image类相关在1.9引擎下均无法实现(强行实现运行效率也会很低,无意义)】
screen.getDPI--因为1.9引擎限制,在ios系统下可能会出现返回值不准的情况(不确定)
screen.capture--涉及Image类,1.9引擎无法实现,抛出错误

其余功能全部实现,包括screen.setMockTransform等函数
screen.findColors函数在1.9引擎只返回99个点的BUG已经修复
]]
Config.touch=[[
touch — 点按模块
实现2.0引擎touch类的大部分功能
(下面是没有完全实现的)


touch.press--在1.9引擎下只有HOME键,返回键,菜单键的控制会生效,其余都不会生效
touch.doublePress--同上
touch.captureTap--timeoutMs,等待时间的参数不会生效,在1.9引擎下最长会等待30/60秒

touch.captureTap函数在1.9引擎下返回值坐标系始终为竖屏的BUG已经修复,现在会跟随screen.init的方向返回对应坐标
]]
Config.storage=[[
storage — 简单存储模块
实现2.0引擎storage类的大部分功能
(下面是没有完全实现的)

storage.purge--1.9引擎没有提供清除保存数据的功能,无法实现,调用效果和storage.undo相同,同时打印出警告,不会抛出错误
]]
Config.task=[[
task — 任务执行模块
实现2.0引擎task类的所有功能
]]

Config.runtime=[[
runtime — 系统/运行时模块
实现2.0引擎runtime类的所有功能
]]
Config.UI=[[
UI — 内置UI模块

唯一实现的函数
UI:toast
并且第二个参数lenth不会生效
]]


return Config