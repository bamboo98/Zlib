local Z = {}
local config = {['启用插件'] = false}

Z.info = [[
Author: 竹子菌
QQ: 454689880
Updated: 2019年7月9日21:36:48
Project: https://github.com/bamboo98/Zlibs
开发手册: https://www.yuque.com/zhuzijun/zlibs
请关注github获取最新版更新,Zlibs仍在开发中
可能会出现各种不可预知的错误,如果发现BUG请反馈给竹子菌
]]
local init = false
function Z.getJson()
    -- 尝试直接加载2.0的json库
    local ok, json = pcall(require, 'cjson')
    if ok then return json end
    -- 加载1.9的lua版JSON库
    local lo_json = {}
    local obj = require('Zlibs.tool.JSON')
    lo_json.decode = function(x) return obj:decode(x) end
    lo_json.encode = function(x) return obj:encode(x) end
    lo_json.encode_pretty = function(x) return obj:encode_pretty(x) end
    return lo_json
end

function Z.init()
    if init then return end
    init = true
    local log = rawget(_G, "sysLog")
    print = log and function(...)
        local t = {...}
        for k, v in ipairs(t) do
            if type(v) ~= "string" then t[k] = tostring(v) end
        end
        log(table.concat(t, "\t"))
    end or print
    printf = printf or function(...) print(string.format(...)) end
    require"Zlibs.class.Point"._init()
    require"Zlibs.class.Rect"._init()
    require"Zlibs.class.Sequence"._init()
    require"Zlibs.class.Finger"._init()
    printf('Zlibs加载成功\r%s',Z.info)
    if config['启用插件'] then pcall(require, 'Zlibs.plugins.init') end
end
function Z.MD5(s)
    local md5func = rawget(_G, 'md5') or rawget(_G, 'md5_fast') or
                        require'crypto'.md5
    return md5func(s)
end

local type = require 'Zlibs.tool.type'
function var_dump(val)
    local function dump(val, deep)
        local s = ''
        deep = deep or 0
        if type(val) == 'table' then
            s = s .. '{\r'
            deep = deep + 1
            for k, v in pairs(val) do
                s = s .. string.rep('\t', deep) .. '[' .. dump(k, deep) ..
                        '] = ' .. dump(v, deep) .. ',\r'
            end
            s = s .. string.rep('\t', deep - 1) .. '}'
        elseif type(val) ~= 'string' then
            s = tostring(val)
        else
            s = '"' .. val .. '"'
        end
        return s
    end
    local s = dump(val)
    print(s)
    return s
end

return Z
