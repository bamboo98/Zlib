local Zlog = require "Zlibs.class.Log"
local table = require "Zlibs.class.table"
local mt={}
if line==nil then line=false end
function mt:__index(k)
	Zlog.error("试图读取不存在的全局变量[%s]",k)
end
function mt:__newindex(k,v)
	if type(v)~="function" then
		Zlog.info("不建议的操作:创建全局变量[%s]=[%s]\r\t%s",k,v,string.gsub(debug.traceback(),[[^stack traceback:
	(.-)
]],"调用堆栈:\n"):gsub([[%[C%]: in .]],""))
	end
	rawset(self,k,v)
end
mt.onRuntimeError = onRuntimeError or function() end
onRuntimeError=mt.onRuntimeError

function mt.showGlobalValues()
	local class={}
	local func={}
	local oth={}
	for k,_ in pairs(_G) do
		if k~="_G" then
			local t=type(_G[k])
			if t=="userdata" or (t=="table" and _G[k].__tag) then
				table.insert(class,k)
			elseif t=="function" then
				table.insert(func,k)
			else
				table.insert(oth,"["..t.."]"..k)
			end
		end
	end
	print("[%d]Class List:%s",#class,table.concat(class,", "))
	print("[%d]Function List:%s",#func,table.concat(func,", "))
	print("[%d]Others:%s",#oth,table.concat(oth,", "))
end
function mt.checkMemoryUsed()
	collectgarbage("collect")
	Zlog.info("当前内存使用:%.3fkb",collectgarbage("count"))
end






setmetatable(_G,mt)

return mt