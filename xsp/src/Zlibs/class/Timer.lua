local Zlog = require "Zlibs.class.Log"
local api = require "Zlibs.class.api"
local obj={}
local funcValues={}
local AllTimer={}
-- 魔术变量接口_插件用
obj._magicValues = funcValues
--默认变量
obj.__tag="Timer"
obj.name="default"
obj.createtime=-1
obj.updatetime=-1
obj.updatecount=0
obj.enable=false

obj.destroyed=false
--默认变量结束
--/////////////////////////////////////////
--/////////////////////////////////////////
--内部函数

--内部函数结束
--/////////////////////////////////////////
--/////////////////////////////////////////
--元表设置
function obj:__newindex(k,v)
	rawset(self,k,v)
	Zlog.warn("不建议的操作:设置了[%s]对象中[%s]元素的值为[%s]",self.__tag,tostring(k),tostring(v))
end
function obj:__index(k)
	if type(funcValues[k])=="function" then return funcValues[k](self) end
	if type(k)=="number" then return self.point[k] end
	return obj[k]
end
function obj:__tostring()
	return string.format("%s \"%s\" 创建于:%d,触发次数:%d,上次触发于:%d,",obj.__tag,self.name,self.createtime,self.updatecount,self.updatetime)
end
function obj:__call(name)
	if type(name)~="string" then
		Zlog.fatal("请使用字符串作为计时器的名称")
	end
	local o=setmetatable({name=name,createtime=api.mTime(),updatetime=api.mTime(),updatecount=0}, obj)
	AllTimer[name] = o
	return o
end
--元表设置结束
--/////////////////////////////////////////
--/////////////////////////////////////////
--自动变量
function funcValues.difftime(self)
    return api.mTime()-self.updatetime
end
function funcValues.survivetime(self)
    return api.mTime()-self.createtime
end
--自动变量结束
--/////////////////////////////////////////
--/////////////////////////////////////////
--成员函数
function obj.get(name)
	return AllTimer[name]
end
function obj.destroy(self)
	if type(self)=="string" then
		self=obj.get(self)
	end
	AllTimer[self.name]=nil
	rawset(self,"destroyed",true)
end
function obj.check(self,t,flag)
    if not self.enable then return false end
    if flag==nil then flag=true end
    local now=api.mTime()
    if now-self.updatetime>=t then
        if flag then
            self.updatetime=now
            self.updatecount=self.updatecount+1
        end
        return true
    end
    return false
end
function obj.reset(self,t)
    self.updatetime=t or api.mTime()
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
