# lua-resty-weixin

## 功能 (Features)

* 支持 微信公众号接口
* 支持 微信小程序接口
* 支持 微信支付接口(同时支持服务商与普通商户两种模式)

## 依赖 (Dependences)

* [openresty-appx](https://github.com/killsen/openresty-appx)
* [openresty-orpm](https://github.com/killsen/openresty-orpm)

## 微信公众号调用

```lua
local wxgzh         = require "resty.weixin.gzh"

-- 设置账户
wxgzh.ctx.set{
    appid  = "YOUR APPID",
    secret = "YOUR SECRET",
}

local  res, err = wxgzh.menu.get()
return res or err

```
