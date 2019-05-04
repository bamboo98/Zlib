local Zlog = require "Zlibs.class.Log"
local Scene = require "Zlibs.class.Scene"
local obj={}
local all={}
--默认变量
obj.__tag="Blackboard"
obj.name="default"

--默认变量结束
--/////////////////////////////////////////
--/////////////////////////////////////////
--内部函数

--内部函数结束
--/////////////////////////////////////////
--/////////////////////////////////////////
--元表设置
function obj:__call(name)
	if type(name)~="string" then
		Zlog.fatal("请使用字符串作为黑板的名称")
    end
    if all[name] then return all[name] end
    local con={}
    local func=function (tbl, key)
        local nk, nv = next(con, key)
        if nk then
            nv = tbl[nk]
        end
        return nk, nv
    end
    local o= setmetatable({
            name=name,
            eachValue=function (tbl, key)
                return func, tbl, nil
            end},
        {
            __index = function(self,k)
                if obj[k] then return obj[k] end
                return con[k]
            end,
            __newindex=function(self,k,v)
                con[k]=v
            end,
            __tostring=function(self)
                return string.format("黑板 %s",self.name)
            end
            ,
            --__pairs该项只在lua5.3引擎以上版本起效,以下版本请使用eachValue()遍历
            __pairs = function (tbl, key)
                return func, tbl, nil
            end
        })

	all[name] = o
	return o
end
--元表设置结束
--/////////////////////////////////////////
--/////////////////////////////////////////
--自动变量

--自动变量结束
--/////////////////////////////////////////
--/////////////////////////////////////////
--成员函数
function obj.createScene(self,name)
    local s=Scene(name)
    return s:bindBlackboard(self)
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
