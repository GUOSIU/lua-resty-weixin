
local wx = require "resty.weixin"

local __ = { _VERSION = "22.11.04" }

__._TESTING = function()

    wx.test.run {
        name    = " ------------ 获取用户基本信息 ------------ ",
        fun     = __.info,
        param   = { openid = "oVs8y6bohaCm8I0XmuGuLbhzr_IU" }
    }

    wx.test.run {
        name    = " ------------ 批量获取用户基本信息 ------------ ",
        fun     = __.batchget,
        param   = {
            user_list = {
                { openid = "oVs8y6bohaCm8I0XmuGuLbhzr_IU" }
            }
        }
    }

    wx.test.run {
        name    = " ------------ 用户管理/获取用户列表 ------------ ",
        fun     = __.get,
     -- param   = { next_openid = "oVs8y6bohaCm8I0XmuGuLbhzr_IU" }
    }

end

__.types = {
    User = {
        { "openid"  , "用户的标识"          },
        { "lang?"   , "国家地区语言版本"    },
    },
    UserInfo = {
        { "subscribe"       , "用户是否订阅该公众号标识" , "number" },
        { "openid?"         , "用户的标识" },
        { "language?"       , "用户的语言" },
        { "subscribe_time?" , "用户最后关注时间，为时间戳" , "number" },
        { "unionid?"        , "只有在用户将公众号绑定到微信开放平台帐号后，才会出现该字段" },
        { "remark?"         , "公众号运营者对粉丝的备注" },
        { "groupid?"        , "用户所在的分组ID" , "number" },
        { "tagid_list?"     , "用户被打上的标签 ID 列表", "number[]" },
        { "qr_scene?"       , "二维码扫码场景（开发者自定义）" },
        { "qr_scene_str?"   , "二维码扫码场景描述（开发者自定义）" },
    },
}

__.info__ = {
    "获取用户基本信息(UnionID机制)",
    doc = "https://developers.weixin.qq.com/doc/offiaccount/User_Management/Get_users_basic_information_UnionID.html#UinonId",
    req = {
        "@User",
        { "appid?"  , "第三方用户唯一凭证"      },
        { "secret?" , "第三方用户唯一凭证密钥"  },
    },
    res = "@UserInfo"
}
__.info = function(t)
    return wx.http.send {
        url     = "https://api.weixin.qq.com/cgi-bin/user/info",
        token   = true,
        appid   = t.appid,
        secret  = t.secret,
        args    = { openid = t.openid, lang = "zh_CN" }
    }
end

__.batchget__ = {
    "批量获取用户基本信息",
    doc = "https://developers.weixin.qq.com/doc/offiaccount/User_Management/Get_users_basic_information_UnionID.html#UinonId",
    req = {
        { "appid?"      , "第三方用户唯一凭证"      },
        { "secret?"     , "第三方用户唯一凭证密钥"  },
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
        appid   = t.appid,
        secret  = t.secret,
        body    = { user_list = t.user_list },
    }
end

__.get__ = {
    "用户管理/获取用户列表",
    doc = "https://developers.weixin.qq.com/doc/offiaccount/User_Management/Getting_a_User_List.html",
    req = {
        { "appid?"          , "第三方用户唯一凭证"      },
        { "secret?"         , "第三方用户唯一凭证密钥"  },
        { "next_openid?"    , "第一个拉取的OPENID，不填默认从头开始拉取"  },
    },
    res = {
        { "total"   , "关注该公众账号的总用户数"            , "number"  },
        { "count"   , "拉取的 OPENID 个数，最大值为10000"   , "number"  },
        { "data?"   , "列表数据，OPENID的列表"              , "string[]"},
        { "next_openid" , "拉取列表的最后一个用户的OPENID"              },
    }
}
__.get = function(t)
    return wx.http.send {
        url     = "https://api.weixin.qq.com/cgi-bin/user/get",
        token   = true,
        appid   = t.appid,
        secret  = t.secret,
        args    = { next_openid = t.next_openid }
    }
end

return __
