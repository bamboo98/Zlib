return function(config)
    local math=require "Zlibs.class.math"
    local Color = require "Zlibs.class.Color"
    local meta = getmetatable(Color)
    local magicValues = meta._magicValues

    function magicValues.toHSV(self)
        local R, G, B = self.r, self.g, self.b
        local r1, g1, b1 = R / 255, G / 255, B / 255
        local H, S, V
        local max = math.max(r1, g1, b1)
        local min = math.min(r1, g1, b1)
        local delta = max - min
        if max == min then
            H = 0
        else
            if r1 == max then H = ((g1 - b1) / delta) % 6 end
            if g1 == max then H = 2 + (b1 - r1) / delta end
            if b1 == max then H = 4 + (r1 - g1) / delta end
        end
        H = math.round(H * 60)
        if H < 0 then H = H + 360 end
        V = math.round(max * 100)
        if max == 0 then
            S = 0
        else
            S = math.round(delta / max * 100)
        end
        return {H, S, V}
    end
    local func = {
        [0] = function(p, q, t, v) return Color(v, t, p) end,
        [1] = function(p, q, t, v) return Color(q, v, p) end,
        [2] = function(p, q, t, v) return Color(p, v, t) end,
        [3] = function(p, q, t, v) return Color(p, q, v) end,
        [4] = function(p, q, t, v) return Color(t, p, v) end,
        [5] = function(p, q, t, v) return Color(v, p, q) end
    }
    function meta.fromHSV(hsv)
        local h = hsv[1]
        local s = hsv[2] / 100
        local v = hsv[3] / 100
        local hi = math.floor(h / 60)
        local f = h / 60 - hi
        local p = v * (1 - s) * 0xff
        local q = v * (1 - f * s) * 0xff
        local t = v * (1 - s * (1 - f)) * 0xff
        return func[hi](p, q, t, v * 0xff)
    end
end
