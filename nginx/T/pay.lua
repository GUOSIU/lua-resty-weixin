
package.loaded["resty.weixin.pay"] = nil
local wxpay         = require "resty.weixin.pay"
local cjson_pretty  = require "resty.prettycjson"

wxpay.ctx.set{
    appid   = "YOUR APPID",
    mchid   = "YOUR MCHID",
    mchkey  = "YOUR MCHKEY",
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
    notify_url      = "https://ngx.weimember.cn/notify_url.lpage",
    trade_type      = "JSAPI",
    openid          = "oFTJvt9wP8DeZY3lb30zqCq-BySw",
}
echo(cjson_pretty(res or err))
echo ""

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
