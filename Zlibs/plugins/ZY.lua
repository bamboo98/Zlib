local config = {
    serverURL = {
        ['测试'] = "http://59.110.143.3/zhuzijunniubi/getTestColorGroup.php",
        ['正式'] = "http://59.110.143.3/zhuzijunniubi/getColorGroup.php"
    },
    -- 每次运行都会强制更新本地缓存,正式发布版请设置false,否则有可能会造成访问量过大的情况
    forceUpdate = false,
    -- 脚本用户的唯一ID,统计数据用
    userID = rawget(_G, 'getUserID')(),
    -- 如果获取失败,重新尝试获取的次数(通常是用户网络原因)
    tryCount = 1,
    -- 如果是在测试环境,请设置此项为true,将会访问测试环境的数据
    -- 脚本发布时请将测试环境数据同步至正式环境,并将此项设置为false再发布
    debugMode = true,
    -- 竹云平台用户token(需要填写)
    token = "",
    -- 黑边模式:自动/无/简单纯黑/定比/自定义......
    edgeMode = "自动",
    -- 自动模式和定比模式限制的客户区最大宽高比
    maxWH = 22.5 / 9,
    -- 自动模式和定比模式限制的客户区最小宽高比
    minWH = 4 / 3,
    -- 当运行设备分辨率在以下列表存在时,强制使用列表中的数据,优先级最高
    forceData = {
        -- ["1920_1080"]={--key为width_height
        --     gameWidth=1920,
        --     gameHeight=1080,
        --     topEdge=0,
        --     bottomEdge=0,
        --     leftEdge=0,
        --     rightEdge=0,
        -- }
    }
}

local data = {
    -- 游戏名(需要填写)
    gameName = "",
    -- 开发分辨率(需要填写)
    developWidth = 1920,
    developHeight = 1080,
    -- 运行设备分辨率数据(以下均无需填写)
    screenWidth = 1920,
    screenHeight = 1080,
    -- 屏幕方向:0横屏,1竖屏
    direction = 0,
    -- 游戏客户区分辨率
    gameWidth = 1920,
    gameHeight = 1080,
    -- 运行设备黑边
    topEdge = 0,
    bottomEdge = 0,
    leftEdge = 0,
    rightEdge = 0,
    -- 通用缩放系数
    scale = 1
}

