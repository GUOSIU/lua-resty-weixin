
-- Lua-iconv: performs character set conversions in Lua
-- (c) 2005-11 Alexandre Erwin Ittner <alexandre@ittner.com.br>
-- Project page: http://ittner.github.com/lua-iconv/

local __ = {}
__.ver   = "21.08.30"
__.name  = "ittner/lua-iconv"
__.doc   = "https://github.com/ittner/lua-iconv"
------------------------------------------------------

local iconv = require "iconv"

__.actx = function()

    ngx.header["content-type"] = "text/plain; charset=gbk"

    ngx.update_time()
    local t1 = ngx.now()
    ngx.say("start   : ", t1)

    local utf8_to_gbk = iconv.new("gbk", "utf-8")
    local gbk_to_utf8 = iconv.new("utf-8", "gbk")

    local str = "abc我是中国人123"
    local count = 100000

    ngx.say("count   : ", count)

    for i=1, count do
        local str_gbk, err = utf8_to_gbk:iconv(str)
        assert(str_gbk and err == nil)
        if i==count then ngx.say("gbk     : ", str_gbk) end

        local str_inv, err = gbk_to_utf8:iconv(str)
        assert(str_inv=="abc鎴戞槸涓" and err == iconv.ERROR_INVALID)
        if i==count then ngx.say("invalid : ", str_inv) end

        local str_utf8, err = gbk_to_utf8:iconv(str_gbk)
        assert(str_utf8==str and err == nil)
        if i==count then ngx.say("utf8    : ", str_utf8) end
    end

    ngx.update_time()
    local t2 = ngx.now()
    ngx.say("finish  : ", t2)
    ngx.say("used    : ", t2-t1)

end

------------------------------------------------------
return __ -- 返回模块
