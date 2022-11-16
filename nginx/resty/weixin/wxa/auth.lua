
local wx    = require "resty.weixin"
local utils = require "app.utils"

local __ = { _VERSION = "22.11.16" }

__._TESTING = function()

    package.loaded["resty.weixin"] = nil
    wx = require "resty.weixin"

    wx.init()

    local res, err = wx.wxa.auth.jscode2session { js_code = "1235467890" }
    wx.test.echo ( "-- 小程序登录", res or err)

end

__.code2Session__ = {
    "小程序登录",
    doc = "https://developers.weixin.qq.com/miniprogram/dev/OpenApiDoc/user-login/code2Session.html",
    req = {
        { "appid?"      , "小程序 appId"          },
        { "secret?"     , "小程序 appSecret"      },
        { "js_code"     , "登录时获取的 code，可通过wx.login获取"    },
    },
    res = {
        session_key = "string //会话密钥",
        openid      = "string //用户唯一标识",
        unionid     = "string //用户在开放平台的唯一标识符，若当前小程序已绑定到微信开放平台帐号下会返回",
        errmsg      = "string //错误信息",
        errcode     = "number //错误码",
    }
}
__.code2Session = function(t)

    local weixin = ngx.ctx.weixin or {}

    t.appid  = utils.str.strip(t.appid ) or weixin.appid
    t.secret = utils.str.strip(t.secret) or weixin.secret

    return wx.http.send {
        url     = "https://api.weixin.qq.com/sns/jscode2session",
        token   = false,   -- 不需要 access_token
        args    = {
            appid       = t.appid,
            secret      = t.secret,
            js_code     = t.js_code,
            grant_type  = "authorization_code", -- 默认，填写为authorization_code
        }
    }
end

return __
