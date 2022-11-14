
local gsub, sub = string.gsub, string.sub

local prefix = ngx.config.prefix()

prefix = gsub(prefix, "\\", "/")
if "/" ~= sub(prefix, -1) then
    prefix = prefix .. "/"
end

local lua_modules = prefix .. "../lua_modules/"

for i = #prefix - 1, 2, -1 do
    if "/" == sub(prefix, i, i) then
        lua_modules = sub(prefix, 1, i) .. "lua_modules/"
        break
    end
end

-- 保留原有的 package.path
local package_path = rawget(_G, "package_path")
if not package_path then
    package_path = package.path
    rawset(_G, "package_path", package_path)
end

-- 保留原有的 package.cpath
local package_cpath = rawget(_G, "package_cpath")
if not package_cpath then
    package_cpath = package.cpath
    rawset(_G, "package_cpath", package_cpath)
end

-- lua 模块检索路径
local path = {
    prefix      .. "?.lua",
    prefix      .. "?/init.lua",
    prefix      .. "lua/?.lua",
    prefix      .. "lua/?/init.lua",
    prefix      .. "lualib/?.lua",
    prefix      .. "lualib/?/init.lua",
    ------------------------------------
    lua_modules .. "?.lua",
    lua_modules .. "?/init.lua",
    lua_modules .. "lua/?.lua",
    lua_modules .. "lua/?/init.lua",
    lua_modules .. "lualib/?.lua",
    lua_modules .. "lualib/?/init.lua",
    ------------------------------------
    package_path, ";"  -- 原有的 package.path
}

-- clib 模块检索路径
local cpath = {
    prefix      .. "?.so",
    prefix      .. "clib/?.so",
    prefix      .. "clib/?/?.so",
    prefix      .. "lualib/?.so",
    prefix      .. "lualib/?/?.so",
    ------------------------------------
    lua_modules .. "?.so",
    lua_modules .. "clib/?.so",
    lua_modules .. "clib/?/?.so",
    lua_modules .. "lualib/?.so",
    lua_modules .. "lualib/?/?.so",
    ------------------------------------
    prefix      .. "?.dll",
    prefix      .. "clib/?.dll",
    prefix      .. "clib/?/?.dll",
    prefix      .. "lualib/?.dll",
    prefix      .. "lualib/?/?.dll",
    ------------------------------------
    lua_modules .. "?.dll",
    lua_modules .. "clib/?.dll",
    lua_modules .. "clib/?/?.dll",
    lua_modules .. "lualib/?.dll",
    lua_modules .. "lualib/?/?.dll",
    ------------------------------------
    package_cpath, ";"  -- 原有的 package.cpath
}

package.path = table.concat(path, ";")
package.cpath = table.concat(cpath, ";")

local pok, err = pcall(require, "app.comm._init")
if not pok then
    ngx.log(ngx.ERR, err)
    return
end

local pok, app = pcall(require, "app")
if not pok then
    ngx.log(ngx.ERR, app)
    return
end

rawset(_G, "_app_main"      , app.main)
rawset(_G, "_app_auth"      , app.auth)
rawset(_G, "_app_help"      , app.help)
rawset(_G, "_app_monitor"   , app.monitor)
rawset(_G, "_app_info"      , app.info)
rawset(_G, "_app_debug"     , app.debug)
