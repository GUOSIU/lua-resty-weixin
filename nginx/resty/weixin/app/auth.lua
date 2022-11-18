
local wxapp = require "resty.weixin.app"

local __ = { _VERSION = "22.11.16" }

__.code2session__ = {
    "小程序登录",
    doc = "https://developers.weixin.qq.com/miniprogram/dev/OpenApiDoc/user-login/code2Session.html",
    req = {
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
__.code2session = function(t)

    local  appid  = wxapp.ctx.get_appid()
    local  secret = wxapp.ctx.get_secret()
    if not appid  then return nil, "第三方用户唯一凭证不能为空" end
    if not secret then return nil, "第三方用户唯一凭证密钥不能为空" end

    return wxapp.ctx.request {
        url     = "https://api.weixin.qq.com/sns/jscode2session",
        token   = false,   -- 不需要 access_token
        args    = {
            appid       = appid,
            secret      = secret,
            js_code     = t.js_code,
            grant_type  = "authorization_code", -- 默认，填写为authorization_code
        }
    }
end

return __
