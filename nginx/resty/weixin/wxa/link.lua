
local wx = require "resty.weixin"

local __ = { _VERSION = "22.11.16" }

__._TESTING = function()

    package.loaded["resty.weixin"] = nil
    wx = require "resty.weixin"

    wx.init()

    local res, err = wx.wxa.link.generate_scheme()
    wx.test.echo ( "-- 获取scheme码", res or err)

    local res, err = wx.wxa.link.generate_url_link()
    wx.test.echo ( "-- 获取 URL Link", res or err)

end

__.types = {
    JumpInfo = {
        path    = "string? //小程序页面路径：通过 scheme 码进入的小程序页面路径，必须是已经发布的小程序存在的页面，不可携带 query。path 为空时会跳转小程序主页。",
        query   = "string? //查询参数：通过 scheme 码进入小程序时的 query，最大1024个字符，只支持数字，大小写英文以及部分特殊字符：`!#$&'()*+,/:;=?@-._~%``",
        env_version = 'string? //小程序版本：默认值"release"。要打开的小程序版本。正式版为"release"，体验版为"trial"，开发版为"develop"，仅在微信外打开时生效',
    }
}

__.generate_scheme__ = {
    "获取scheme码",
    doc = "https://developers.weixin.qq.com/miniprogram/dev/OpenApiDoc/qrcode-link/url-scheme/generateScheme.html",
    req = {
        jump_wxa    = "@JumpInfo? //跳转到的目标小程序信息",
        is_expire   = "string? //scheme码类型：默认值false。生成的 scheme 码类型，到期失效：true，永久有效：false",
        expire_time = "number? //scheme码失效时间：到期失效的 scheme 码的失效时间，为 Unix 时间戳。生成的到期失效 scheme 码在该时间前有效。最长有效期为1年。is_expire 为 true 且 expire_type 为 0 时必填",
        expire_type = "number? //scheme码失效类型：默认值0，到期失效的 scheme 码失效类型，失效时间：0，失效间隔天数：1",
        expire_interval = "number? //scheme码的失效间隔天数：生成的到期失效 scheme 码在该间隔时间到达前有效。最长间隔天数为365天。is_expire 为 true 且 expire_type 为 1 时必填"
    },
    res = {
        openlink    = "string // 生成的小程序 scheme 码",
        errcode     = "number // 错误码",
        errmsg      = "string // 错误信息",
    }
}
__.generate_scheme = function(t)
    return wx.http.send {
        url     = "https://api.weixin.qq.com/wxa/generatescheme",
        token   = true,
        body    = {
            jump_wxa        = t.jump_wxa,
            is_expire       = t.is_expire,
            expire_time     = t.expire_time,
            expire_type     = t.expire_type,
            expire_interval = t.expire_interval,
        }
    }
end

__.generate_url_link__ = {
    "获取 URL Link",
    doc = "https://developers.weixin.qq.com/miniprogram/dev/OpenApiDoc/qrcode-link/url-link/generateUrlLink.html",
    req = {
        path = "string? // 小程序页面路径：通过 URL Link 进入的小程序页面路径，必须是已经发布的小程序存在的页面，不可携带 query 。path 为空时会跳转小程序主页",
        query = "string? // 请求参数：通过 URL Link 进入小程序时的query，最大1024个字符，只支持数字，大小写英文以及部分特殊字符：!#$&'()*+,/:;=?@-._~%",
        is_expire   = "string? //URL Link 类型：默认值false。生成的 URL Link 类型，到期失效：true，永久有效：false",
        expire_type = "number? //URL Link失效类型：默认值0，到期失效的 URL Link 失效类型，失效时间：0，失效间隔天数：1",
        expire_time = "number? //到期失效的 URL Link 的失效时间，为 Unix 时间戳。生成的到期失效 URL Link 在该时间前有效。最长有效期为1年。expire_type 为 0 必填",
        expire_interval = "number? //到期失效的URL Link的失效间隔天数。生成的到期失效URL Link在该间隔时间到达前有效。最长间隔天数为365天。expire_type 为 1 必填",
        env_version = 'string? //小程序版本：默认值"release"。要打开的小程序版本。正式版为"release"，体验版为"trial"，开发版为"develop"，仅在微信外打开时生效',

    },
    res = {

    }
}
__.generate_url_link = function(t)
    return wx.http.send {
        url     = "https://api.weixin.qq.com/wxa/generate_urllink",
        token   = true,
        body    = {
            path            = t.path,
            query           = t.query,
            is_expire       = t.is_expire,
            expire_type     = t.expire_type,
            expire_time     = t.expire_time,
            expire_interval = t.expire_interval,
            env_version     = t.env_version,
        }
    }
end

return __
