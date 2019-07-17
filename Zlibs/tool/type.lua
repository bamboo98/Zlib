return function(o)
	local t=type(o)
	if (t=="userdata" or t=="table") and o.__tag then
		return o.__tag
	else
		return t
	end
end