

local wx    = require "resty.weixin"
local utils = require "app.utils"

local __ = { _VERSION = "22.11.04" }

__._TESTING = function()

    package.loaded["resty.weixin"] = nil
    wx = require "resty.weixin"

    wx.init()

    local res, err = wx.gzh.auth.access_token { code = "1235467890" }
    wx.test.echo ( "-- 通过 code 换取网页授权access_token", res or err)

    local res, err = wx.gzh.auth.refresh_token { refresh_token = "1234567890" }
    wx.test.echo ("-- 刷新access_token", res or err)

    local res, err = wx.gzh.auth.get_user_info { access_token = "1234567890", openid = "1234567890" }
    wx.test.echo ("-- 拉取用户信息", res or err)

end

__.types = {
    UserInfo = {
        openid	        = "string   //用户标识：对当前公众号唯一",
        nickname	    = "string   //用户昵称",
        sex	            = "number   //用户性别：值为1时是男性，值为2时是女性，值为0时是未知",
        province	    = "string   //用户个人资料填写的省份",
        city	        = "string   //普通用户个人资料填写的城市",
        country	        = "string   //国家，如中国为CN",
        headimgurl	    = "string   //用户头像，最后一个数值代表正方形头像大小（有0、46、64、96、132数值可选，0代表640*640正方形头像），用户没有头像时该项为空。若用户更换头像，原有头像 URL 将失效。",
        privilege       = "string[] //用户特权信息，json 数组，如微信沃卡用户为（chinaunicom）",
        unionid	        = "string   //只有在用户将公众号绑定到微信开放平台帐号后，才会出现该字段。",
    }
}

__.access_token__ = {
    "通过 code 换取网页授权access_token",
    doc = "https://developers.weixin.qq.com/doc/offiaccount/OA_Web_Apps/Wechat_webpage_authorization.html",
    req = {
        { "appid?"      , "第三方用户唯一凭证"          },
        { "secret?"     , "第三方用户唯一凭证密钥"      },
        { "code"        , "用户同意授权后，获取code"    },
    },
    res = {
        access_token    = "string   //网页授权接口调用凭证,注意：此access_token与基础支持的access_token不同",
        expires_in      = "number   //access_token接口调用凭证超时时间，单位（秒）",
        refresh_token   = "string   //用户刷新access_token",
        openid          = "string   //用户唯一标识，请注意，在未关注公众号时，用户访问公众号的网页，也会产生一个用户和公众号唯一的OpenID",
        scope           = "string   //用户授权的作用域，使用逗号（,）分隔",
        is_snapshotuser = "string   //是否为快照页模式虚拟账号，只有当用户是快照页模式虚拟账号时返回，值为1",
    }
}
__.access_token = function(t)

    local weixin = ngx.ctx.weixin or {}

    t.appid  = utils.str.strip(t.appid ) or weixin.appid
    t.secret = utils.str.strip(t.secret) or weixin.secret

    return wx.http.send {
        url     = "https://api.weixin.qq.com/sns/oauth2/access_token",
        token   = false,   -- 不需要 access_token
        args    = {
            appid       = t.appid,
            secret      = t.secret,
            code        = t.code,
            grant_type  = "authorization_code", -- 默认，填写为authorization_code
        }
    }
end

__.refresh_token__ = {
    "刷新access_token",
    doc = "https://developers.weixin.qq.com/doc/offiaccount/OA_Web_Apps/Wechat_webpage_authorization.html",
    req = {
        { "appid?"          , "第三方用户唯一凭证"                              },
        { "refresh_token"   , "填写通过access_token获取到的refresh_token参数"   },
    },
    res = {
        access_token    = "string   //网页授权接口调用凭证,注意：此access_token与基础支持的access_token不同",
        expires_in      = "number   //access_token接口调用凭证超时时间，单位（秒）",
        refresh_token   = "string   //用户刷新access_token",
        openid          = "string   //用户唯一标识，请注意，在未关注公众号时，用户访问公众号的网页，也会产生一个用户和公众号唯一的OpenID",
        scope           = "string   //用户授权的作用域，使用逗号（,）分隔",
    }
}
__.refresh_token = function(t)

    local weixin = ngx.ctx.weixin or {}

    t.appid  = utils.str.strip(t.appid ) or weixin.appid

    return wx.http.send {
        url     = "https://api.weixin.qq.com/sns/oauth2/refresh_token",
        token   = false,   -- 不需要 access_token
        args    = {
            appid           = t.appid,
            refresh_token   = t.refresh_token,
            grant_type      = "refresh_token", -- 默认，填写为refresh_token
        }
    }
end

__.get_user_info__ = {
    "拉取用户信息(需 scope 为 snsapi_userinfo)",
    doc = "https://developers.weixin.qq.com/doc/offiaccount/OA_Web_Apps/Wechat_webpage_authorization.html",
    req = {
        { "access_token?"   , "网页授权接口调用凭证,注意：此access_token与基础支持的access_token不同"   },
        { "openid"          , "用户的唯一标识"                                                          },
        { "lang?"           , "返回国家地区语言版本，zh_CN 简体，zh_TW 繁体，en 英语"                   },
    },
    res = "@UserInfo"
}
__.get_user_info = function(t)
    return wx.http.send {
        url     = "https://api.weixin.qq.com/sns/userinfo",
        token   = false,   -- 不需要 access_token
        args    = {
            access_token    = t.access_token,
            openid          = t.openid,
            lang            = t.lang or "zh_CN"
        }
    }
end

return __
