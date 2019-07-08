local obj={}
local funcValues={}
local print=print
local unpack=rawget(_G,"unpack") or table.unpack
--默认变量
obj.__tag="Zlog"
obj.level={
	trace=1,
	debug=2,
	info=3,
	warn=4,
	error=5,
	fatal=6,
	"trace",
	"debug",
	"info",
	"warn",
	"error",
	"fatal"
}
obj.printlevel=1
obj.writetofile=false
obj.time=os.time()
obj.logcount=0
local f
obj.lastfilename=false
obj.nowfilename=false
--默认变量结束
--/////////////////////////////////////////
--/////////////////////////////////////////
--元表设置
function obj.__newindex(self,k,v)
	rawset(self,k,v)
	obj.warn("不建议的使用方法,设置了[%s]对象[%s]元素的值为[%s]",self.__tag,tostring(k),tostring(v))
end
function obj.__index(self,k)
	if type(funcValues[k])=="function" then return funcValues[k]() end
	return obj[k]
end
function obj.__tostring()
	return string.format("[%s]当前输出级别:[%s] 已输出[%d]条日志",obj.__tag,obj.level[obj.printlevel],obj.logcount)
end

--元表设置结束
--/////////////////////////////////////////
--/////////////////////////////////////////
--自动变量

--自动变量结束
--/////////////////////////////////////////
--/////////////////////////////////////////
--内部函数

--内部函数结束
--/////////////////////////////////////////
--/////////////////////////////////////////
--成员函数
--- obj.logLevel 设置日志等级,低于此等级的日志不会被输出
-- @param level 日志等级,传入为Zlog.level.trace/Zlog.level.fatal等
function obj.logLevel(level)
	obj.printlevel=level
end
--- obj.tofile 设置日志是否保存到文件
-- @param flag true保存,false不保存,多次调用此函数可以保存到不同的文件里,用Zlog.lastfilename获取上一个日志的文件名,nowfilename为当前日志的文件名,但是file没有close可能会无法正常读取
function obj.tofile(flag)
	if flag then
		if not f then
			obj.nowfilename='[public]Zlog_'..os.date("%Y_%m_%d_%H_%M_%S"..".txt")
			f=io.open(obj.nowfilename,'w')
		else
			f:close()
			obj.lastfilename=obj.nowfilename
			obj.nowfilename='[public]Zlog_'..os.date("%Y_%m_%d_%H_%M_%S"..".txt")
			f=io.open(obj.nowfilename,'w')
		end
		obj.writetofile=true
	else
		if f then
			f:close()
			obj.lastfilename=obj.nowfilename
			obj.nowfilename=false
			f=nil
		end
		obj.writetofile=false
	end
end
--- obj.trace 输出日志,等级trace
-- @param s   同string.format参数
-- @param ... 同string.format参数
function obj.trace(s,...)
	if obj.printlevel<=obj.level.trace then
		local t={...}
		for i=1,#t do
			t[i]=tostring(t[i])
		end
		s=string.format(tostring(s),unpack(t))
		s=string.format("[%s] Trace: %s",os.time()-obj.time,s)
		print(s)
		if obj.writetofile then
			f:write(s.."\r\n")
		end
		obj.logcount=obj.logcount+1
	end
end
--- obj.debug 输出日志,等级debug
-- @param s   同string.format参数
-- @param ... 同string.format参数
function obj.debug(s,...)
	if obj.printlevel<=obj.level.debug then
		local t={...}
		for i=1,#t do
			t[i]=tostring(t[i])
		end
		s=string.format(tostring(s),unpack(t))
		s=string.format("[%s] Debug: %s",os.time()-obj.time,s)
		print(s)
		if obj.writetofile then
			f:write(s.."\r\n")
		end
		obj.logcount=obj.logcount+1
	end
end
--- obj.info 输出日志,等级info
-- @param s   同string.format参数
-- @param ... 同string.format参数
function obj.info(s,...)
	if obj.printlevel<=obj.level.info then
		local t={...}
		for i=1,#t do
			t[i]=tostring(t[i])
		end
		s=string.format(tostring(s),unpack(t))
		s=string.format("[%s] Info: %s",os.time()-obj.time,s)
		print(s)
		if obj.writetofile then
			f:write(s.."\r\n")
		end
		obj.logcount=obj.logcount+1
	end
end
--- obj.warn 输出日志,等级warn
-- @param s   同string.format参数
-- @param ... 同string.format参数
function obj.warn(s,...)
	if obj.printlevel<=obj.level.warn then
		local t={...}
		for i=1,#t do
			t[i]=tostring(t[i])
		end
		s=string.format(tostring(s),unpack(t))
		s=string.format("[%s] Warn: %s",os.time()-obj.time,s)
		print(s)
		if obj.writetofile then
			f:write(s.."\r\n")
		end
		obj.logcount=obj.logcount+1
	end
end
--- obj.error 输出日志,等级error
-- @param s   同string.format参数
-- @param ... 同string.format参数
function obj.error(s,...)
	if obj.printlevel<=obj.level.error then
		local t={...}
		for i=1,#t do
			t[i]=tostring(t[i])
		end
		s=string.format(tostring(s),unpack(t))
		s=string.format("[%s] ERROR: %s",os.time()-obj.time,s)
		print(s)
		if obj.writetofile then
			f:write(s.."\r\n")
		end
		obj.logcount=obj.logcount+1
	end
end
--- obj.fatal 输出日志,等级fatal,此方法会抛出error错误
-- @param s   同string.format参数
-- @param ... 同string.format参数
function obj.fatal(s,...)
	if obj.printlevel<=obj.level.fatal then
		local t={...}
		for i=1,#t do
			t[i]=tostring(t[i])
		end
		s=string.format(tostring(s),unpack(t))
		s=string.format("[%s] __FATAL__: %s",os.time()-obj.time,s)
		print(s)
		if obj.writetofile then
			f:write(s.."\r\n")
		end
		obj.logcount=obj.logcount+1
		error(s)
	end
end
--成员函数结束
--/////////////////////////////////////////
--/////////////////////////////////////////
--类初始化
--rawset(_G,obj.__tag,setmetatable({},obj))
return setmetatable({},obj)
--类初始化结束
--/////////////////////////////////////////
--/////////////////////////////////////////
