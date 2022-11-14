
local __ = {}
__.ver   = "22.10.27"
__.name  = "Hello, OpenResty"
__.doc   = "https://openresty.org/"
------------------------------------------------------

__.actx = function()

    local ffi = require "ffi"
    local IS_64_BIT = ffi.abi('64bit')

    ngx.header["content-type"] = "text/plain"

    ngx.say ""
    ngx.say ("Hello, OpenResty! ",  ffi.os, IS_64_BIT and " 64bit" or " 32bit")
    ngx.say ""
    ngx.say "------------------------------------------"
    ngx.say ""

    local function load_lib(lib_name)
        local pok, lib = pcall(require, lib_name)
        if pok then
            ngx.say(lib_name, ": ", lib._VERSION or lib.VERSION or " (ok)")
        else
            ngx.say(lib_name, ": ", lib)
        end
    end

    load_lib("lfs")
    load_lib("socket")
    load_lib("utf8")
    load_lib("hashids")
    load_lib("iconv")
    ngx.say "------------------------------------------"
    load_lib("resty.mlcache")
    load_lib("resty.template")
    load_lib("resty.http")
    load_lib("resty.iputils")

    ngx.say ""
    ngx.say "------------------------------------------"
    ngx.say ""

    ffi.cdef[[
    const char *zlibVersion();
    const char *OpenSSL_version(int t);
    const char *ngx_http_lua_ffi_pcre_version(void);
    ]]

    local zlibVersion = ffi.string(ffi.C.zlibVersion())
    ngx.say("zlibVersion: ", zlibVersion)

    local OpenSSL_version = ffi.string(ffi.C.OpenSSL_version(0))
    ngx.say("OpenSSL_version: ", OpenSSL_version)

    local pcre_version = ffi.string(ffi.C.ngx_http_lua_ffi_pcre_version())
    ngx.say("pcre_version: ", pcre_version)

    ngx.say ""
    ngx.say "------------------------------------------"
    ngx.say ""
    ngx.say ( "ngx.config.subsystem          ", ngx.config.subsystem       )
    ngx.say ( "ngx.config.debug              ", ngx.config.debug           )
    ngx.say ( "ngx.config.prefix()           ", ngx.config.prefix()        )
    ngx.say ( "ngx.config.nginx_version      ", ngx.config.nginx_version   )
    ngx.say ( "ngx.config.ngx_lua_version    ", ngx.config.ngx_lua_version )

    ngx.say ""
    ngx.say "------------------------------------------"
    ngx.say ""

    local conf = ngx.config.nginx_configure()
    conf = string.gsub(conf, "--prefix", "\n--prefix")
    conf = string.gsub(conf, "--with-", "\n--with-")
    conf = string.gsub(conf, "--add-", "\n--add-")
    ngx.say ( "ngx.config.nginx_configure()")
    ngx.say ( conf )
    ngx.say ""
    ngx.say "------------------------------------------"
    ngx.say ""
    ngx.say "package.path: "
    ngx.say ""
    local path = string.gsub(package.path, ";", ";\n")
    ngx.say (path)
    ngx.say ""
    ngx.say "------------------------------------------"
    ngx.say ""
    ngx.say "package.cpath: "
    ngx.say ""
    local cpath = string.gsub(package.cpath, ";", ";\n")
    ngx.say (cpath)
    ngx.say ""
end

------------------------------------------------------
return __ -- 返回模块
