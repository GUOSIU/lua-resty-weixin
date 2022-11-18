
local wxpay     = require "resty.weixin.pay"
local _http     = require "resty.weixin.http"
local utils     = require "app.utils"
local _encode   = require "cjson.safe".encode

local __ = { _VERSION = "22.11.16" }

__.types = {
    WxPayReult = {
        return_code     = "//返回状态码：SUCCESS/FAIL，此字段是通信标识，非交易标识，交易是否成功需要查看result_code来判断",
        return_msg      = "//返回信息：当return_code为FAIL时返回信息为错误原因，例如签名失败参数格式校验错误",

        -- 以下字段在return_code为SUCCESS的时候有返回
        appid           = "//公众账号ID：调用接口提交的公众账号ID",
        mch_id	        = "//商户号：调用接口提交的商户号",
        device_info	    = "//设备号：自定义参数，可以为请求支付的终端设备号等",
        nonce_str 	    = "//随机字符串：微信返回的随机字符串",
        sign   	        = "//签名：微信返回的签名值，详见签名算法",
        result_code     = "//业务结果：SUCCESS/FAIL",
        err_code        = "//错误代码：当result_code为FAIL时返回错误代码",
        err_code_des    = "//错误描述：当result_code为FAIL时返回错误描述",
    },
}