local edgeFunc = {
    ['自动'] = function(config, data)
        -- 先确定客户区的大小
        if data.screenWidth / data.screenHeight > config.maxWH then
            local outWidth = data.screenWidth - config.maxWH * data.screenHeight
            data.leftEdge = math.floor(outWidth / 2 + 0.5)
            data.rightEdge = math.floor(outWidth / 2 + 0.5)
            data.topEdge = 0
            data.bottomEdge = 0
        elseif data.screenWidth / data.screenHeight < config.minWH then
            local outHeight = data.screenHeight - data.screenWidth /
                                  config.minWH
            data.leftEdge = 0
            data.rightEdge = 0
            data.topEdge = math.floor(outHeight / 2 + 0.5)
            data.bottomEdge = math.floor(outHeight / 2 + 0.5)
        end
        -- 排查是否有不等黑边,即两侧黑边的宽度不一致
        keepScreen(true)
        local i
        i = 0
        while getColor(i, data.screenHeight / 5) == 0 and
            getColor(i, data.screenHeight / 5 * 2) == 0 and
            getColor(i, data.screenHeight / 5 * 3) == 0 and
            getColor(i, data.screenHeight / 5 * 4) == 0 do i = i + 1 end
        local leftEdge = i
        i = 0
        while getColor(data.screenWidth - 1 - i, data.screenHeight / 5) == 0 and
            getColor(data.screenWidth - 1 - i, data.screenHeight / 5 * 2) == 0 and
            getColor(data.screenWidth - 1 - i, data.screenHeight / 5 * 3) == 0 and
            getColor(data.screenWidth - 1 - i, data.screenHeight / 5 * 4) == 0 do
            i = i + 1
        end
        local rightEdge = i

        i = 0
        while getColor(data.screenWidth / 5, i) == 0 and
            getColor(data.screenWidth / 5 * 2, i) == 0 and
            getColor(data.screenWidth / 5 * 3, i) == 0 and
            getColor(data.screenWidth / 5 * 4, i) == 0 do i = i + 1 end
        local topEdge = i
        i = 0
        while getColor(data.screenWidth / 5, data.screenHeight - 1 - i) == 0 and
            getColor(data.screenWidth / 5 * 2, data.screenHeight - 1 - i) == 0 and
            getColor(data.screenWidth / 5 * 3, data.screenHeight - 1 - i) == 0 and
            getColor(data.screenWidth / 5 * 4, data.screenHeight - 1 - i) == 0 do
            i = i + 1
        end
        local bottomEdge = i
        keepScreen(false)
        data.leftEdge = data.leftEdge + (leftEdge - rightEdge)
        data.rightEdge = data.rightEdge - (leftEdge - rightEdge)
        data.topEdge = data.topEdge + (topEdge - bottomEdge)
        data.bottomEdge = data.bottomEdge - (topEdge - bottomEdge)
        -- 检查数据防止出现负数黑边,负数纠正为0
        if data.leftEdge < 0 then
            data.rightEdge = data.rightEdge + data.leftEdge
            data.leftEdge = 0
        end
        if data.rightEdge < 0 then
            data.leftEdge = data.rightEdge + data.leftEdge
            data.rightEdge = 0
        end
        if data.topEdge < 0 then
            data.bottomEdge = data.topEdge + data.bottomEdge
            data.topEdge = 0
        end
        if data.bottomEdge < 0 then
            data.topEdge = data.topEdge + data.bottomEdge
            data.bottomEdge = 0
        end
        -- 设置游戏客户区大小和通用缩放比例
        data.gameWidth = data.screenWidth - data.leftEdge - data.rightEdge
        data.gameHeight = data.screenHeight - data.topEdge - data.bottomEdge
        data.scale = data.developHeight / data.developHeight * data.gameHeight <
                         data.gameWidth and data.gameHeight / data.developHeight or
                         data.gameWidth / data.developWidth
    end,
    ['无'] = function(config, data)
        data.gameWidth = data.screenWidth
        data.gameHeight = data.screenHeight
        data.topEdge = 0
        data.bottomEdge = 0
        data.leftEdge = 0
        data.rightEdge = 0
        data.scale = data.developHeight / data.developHeight * data.gameHeight <
                         data.gameWidth and data.gameHeight / data.developHeight or
                         data.gameWidth / data.developWidth
    end,
    ['简单纯黑'] = function(config, data)
        keepScreen(true)
        local i
        i = 0
        while getColor(i, data.screenHeight / 5) == 0 and
            getColor(i, data.screenHeight / 5 * 2) == 0 and
            getColor(i, data.screenHeight / 5 * 3) == 0 and
            getColor(i, data.screenHeight / 5 * 4) == 0 do i = i + 1 end
        data.leftEdge = i
        i = 0
        while getColor(data.width - 1 - i, data.screenHeight / 5) == 0 and
            getColor(data.width - 1 - i, data.screenHeight / 5 * 2) == 0 and
            getColor(data.width - 1 - i, data.screenHeight / 5 * 3) == 0 and
            getColor(data.width - 1 - i, data.screenHeight / 5 * 4) == 0 do
            i = i + 1
        end
        data.rightEdge = i

        i = 0
        while getColor(data.screenWidth / 5, i) == 0 and
            getColor(data.screenWidth / 5 * 2, i) == 0 and
            getColor(data.screenWidth / 5 * 3, i) == 0 and
            getColor(data.screenWidth / 5 * 4, i) == 0 do i = i + 1 end
        data.topEdge = i
        i = 0
        while getColor(data.screenWidth / 5, data.screenHeight - 1 - i) == 0 and
            getColor(data.screenWidth / 5 * 2, data.screenHeight - 1 - i) == 0 and
            getColor(data.screenWidth / 5 * 3, data.screenHeight - 1 - i) == 0 and
            getColor(data.screenWidth / 5 * 4, data.screenHeight - 1 - i) == 0 do
            i = i + 1
        end
        data.bottomEdge = i
        keepScreen(false)
        data.gameWidth = data.screenWidth - data.leftEdge - data.rightEdge
        data.gameHeight = data.screenHeight - data.topEdge - data.bottomEdge
        data.scale = data.developHeight / data.developHeight * data.gameHeight <
                         data.gameWidth and data.gameHeight / data.developHeight or
                         data.gameWidth / data.developWidth
    end,
    ['定比'] = function(config, data)
        if data.screenWidth / data.screenHeight > config.maxWH then
            local outWidth = data.screenWidth - config.maxWH * data.screenHeight
            data.leftEdge = math.floor(outWidth / 2 + 0.5)
            data.rightEdge = math.floor(outWidth / 2 + 0.5)
            data.topEdge = 0
            data.bottomEdge = 0
        elseif data.screenWidth / data.screenHeight < config.minWH then
            local outHeight = data.screenHeight - data.screenWidth /
                                  config.minWH
            data.leftEdge = 0
            data.rightEdge = 0
            data.topEdge = math.floor(outHeight / 2 + 0.5)
            data.bottomEdge = math.floor(outHeight / 2 + 0.5)
        end
        data.gameWidth = data.screenWidth - data.leftEdge - data.rightEdge
        data.gameHeight = data.screenHeight - data.topEdge - data.bottomEdge
        data.scale = data.developHeight / data.developHeight * data.gameHeight <
                         data.gameWidth and data.gameHeight / data.developHeight or
                         data.gameWidth / data.developWidth
    end,
    ['自定义'] = function(config, data)
        -- 可以在这自定义你的客户区计算方式
    end

}

