local mt={}
mt.__index=math
setmetatable(mt,mt)

--- mt.round 四舍五入取整
-- @param n 取整的数字 number
function mt.round(n)
	return math.floor(0.5+n)
end

--把默认math库中弧度计算全部转换为角度
--弧度去死吧
local deg = math.deg(1)
local rad = math.rad(1)

--正弦
local sin = math.sin
function mt.sin(r)
	return sin(r * rad)
end

--余弦
local cos = math.cos
function mt.cos(r)
	return cos(r * rad)
end

--正切
local tan = math.tan
function mt.tan(r)
	return tan(r * rad)
end

--反正弦
local asin = math.asin
function mt.asin(v)
	return asin(v) * deg
end

--反余弦
local acos = math.acos
function mt.acos(v)
	return acos(v) * deg
end

--反正切
local atan = math.atan2 or math.atan
function mt.atan(v1, v2)
	return atan(v1, v2) * deg
end
--- mt.oneIn 获取随机布尔值,返回true的概率为1/num或num/num2
-- @param num  只传入一个参数时,返回true的概率为1/num
-- @param num2 传入2个参数时,返回true的概率为num/num2
function mt.oneIn(num,num2)
	if num2 then
		return math.random(1,num2)<=num
	else
		return math.random(1,num)==1
	end
end

--- mt.sectoday 将时间(秒)转化为-天-小时-分-秒的格式
-- @param Sec 时间(秒) number
function mt.secondToDay(Sec)
	local iRet, sRet = pcall(function()
		local Day,Hour,Min = 0,0,0
		if Sec < 0 then
			return "0天0小时0分0秒"
		end
		Sec = tonumber(Sec)
		for i =1,Sec/60 do
			Min = Min + 1
			if Min == 60 then Min = 0 Hour = Hour + 1 end
			if Hour == 24 then Hour = 0 Day = Day + 1 end
		end
		Sec=Sec%60
		return Day.."天"..Hour.."小时"..Min.."分"..Sec.."秒"
	end)
	if iRet == true then
		return sRet
	else
		print(sRet)
		return nil
	end
end

return mt