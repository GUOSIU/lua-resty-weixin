
package.loaded["resty.weixin.app"] = nil
local wxapp         = require "resty.weixin.app"
local cjson_pretty  = require "resty.prettycjson"

wxapp.ctx.set{
    appid  = "YOUR APPID",
    secret = "YOUR SECRET",
}

ngx.header["content-type"] = "text/plain"
ngx.header["language"] = "lua"

local function echo(...)
    ngx.say(...)
    ngx.flush()
end

echo "-- 1. auth授权接口 -------------------------------------------------"
echo "-- 小程序登录"
    local  res, err = wxapp.auth.code2session { js_code = "1235467890" }
echo ( cjson_pretty(res or err) )
echo ""

echo "-- 2. link链接接口 -------------------------------------------------"
echo "-- 获取scheme码"
    local  res, err = wxapp.link.generate_scheme()
echo ( cjson_pretty(res or err) )
echo ""

echo "-- 获取URL-Link"
    local  res, err = wxapp.link.generate_url_link()
echo ( cjson_pretty(res or err) )
echo ""

echo "-- 3. message消息接口 -------------------------------------------------"
echo "-- 获取客服消息内的临时素材"
    local  res, err = wxapp.message.get_temp_media { media_id = "1235467890" }
echo ( cjson_pretty(res or err) )
echo ""

echo "-- 新增图片素材"
    local  res, err = wxapp.message.upload_temp_media { image_content = "1235467890" }
echo ( cjson_pretty(res or err) )
echo ""

echo "-- 发送客服消息"
    local  res, err = wxapp.message.send_custom_message {
        touser  = "oVs8y6bohaCm8I0XmuGuLbhzr_IU",
        msgtype = "text",
        text    = { content = "hello openresty!" }
    }
echo ( cjson_pretty(res or err) )
echo ""


echo "-- 4. qrcode二维码接口 -------------------------------------------------"
echo "-- 获取小程序码"
    local  res, err = wxapp.qrcode.get_qrcode  {
        path = "/pages/home",
    }
echo ( cjson_pretty(res or err) )
echo ""

echo "-- 获取不限制的小程序码"
    local  res, err = wxapp.qrcode.get_unlimited_qrcode  {
        scene = "1234567890",
    }
echo ( cjson_pretty(res or err) )
echo ""

echo "-- 获取小程序二维码"
    local  res, err = wxapp.qrcode.create_qrcode  {
        path = "/pages/home",
    }
echo ( cjson_pretty(res or err) )
echo ""

echo "-- 5. user用户接口 -------------------------------------------------"
echo "-- 获取手机号"
    local  res, err = wxapp.user.get_phone_number  { code = "your code" }
echo ( cjson_pretty(res or err) )
echo ""
