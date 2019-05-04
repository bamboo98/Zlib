local Zlog = require "Zlibs.class.Log"
local math = require "Zlibs.class.math"
local type = require "Zlibs.tool.type"
local obj={}
local funcValues={}
local abs=math.abs

--默认变量
obj.__tag="Color"
obj.r=0
obj.g=0
obj.b=0
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
	return string.format("%s(%d ,%d ,%d)",obj.__tag,self.r,self.g,self.b)
end
function obj:__add(s)
	return obj:__call(self.r+s.r,self.g+s.g,self.b+s.b)
end
function obj:__sub(s)
	return obj:__call(self.r-s.r,self.g-s.g,self.b-s.b)
end
function obj:__unm()
	return obj:__call(-self.r,-self.g,-self.b)
end
function obj:__eq(s)
	return self.r==s.r and self.g==s.g and self.b==s.b
end

function obj:__call(...)
	local o={}
	local t={...}
	local r,g,b
	if #t==0 then
		r,g,b=0,0,0
	elseif #t==1 and type(t[1])=="Color" then
		r,g,b=t[1].r,t[1].g,t[1].b
	elseif #t==1 and type(t[1])=="number" then
		r,g,b=math.floor(t[1]/0x10000),math.floor(t[1]/0x100%0x100),t[1]%0x100
	elseif #t==1 and type(t[1])=="string" then
		t[1]=tonumber(t[1],16)
		r,g,b=math.floor(t[1]/0x10000),math.floor(t[1]/0x100%0x100),t[1]%0x100
	elseif #t==3 then
		r,g,b=math.round(t[1]),math.round(t[2]),math.round(t[3])
	else
		Zlog.fatal("[%s]创建时参数传入错误",self.__tag)
	end
	o.r,o.g,o.b=math.min(255,math.max(0,r)),math.min(255,math.max(0,g)),math.min(255,math.max(0,b))
	return setmetatable(o, obj)
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
function obj.toInt(self)
	return self.r*0x10000+self.g*0x100+self.b
end
function obj.toString(self)
	return string.format("0x%02x%02x%02x",self.r,self.g,self.b)
end
function obj.match(self,other,fuzz)
	fuzz=fuzz or 100
	fuzz=(100-fuzz)/100*0xff
	return abs(self.r-other.r)<=fuzz and abs(self.g-other.g)<=fuzz and abs(self.b-other.b)<=fuzz
end
function obj.matchRGB(self,r,g,b,fuzz)
	fuzz=fuzz or 100
	fuzz=(100-fuzz)/100*0xff
	return abs(self.r-r)<=fuzz and abs(self.g-g)<=fuzz and abs(self.b-b)<=fuzz
end
function obj.matchRGBByOffset(self,r,g,b,offset)
	return abs(self.r-r)<=offset.r and abs(self.g-g)<=offset.g and abs(self.b-b)<=offset.b
end
function obj.toHSV(self)
	local R, G, B = self.r, self.g, self.b
	local max=math.max(R,G,B)
	local min=math.min(R,G,B)
	if R == max then H = (G-B)/(max-min) end
	if G == max then H = 2 + (B-R)/(max-min) end
	if B == max then H = 4 + (R-G)/(max-min) end
	H = math.floor((H * 60) + 0.5)
	if H < 0 then H = H + 360 end
	V=math.floor((math.max(R,G,B) / 255 * 100) + 0.5)
	S=math.floor(((max-min)/max * 100) + 0.5)
	return {H, S, V}
end
--成员函数结束
--/////////////////////////////////////////
--/////////////////////////////////////////
--类初始化
--rawset(_G,obj.__tag,setmetatable({},obj))
obj.INVALID=obj:__call(0)
obj.INVALID.r=-1
obj.INVALID.g=-1
obj.INVALID.b=-1
return setmetatable({},obj)
--类初始化结束
--/////////////////////////////////////////
--/////////////////////////////////////////
