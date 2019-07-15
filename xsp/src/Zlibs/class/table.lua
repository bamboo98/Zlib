local mt = {}
mt.__index = table
setmetatable(mt, mt)

--- mt.concat 连接字符串(改良版,自动调用tostring)
-- @param t table
-- @param s 连接符
function mt.concat(t, s)
    local tt = {}
    for i = 1, #t do tt[i] = tostring(t[i]) end
    return table.concat(tt, s)
end
--- mt.deepcopy 深度拷贝
-- @param obj object
function mt.deepCopy(obj)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end

    return _copy(obj)
end
--- mt.simplecopy 浅拷贝
-- @param tbl table
function mt.simpleCopy(tbl)
    local newtbl = {}
    for k, v in pairs(tbl) do
        if type(v) == 'table' then
            newtbl[k] = mt.simplecopy(v)
        else
            newtbl[k] = v
        end
    end
    return newtbl
end
--- mt.shuffle 打乱数组顺序(洗牌算法),返回一个新的数组
-- @param tbl 数组
function mt.shuffle(tbl)
    tbl = mt.simplecopy(tbl)
    local newtbl = {}
    local num = #tbl
    local num2 = num
    for i = 1, num do
        table.insert(newtbl, table.remove(tbl, math.random(1, num2)))
        num2 = num2 - 1
    end
    return newtbl
end
--- mt.fromfile 逐行读取文件并保存到table中返回
-- @param path 文件路径
function mt.fromFile(path)
    local Lines = {}
    local f = io.open(path, "r")
    if f == nil then return nil end
    for v in f:lines() do table.insert(Lines, v) end
    f:close()
    return Lines
end
--- mt.writefile 将数组保存到文件中,逐行保存
-- @param path 文件路径,会覆盖原有文件
-- @param tbl  数组
function mt.writeFile(path, tbl, mode)
    tbl = table.concat(tbl, "\r\n")
    local f = io.open(path, mode or 'w')
    f:write(tbl)
    f:close()
end

function mt.print(t)
    var_dump(t)
end

---@param t table table
---@param v any any
function mt.indexOf(t, v)
    for k, value in ipairs(t) do if v == value then return k end end
    return -1
end
---@param t table table
---@param v any any
function mt.keyOf(t, v)
    for k, value in pairs(t) do if v == value then return k end end
    return nil
end

---@param t table table
function mt.reverse(t)
    local r = {}
    for i = #t, 1 do r[#r + 1] = t[i] end
    return r
end

function mt.createReadOnlyTable(t)
    return setmetatable({}, {
        __index = t,
        __newindex = function() end,
        __metatable = false
    })
end

function mt.intersect(t1, t2)
    local t = {}
    for i = 1, #t2 do t[t2[i]] = true end
    local r = {}
    for i = 1, #t1 do if t[t1[i]] then table.insert(r, t1[i]) end end
    return r
end
-- lua5.3 table.move函数
mt.move = table.move or function(a1, f, e, t, a2)
    a2 = a2 or a1
    for i = f, e do a2[t + i - f] = a1[i] end
    return a2
end
-- lua5.3 table.unpack函数
mt.unpack = table.unpack or unpack
-- lua5.3 table.pack函数
mt.pack = table.pack or function(...)
    local r = {...}
    r.n = #r
    return r
end

return mt
