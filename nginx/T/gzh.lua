
package.loaded["resty.weixin.gzh"] = nil
local wxgzh         = require "resty.weixin.gzh"
local cjson_pretty  = require "resty.prettycjson"

wxgzh.ctx.set{
    appid  = "YOUR APPID",
    secret = "YOUR SECRET",
}

ngx.header["content-type"] = "text/plain"
ngx.header["language"] = "lua"

local function echo(...)
    ngx.say(...)
    ngx.flush()
end

echo "-- 1. menu菜单接口 -------------------------------------------------"
echo "-- 自定义菜单/查询接口"
    local  res, err = wxgzh.menu.get()
echo ( cjson_pretty(res or err) )
echo ""

echo "-- 自定义菜单/创建接口"
    local  res, err = wxgzh.menu.create {
        button  = {
            { name = "今日歌曲", type = "view", url = "http://www.soso.com/" },
            { name = "发送位置", type = "location_select", key = "rselfmenu_2_0" },
            { name = "多级菜单", sub_button = {
                { name = "今日歌曲", type = "view", url = "http://www.soso.com/" },
                { name = "发送位置", type = "location_select", key = "rselfmenu_2_0" },
            }}
        }
    }
echo ( cjson_pretty(res or err) )
echo ""

echo "-- 自定义菜单/删除接口"
    local  res, err = wxgzh.menu.delete()
echo ( cjson_pretty(res or err) )
echo ""

echo "-- 2. auth用户授权接口 -------------------------------------------------"
echo "-- 通过code换取网页授权access_token"
    local  res, err = wxgzh.auth.access_token  { code = "1235467890" }
echo ( cjson_pretty(res or err) )
echo ""

echo "-- 刷新access_token"
    local  res, err = wxgzh.auth.refresh_token { refresh_token = "1235467890" }
echo ( cjson_pretty(res or err) )
echo ""

echo "-- 拉取用户信息"
    local  res, err = wxgzh.auth.get_user_info { access_token = "1234567890", openid = "1234567890" }
echo ( cjson_pretty(res or err) )
echo ""

echo "-- 3. message消息接口 -------------------------------------------------"
echo "-- 发送模板消息"
    local  res, err = wxgzh.message.template_send {
        touser      = "",
        template_id = "123",
        url         = "https://www.baidu.com",
        first       = "您好！",
        remark      = "欢迎下次光临！",
        keywords    = {ngx.localtime(), "abc", "123"}
    }
echo ( cjson_pretty(res or err) )
echo ""

echo "-- 4. qrcode二维码接口 -------------------------------------------------"
echo "-- 创建临时二维码"
    local  res, err = wxgzh.qrcode.create_qrcode {
        expire_seconds = 6000,
        scene_str = "test"
    }
echo ( cjson_pretty(res or err) )
echo ""

echo "-- 生成永久二维码"
    local  res, err = wxgzh.qrcode.create_limit_qrcode {
        scene_str = "test"
    }
echo ( cjson_pretty(res or err) )
echo ""

echo "-- 5. user用户接口 -------------------------------------------------"
echo "-- 获取用户基本信息"
    local  res, err = wxgzh.user.info { openid = "" }
echo ( cjson_pretty(res or err) )
echo ""

echo "-- 批量获取用户基本信息"
    local  res, err = wxgzh.user.batchget {
        user_list = {
            { openid = "" }
        }
    }
echo ( cjson_pretty(res or err) )
echo ""

echo "-- 用户管理/获取用户列表"
    local  res, err = wxgzh.user.get {  }
echo ( cjson_pretty(res or err) )
echo ""

