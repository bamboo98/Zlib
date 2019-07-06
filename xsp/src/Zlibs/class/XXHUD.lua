--本类只支持在叉叉引擎环境调用
local Zlog = require "Zlibs.class.Log"
local Rect = require "Zlibs.class.Rect"
local type = require "Zlibs.tool.type"


local string = require "Zlibs.class.string"
local obj={}
local funcValues={}
local AllHUD = {}
--默认变量
obj.__tag="HUD"
obj.name="default"
obj.destroyoyed=false
obj.text='未定义'
obj.size=10
obj.color='0xffffff00'
obj.bg='0x33333333'
obj.rect=Rect(0,0,150,30)
obj.id=-1
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
	if self.name=="default" then
		return string.format("%s{text='%s',size=%d,color='%s',bg='%s',rect=%s}",obj.__tag,self.text,self.size,self.color,self.bg,tostring(self.rect))
    else
		return string.format("%s'%s'{text='%s',size=%d,color='%s',bg='%s',rect=%s}",obj.__tag,self.name,self.text,self.size,self.color,self.bg,tostring(self.rect))
    end
end

function obj:__call(...)
	local o={
        id=-1,
        text='未定义',
        size=10,
        color='0xffffff00',
        bg='0x33333333',
        rect=Rect(0,0,150,30)
    }
	setmetatable(o, obj)
	local t={...}
	if #t==1 and type(t[1])=="string" then
		if AllHUD[t[1]] then
			Zlog.warn("HUD出现重名[%s],旧数据将会被新数据覆盖",t[1])
			o=AllHUD[t[1]]
		end
		rawset(o,"name",t[1])
		AllHUD[o.name]=o

        ---@param data table | "{text='文本',size=10,color='0xffffff00',bg='0x33333333',rect=Rect(0,0,150,30)}"
        return function(data)
            if not data or (type(data)~='table' and type(data)~='HUD') then
                return o
            end
            o.text=data.text or self.text
            o.size=data.size or self.size
            o.color=data.color or self.color
            o.bg=data.bg or self.bg
            o.rect=data.rect or self.rect
			return o
		end
    else
        if #t==1 and (type(t[1])=="table" or type(t[1])=="HUD") then
            local data=t[1]
            o.text=data.text or self.text
            o.size=data.size or self.size
            o.color=data.color or self.color
            o.bg=data.bg or self.bg
            o.rect=data.rect or self.rect
		else
			Zlog.fatal("[%s]创建时参数传入错误",self.__tag)
		end
		return o
	end
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
function obj.get(name)
	return AllHUD[name]
end
function obj.destroy(self)
	if type(self)=="string" then
		self=obj.get(self)
    end
    AllHUD[self.name]:hide()
	AllHUD[self.name]=nil
	rawset(self,"destroyoyed",true)
end

function obj.getID(hud)
    return hud.id
end
function obj.show(hud,data)
    if type(hud)=='table' then
        hud=obj:__call(hud)
    end
    if hud.id==-1 then
        --需要申请ID
        hud.id=createHUD()
    end
    if type(data)=='table' then
        hud.text=data.text or hud.text
        hud.size=data.size or hud.size
        hud.color=data.color or hud.color
        hud.bg=data.bg or hud.bg
        hud.rect=data.rect or hud.rect
    end
    showHUD(hud.id,hud.text,hud.size,hud.color,hud.bg,0,hud.rect.x,hud.rect.y,hud.rect.width,hud.rect.height)
    return hud
end
function obj.hide(hud)
    if hud.id==-1 then return end
    hideHUD(hud.id)
    hud.id=-1
end



--成员函数结束
--/////////////////////////////////////////
--/////////////////////////////////////////
--类初始化
return setmetatable({},obj)
--类初始化结束
--/////////////////////////////////////////
--/////////////////////////////////////////