__.create__ = {
    "统一下单",
    doc = "https://pay.weixin.qq.com/wiki/doc/api/wxa/wxa_api.php?chapter=9_1",
    req = {
     -- appid       = "string // 公众账号ID或小程序ID: String(32)小程序ID或公众号ID",
     -- mch_id      = "string // 商户号: String(32)微信支付分配的商户号",
        device_info = "string? // 端设备号：String(32)自定义参数，可以为终端设备号(门店号或收银设备ID)，PC网页或公众号内支付可以传'WEB'",
     -- nonce_str   = "string // 随机字符串：String(32)长度要求在32位以内。",
     -- sign        = "string // 签名: String(64)通过签名算法计算得出的签名值",
        sign_type   = "string?// 签名类型: String(32)签名类型，默认为MD5，支持HMAC-SHA256和MD5。",
        body        = "string // 商品描述: String(127)商品简单描述",
        detail      = "string? // 商品详情: String(6000)商品详细描述，对于使用单品优惠的商户，该字段必须按照规范上传",
        attach      = "any? // 附加数据: String(127)附加数据，在查询API和支付通知中原样返回，可作为自定义参数使用",
        out_trade_no = "string // 商户订单号: String(32)商户系统内部订单号，要求32个字符内，只能是数字、大小写字母_-|*且在同一个商户号下唯一",
        fee_type    = "string? // 标价币种: String(16)符合ISO 4217标准的三位字母代码，默认人民币：CNY",
        total_fee   = "number // 标价金额: int订单总金额，单位为元 (特殊地，内部转换单位为分)",
     -- spbill_create_ip = "string // 终端IP: String(64)支持IPV4和IPV6两种格式的IP地址。调用微信支付API的机器IP",
        time_start  = "string? // 交易起始时间: String(14)订单生成时间，格式为yyyyMMddHHmmss",
        time_expire = "string? // 交易结束时间: String(14)订单失效时间，格式为yyyyMMddHHmmss",
        goods_tag   = "string? // 订单优惠标记: String(32)订单优惠标记，使用代金券或立减优惠功能时需要的参数",
        notify_url  = "string // 通知地址: String(256)异步接收微信支付结果通知的回调地址，通知url必须为外网可访问的url，不能携带参数。公网域名必须为https",
        trade_type  = "string // 交易类型: String(16) 小程序 - JSAPI, JSAPI支付 - JSAPI, Native支付 - NATIVE, APP支付 - APP",
        product_id  = "string? // 商品ID: String(32)trade_type=NATIVE时，此参数必传。此参数为二维码中包含的商品ID，商户自行定义",
        limit_pay   = "string? // 指定支付方式: String(32)上传此参数no_credit--可限制用户不能使用信用卡支付",
        openid      = "string? // 用户标识: String(128)trade_type=JSAPI，此参数必传，用户在商户appid下的唯一标识",
        receipt     = "string? // 电子发票入口开放标识: String(8)Y，传入Y时，支付成功消息和支付详情页将出现开票入口。需要在微信支付商户平台或微信公众平台开通电子发票功能，传此字段才可生效",
        profit_sharing = "string? // 是否需要分账: String(16)Y-是，需要分账,N-否，不分账, 字母要求大写，不传默认不分账",
        scene_info = "string? // 场景信息: String(256)该字段常用于线下活动时的场景信息上报，支持上报实际门店信息，商户也可以按需求自己上报相关信息。该字段为JSON对象数据",
    },
    res = {
        "@WxPayReult",
        -- 以下字段在return_code 和result_code都为SUCCESS的时候有返回
        trade_type      = "//交易类型：JSAPI支付、Native支付、APP支付",
        prepay_id       = "//预支付交易会话标识：用于后续接口调用中使用，该值有效期为2小时",
        code_url        = [[//二维码链接：
        trade_type=NATIVE时有返回，此url用于生成支付二维码，然后提供给用户进行扫码支付。
        注意：code_url的值并非固定，使用时按照URL格式转成二维码即可]],

        -- 以下字段我们加的
        out_trade_no    = "//商户订单号：【补充字段】"
    }
}
__.create = function(t)

    local appid     = wxpay.ctx.get_appid()
    local mchid     = wxpay.ctx.get_mchid()

    if not appid then return nil, "公众账号ID或小程序ID不能为空" end
    if not mchid then return nil, "商户号不能为空" end

    t.total_fee = tonumber(t.total_fee)
    if not t.total_fee or t.total_fee<=0 then return nil, "支付金额必须大于0" end

    if t.trade_type == "JSAPI" and (not t.openid or t.openid == "") then
        return nil, "用户标识不能为空"
    end

    if t.trade_type == "NATIVE" and (not t.product_id or t.product_id == "") then
        return nil, "商品ID不能为空"
    end

    if type(t.attach) == "table" then t.attach = _encode(t.attach) end

    local body = {
        appid               = appid,
        mch_id              = mchid,

        openid              = t.openid,
        out_trade_no        = t.out_trade_no,
        total_fee           = t.total_fee * 100, -- 金额（单位：分）
        fee_type            = t.fee_type or "CNY", -- 默认人民币

        notify_url          = t.notify_url,
        nonce_str           = wxpay.ctx.gen_nonce(32),

        trade_type          = t.openid and "JSAPI" or "NATIVE",
        sign_type           = t.sign_type or "MD5",

        device_info         = t.device_info or "WEB",
        body                = t.body,
        goods_tag           = t.goods_tag,
        product_id          = t.product_id,
        attach              = t.attach,
        spbill_create_ip    = t.spbill_create_ip or ngx.var.remote_addr,

        detail              = t.detail,
        time_start          = t.time_start,
        time_expire         = t.time_expire,
        limit_pay           = t.limit_pay,
        receipt             = t.receipt,
        profit_sharing      = t.profit_sharing,
        scene_info          = t.scene_info,
    }

    -- 签名
    body.sign = wxpay.ctx.gen_sign(body)

    local xml, err = _http.send {
        url     = "https://api.mch.weixin.qq.com/pay/unifiedorder",
        token   = false,    -- 不需要 access_token
        xml     = true,     -- 返回 xml
        body    = utils.xml.to_xml(body)
    }
    if not xml then return nil, err end

    local  res, err = utils.xml.from_xml(xml)
    if not res then return nil, err end

    if res.return_code ~= "SUCCESS" then return nil, res.return_msg   end
    if res.result_code ~= "SUCCESS" then return nil, res.err_code_des end

    res.out_trade_no = t.out_trade_no
    return res

end

return __