local http = require "Zlibs.class.Http"
local Zlog = require "Zlibs.class.Log"
local Point = require "Zlibs.class.Point"
local Rect = require "Zlibs.class.Rect"
local Sequence = require "Zlibs.class.Sequence"
local table = require "Zlibs.class.table"

local function ConvertPoint(pos)
    return Point(pos.x * data.scale, pos.y * data.scale)
end

-- init的参数中可以传入黑边计算方式,如果没有传入则会使用config中的
local function ZY_init(modename)
    local width, height = getScreenSize()
    local direction = getScreenDirection()
    init("0", direction)
    if direction ~= 0 then
        width, height = height, width
        data.direction = 0
    else
        data.direction = 1
    end
    data.screenWidth, data.screenHeight = width, height
    -- 检测分辨率是否在强制适配列表中
    if config.forceData[width .. "_" .. height] then
        data.gameHeight = config.forceData[width .. "_" .. height].gameHeight
        data.gameWidth = config.forceData[width .. "_" .. height].gameWidth
        data.topEdge = config.forceData[width .. "_" .. height].topEdge
        data.bottomEdge = config.forceData[width .. "_" .. height].bottomEdge
        data.leftEdge = config.forceData[width .. "_" .. height].leftEdge
        data.rightEdge = config.forceData[width .. "_" .. height].rightEdge
        data.scale = data.developHeight / data.developHeight * data.gameHeight <
                         data.gameWidth and data.gameHeight / data.developHeight or
                         data.gameWidth / data.developWidth
        return
    end
    edgeFunc[modename or config.edgeMode](config, data)
end

local function getJSON()
    local lo_json = {}
    local obj = require('Zlibs.tool.JSON')
    lo_json.decode = function(x) return obj:decode(x) end
    lo_json.encode = function(x) return obj:encode(x) end
    lo_json.encode_pretty = function(x) return obj:encode_pretty(x) end
    return lo_json
