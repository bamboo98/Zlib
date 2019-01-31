local Z={}
Z.info=[[
Zlibs[Z库]
适配叉叉助手

Version: 0.0.1
Author: 竹子菌
QQ: 454689880
Updated: 2019年1月25日03:57:16
Project: https://github.com/bamboo98/Zlib

函数列表:
Z.loadNewApis--api转换模块(2.0转换1.9)
Z.getJson--获取Json库,返回值json对象(2.0运行自动获取Cjson库,1.9运行自动获取Zlibs中的Json库)
z.getSocketLib--获取Socket库,传入参数libName模块名称(dns/http/ltn12/socket/smtp/ftp等),根据2.0或者1.9引擎自动获取
]]


Z.loadNewApis=function()
	sysLog("开始加载Zlib-api转换模块(2.0转换1.9),转换完成后将再输出一条消息")
	require "Zlibs.ConvertApis"

	printf("%s",[[
这条消息由printf函数发出,看到这条消息即为转换成功,现在可以在1.9引擎上运行大多数2.0引擎的代码了
基础函数
print,log,printf,sleep,os.netTime,os.milliTime
----------
基础类
Point,Size,Rect,Color3B,Color3F,xmod,
script,screen,touch,storage,task,runtime,UI
以上基础类您可以直接print(类名)查看类的具体实现信息

附:叉叉2.0的开发手册https://www.yuque.com/irvinpang/xxzhushou/xmod_api
]])
end

Z.getJson=function()
	--尝试直接加载2.0的json库
	local ok, json = pcall(require, 'cjson')
	if ok then return json end
	--加载1.9的lua版JSON库
	local lo_json = {}
	local obj = require('Zlibs.JSON')
	lo_json.decode = function(x) return obj:decode(x) end
	lo_json.encode = function(x) return obj:encode(x) end
	lo_json.encode_pretty = function(x) return obj:encode_pretty(x) end;
	local json = lo_json
	return json
end

Z.getSocketLib=function(LibName)--需要传入子模块名(dns/http/ltn12/socket/smtp/ftp等)
	local ok, lib = pcall(require, 'socket.'..LibName)
	if ok then return lib end
	return require('Zlibs.socket.'..LibName)
end

return Z