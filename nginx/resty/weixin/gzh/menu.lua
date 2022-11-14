
local http_send = require "resty.weixin.http".send

local __ = { _VERSION = "22.11.01" }

__.types = {
    news_info = {
        { "title"       , "图文消息的标题"  },
        { "author"      , "作者"            },
        { "digest"      , "摘要"            },
        { "show_cover"  , "是否显示封面，0为不显示，1为显示" , "number" },
        { "cover_url"   , "封面图片的URL"   },
        { "content_url" , "正文的URL"       },
        { "source_url"  , "原文的URL，若置空则无查看原文入口" },
    },
    news_info_list = {
        { "list"        , "图文消息列表"    , "@news_info[]" }
    },
    button_info = {
        { "type"        , "菜单的类型"      },
        { "name"        , "菜单名称"        },
        { "key?"        , "指定类型的值"    },
        { "url?"        , "指定类型的值"    },
        { "value?"      , "指定类型的值"    },
        { "news_info?"  , "图文消息的信息"  , "@news_info_list" },
    },
    sub_button = {
        { "list"        , "子菜单列表"  , "@button_info[]" }
    },
    button = {
        "@button_info",
        { "sub_button?" , "子菜单"      , "sub_button" }
    },
    selfmenu_info = { { "button?" , "菜单按钮", "@button[]" } },
    sub_buttonx = {
        { "name"        , "菜单标题，不超过16个字节，子菜单不超过60个字节" },
        { "type"        , "菜单的响应动作类型，view表示网页类型，click表示点击类型，miniprogram表示小程序类型" },
        { "url?"        , "网页链接，用户点击菜单可打开链接，不超过1024字节" },
        { "key?"        , "菜单KEY值，用于消息接口推送，click等点击类型必须" },
        { "media_id?"   , "调用新增永久素材接口返回的合法media_id。media_id类型和view_limited类型必须" },
        { "appid?"      , "小程序的appid（仅认证公众号可配置）。miniprogram类型必须" },
        { "pagepath?"   , "小程序的页面路径。miniprogram类型必须" },
        { "article_id?" , "发布后获得的合法 article_id。article_id类型和article_view_limited类型必须" },
    },
    buttonx = {
        { "name"        , "菜单标题，不超过16个字节，子菜单不超过60个字节"      },
        { "type?"       , "菜单的响应动作类型，view表示网页类型，click表示点击类型，miniprogram表示小程序类型" },
        { "url?"        , "网页链接，用户点击菜单可打开链接，不超过1024字节" },
        { "key?"        , "菜单KEY值，用于消息接口推送，click等点击类型必须"    },
        { "media_id?"   , "调用新增永久素材接口返回的合法media_id。media_id类型和view_limited类型必须" },
        { "appid?"      , "小程序的appid（仅认证公众号可配置）。miniprogram类型必须" },
        { "pagepath?"   , "小程序的页面路径。miniprogram类型必须" },
        { "article_id?" , "发布后获得的合法 article_id。article_id类型和article_view_limited类型必须" },
        { "sub_button?" , "二级菜单数组，个数应为1~5个", "@sub_buttonx[]"   },
    },
}

__.get__ = {
    "自定义菜单/查询接口",
    doc = "https://developers.weixin.qq.com/doc/offiaccount/Custom_Menus/Querying_Custom_Menus.html",
    req = {
        { "appid"   , "第三方用户唯一凭证"      },
        { "secret"  , "第三方用户唯一凭证密钥"  },
    },
    res = {
        { "is_menu_open"    , "菜单是否开启"    , "number"          },
        { "selfmenu_info"   , "菜单信息"        , "selfmenu_info[]" },
    }
}
__.get = function(t)
    return http_send {
        url     = "https://api.weixin.qq.com/cgi-bin/get_current_selfmenu_info",
        token   = true,
        appid   = t.appid,
        secret  = t.secret,
    }
end

__.create__ = {
    "自定义菜单/创建接口",
    doc = "https://developers.weixin.qq.com/doc/offiaccount/Custom_Menus/Creating_Custom-Defined_Menu.html",
    req = {
        { "appid"   , "第三方用户唯一凭证"      },
        { "secret"  , "第三方用户唯一凭证密钥"  },
        { "button"  , "一级菜单数组，个数应为1~3个" , "@buttonx[]"   },
    },
    res = {
        { "errcode" , "错误编码，0为正确", "number" },
        { "errmsg"  , "错误信息，ok为正确"          }
    }
}
__.create = function(t)
    return http_send {
        url     = "https://api.weixin.qq.com/cgi-bin/menu/create",
        token   = true,
        appid   = t.appid,
        secret  = t.secret,
        body    = { button = t.button },
    }
end

__.delete__ = {
    "自定义菜单/删除接口",
    doc = "https://developers.weixin.qq.com/doc/offiaccount/Custom_Menus/Deleting_Custom-Defined_Menu.html",
    req = {
        { "appid"   , "第三方用户唯一凭证"      },
        { "secret"  , "第三方用户唯一凭证密钥"  },
    },
    res = {
        { "errcode" , "错误编码，0为正确", "number" },
        { "errmsg"  , "错误信息，ok为正确"          }
    }
}
__.delete = function(t)
    return http_send {
        url     = "https://api.weixin.qq.com/cgi-bin/menu/delete",
        token   = true,
        appid   = t.appid,
        secret  = t.secret,
    }
end

return __