end
local json = getJSON()

local function getColorGroup(groupname, count)
    count = count or 0
    if type(groupname) == "string" then
        if type(data) ~= "table" then
            Zlog.fatal(
                "获取色组传入参数错误,请传入色组名或者色组名组成的表")
        end
        local postdata = {
            gamename = data.gameName,
            groupname = groupname,
            token = config.token,
            direction = data.direction,
            curw = data.screenWidth,
            curh = data.screenHeight,
            curleft = data.leftEdge,
            curright = data.rightEdge,
            curtop = data.topEdge,
            curbottom = data.bottomEdge,
            pid = config.userID
        }
        -- 获取本地色组的版本号
        local versionstr = "__v__" .. postdata.curw .. postdata.curh ..
                               postdata.curleft .. postdata.curright ..
                               postdata.curtop .. postdata.curbottom
        local codestr = "__s__" .. postdata.curw .. postdata.curh ..
                            postdata.curleft .. postdata.curright ..
                            postdata.curtop .. postdata.curbottom
        if config.debugMode then
            versionstr = "__devv__" .. postdata.curw .. postdata.curh ..
                             postdata.curleft .. postdata.curright ..
                             postdata.curtop .. postdata.curbottom
            codestr = "__devs__" .. postdata.curw .. postdata.curh ..
                          postdata.curleft .. postdata.curright ..
                          postdata.curtop .. postdata.curbottom
        end

        postdata.version = getNumberConfig(
                               data.gameName .. versionstr .. groupname, -1)

        -- if getStringConfig("__ScreenSize__","")~= postdata.curw..postdata.curh..postdata.curleft..postdata.curright..postdata.curtop..postdata.curbottom then
        -- 	postdata.version=-1
        -- 	setStringConfig("__ScreenSize__",postdata.curw..postdata.curh..postdata.curleft..postdata.curright..postdata.curtop..postdata.curbottom)
        -- end
        if config.forceUpdate then postdata.version = -1 end
        local ret
        if config.debugMode then
            ret = http.Post.table(config.serverURL['测试'], postdata)
        else
            ret = http.Post.table(config.serverURL['正式'], postdata)
        end

        local decoderet

        if ret == "" then -- 网络错误
            if count < config.tryCount then
                Zlog.warn(
                    "竹云色组数据获取失败,正在尝试获取重新获取......第%d次.",
                    count + 1)
                toast("数据获取失败,正在尝试获取重新获取......")
                return getColorGroup(groupname, count + 1)
            else
                Zlog.warn("竹云色组数据获取失败,将使用本地数据")
                toast("数据获取失败,将使用本地数据")
                decoderet = getStringConfig(
                                data.gameName .. codestr .. groupname, "")
                if decoderet == "" then
                    Zlog.warn(
                        "脚本运行数据获取失败,且本地没有预存数据,停止运行")
                    dialog(
                        "脚本运行数据获取失败,且本地没有预存数据,请检查网络连接后重试")
                    lua_exit()
                end
            end
        end
        -- 返回结果解码,json格式
        local flag
        flag, decoderet = pcall(json.decode, ret)
        if not flag then
            if count < config.tryCount then
                Zlog.warn(
                    "竹云色组数据获取失败,正在尝试获取重新获取......第%d次.",
                    count + 1)
                toast("数据获取失败,正在尝试获取重新获取......")
                return getColorGroup(groupname, count + 1)
            else
                Zlog.warn("竹云色组数据获取失败,将使用本地数据")
                toast("数据获取失败,将使用本地数据")
                decoderet = getStringConfig(
                                data.gameName .. codestr .. groupname, "")
                if decoderet == "" then
                    Zlog.warn(
                        "脚本运行数据获取失败,且本地没有预存数据,停止运行")
                    dialog(
                        "脚本运行数据获取失败,且本地没有预存数据,请检查网络连接后重试")
                    lua_exit()
                end
            end
        end
        -- 参数错误或作者账号欠费
        if decoderet['state'] == "Error" then
            dialog(decoderet['because'])
            lua_exit()
        end

        -- 色组没有版本更新,使用本地保存的版本
        if decoderet['state'] == "NoUpdate" then
            ret = getStringConfig(data.gameName .. codestr .. groupname, "")
            flag, decoderet = pcall(json.decode, ret)
            if ret == "" or not flag then
                -- 本地数据有错误,重置本地数据并且重新获取
                setStringConfig(data.gameName .. codestr .. groupname, "")
                setNumberConfig(data.gameName .. versionstr .. groupname, -1)
                Zlog.warn(
                    "竹云色组数据从本地读取时出错,已清空本地数据并发起重新获取的请求",
                    count + 1)
                return getColorGroup(groupname, count + 1)
            end
        else
            -- 把当前获取到的色组保存到本地
            setStringConfig(data.gameName .. codestr .. groupname, ret)
            -- 更新本地版本号
            setNumberConfig(data.gameName .. versionstr .. groupname,
                            decoderet['version'] or -1)
        end

        -- print(decoderet)--这里可以查看一下原始json解析的数据,可以根据需要修改
        local rettbl = {}
        local temptbl
        for k, v in ipairs(decoderet['colors']) do
            if tonumber(v['type']) == 1 then
                -- 单坐标处理
                rettbl[v['colorname']] =
                    Point(v['colorname']){
                        pos = {
                            x = tonumber(v['mainpoint']['x']),
                            y = tonumber(v['mainpoint']['y'])
                        }
                    }
            elseif tonumber(v['type']) == 2 then
                -- 双坐标/范围处理
                if Rect.getLocationMode() == 1 then
                    rettbl[v['colorname']] =
                        Rect(v['colorname']){
                            tonumber(v['area']['x1']),
                            tonumber(v['area']['y1']),
                            tonumber(v['area']['x2']), tonumber(v['area']['y2'])
                        }
                elseif Rect.getLocationMode() == 2 then
                    rettbl[v['colorname']] =
                        Rect(v['colorname']){
                            tonumber(v['area']['x1']),
                            tonumber(v['area']['y1']),
                            tonumber(v['area']['x2']) -
                                tonumber(v['area']['x1']) + 1,
                            tonumber(v['area']['y2']) -
                                tonumber(v['area']['y1']) + 1
                        }
                else
                    error(
                        '请先设置Rect类使用的坐标格式,再获取色组[相关函数Rect.setLocationMode]')
                end
            elseif tonumber(v['type']) == 3 then
                -- 色点集处理
                local seq = {}
                for _, vv in ipairs(v['points']) do
                    temptbl = {
                        pos = {x = tonumber(vv['x']), y = tonumber(vv['y'])},
                        color = tonumber(vv['color'], 16)
                    }
                    if vv['diffcolor'] ~= "0x000000" then
                        -- 设置偏色
                        temptbl.offset = tonumber(vv['diffcolor'], 16)
                    end
                    table.insert(seq, temptbl)
                end
                rettbl[v['colorname']] = Sequence(v['colorname'])(seq)
            end
        end

        return rettbl
    elseif type(groupname) == "table" then
        local tmptbl = {}
        local rettbl = {}
        for _, v in ipairs(groupname) do
            -- print("获取色组:",v)
            tmptbl = getColorGroup(v)
            -- print("完成获取,正在合并")
            for k, v in pairs(tmptbl) do
                if rettbl[k] then
                    dialog(string.format(
                               "特征重名!无法合并!将舍弃该特征,游戏名:%s 色组名:%s 特征名:%s",
                               data.gameName, groupname, k))
                else
                    rettbl[k] = v
                end
            end
        end
        tmptbl = {}
        return rettbl
    else
        return {}
    end
end

require'Z'.ZY = {init = ZY_init, getCG = getColorGroup, CP = ConvertPoint}
