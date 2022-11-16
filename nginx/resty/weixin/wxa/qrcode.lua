
local wx = require "resty.weixin"

local __ = { _VERSION = "22.11.16" }

__._TESTING = function()

    package.loaded["resty.weixin"] = nil
    wx = require "resty.weixin"

    wx.init()

    local res, err = wx.wxa.qrcode.get_qrcode {
        path = "/pages/home",
    }
    wx.test.echo ( "-- 获取小程序码", res or err)

    local res, err = wx.wxa.qrcode.get_unlimited_qrcode {
        scene = "1234567890",
    }
    wx.test.echo ( "-- 获取不限制的小程序码", res or err)

    local res, err = wx.wxa.qrcode.create_qrcode {
        path = "/pages/home",
    }
    wx.test.echo ( "-- 获取小程序二维码", res or err)

end

__.get_qrcode__ = {
    "获取小程序码",
    doc = "https://developers.weixin.qq.com/miniprogram/dev/OpenApiDoc/qrcode-link/qr-code/getQRCode.html",
    req = {
        path        = "string //小程序页面：扫码进入的小程序页面路径，最大长度 128 字节，不能为空",
        width       = "number? //二维码宽度：单位 px。默认值为430，最小 280px，最大 1280px",
        auto_color  = "boolean? //自动配置线条颜色：默认值false；自动配置线条颜色，如果颜色依然是黑色，则说明不建议配置主色调",
        line_color  = '@LintColor? //自定义线条颜色：默认值{"r":0,"g":0,"b":0} ；auto_color 为 false 时生效，使用 rgb 设置颜色',
        is_hyaline  = "boolean? //是否透明底色：默认值false；是否需要透明底色，为 true 时，生成透明底色的小程序码",
    },
    types = {
        LintColor = {
            r = 'string // 默认值{"r":0,"g":0,"b":0} ；auto_color 为 false 时生效，使用 rgb 设置颜色',
            g = 'string // 默认值{"r":0,"g":0,"b":0} ；auto_color 为 false 时生效，使用 rgb 设置颜色',
            b = 'string // 默认值{"r":0,"g":0,"b":0} ；auto_color 为 false 时生效，使用 rgb 设置颜色',
        },
    },
    res = {
        buffer      = "string // 图片 Buffer",
        errcode     = "number // 错误码",
        errmsg      = "string // 错误信息",
    }
}
__.get_qrcode = function(t)
    return wx.http.send {
        url     = "https://api.weixin.qq.com/wxa/getwxacode",
        token   = true,
        body    = {
            path        = t.path,
            width       = t.width,
            auto_color  = t.auto_color,
            line_color  = t.line_color,
            is_hyaline  = t.is_hyaline,
        }
    }
end

__.get_unlimited_qrcode__ = {
    "获取不限制的小程序码",
    doc = "https://developers.weixin.qq.com/miniprogram/dev/OpenApiDoc/qrcode-link/qr-code/getUnlimitedQRCode.html",
    req = {
        scene       = "string   //二维码场景：最大32个可见字符，只支持数字，大小写英文以及部分特殊字符：!#$&'()*+,/:;=?@-._~，其它字符请自行编码为合法字符（因不支持%，中文无法使用 urlencode 处理，请使用其他编码方式）",
        page        = "string?  //小程序页面：默认是主页，页面 page，例如 pages/index/index，根路径前不要填加 /，不能携带参数（参数请放在 scene 字段里），如果不填写这个字段，默认跳主页面。",
        check_path  = "boolean? //检查路径：默认是true，检查page 是否存在，为 true 时 page 必须是已经发布的小程序存在的页面（否则报错）；为 false 时允许小程序未发布或者 page 不存在， 但page 有数量上限（60000个）请勿滥用。",
        env_version = 'string?  //小程序版本：正式版为 "release"，体验版为 "trial"，开发版为 "develop"。默认是正式版。',
        width       = "number?  //二维码宽度：单位 px，默认 430px，最小 280px，最大 1280px",
        auto_color  = "boolean? //自动配置线条颜色：如果颜色依然是黑色，则说明不建议配置主色调，默认 false",
        line_color  = "@LintColor? //自定义线条颜色：auto_color 为 false 时生效，使用 rgb 设置颜色",
        is_hyaline  = "boolean? //是否透明底色：默认值false；是否需要透明底色，为 true 时，生成透明底色的小程序码",
    },
    res = {
        buffer      = "string // 图片 Buffer",
        errcode     = "number // 错误码",
        errmsg      = "string // 错误信息",
    }
}
__.get_unlimited_qrcode = function(t)
    return wx.http.send {
        url     = "https://api.weixin.qq.com/wxa/getwxacodeunlimit",
        token   = true,
        body    = {
            scene       = t.scene,
            page        = t.page,
            check_path  = t.check_path,
            env_version = t.env_version,
            width       = t.width,
            auto_color  = t.auto_color,
            line_color  = t.line_color,
            is_hyaline  = t.is_hyaline,
        }
    }
end

__.create_qrcode__ = {
    "获取小程序二维码",
    doc = "https://developers.weixin.qq.com/miniprogram/dev/OpenApiDoc/qrcode-link/qr-code/createQRCode.html",
    req = {
        path        = "string  //小程序页面：扫码进入的小程序页面路径，最大长度 128 字节，不能为空",
        width       = "number? //二维码宽度：单位 px。默认值为430，最小 280px，最大 1280px",
    },
    res = {
        buffer      = "string // 图片 Buffer",
        contentType = "string // contentType",
        errcode     = "number // 错误码",
        errmsg      = "string // 错误信息",
    }
}
__.create_qrcode = function(t)
    return wx.http.send {
        url     = "https://api.weixin.qq.com/cgi-bin/wxaapp/createwxaqrcode",
        token   = true,
        body    = {
            path    = t.path,
            width   = t.width,
        }
    }
end

return __
