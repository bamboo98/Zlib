local Zlog = require "Zlibs.class.Log"
local type = require "Zlibs.tool.type"
local Timer = require "Zlibs.class.Timer"
local api = require "Zlibs.class.api"
local obj={}
local all={}
--默认变量
obj.__tag="Scene"
obj.name="default"
obj.blackboard=false
obj.children=false
obj.behavior=false
obj.trigger=false
obj.runcount=1
obj.cuttime=0


function obj:__call(name)
	if type(name)~="string" then
		Zlog.fatal("请使用字符串作为场景的名称")
    end
    if all[name] then return all[name] end
    local con={}
    local o= setmetatable({
            name=name,
            eachValue=function (tbl, key)
                return function (tbl, key)
                    local nk, nv = next(con, key)
                    if nk then
                        nv = tbl[nk]
                    end
                    return nk, nv
                end, tbl, nil
            end,
            children=false,
            behavior=false,
            trigger=false,
            blackboard=false,
            runcount=1,
            cuttime=0
        },{
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
                return function (tbl, key)
                    return function (tbl, key)
                        local nk, nv = next(con, key)
                        if nk then
                            nv = tbl[nk]
                        end
                        return nk, nv
                    end, tbl, nil
                end, tbl, nil
            end
        })

	all[name] = o
	return o
end

function obj.bindBlackboard(self,bb)
    if type(bb)~="Blackboard" then
        Zlog.fatal("场景[%s]绑定黑板时传入的参数错误",self.name)
    end
    rawset(self,"blackboard",bb)
    return self
end

function obj.createchild(self,name)
    local o=obj:__call(name)
    if not self.children then self.children={}end
    table.insert(self.children,o)
    --继承父场景的黑板
    o.blackboard=self.blackboard
    return o
end

function obj.addchild(self,scene)
    if type(scene)~="Scene" then
        Zlog.fatal("场景[%s]添加子场景参数错误",self.name)
    end
    if not self.children then self.children={}end
    table.insert(self.children,scene)
    return self
end

function obj.check(self)
    if type(self.trigger)=="function" then
        return self.trigger(self.blackboard or {},self)
    end
    return false
end
function obj.run(self)
    local timer
    if self:check() then
        self:forceRun()
        if self.cuttime>0 then
            --如果场景切换时间大于0,启用切换计时器
            --计时器随机名称,防止同一秒内出现重复
            timer=Timer(self.name.."_"..os.time().."_"..math.random(0,99999))
        end
        repeat
            --有子场景则检测一遍子场景是否能触发
            if self.children then
                local flag=true
                while flag do
                    flag=false
                    for _,v in ipairs(self.children) do
                        --如果任意一个子场景执行成功则重新遍历子场景执行
                        flag=v:run() or flag
                    end
                end
            end
            
            --当没有达到切换时间时候,循环运行
            -- api.mSleep(100)
            --如果有需要的话可以在这里加一个延迟
            
            --执行完之后再次检查是否能执行
        until (self.cuttime<=0 or timer:check(self.cuttime)) and not self:run()
        if self.cuttime>0 then
            --销毁计时器
            timer:destroy()
        end
        return true
    end
    return false
end

function obj.forceRun(self)
    if type(self.behavior)=="function" then
        --执行单次触发执行次数
        for i=1,self.runcount do
            if not self.behavior(self.blackboard or {},self) then
                break
            end
        end
        --当单次执行次数设置为-1时无限执行直到behavior返回值为false
        while self.runcount==-1 do
            if not self.behavior(self.blackboard,self) then
                break
            end
        end
    end
end
return setmetatable({},obj)