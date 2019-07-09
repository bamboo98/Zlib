-- 此文件作为Zlibs插件加载入口文件
-- 此文件会在Z.init()的最后被调用,无须手动调用
-- 修改此文件之前请确保对Zlibs有充足理解
-- 插件列表
local pluginsList = {
    'ZY', -- 竹云
    'ExtraFindColor' -- 额外的找色函数
}
local Zlog = require 'Zlibs.class.Log'
for _, v in ipairs(pluginsList) do
    local ok, _ = pcall(require, 'Zlibs.plugins.' .. v)
    if ok then
        Zlog.info('插件<%s>加载成功', v)
        -- else
        --     Zlog.info('插件<%s>加载失败',v)
    end
end
