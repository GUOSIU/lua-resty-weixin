# lua-resty-weixin

## 功能 (Features)

* 支持 微信公众号接口
* 支持 微信小程序接口
* 支持 微信支付接口(同时支持服务商与普通商户两种模式)

## 依赖 (Dependences)

* [openresty-appx](https://github.com/killsen/openresty-appx)
* [openresty-orpm](https://github.com/killsen/openresty-orpm)

## 调用微信公众号接口

```lua
local wxgzh = require "resty.weixin.gzh"

-- 设置账户
wxgzh.ctx.set{
    appid  = "YOUR APPID",
    secret = "YOUR SECRET",
}

local  res, err = wxgzh.menu.get()
return res or err

```

## 调用微信小程序接口
```lua
local wxapp = require "resty.weixin.wxapp"

-- 设置账户
wxapp.ctx.set{
    appid  = "YOUR APPID",
    secret = "YOUR SECRET",
}

local  res, err = wxapp.auth.code2session { js_code = "" }
return res or err

```

## 调用微信支付接口
```lua
local wxpay = require "resty.weixin.wxpay"

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

-- 统一下单接口
local res, err = wxpay.order.create {
    body            = "测试商品",
    out_trade_no    = out_trade_no,
    total_fee       = total_fee,
    notify_url      = "Your Notify_url",
    trade_type      = "JSAPI",
    openid          = "",
}
return res or err

```
