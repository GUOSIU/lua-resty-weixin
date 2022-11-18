
local wx    = require "resty.weixin"

local __ = { _VERSION = "22.11.16" }

__._TESTING = function()

    package.loaded["resty.weixin"] = nil
    wx = require "resty.weixin"

    wx.init()

    local res, err = wx.wxa.kf_message.get_temp_media { media_id = "1235467890" }
    wx.test.echo ( "-- 获取客服消息内的临时素材", res or err)

    local res, err = wx.wxa.kf_message.upload_temp_media {
        image_content = "1234567890"
    }
    wx.test.echo ( "-- 新增图片素材", res or err)

    local res, err = wx.wxa.kf_message.send_custom_message {
        touser  = "oVs8y6bohaCm8I0XmuGuLbhzr_IU",
        msgtype = "text",
        text    = { content = "hello openresty!" }
    }
    wx.test.echo ( "-- 发送客服消息", res or err)

end

__.get_temp_media__ = {
    "获取客服消息内的临时素材",
    doc = "https://developers.weixin.qq.com/miniprogram/dev/OpenApiDoc/kf-mgnt/kf-message/getTempMedia.html",
    req = {
        { "media_id"    , "媒体文件ID" },
    },
    res = {
        buffer      = "string // 图片 Buffer",
        contentType = "string // contentType",
        errcode     = "number // 错误码",
        errmsg      = "string // 错误信息",
    }
}
__.get_temp_media = function(t)
    return wx.http.send {
        url     = "https://api.weixin.qq.com/cgi-bin/media/get",
        token   = true,
        args    = { media_id = t.media_id }
    }
end

__.upload_temp_media__ = {
    "新增图片素材（用于发送客服消息或被动回复用户消息，3天有效）",
    doc = "https://developers.weixin.qq.com/miniprogram/dev/OpenApiDoc/kf-mgnt/kf-message/uploadTempMedia.html",
    req = {
        type            = "string? //文件类型：可填“ image”，表示图片，目前仅支持图片",
        image_type      = "string? //上传的文件类型",
        image_content   = "string  //上传的文件内容",
     -- media = "FormData//媒体文件标识：form-data 中媒体文件标识，有filename、filelength、content-type等信息"
    },
    res = {
        type        = "string // 文件类型",
        media_id    = "string // 媒体文件上传后，获取标识，3天内有效。",
        created_at  = "number // 媒体文件上传时间戳",
        errcode     = "number // 错误码",
        errmsg      = "string // 错误信息",
    }
}
__.upload_temp_media = function(t)
    return wx.http.send {
        url             = "https://api.weixin.qq.com/cgi-bin/media/upload",
        token           = true,
        args            = { type = t.type or "image" },
        image_type      = t.image_type or "jpg",
        image_content   = t.image_content,
    }
end

__.send_custom_message__ = {
    "发送客服消息",
    doc = "https://developers.weixin.qq.com/miniprogram/dev/OpenApiDoc/kf-mgnt/kf-message/sendCustomMessage.html",
    req = {
        touser  = "string //用户的 OpenID",
        msgtype = "string //消息类型：text表示文本消息；image表示图片消息；link表示图文链接；miniprogrampage表示小程序卡片",
        text    = '@TextInfo? // 文本消息：msgtype="text" 时必填',
        image   = '@ImageInfo? // 图片消息：msgtype="image" 时必填',
        link    = '@LinkInfo? // 图文链接：msgtype="link" 时必填',
        miniprogrampage = '@MiniProgrampageInfo? // 小程序卡片：msgtype="miniprogrampage" 时必填',
    },
    types = {
        TextInfo = {
            content = "string // 文本消息内容"
        },
        ImageInfo = {
            media_id = "string // 发送的图片的媒体ID：通过 uploadTempMedia上传图片文件获得。"
        },
        LinkInfo = {
            title       = "string // 消息标题",
            description = "string // 图文链接消息",
            url         = "string // 图文链接消息被点击后跳转的链接",
            thumb_url   = "string // 图文链接消息的图片链接，支持 JPG、PNG 格式，较好的效果为大图 640 X 320，小图 80 X 80",
        },
        MiniProgrampageInfo = {
            title       = "string // 消息标题",
            pagepath    = "string // 小程序的页面路径，跟 app.json 对齐，支持参数，比如pages/index/index?foo=bar",
            thumb_media_id = "string // 小程序消息卡片的封面， image 类型的 media_id，通过 uploadTempMedia接口上传图片文件获得，建议大小为 520*416",
        }
    },
    res = {
        errcode     = "number // 错误码",
        errmsg      = "string // 错误信息",
    }
}
__.send_custom_message = function(t)

    t.text              = t.msgtype == "text"  and t.text  or nil
    t.image             = t.msgtype == "image" and t.image or nil
    t.link              = t.msgtype == "link"  and t.link  or nil
    t.miniprogrampage   = t.msgtype == "miniprogrampage" and t.miniprogrampage or nil

    if t.msgtype == "text" then
        if not t.text then return nil, "文本消息不能为空" end
    elseif t.msgtype == "image" then
        if not t.image then return nil, "图片消息不能为空" end
    elseif t.msgtype == "link" then
        if not t.link then return nil, "图文链接不能为空" end
    elseif t.msgtype == "miniprogrampage" then
        if not t.miniprogrampage then return nil, "小程序卡片不能为空" end
    else
        return nil, "msgtype类型错误"
    end

    return wx.http.send {
        url     = "https://api.weixin.qq.com/cgi-bin/message/custom/business/send",
        token   = true,
        body    = {
            touser      = t.touser,
            msgtype     = t.msgtype,
            test        = t.text,
            image       = t.image,
            link        = t.link,
            miniprogram = t.miniprogrampage
        }
    }
end

return __
