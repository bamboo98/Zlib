return function(config)
    local type = require 'Zlibs.tool.type'
    local Point = require 'Zlibs.class.Point'
    local Rect = require 'Zlibs.class.Rect'
    local Sequence = require 'Zlibs.class.Sequence'
    local api = require "Zlibs.class.api"
    -- 整理分辨率格式
    local width, height = getScreenSize()
    if config.init == 1 then
        width, height = math.max(width, height), math.min(width, height)
        config.width, config.height = math.max(config.width, config.height),
                                      math.min(config.width, config.height)

    elseif config.init == 0 then
        width, height = math.min(width, height), math.max(width, height)
        config.width, config.height = math.min(config.width, config.height),
                                      math.max(config.width, config.height)
    end
    -- 获取缩放分辨率
    local scale = math.max(config.width / width, config.height / height)

    local function getNewRect(r)
        if not r.NewRect then
            local rect = r
            if type(rect) == "Sequence" then rect = rect[1].pos end
            if type(rect) == "Point" then rect = Rect(rect) end
            rect = rect /
                       Rect(Point(-config.safeSpace, -config.safeSpace),
                            Size(2 * config.safeSpace))
            rect = Rect(Point(rect.tl.x / scale, rect.tl.y / scale),
                        Point((rect.br.x - config.width) / scale + width,
                              (rect.br.y - config.height) / scale + height))
            rawset(r, 'NewRect', rect)
        end
        return r.NewRect
    end

    -- HOOK原版的serialize函数
    local seqmeta = getmetatable(Sequence)
    local nativeserialize = seqmeta.serialize
    seqmeta.serialize = function(self)
        if #(self.point) > 0 then
            local new = {}
            for _, v in ipairs(self.point) do
                new[#new + 1] = Point(v)
                new[#new].x = new[#new].x / scale
                new[#new].y = new[#new].y / scale
                new[#new] = new[#new] + (-new[1].pos)
            end
            local str = {}
            for i = 1, #new do str[i] = new[i].toString end
            rawset(self, 'NewStr', table.concat(str, ","))
        else
            rawset(self, 'NewStr', '')
        end
        getNewRect(self)
        nativeserialize(self)
    end

    -- version 1:1.9引擎 2:2.0引擎
    local version = 1
    if table.unpack then version = 2 end

    if version == 1 then
        seqmeta.ExtraFindInRect = function(self, rect, degree, hdir, vdir,
                                           priority)
            if type(rect) == 'string' then rect = Rect.get(rect) end
            return api.findColor(getNewRect(rect), {str = self.NewStr}, degree,
                                 hdir, vdir, priority)
        end
        seqmeta.ExtraFindMultiInRect = function(self, rect, degree, hdir, vdir,
                                                priority, limit)
            if type(rect) == 'string' then rect = Rect.get(rect) end
            return api.findColors(getNewRect(rect), {str = self.NewStr}, degree,
                                  hdir, vdir, priority, limit)
        end
        seqmeta.ExtraFindInRange = function(self, range, degree, hdir, vdir,
                                            priority)
            local rect = getNewRect(self)
            rect.x = rect.x - range.x
            rect.y = rect.y - range.y
            rect.width = rect.width + 2 * range.x
            rect.height = rect.height + 2 * range.y
            return api.findColor(rect, self, degree, hdir, vdir, priority)
        end
        seqmeta.ExtraFindInRangeTap = function(self, range, degree, hdir, vdir,
                                               priority)
            local rect = getNewRect(self)
            rect.x = rect.x - range.x
            rect.y = rect.y - range.y
            rect.width = rect.width + 2 * range.x
            rect.height = rect.height + 2 * range.y
            local p = api.findColor(rect, {str = self.NewStr}, degree, hdir,
                                    vdir, priority)
            if p ~= Point.INVALID then p:tap() end
            return p
        end
        seqmeta.ExtraFindMultiInRange = function(self, range, degree, hdir,
                                                 vdir, priority, limit)
            local rect = getNewRect(self)
            rect.x = rect.x - range.x
            rect.y = rect.y - range.y
            rect.width = rect.width + 2 * range.x
            rect.height = rect.height + 2 * range.y
            return api.findColors(rect, {str = self.NewStr}, degree, hdir, vdir,
                                  priority, limit)
        end

    elseif version == 2 then
        seqmeta.ExtraFindInRect = function(self, rect, globalFuzz, priority)
            if type(rect) == 'string' then rect = Rect.get(rect) end
            return api.findColor(getNewRect(rect), {str = self.NewStr},
                                 globalFuzz, priority)
        end
        seqmeta.ExtraFindMultiInRect = function(self, rect, globalFuzz,
                                                priority, limit)
            if type(rect) == 'string' then rect = Rect.get(rect) end
            return api.findColors(getNewRect(rect), {str = self.NewStr},
                                  globalFuzz, priority, limit)
        end
        seqmeta.ExtraFindInRange = function(self, range, globalFuzz, priority)
            local rect = getNewRect(self)
            rect.x = rect.x - range.x
            rect.y = rect.y - range.y
            rect.width = rect.width + 2 * range.x
            rect.height = rect.height + 2 * range.y
            return
                api.findColor(rect, {str = self.NewStr}, globalFuzz, priority)
        end
        seqmeta.ExtraFindInRangeTap =
            function(self, range, globalFuzz, priority)
                local rect = getNewRect(self)
                rect.x = rect.x - range.x
                rect.y = rect.y - range.y
                rect.width = rect.width + 2 * range.x
                rect.height = rect.height + 2 * range.y
                local p = api.findColor(rect, {str = self.NewStr}, globalFuzz,
                                        priority)
                if p ~= Point.INVALID then p:tap() end
                return p
            end
        seqmeta.ExtraFindMultiInRange = function(self, range, globalFuzz,
                                                 priority, limit)
            local rect = getNewRect(self)
            rect.x = rect.x - range.x
            rect.y = rect.y - range.y
            rect.width = rect.width + 2 * range.x
            rect.height = rect.height + 2 * range.y
            return api.findColors(rect, {str = self.NewStr}, globalFuzz,
                                  priority, limit)
        end
    end
end
