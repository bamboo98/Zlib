local Zlog = require "Zlibs.class.Log"
local Point = require "Zlibs.class.Point"
local Size = require "Zlibs.class.Size"
local Rect = require "Zlibs.class.Rect"
local Circle = require "Zlibs.class.Circle"
local math = require "Zlibs.class.math"
local type = require "Zlibs.tool.type"
local obj={}
local funcValues={}
local allRegion={}
-- 魔术变量接口_插件用
obj._magicValues = funcValues
--默认变量
obj.__tag="Region"
obj.name="default"
obj.area={}
obj.mode={}
obj.destroyed=false
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
	return string.format("%s{area count = %d}",obj.__tag,#self.area)
end
-- Region{{true,Rect1},{false,Rect2},{false,Rect3},...}
function obj:__call(name)
	if type(name)~="string" then
		Zlog.fatal("请使用字符串作为不规则区域的名称")
	end
	local o=setmetatable({name=name,mode={},area={}}, obj)
	if allRegion[name] then
		Zlog.warn("颜色序列类型出现重名[%s],旧数据将会被新数据覆盖",name)
		o=allRegion[name]
	end
	allRegion[name]=o
	return function (t)
		t = t or {}
		for i=1,#t do
			if type(t[i])=="table" then
				if t[i][1] then
					o:add(t[i][2])
				else
					o:sub(t[i][2])
				end
			else
				o:add(t[i])
			end
		end
		return o
	end
end
--元表设置结束
--/////////////////////////////////////////
--/////////////////////////////////////////
--自动变量
function funcValues.randomPoint(self)
	if self.destroyed then return Point.INVALID end
	local allowrect
	for i=1,#self.area do
		if self.mode[i] then
			local r
			if type(self.area[i]) == "Rect" then
				r=Rect(self.mode[i])
			elseif type(self.area[i]) == "Circle" then
				r=self.area[i].outRect
			elseif type(self.area[i]) == "Point" then
				r=Rect(self.area[i],Size.ZERO)
			end
			if not allowrect then 
				allowrect = r 
			else
				allowrect = allowrect:union(r)
			end
		end
	end
	if allowrect then
		local p = allowrect.randomPoint
		local count = 0
		while not self:contains(p) and count<100000 do
			p = allowrect.randomPoint
			count = count + 1
		end
		if count == 100000 then
			Zlog.warn("随机次数超过上限,获取随机点失败,不规则区域中有效区域太小了")
		else
			return p
		end
	end
	return Point.INVALID
end
--自动变量结束
--/////////////////////////////////////////
--/////////////////////////////////////////
--内部函数
local function clearupGroup(self)
	local tar=self.area[#self.area]
	if #self.area<2 then return end
	for i=#self.area-1,1,-1 do
		if tar:contains(self.area[i]) then
			table.remove(self.area,i)
			table.remove(self.mode,i)
		end
	end
end
--内部函数结束
--/////////////////////////////////////////
--/////////////////////////////////////////
--成员函数
function obj.get(name)
	return allRegion[name]
end
function obj.destroy(self)
	if type(self)=="string" then
		self=obj.get(self)
	end
	allRegion[self.name]=nil
	rawset(self,"destroyed",true)
end
function obj.add(self,a)
	if self.destroyed then return false end
	table.insert(self.area,a)
	table.insert(self.mode,true)
	clearupGroup(self)
end
function obj.sub(self,a)
	if self.destroyed then return false end
	table.insert(self.area,a)
	table.insert(self.mode,false)
	clearupGroup(self)
end
function obj.contains(self,p)
	if self.destroyed then return false end
	if type(p)~="Point" then
		Zlog.warn("只支持检测点是否在不规则区域内")
		return false
	end
	for i=#self.area,1,-1 do
		if self.area[i]:contains(p) then return self.mode[i] end
	end
	return false
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
