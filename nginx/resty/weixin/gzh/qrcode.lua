
local wxgzh = require "resty.weixin.gzh"

local __ = { _VERSION = "22.11.16" }

__.create_qrcode__ = {
    "生成临时二维码",
    doc = "https://developers.weixin.qq.com/doc/offiaccount/Account_Management/Generating_a_Parametric_QR_Code.html",
    req = {
        { "expire_seconds"  , "该二维码有效时间，以秒为单位。 最大不超过2592000（即30天），此字段如果不填，则默认有效期为60秒。", "number" },
        { "scene_str"       , "场景值ID（字符串形式的ID），字符串类型，长度限制为1到64" },
    },
    res = {
        ticket          = "string //获取的二维码ticket，凭借此 ticket 可以在有效时间内换取二维码。",
        expire_seconds  = "number // 该二维码有效时间，以秒为单位。 最大不超过2592000（即30天）。",
        url             = "string //二维码图片解析后的地址，开发者可根据该地址自行生成需要的二维码图片",
    }
}
__.create_qrcode = function(t)

    t.expire_seconds = tonumber(t.expire_seconds) or 60            -- 以秒为单位
    if t.expire_seconds > 2592000 then t.expire_seconds = 2592000 end -- 最大30天
    if t.expire_seconds < 60      then t.expire_seconds = 60      end -- 最小60秒

    return wxgzh.ctx.request {
        url     = "https://api.weixin.qq.com/cgi-bin/qrcode/create",
        token   = true,
        body    = {
            action_name     = "QR_STR_SCENE",
            expire_seconds  = t.expire_seconds,
            action_info     = { scene = { scene_str = t.scene_str }},
        }
    }
end

__.create_limit_qrcode__ = {
    "生成永久二维码",
    doc = "https://developers.weixin.qq.com/doc/offiaccount/Account_Management/Generating_a_Parametric_QR_Code.html",
    req = {
        { "scene_str"       , "场景值ID（字符串形式的ID），字符串类型，长度限制为1到64" },
    },
    res = {
        ticket          = "string //获取的二维码ticket，凭借此 ticket 可以在有效时间内换取二维码。",
        expire_seconds  = "number // 该二维码有效时间，以秒为单位。 最大不超过2592000（即30天）。",
        url             = "string //二维码图片解析后的地址，开发者可根据该地址自行生成需要的二维码图片",
    }
}
__.create_limit_qrcode = function(t)
    return wxgzh.ctx.request {
        url     = "https://api.weixin.qq.com/cgi-bin/qrcode/create",
        token   = true,
        body    = {
            action_name     = "QR_LIMIT_STR_SCENE",
            action_info     = { scene = { scene_str = t.scene_str }},
        }
    }
end


return __
