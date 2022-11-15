
local wx            = require "resty.weixin"
local cjson_pretty  = require "resty.prettycjson"

local __ = {}

__.echo = function(...)

    ngx.header["language"] = "lua"

    for _, v in ipairs({...}) do
        if type(v) == "table" then
            ngx.say(cjson_pretty(v))
        else
            ngx.say(v)
        end
    end

    ngx.say ""

end

__.run__ = {
    "代码测试",
    req = {
        { "name"    , "描述信息"                    },
        { "fun"     , "执行方法"    , "function"    },
        { "param?"  , "参数"        , "any"         },
    }
}
__.run = function(t)

    wx.init()

    local  pok, res, err = pcall(t.fun, t.param or {})
    if not pok then
        __.echo(t.name, res)
        return
    end

    __.echo (t.name, res or err)

end

return __
