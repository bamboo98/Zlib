local Z={}
Z.info=[[
Version: 0.1.0
Author: 竹子菌
QQ: 454689880
Updated: 2019年5月4日22:11:08
Project: https://github.com/bamboo98/Zlib
]]


function Z.getJson()
	--尝试直接加载2.0的json库
	local ok, json = pcall(require, 'cjson')
	if ok then return json end
	--加载1.9的lua版JSON库
	local lo_json = {}
	local obj = require('Zlibs.tool.JSON')
	lo_json.decode = function(x) return obj:decode(x) end
	lo_json.encode = function(x) return obj:encode(x) end
	lo_json.encode_pretty = function(x) return obj:encode_pretty(x) end
	return lo_json
end

function Z.init()
	local log=rawget(_G,"sysLog")
	print = log and function(...)
		local t={...}
		for k,v in ipairs(t) do
			if type(v)~="string" then
				t[k]=tostring(v)
			end
		end
		log(table.concat(t, "\t"))
	end or print
	require "Zlibs.class.Point"._init()
	require "Zlibs.class.Rect"._init()
	require "Zlibs.class.Sequence"._init()
	require "Zlibs.class.Finger"._init()
end




return Z