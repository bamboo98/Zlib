local Zlog = require "Zlibs.class.Log"
local math = require "Zlibs.class.math"
local type = require "Zlibs.tool.type"
local obj={}
local funcValues={}

-- 魔术变量接口_插件用
obj._magicValues = funcValues
--默认变量
obj.__tag="Size"
obj.width=-1
obj.height=-1
--默认变量结束
--/////////////////////////////////////////
--/////////////////////////////////////////
--元表设置
function obj:__newindex(k,v)
	rawset(self,k,v)
	Zlog.warn("不建议的操作:设置了[%s]对象中[%s]元素的值为[%s]",self.__tag,tostring(k),tostring(v))
end
function obj:__index(k)
	if type(funcValues[k])=="function" then return funcValues[k](self) end
	return obj[k]
end
function obj:__tostring()
	return string.format("%s(%d ,%d)",obj.__tag,self.width,self.height)
end
function obj:__add(s)
	return obj:__call(self.width+s.width,self.height+s.height)
end
function obj:__sub(s)
	return obj:__call(self.width-s.width,self.height-s.height)
end
function obj:__mul(n)
	return obj:__call(math.round(self.width*n),math.round(self.height*n))
end
function obj:__div(n)
	return obj:__call(math.round(self.width/n),math.round(self.height/n))
end
function obj:__unm()
	return obj:__call(-self.width,-self.height)
end
function obj:__eq(s)
	return self.width==s.width and self.height==s.height
end
function obj:__lt(s)
	return self.area < s.area
end

function obj:__call(...)
	local o={}
	local t={...}
	local w,h
	if #t==0 then
		w,h=0,0
	elseif #t==1 and type(t[1])=="Point" then
		w,h=t[1].x,t[1].y
	elseif #t==1 and type(t[1])=="Size" then
		w,h=t[1].width,t[1].height
	elseif #t==1 and type(t[1])=="number" then
		w,h=t[1],t[1]
	elseif #t==2 then
		w,h=math.round(t[1]),math.round(t[2])
	else
		Zlog.fatal("[%s]创建时参数传入错误",self.__tag)
	end
	o.width,o.height=math.round(w),math.round(h)
	return setmetatable(o, obj)
end
--元表设置结束
--/////////////////////////////////////////
--/////////////////////////////////////////
--自动变量
function funcValues.area(self)
	return self.width*self.height
end

--自动变量结束
--/////////////////////////////////////////
--/////////////////////////////////////////
--内部函数

--内部函数结束
--/////////////////////////////////////////
--/////////////////////////////////////////
--成员函数
--成员函数结束
--/////////////////////////////////////////
--/////////////////////////////////////////
--类初始化
--rawset(_G,obj.__tag,setmetatable({},obj))
obj.INVALID=obj:__call(-1, -1)
obj.ZERO=obj:__call(0, 0)
return setmetatable({},obj)
--类初始化结束
--/////////////////////////////////////////
--/////////////////////////////////////////
