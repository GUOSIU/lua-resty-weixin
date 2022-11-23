
package.loaded["resty.weixin.pay"] = nil
local wxpay         = require "resty.weixin.pay"
local cjson_pretty  = require "resty.prettycjson"

wxpay.ctx.set {
    appid           = "",       -- 公众账号ID或小程序ID
    mchid           = "",       -- 商户编码
    mchkey          = "",       -- 商户秘钥

    -- 服务商模式需要填写以下内容
    parent_mode     = 0,        -- 1 服务商 0 普通商户
    is_wxapp        = false,    -- 是否小程序
    parent_appid    = "",       -- 服务商公众账号ID
    parent_mchid    = "",       -- 服务商商户编码
    parent_mchkey   = "",       -- 服务商商户秘钥
}

ngx.header["content-type"] = "text/plain"
ngx.header["language"] = "lua"

local function echo(...)
    ngx.say(...)
    ngx.flush()
end

local out_trade_no  = wxpay.ctx.gen_nonce(32)
local out_refund_no = wxpay.ctx.gen_nonce(32)
local total_fee    = 0.01
echo ""
echo ("out_trade_no     :   ", out_trade_no)
echo ("out_refund_no    :   ", out_refund_no)
echo ("total_fee        :   ", total_fee)
echo ""

echo "-- 1. order支付接口 ---------------------------------"
echo "-- 统一下单接口"
local res, err = wxpay.order.create {
    body            = "测试商品",
    out_trade_no    = out_trade_no,
    total_fee       = total_fee,
    notify_url      = "Your Notify_url",
    trade_type      = "JSAPI",
    openid          = "",
}
echo(cjson_pretty(res or err))
echo ""

-- echo "-- 付款码支付接口"
-- local res, err = wxpay.order.micropay {
--     body            = "测试商品",
--     out_trade_no    = out_trade_no,
--     total_fee       = total_fee,
--     auth_code       = "",
-- }
-- echo(cjson_pretty(res or err))
-- echo ""

echo "-- 查询订单接口"
local res, err = wxpay.order.query {
    out_trade_no = out_trade_no
}
echo(cjson_pretty(res or err))
echo ""

echo "-- 关闭订单接口"
local res, err = wxpay.order.close {
    out_trade_no = out_trade_no
}
echo(cjson_pretty(res or err))
echo ""

echo "-- 申请退款接口"
local res, err = wxpay.order.refund {
    out_trade_no  = out_trade_no,
    out_refund_no = out_refund_no,
    total_fee     = total_fee,
    refund_fee    = total_fee,
}
echo(cjson_pretty(res or err))
echo ""

echo "-- 查询退款接口"
local res, err = wxpay.order.refund_query {
    out_trade_no  = out_trade_no,
    out_refund_no = out_refund_no,
}
echo(cjson_pretty(res or err))
echo ""

-- echo "-- 撤销订单(付款码支付)接口"
-- local res, err = wxpay.order.reverse {
--     out_trade_no = out_trade_no
-- }
-- echo(cjson_pretty(res or err))
-- echo ""
