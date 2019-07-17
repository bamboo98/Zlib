local string = require "Zlibs.class.string"
local Zlog = require "Zlibs.class.Log"
local Point = require "Zlibs.class.Point"
local rg = require "Zlibs.class.Rect".get
local sg = require "Zlibs.class.Sequence".get
--version 1:1.9引擎 2:2.0引擎
local version = 1
if table.unpack then version = 2 end

local api={}

local function getfunc(name,...)
    local t={...}
    for _,v in ipairs(t) do
        local vv = string.split(v,".")
        local index=1
        local ret=rawget(_G,vv[index])
        while ret and vv[index+1]  do
            index=index+1
            ret=rawget(ret,vv[index])
        end
        if ret then return ret end
    end
    Zlog.warn("获取[%s]内置函数失败,对该函数的调用将为无效调用",name)
    return function(...)
        Zlog.warn("调用无效API:[%s],传入参数 %s",name,table.concat({...},", ") or "")
    end
end

--设置API类为静态
function api.__newindex()
    Zlog.info("请不要修改API设置")
end
function api.__index(_,k)
    if api[k] then return api[k] end
    Zlog.warn("试图访问不存在的API:[%s]",tostring(k))
end
--保护metatable防止修改
api.__metatable=false

--delay(int)  延迟int毫秒
api.mSleep = getfunc("mSleep","sleep","mSleep")
--trace(string)    控制台输出string信息
api.sysLog = getfunc("sysLog","log","sysLog")
--mTime()   返回本地时间,毫秒级
api.mTime =  getfunc("mTime","os.milliTime","mTime")
--touchdown(index,x,y)  index号手指在x,y点按下
api.touchDown=getfunc("touchDown","touch.down","touchDown")
--touchmove(index,x,y)  index号手指移动到x,y点(非连续滑动)
api.touchMove=getfunc("touchMove","touch.move","touchMove")
--touchup(index,x,y)  index号手指在x,y点抬起
api.touchUp=getfunc("touchUp","touch.up","touchUp")
--getcolor(x,y) 获取x,y点的颜色,int返回
api.getColor=getfunc("getColor","screen.getColorHex","getColor")
--r,g,b=getcolorRGB(x,y)    获取x,y点的颜色,rgb分别返回
api.getColorRGB=getfunc("getColorRGB","screen.getColorRGB","getColorRGB")
--keepscreen(bool)  保持屏幕开关
api.keepScreen=getfunc("keepScreen","screen.keep","keepScreen")
api.lua_exit=getfunc("lua_exit","lua_exit","os.exit")

api.getColor=getfunc("getColor","screen.getColor","getColor")
api.getColorRGB=getfunc("getColorRGB","screen.getColorHex","getColorRGB")

if version==1 then
    --针对1.9的api
    local findColor=getfunc("findColor","findColor")
    api.findColor=function(rect,color,degree,hdir,vdir,priority)
        if type(rect)=="string" then rect=rg(rect) end
        if type(color)=="string" then color=sg(color) end
        local x,y = findColor(rect.toTable,color.str,degree or 100,hdir or 0,vdir or 0,priority or 0)
        if x==-1 then return Point.INVALID end
        return Point(x,y)
    end
    local findColors=getfunc("findColors","findColors")
    --修复版的findColors函数,自定义返回值数量(limit参数,默认200),支持hdir,vdir,priority三个参数的全部八种搜索方式
    local function RepairFindColors(rect,color,degree,hdir,vdir,priority,limit)
        local allresult={}
        local oneresult
        limit=limit or 200
        oneresult=findColors(rect,color,degree,hdir,vdir,priority)
        if #oneresult>0 then
            for i=1,#oneresult do
                table.insert(allresult,oneresult[i])
                if i>= limit then break end
            end
        end
        if #oneresult==99 then
            local result99=oneresult[99]
            if priority==0 and hdir==0 then
                oneresult=RepairFindColors(
                    {result99.x+1,result99.y,rect[3],result99.y},
                    color,degree,hdir,vdir,priority,limit-#allresult)
            elseif priority==0 and hdir==1 then
                oneresult=RepairFindColors(
                    {rect[1],result99.y,result99.x-1,result99.y},
                    color,degree,hdir,vdir,priority,limit-#allresult)
            elseif priority==1 and vdir==0 then
                oneresult=RepairFindColors(
                    {result99.x,result99.y+1,result99.x,rect[4]},
                    color,degree,hdir,vdir,priority,limit-#allresult)
            elseif priority==1 and vdir==1 then
                oneresult=RepairFindColors(
                    {result99.x,rect[2],result99.x,result99.y-1},
                    color,degree,hdir,vdir,priority,limit-#allresult)
            end
            if #oneresult>0 then
                for i=1,#oneresult do
                    if #allresult>= limit then break end
                    table.insert(allresult,oneresult[i])
                end
            end
            if #allresult<limit then
                if priority==0 and vdir==0 and result99.y<rect[4] then
                    oneresult=RepairFindColors(
                        {rect[1],result99.y+1,rect[3],rect[4]},
                        color,degree,hdir,vdir,priority,limit-#allresult)
                elseif priority==0 and vdir==1 and result99.y>rect[2] then
                    oneresult=RepairFindColors(
                        {rect[1],rect[2],rect[3],result99.y-1},
                        color,degree,hdir,vdir,priority,limit-#allresult)
                elseif priority==1 and hdir==0 and result99.x<rect[3] then
                    oneresult=RepairFindColors(
                        {result99.x+1,rect[2],rect[3],rect[4]},
                        color,degree,hdir,vdir,priority,limit-#allresult)
                elseif priority==1 and hdir==1 and result99.x>rect[1] then
                    oneresult=RepairFindColors(
                        {rect[1],rect[2],result99.x-1,rect[4]},
                        color,degree,hdir,vdir,priority,limit-#allresult)
                else
                    return allresult
                end
                if #oneresult>0 then
                    for i=1,#oneresult do
                        if #allresult>= limit then break end
                        table.insert(allresult,oneresult[i])
                    end
                end
            end
        end
        return allresult
    end
    api.findColors=function(rect,color,degree,hdir,vdir,priority,limit)
        if type(rect)=="string" then rect=rg(rect) end
        if type(color)=="string" then color=sg(color) end
        local ret = RepairFindColors(
            rect.toTable,color.str,
            degree or 100,hdir or 0,vdir or 0,priority or 0,limit or 200)
        for i=1,#ret do
            ret[i]=Point(ret[i].x,ret[i].y)
        end
        return ret
    end



elseif version==2 then
    --针对2.0的api
    local findColor=getfunc("findColor","screen.findColor")
    api.findColor=function(rect,color,globalFuzz,priority)
        if type(rect)=="string" then rect=rg(rect) end
        if type(color)=="string" then color=sg(color) end
        local x,y = findColor(rect.toNativeRect,color.str,globalFuzz or 100,priority)
        if x==-1 then return Point.INVALID end
        return Point(x,y)
    end
    local findColors=getfunc("findColors","screen.findColors")
    api.findColors=function(rect,color,globalFuzz,priority,limit)
        if type(rect)=="string" then rect=rg(rect) end
        if type(color)=="string" then color=sg(color) end
        local ret = findColors(rect.toNativeRect,color.str,globalFuzz or 100,priority,limit)
        for i=1,#ret do
            ret[i]=Point(ret[i].x,ret[i].y)
        end
        return ret
    end


end




















return setmetatable({},api)