-- @@api : openresty-vsce

local apix = require "app.comm.apix"

local api = apix.new()

api.init__ = {
    "初始化账户",
    req = {
        { "appid?"  , "第三方用户唯一凭证"          },
        { "secret?" , "第三方用户唯一凭证密钥"      },
    },
    res = "boolean"
}
api.init = function(t)

    if ngx.var.host == "127.0.0.1" then
        t = t or {
            appid  = "wxf2031a5be9134a04",
            secret = "9767d26d925e7db586625de09c37035a",
        }
    end

    if type(t) ~= "table" then return nil, "提供参数错误" end
    if type(t.appid) ~= "string" or t.appid == "" then return nil, "appid不能为空" end
    if type(t.secret) ~= "string" or t.secret == "" then return nil, "secret不能为空" end

    ngx.ctx.weixin = {
        appid   = t.appid,
        secret  = t.secret,
    }
    return true

end

return api
