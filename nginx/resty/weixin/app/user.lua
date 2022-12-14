
local wxapp = require "resty.weixin.app"

local __ = { _VERSION = "22.11.16" }

__.get_phone_number__ = {
    "获取手机号",
    doc = "https://developers.weixin.qq.com/miniprogram/dev/OpenApiDoc/user-info/phone-number/getPhoneNumber.html",
    req = {
        { "code"    , "手机号获取凭证。动态令牌。可通过动态令牌换取用户手机号"  },
    },
    types = {
        WaterMark = {
            timestamp   = "number //用户获取手机号操作的时间戳",
            appid       = "string //小程序appid"
        }
    },
    res = {
        phoneNumber     = "string //用户绑定的手机号（国外手机号会有区号）",
        purePhoneNumber = "string //没有区号的手机号",
        countryCode     = "string //区号",
        watermark       = "@WaterMark//数据水印",
    }
}
__.get_phone_number = function(t)
    return wxapp.ctx.request {
        url     = "https://api.weixin.qq.com/wxa/business/getuserphonenumber",
        token   = true,
        body    = { code = t.code },
    }
end

return __
