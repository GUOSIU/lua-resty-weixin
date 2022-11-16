
local wx = require "resty.weixin"

local __ = { _VERSION = "22.11.16" }

__._TESTING = function()

    package.loaded["resty.weixin"] = nil
    wx = require "resty.weixin"

    wx.init()

    local res, err = wx.gzh.message.template_send {
        touser      = "oVs8y6bohaCm8I0XmuGuLbhzr_IU",
        template_id = "123",
        url         = "https://www.baidu.com",
        first       = "您好！",
        remark      = "欢迎下次光临！",
        keywords    = {ngx.localtime(), "abc", "123"}
    }
    wx.test.echo ( "-- 发送模板消息", res or err)

end

__.types = {
    MiniInfo = {
        appid    = "string  //所需跳转到的小程序appid（该小程序 appid 必须与发模板消息的公众号是绑定关联关系，暂不支持小游戏）",
        pagepath = "string? //所需跳转到小程序的具体页面路径，支持带参数,（示例index?foo=bar），要求该小程序已发布，暂不支持小游戏"
    },
}

__.template_send__ = {
    "发送模板消息",
    doc = "https://developers.weixin.qq.com/doc/offiaccount/Message_Management/Template_Message_Interface.html",
    req = {
        touser          = "string  //接收者openid",
        template_id     = "string  //模板ID",
        url             = "string? //模板跳转链接（海外帐号没有跳转能力）",
        miniprogram     = "@MiniInfo? //跳小程序所需数据，不需跳小程序可不用传该数据",
     -- data            = "string //模板数据",
        first           = "string   // 首行内容",
        remark          = "string   // 底部内容",
        keywords        = "string[] // 关键词数组",
        color           = "string? //模板内容字体颜色，不填默认为黑色",
        client_msg_id   = "string? //防重入id。对于同一个openid + client_msg_id, 只发送一条消息,10分钟有效,超过10分钟不保证效果。若无防重入需求，可不填"
    },
    res = {
        msgid       = "number //消息编码",
        errcode     = "number //错误编码",
        errmsg      = "string //错误信息",
    }
}
__.template_send = function(t)

    local data = {
        first  = { value = t.first .. "\n",  color="#173177" },
        remark = { value = "\n" .. t.remark, color="#173177" },
    }
    for i, v in ipairs(t.keywords) do
        data["keyword" .. i] = { value=v, color="#173177" }
    end

    return wx.http.send {
        url     = "https://api.weixin.qq.com/cgi-bin/message/template/send"
    ,   token   = true
    ,   body    = {
            touser          = t.touser,
            template_id     = t.template_id,
            url             = t.url,
            miniprogram     = t.miniprogram,
            data            = data,
            color           = t.color,
            client_msg_id   = t.client_msg_id,
        }
    }
end

return __
