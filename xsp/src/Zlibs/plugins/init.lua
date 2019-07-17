-- 此文件作为Zlibs插件加载入口文件
-- 此文件会在Z.init()的最后被调用,无须手动调用
-- 修改此文件之前请确保对Zlibs有充足理解
local Zlog = require 'Zlibs.class.Log'
for _, config in ipairs(require'Z'.config.PluginList) do
    if config.enable then
        if config.addIndex and require'Z'[config.addIndex] then
            Zlog.warn(
                '插件<%s>加载失败,可能是已加载或与其他插件冲突',
                config.name)
        end
        local ok, ret = pcall(require, 'Zlibs.plugins.' .. config.entry)
        if ok then
            if type(ret) == 'function' then
                ok, ret = pcall(ret, config.config)
            end
            if ok then
                Zlog.info('插件<%s>加载成功', config.name)
                if config.addIndex then
                    ret = ret or true
                    require'Z'[config.addIndex] = ret
                end
            else
                Zlog.warn('插件<%s>加载失败,插件初始化失败',
                          config.name)
            end
        else
            Zlog.warn('插件<%s>加载失败,没有找到入口文件',
                      config.name)
        end
    end
end
