
local mt={}
setmetatable(mt,{__index=string})

--这个表就是控制允许出现哪些随机字符,可以自行删减
local randomlist={
	1,2,3,4,5,6,7,8,9,0,
	"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",
	"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"
}
--- mt.split 字符串分割成table
-- @param self 字符串
-- @param sep  分隔符
function mt.split(self,sep)
	sep = sep or "\t"
	local fields = {}
	local pattern = string.format("([^%s]+)", sep)
	self:gsub(pattern, function(c) fields[#fields+1] = c end)
	return fields
end
--- mt.urlencode urlencode编码
-- @param self 字符串
function mt.urlencode(self)
	return self:gsub("([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end):gsub(" ", "+")
end
--- mt.urldecode urldecode解码
-- @param self 字符串
function mt.urldecode(self)
	return self:gsub('%%(%x%x)', function(h) return string.char(tonumber(h, 16)) end)
end
--- mt.left 字符串从左往右取len位(中文算一位)
-- @param self 字符串
-- @param len  长度
function mt.left(self,len)
	return mt.utf8sub(self,1,math.min(#self,len))
end

--- mt.right 字符串从右往左取len位(中文算一位)
-- @param self 字符串
-- @param len  长度
function mt.right(self,len)
	return mt.utf8sub(self,math.max(1,#self-len+1),#self)
end

--获取字符串中第index个字符实际占用的字符数
local function SubStringGetByteCount(str, index)
	local curByte = string.byte(str, index)
	local byteCount = 1;
	if curByte == nil then
		byteCount = 0
	elseif curByte > 0 and curByte <= 127 then
		byteCount = 1
	elseif curByte>=192 and curByte<=223 then
		byteCount = 2
	elseif curByte>=224 and curByte<=239 then
		byteCount = 3
	elseif curByte>=240 and curByte<=247 then
		byteCount = 4
	end
	return byteCount;
end
local function SubStringGetTrueIndex(str, index)
	local curIndex = 0;
	local i = 1;
	local lastCount = 1;
	repeat 
		lastCount = SubStringGetByteCount(str, i)
		i = i + lastCount;
		curIndex = curIndex + 1;
	until(curIndex >= index);
	return i - lastCount;
end

--- mt.utf8len 获取字符串长度,中文算作一位
-- @param str   字符串
-- @param index 保留变量,留空即可
function mt.utf8len(str,index)
	local curIndex = 0;
	local i = 1;
	local lastCount
	repeat
		lastCount = SubStringGetByteCount(str, i)
		i = i + lastCount;
		curIndex = curIndex + 1;
	until(lastCount == 0);
	return curIndex - 1;
end
--- mt.utf8sub 含中文字符串的string.sub,字符串截取
-- @param str        字符串
-- @param startIndex 起始位置
-- @param endIndex   结束位置
function mt.utf8sub(str, startIndex, endIndex)
	if startIndex < 0 then
		startIndex = mt.utf8len(str) + startIndex + 1;
	end

	if endIndex ~= nil and endIndex < 0 then
		endIndex = mt.utf8len(str) + endIndex + 1;
	end

	if endIndex == nil then 
		return string.sub(str, SubStringGetTrueIndex(str, startIndex));
	else
		return string.sub(str, SubStringGetTrueIndex(str, startIndex), SubStringGetTrueIndex(str, endIndex + 1) - 1);
	end
end
--- mt.ltrim 去除字符串前导符号
-- @param s 字符串
-- @param p 去除的字符,默认为空白字符%s
function mt.ltrim(s,p)
	p=p or "%s"
	return (string.gsub(s,"^"..p.."*",""))
end
--- mt.rtrim 去除字符串后导符号
-- @param s 字符串
-- @param p 去除的字符,默认为空白字符%s
function mt.rtrim(s,p)
	p=p or "%s"
	return (string.gsub(s,p.."*$",""))
end
--- mt.trim 去除字符串前导和后导字符
-- @param s 字符串
-- @param p 去除的字符,默认为空白字符%s
function mt.trim(s,p)
	return mt.rtrim(mt.ltrim(s,p),p)
end
--- mt.has 检查字符串是否含有某子串
-- @param s  字符串
-- @param s2 子串
function mt.has(s,s2)
	return type(string.find(s,s2))=="number"
end
--- mt.isalpha 检查字符串是否完全为字母组成
-- @param str 字符串
function mt.isalpha(str)
	local len = string.len(str)
	for i = 1, len do
		local ch = string.sub(str, i, i)
		if not ((ch >= 'a' and ch <= 'z') or (ch >= 'A' and ch <= 'Z')) then
			return false
		end
	end
	return true
end
--- mt.isdigit 检查字符串是否完全为数字组成,更建议使用tonumber测试
-- @param str 字符串
function mt.isdigit(str)
	local len = string.len(str)
	for i = 1, len do
		local ch = string.sub(str, i, i)
		if ch < '0' or ch > '9' then
			return false
		end
	end
	return true
end
--- mt.delpart 删除字符串一部分,中文按1位算
-- @param str  字符串
-- @param sval 删除起始位置
-- @param eval 删除结束位置
function mt.delPart(str,sval,eval)
	local LStr = mt.utf8sub(str, 1, sval-1)
	local RStr = mt.utf8sub(str, eval+1, -1)
	local RetStr = LStr ..RStr
	return RetStr
end
--- 统计字符串中某个子串出现的次数
---@param str string '要检查的字符串'
---@param substr string

function mt.count(str,substr)
	local count = 0
	for _ in string.gmatch(str, substr) do
		count = count +1
	end
	return count
end

--- mt.leftdel 删除字符串开头一定长度的字符,中文按1位算
-- @param str 字符串
-- @param num 长度
function mt.delLeft(str,num)
	return mt.utf8sub(str,num + 1, -1)
end
--- mt.rightdel 删除字符串结尾一定长度的字符,中文按1位算
-- @param str 字符串
-- @param num 长度
function mt.delRight(str,num)
	return mt.utf8sub(1, mt.utf8len(str) - num)
end
--- mt.xmlToTable 将xml字符串转换为table
-- @param xml xml字符串
function mt.xmlToTable(xml)
	local tXml = {}
	local i = 1
	for k in xml:gmatch("<node[^>]+/?>") do
		tXml[i] = {}
		for w, y in k:gmatch("([^ ]+)=([^ ]+)") do
			tXml[i][w] = y
		end
		i = i + 1
	end
	return tXml
end
--- mt.findXmlKey 查找xml字符串中的key,返回第一个匹配的结果
-- @param Xml  xml字符串
-- @param key  查找的key
-- @param val  字段名
-- @param key1 子key
function mt.findXmlKey(Xml, key, val, key1)
	local tXml = mt.xmlToTable(Xml)
	local i = 1
	for i = 1, #tXml do
		if tXml[i][key] == "\""..val.."\"" then
			return tXml[i][key1]:match("\"(.+)\"")
		end
	end
	return ""
end
--- mt.findXmlKeyAll 查找xml字符串中的key,返回所有匹配的结果
-- @param Xml  xml字符串
-- @param key  查找的key
-- @param val  字段名
-- @param key1 子key
function mt.findXmlKeyAll(Xml, key, val, key1)
	local tXml = mt.xmlToTable(Xml)
	local tmptable = {}
	for i = 1, #tXml do
		if tXml[i][key] == "\""..val.."\"" then
			table.insert(tmptable, tXml[i][key1]:match("\"(.+)\""))
		end
	end
	if tmptable[1] == nil then
		return nil
	else
		return tmptable
	end
end
--- mt.randomstr 获取指定长度的随机字符串,由
-- @param len Describe the parameter
function mt.randomStr(len,list)
	list=list or randomlist
	local rt = ""
	for i=1,len,1 do
		rt = rt..list[math.random(1,#list)]
	end
	return rt
end
--- mt.encodeBase64 将字符串base64编码
-- @param source_str 字符串
function mt.encodeBase64(source_str)
	local b64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
	local s64 = ''
	local str = source_str
	while #str > 0 do
		local bytes_num = 0
		local buf = 0
		for byte_cnt=1,3 do
			buf = (buf * 256)
			if #str > 0 then
				buf = buf + string.byte(str, 1, 1)
				str = string.sub(str, 2)
				bytes_num = bytes_num + 1
			end
		end
		for group_cnt=1,(bytes_num+1) do
			local b64char = math.fmod(math.floor(buf/262144), 64) + 1
			s64 = s64 .. string.sub(b64chars, b64char, b64char)
			buf = buf * 64
		end
		for fill_cnt=1,(3-bytes_num) do
			s64 = s64 .. '='
		end
	end
	return s64
end
--- mt.decodeBase64 将base64字符串解码
-- @param str64 字符串
function mt.decodeBase64(str64)
	local b64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
	local temp={}
	for i=1,64 do
		temp[string.sub(b64chars,i,i)] = i
	end
	temp['=']=0
	local str=""
	for i=1,#str64,4 do
		if i>#str64 then
			break
		end
		local data = 0
		local str_count=0
		for j=0,3 do
			local str1=string.sub(str64,i+j,i+j)
			if not temp[str1] then
				return
			end
			if temp[str1] < 1 then
				data = data * 64
			else
				data = data * 64 + temp[str1]-1
				str_count = str_count + 1
			end
		end
		for j=16,0,-8 do
			if str_count > 0 then
				str=str..string.char(math.floor(data/math.pow(2,j)))
				data=math.mod(data,math.pow(2,j))
				str_count = str_count - 1
			end
		end
	end
	local last = tonumber(string.byte(str, string.len(str), string.len(str)))
	if last == 0 then
		str = string.sub(str, 1, string.len(str) - 1)
	end
	return str
end

local function digit_to(n,s)
	assert(type(n)=="number", "arg #1 error: need a number value.")
	assert(type(s)=="string", "arg #2 error: need a string value.")
	assert((#s)>1, "arg #2 error: too short.")
	local fl = math.floor
	local i = 0
	while 1 do
		if n>(#s)^i then
			i = i + 1
		else
			break
		end
	end
	local ret = ""
	while i>=0 do
		if n>=(#s)^i then
			local tmp = fl(n/(#s)^i)
			n = n - tmp*(#s)^i
			ret = ret..s:sub(tmp+1, tmp+1)
		else
			if ret~="" then
				ret = ret..s:sub(1, 1)
			end
		end
		i = i - 1
	end
	return ret
end
local function to_digit(ns,s)
	assert(type(ns)=="string", "arg #1 error: need a string value.")
	assert(type(s)=="string", "arg #2 error: need a string value.")
	assert((#s)>1, "arg #2 error: too short.")
	local ret = 0
	for i=1,#ns do
		local fd = s:find(ns:sub(i,i))
		if not fd then
			return nil
		end
		fd = fd - 1
		ret = ret + fd*((#s)^((#ns)-i))
	end
	return ret
end
local function s2h(str,spacer)return (string.gsub(str,"(.)",function (c)return string.format("%02x%s",string.byte(c), spacer or"")end))end
local function h2s(h)return(h:gsub("(%x%x)[ ]?",function(w)return string.char(tonumber(w,16))end))end

--- mt.unicode2utf8 unicode字符串转换为utf8
-- @param us unicode字符串
function mt.unicode2utf8(us)
	local u16p = {
		0xdc00,
		0xd800,
	}
	local u16b = 0x3ff
	local u16fx = ""
	local padl = {
		["0"] = 7,
		["1"] = 11,
		["11"] = 16,
		["111"] = 21,
	}
	local padm = {}
	for k,v in pairs(padl) do
		padm[v] = k
	end
	local map = {7,11,16,21}
	return (string.gsub(us, "\\[Uu](%x%x%x%x)", function(uc)
		local ud = tonumber(uc,16)
		for i,v in ipairs(u16p) do
			if ud>=v and ud<(v+u16b) then
				ud = ud - v + (i-1) * 0x40
				if (i-1)>0 then
					u16fx = digit_to(ud, "01")
					return ""
				end
				local bi = digit_to(ud, "01")
				uc = string.format("%x", to_digit(u16fx..string.rep("0",10-#bi)..bi,"01"))
				u16fx = ""
				ud = tonumber(uc,16)
				break
			end
		end
		local bins = digit_to(ud,"01")
		local pads = ""
		for _,i in ipairs(map) do
			if #bins<=i then
				pads = padm[i]
				break
			end
		end
		while #bins<padl[pads] do
			bins = "0"..bins
		end
		local tmp = ""
		if pads~="0" then
			tmp = bins
			bins = ""
		end
		while #tmp>0 do
			bins = "10"..string.sub(tmp, -6, -1)..bins
			tmp = string.sub(tmp, 1, -7)
		end
		return (string.gsub(string.format("%x", to_digit(pads..bins, "01")), "(%x%x)", function(w)
			return string.char(tonumber(w,16))
		end))
	end))
end
--- mt.utf82unicode utf8字符串转换为unicode
-- @param s     字符串
-- @param upper 是否大写
function mt.utf82unicode(s, upper)
	local uec = 0
	s = s:gsub("\\", "\\")
	if upper then
		upper = "\\U"
	else
		upper = "\\u"
	end
	local loop1 = string.gsub(s2h(s), "(%x%x)", function(w)
		local wc = tonumber(w,16)
		if wc>0x7F then
			if uec>0 then
				uec = uec - 1
				if uec==0 then
					return w.."/"
				end
				return w
			end
			local bi = digit_to(wc, "01")
			bi = string.sub(bi, 2, -1)
			while string.sub(bi, 1, 1)=="1" do
				bi = string.sub(bi, 2, -1)
				uec = uec + 1
			end
			return "u/"..w
		else
			if uec>0 then
				uec = 0
				return w.."/"
			end
		end
		return w
	end)
	local u16p = {
		0xdc00,
		0xd800,
	}
	local u16id = 0x10000
	local loop2 = string.gsub(loop1, "u/(%x%x*)/", function(w)
		local wc = tonumber(w,16)
		local tmp
		local bi = digit_to(wc, "01")
		tmp = ""
		while #bi>8 do
			tmp = string.sub(bi, -6, -1)..tmp
			bi = string.sub(bi, 1, -9)
		end
		bi = bi..tmp
		while string.sub(bi, 1, 1)=="1" do
			bi = string.sub(bi, 2, -1)
		end
		wc = to_digit(bi, "01")
		if (wc>=u16id) then
			wc = wc - u16id
			tmp = digit_to(wc, "01")
			tmp = string.rep("0", 20-#tmp)..tmp
			local low = to_digit(string.sub(tmp, -10, -1), "01") + u16p[1]
			local high = to_digit(string.sub(tmp, 1, -11), "01") + u16p[2]
			tmp = string.format("%4x", low)
			return s2h(upper..string.format("%4x", high)..upper..string.format("%4x", low))
		end
		local h = string.format("%x", wc)
		if (#h)%2~=0 then
			h = "0"..h
		end
		return s2h(upper..h)
	end)
	return h2s(loop2)
end

return mt