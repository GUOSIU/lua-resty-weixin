
local wx = require "resty.weixin"

local __ = { _VERSION = "22.11.04" }

__._TESTING = function()

    package.loaded["resty.weixin"] = nil
    wx = require "resty.weixin"

    wx.init()

    local res, err = wx.gzh.user.info { openid = "oVs8y6bohaCm8I0XmuGuLbhzr_IU" }
    wx.test.echo ( "-- 获取用户基本信息", res or err)

    local res, err = wx.gzh.user.batchget {
        user_list = {
            { openid = "oVs8y6bohaCm8I0XmuGuLbhzr_IU" }
        }
    }
    wx.test.echo ( "-- 批量获取用户基本信息", res or err)

    local res, err = wx.gzh.user.get()
    wx.test.echo ( "-- 用户管理/获取用户列表", res or err)

end

__.types = {
    UserInfo = {
        subscribe       = "number   //用户是否订阅该公众号标识，值为0时，代表此用户没有关注该公众号，拉取不到其余信息。",
        openid          = "string   //用户的标识，对当前公众号唯一",
        language        = "string   //用户的语言，简体中文为zh_CN",
        subscribe_time  = "number   //用户关注时间，为时间戳。如果用户曾多次关注，则取最后关注时间",
        unionid         = "string   //只有在用户将公众号绑定到微信开放平台帐号后，才会出现该字段。",
        remark          = "string   //公众号运营者对粉丝的备注，公众号运营者可在微信公众平台用户管理界面对粉丝添加备注",
        groupid         = "string   //用户所在的分组ID（兼容旧的用户分组接口）",
        tagid_list      = "number[] //用户被打上的标签 ID 列表",
        subscribe_scene = "string   //返回用户关注的渠道来源，ADD_SCENE_SEARCH 公众号搜索，ADD_SCENE_ACCOUNT_MIGRATION 公众号迁移，ADD_SCENE_PROFILE_CARD 名片分享，ADD_SCENE_QR_CODE 扫描二维码，ADD_SCENE_PROFILE_LINK 图文页内名称点击，ADD_SCENE_PROFILE_ITEM 图文页右上角菜单，ADD_SCENE_PAID 支付后关注，ADD_SCENE_WECHAT_ADVERTISEMENT 微信广告，ADD_SCENE_REPRINT 他人转载 ,ADD_SCENE_LIVESTREAM 视频号直播，ADD_SCENE_CHANNELS 视频号 , ADD_SCENE_OTHERS 其他",
        qr_scene        = "string   //二维码扫码场景（开发者自定义）",
        qr_scene_str    = "string   //二维码扫码场景描述（开发者自定义）",
    },
}

__.info__ = {
    "获取用户基本信息(UnionID机制)",
    doc = "https://developers.weixin.qq.com/doc/offiaccount/User_Management/Get_users_basic_information_UnionID.html#UinonId",
    req = {
        { "openid"  , "用户的标识"          },
        { "lang?"   , "国家地区语言版本"    },
    },
    res = "@UserInfo"
}
__.info = function(t)
    return wx.http.send {
        url     = "https://api.weixin.qq.com/cgi-bin/user/info",
        token   = true,
        args    = { openid = t.openid, lang = "zh_CN" }
    }
end

__.batchget__ = {
    "批量获取用户基本信息",
    doc = "https://developers.weixin.qq.com/doc/offiaccount/User_Management/Get_users_basic_information_UnionID.html#UinonId",
    req = {
        { "user_list"   , "openid列表"  , "@User[]" },
    },
    res = { "user_info_list", "用户信息列表", "@UserInfo[]"}
}
__.batchget = function(t)

    if type(t.user_list) ~= "table" or #t.user_list == 0 then
        return nil, "openid列表不能为空"
    end

    return wx.http.send {
        url     = "https://api.weixin.qq.com/cgi-bin/user/info/batchget",
        token   = true,
        body    = { user_list = t.user_list },
    }
end

__.get__ = {
    "用户管理/获取用户列表",
    doc = "https://developers.weixin.qq.com/doc/offiaccount/User_Management/Getting_a_User_List.html",
    req = {
        { "next_openid?"    , "第一个拉取的OPENID，不填默认从头开始拉取"  },
    },
    res = {
        total           = "number   //关注该公众账号的总用户数",
        count           = "number   //拉取的OPENID个数，最大值为10000",
        data            = {
            openid      = "string[] //列表数据，OPENID的列表"
        },
        next_openid     = "string   //拉取列表的最后一个用户的OPENID",
    }
}
__.get = function(t)
    return wx.http.send {
        url     = "https://api.weixin.qq.com/cgi-bin/user/get",
        token   = true,
        args    = { next_openid = t.next_openid }
    }
end

return __
