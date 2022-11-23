
local wxpay     = require "resty.weixin.pay"
local _encode   = require "cjson.safe".encode
local utils     = require "app.utils"

local _T = {}
local __ = { _VERSION = "22.11.16", types = _T }

-- 通讯标识
_T.SysCode = {
    return_code     = "//返回状态码：SUCCESS/FAIL，此字段是通信标识，非交易标识，交易是否成功需要查看result_code来判断",
    return_msg      = "//返回信息：返回信息，如非空，为错误原因",
}
-- 业务标识(return_code 为SUCCESS的时候有返回)
_T.BiCode = {
    appid           = "//公众账号ID：调用接口提交的公众账号ID",
    mch_id	        = "//商户号：调用接口提交的商户号",
    sub_appid       = "?//子商户公众账号ID: 微信分配的子商户公众账号ID",
    sub_mch_id      = "?//子商户号: 微信支付分配的子商户号",
    nonce_str 	    = "//随机字符串：微信返回的随机字符串",
    sign   	        = "//签名：微信返回的签名值，详见签名算法",
    result_code     = "//业务结果：SUCCESS/FAIL",
    err_code        = "//错误代码：当result_code为FAIL时返回错误代码",
    err_code_des    = "//错误描述：当result_code为FAIL时返回错误描述",
}

__.create__ = {
    "统一下单",
 -- doc = "https://pay.weixin.qq.com/wiki/doc/api/wxa/wxa_api.php?chapter=9_1",
    doc = "https://pay.weixin.qq.com/wiki/doc/api/jsapi_sl.php?chapter=9_1",
    req = {
     -- appid       = "string // 公众账号ID或小程序ID: String(32)小程序ID或公众号ID",
     -- mch_id      = "string // 商户号: String(32)微信支付分配的商户号",
     -- sub_appid   = "string // 子商户公众账号ID: 微信分配的子商户公众账号ID，如需在支付完成后获取sub_openid则此参数必传",
     -- sub_mch_id  = "string // 子商户号: String(32)微信支付分配的子商户号",
        device_info = "string? // 端设备号：String(32)自定义参数，可以为终端设备号(门店号或收银设备ID)，PC网页或公众号内支付可以传'WEB'",
     -- nonce_str   = "string // 随机字符串：String(32)长度要求在32位以内。",
     -- sign        = "string // 签名: String(64)通过签名算法计算得出的签名值",
        sign_type   = "string?// 签名类型: String(32)签名类型，默认为MD5，支持HMAC-SHA256和MD5。",
        openid      = "string? // 用户标识: String(128)trade_type=JSAPI，此参数必传，用户在商户appid下的唯一标识",
     -- sub_openid  = "string? // 用户子标识: String(128)trade_type=JSAPI，此参数必传，用户在商户appid下的唯一标识",
        body        = "string // 商品描述: String(127)商品简单描述",
        detail      = "string? // 商品详情: String(6000)商品详细描述，对于使用单品优惠的商户，该字段必须按照规范上传",
        attach      = "any? // 附加数据: String(127)附加数据，在查询API和支付通知中原样返回，可作为自定义参数使用",
        out_trade_no = "string // 商户订单号: String(32)商户系统内部订单号，要求32个字符内，只能是数字、大小写字母_-|*且在同一个商户号下唯一",
        fee_type    = "string? // 标价币种: String(16)符合ISO 4217标准的三位字母代码，默认人民币：CNY",
        total_fee   = "number // 订单金额: int订单总金额，单位为元 (特殊地，内部转换单位为分)",
     -- spbill_create_ip = "string // 终端IP: String(64)支持IPV4和IPV6两种格式的IP地址。调用微信支付API的机器IP",
        time_start  = "string? // 交易起始时间: String(14)订单生成时间，格式为yyyyMMddHHmmss",
        time_expire = "string? // 交易结束时间: String(14)订单失效时间，格式为yyyyMMddHHmmss",
        goods_tag   = "string? // 订单优惠标记: String(32)订单优惠标记，使用代金券或立减优惠功能时需要的参数",
        notify_url  = "string // 通知地址: String(256)异步接收微信支付结果通知的回调地址，通知url必须为外网可访问的url，不能携带参数。公网域名必须为https",
        trade_type  = "string // 交易类型: String(16) 小程序 - JSAPI, JSAPI支付 - JSAPI, Native支付 - NATIVE, APP支付 - APP",
        product_id  = "string? // 商品ID: String(32)trade_type=NATIVE时，此参数必传。此参数为二维码中包含的商品ID，商户自行定义",
        limit_pay   = "string? // 指定支付方式: String(32)上传此参数no_credit--可限制用户不能使用信用卡支付",
        receipt     = "string? // 电子发票入口开放标识: String(8)Y，传入Y时，支付成功消息和支付详情页将出现开票入口。需要在微信支付商户平台或微信公众平台开通电子发票功能，传此字段才可生效",
        profit_sharing = "string? // 是否需要分账: String(16)Y-是，需要分账,N-否，不分账, 字母要求大写，不传默认不分账",
        scene_info = "string? // 场景信息: String(256)该字段常用于线下活动时的场景信息上报，支持上报实际门店信息，商户也可以按需求自己上报相关信息。该字段为JSON对象数据",
    },
    res = {
        "@SysCode", "@BiCode",
        -- 以下字段在return_code 和result_code都为SUCCESS的时候有返回
        device_info     = "string? // 设备号: 微信支付分配的终端设备号",
        trade_type      = "string //交易类型：JSAPI支付、Native支付、APP支付",
        prepay_id       = "string //预支付交易会话标识：用于后续接口调用中使用，该值有效期为2小时",
        code_url        = [[string? //二维码链接：
        trade_type=NATIVE时有返回，此url用于生成支付二维码，然后提供给用户进行扫码支付。
        注意：code_url的值并非固定，使用时按照URL格式转成二维码即可]],
        -- 以下字段我们加的
        out_trade_no    = "string //商户订单号：【补充字段】"
    }
}
__.create = function(t)

    local  wx_account, err = wxpay.ctx.get_pay_account()
    if not wx_account then return nil, err end

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
        appid               = wx_account.pay_app_id,
        mch_id              = wx_account.pay_mch_id,
        sub_appid           = wx_account.sub_app_id,
        sub_mch_id          = wx_account.sub_mch_id,

        openid              = not wx_account.sub_app_id and t.openid or nil,
        sub_openid          =     wx_account.sub_app_id and t.openid or nil,

        out_trade_no        = t.out_trade_no,
        total_fee           = t.total_fee * 100, -- 金额（单位：分）
        fee_type            = t.fee_type or "CNY", -- 默认人民币

        notify_url          = t.notify_url,
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

    local obj, err = wxpay.ctx.request {
        url     = "https://api.mch.weixin.qq.com/pay/unifiedorder",
        body    = body
    }
    if not obj then return nil, err end

    obj.out_trade_no = t.out_trade_no
    return obj

end

__.get_package__ = {
    "获取微信支付数据包",
 -- doc = "https://pay.weixin.qq.com/wiki/doc/api/jsapi_sl.php?chapter=7_7&index=6",
    doc = "https://pay.weixin.qq.com/wiki/doc/api/wxa/wxa_sl_api.php?chapter=7_7&index=5",
    req = __.create__.req,
    res = {
        appId       = "//小程序或公众号id: appId为当前服务商号绑定的appid",
        timeStamp   = "//时间戳: 当前的时间",
        nonceStr    = "//随机字符串: 随机字符串，不长于32位",
        package     = "//订单详情扩展字符串: 统一下单接口返回的prepay_id参数值，提交格式如：prepay_id=***",
        signType    = "//签名方式: 签名类型，默认为MD5，支持HMAC-SHA256和MD5。注意此处需与统一下单的签名类型一致",
        paySign     = "//签名"
    },
}
__.get_package = function(t)

    local  wx_account, err = wxpay.ctx.get_pay_account()
    if not wx_account then return nil, err end

    local  res, err = __.create(t)
    if not res then return nil, err end

    local prepay_id = res.prepay_id
    if type(prepay_id) ~= "string" or prepay_id == "" then return nil, "生成预付单号空失败" end

    local p = {
        appId       = wx_account.pkg_app_id,
        timeStamp   = "" .. ngx.now() * 1000,    -- 强制字符串类型，否则ios系统出错
        nonceStr    = wxpay.ctx.gen_nonce(),
        package     = "prepay_id=" .. prepay_id, -- 预付单号
        signType    = "MD5",
    }

    p.paySign = wxpay.ctx.gen_sign(p, wx_account.pay_mch_key)

    return p
end

__.query__ = {
    "查询订单",
 -- doc = "https://pay.weixin.qq.com/wiki/doc/api/wxa/wxa_api.php?chapter=9_2",
    doc = "https://pay.weixin.qq.com/wiki/doc/api/jsapi_sl.php?chapter=9_2",
    req = {
     -- appid       = "string // 公众账号ID或小程序ID: String(32)小程序ID或公众号ID",
     -- mch_id      = "string // 商户号: String(32)微信支付分配的商户号",
        transaction_id  = "string? // 微信订单号: String(32)微信的订单号，优先使用",
        out_trade_no    = "string? // 商户订单号: String(32)商户系统内部订单号，要求32个字符内，只能是数字、大小写字母_-|*且在同一个商户号下唯一",
     -- nonce_str   = "string // 随机字符串：String(32)长度要求在32位以内。",
     -- sign        = "string // 签名: String(64)通过签名算法计算得出的签名值",
        sign_type   = "string?// 签名类型: String(32)签名类型，默认为MD5，支持HMAC-SHA256和MD5。",
    },
    res = {
        "@SysCode", "@BiCode",
        -- 以下字段在return_code 和result_code都为SUCCESS的时候有返回
        device_info     = "string? // 设备号: 微信支付分配的终端设备号",
        openid          = "string  // 用户标识: 用户在商户appid下的唯一标识",
        is_subscribe    = "string  // 是否关注公众账号: 用户是否关注公众账号，Y-关注，N-未关注",
        sub_openid      = "string? // 用户子标识: 用户在子商户appid下的唯一标识",
        trade_type      = "string  // 交易类型: 调用接口提交的交易类型，取值如下：JSAPI，NATIVE，APP，MICROPAY",
        trade_state     = [[string // 交易状态
            SUCCESS     -- 支付成功,
            REFUND      -- 转入退款,
            NOTPAY      -- 未支付,
            CLOSED      -- 已关闭,
            REVOKED     -- 已撤销(刷卡支付),
            USERPAYING  -- 用户支付中,
            PAYERROR    -- 支付失败(其他原因，如银行返回失败),
            ACCEPT      -- 已接收，等待扣款,
        ]],
        bank_type       = "string // 付款银行: 银行类型，采用字符串类型的银行标识",
        total_fee       = "number // 标价金额: 订单总金额，单位为分",
        settlement_total_fee = "number? // 应结订单金额: 当订单使用了免充值型优惠券后返回该参数，应结订单金额=订单金额-免充值优惠券金额",
        fee_type        = "string? // 标价币种: 货币类型，符合ISO 4217标准的三位字母代码，默认人民币：CNY",
        cash_fee        = "number  // 现金支付金额: 现金支付金额订单现金支付金额",
        cash_fee_type   = "string? // 现金支付币种: 货币类型，符合ISO 4217标准的三位字母代码，默认人民币：CNY",
        coupon_fee      = "number? // 代金券金额: 代金券”金额<=订单金额，订单金额-“代金券”金额=现金支付金额",
        coupon_count    = "number? // 代金券使用数量: 代金券使用数量",
        coupon_type_0   = "string? // 代金券类型: CASH--充值代金券, NO_CASH---非充值优惠券",
        coupon_id_0     = "string? // 代金券ID: 代金券ID, $n为下标，从0开始编号",
        coupon_fee_0    = "number? // 单个代金券支付金额: 单个代金券支付金额, $n为下标，从0开始编号",
        transaction_id  = "string  // 微信支付订单号: 微信支付订单号",
        out_trade_no    = "string  // 商户订单号: 商户系统内部订单号",
        attach          = "string? // 附加数据: 附加数据，原样返回",
        time_end        = "string  // 支付完成时间: 订单支付时间，格式为yyyyMMddHHmmss",
        trade_state_desc = "string // 交易状态描述: 对当前查询订单状态的描述和下一步操作的指引",
    }
}
__.query = function(t)

    local  wx_account, err = wxpay.ctx.get_pay_account()
    if not wx_account then return nil, err end

    t.transaction_id = utils.str.strip(t.transaction_id)
    t.out_trade_no   = utils.str.strip(t.out_trade_no)

    if not t.transaction_id and not t.out_trade_no then
        return nil, "微信订单号，或商户订单号，不能为空"
    end

    local body = {
        appid               = wx_account.pay_app_id,
        mch_id              = wx_account.pay_mch_id,
        sub_appid           = wx_account.sub_app_id,
        sub_mch_id          = wx_account.sub_mch_id,
        transaction_id      = t.transaction_id,
        out_trade_no        = t.out_trade_no,
        sign_type           = t.sign_type or "MD5",
    }

    local obj, err = wxpay.ctx.request {
        url     = "https://api.mch.weixin.qq.com/pay/orderquery",
        body    = body
    }
    if not obj then return nil, err end

    -- 若是服务商模式，openid对应的是服务商的appid
    -- 而我们更希望是得到 sub_appid 对应的openid
    if wx_account.sub_app_id then
        obj.openidx = obj.openid
        obj.openid  = obj.sub_openid
    end

    return obj
end

__.close__ = {
    "关闭订单",
 -- doc = "https://pay.weixin.qq.com/wiki/doc/api/wxa/wxa_api.php?chapter=9_3",
    doc = "https://pay.weixin.qq.com/wiki/doc/api/jsapi_sl.php?chapter=9_3",
    req = {
     -- appid           = "string // 公众账号ID或小程序ID: String(32)小程序ID或公众号ID",
     -- mch_id          = "string // 商户号: String(32)微信支付分配的商户号",
        out_trade_no    = "string // 商户订单号: String(32)商户系统内部订单号，要求32个字符内，只能是数字、大小写字母_-|*且在同一个商户号下唯一",
     -- nonce_str       = "string // 随机字符串：String(32)长度要求在32位以内。",
     -- sign            = "string // 签名: String(64)通过签名算法计算得出的签名值",
        sign_type       = "string?// 签名类型: String(32)签名类型，默认为MD5，支持HMAC-SHA256和MD5。",
    },
    res = { "@SysCode", "@BiCode" }
}
__.close = function(t)

    local  wx_account, err = wxpay.ctx.get_pay_account()
    if not wx_account then return nil, err end

    local body = {
        appid               = wx_account.pay_app_id,
        mch_id              = wx_account.pay_mch_id,
        sub_appid           = wx_account.sub_app_id,
        sub_mch_id          = wx_account.sub_mch_id,
        out_trade_no        = t.out_trade_no,
        sign_type           = t.sign_type or "MD5",
    }

    local obj, err = wxpay.ctx.request {
        url     = "https://api.mch.weixin.qq.com/pay/closeorder",
        body    = body
    }
    if not obj then return nil, err end

    return obj
end

__.refund__ = {
    "申请退款",
 -- doc = "https://pay.weixin.qq.com/wiki/doc/api/wxa/wxa_api.php?chapter=9_4",
    doc = "https://pay.weixin.qq.com/wiki/doc/api/jsapi_sl.php?chapter=9_4" ,
    req = {
     -- appid           = "string // 公众账号ID或小程序ID: String(32)小程序ID或公众号ID",
     -- mch_id          = "string // 商户号: String(32)微信支付分配的商户号",
     -- nonce_str       = "string // 随机字符串：String(32)长度要求在32位以内。",
     -- sign            = "string // 签名: String(64)通过签名算法计算得出的签名值",
        sign_type       = "string?// 签名类型: String(32)签名类型，默认为MD5，支持HMAC-SHA256和MD5。",
        transaction_id  = "string? // 微信订单号: String(32)微信生成的订单号，在支付通知中有返回",
        out_trade_no    = "string? // 商户订单号: String(32)商户系统内部订单号，要求32个字符内，只能是数字、大小写字母_-|*且在同一个商户号下唯一",
        out_refund_no   = "string  // 商户退款单号: String(64)商户系统内部的退款单号，商户系统内部唯一，只能是数字、大小写字母_-|*@ ，同一退款单号多次请求只退一笔。",
        total_fee       = "number  // 订单金额: int订单总金额，单位为元 (特殊地，内部转换单位为分)",
        refund_fee      = "number  // 退款金额: int订退款总金额，单位为元 (特殊地，内部转换单位为分)",
        refund_fee_type = "string? // 货币种类: String(8)货币类型，符合ISO 4217标准的三位字母代码，默认人民币：CNY",
        refund_desc     = "string? // 退款原因: String(80)若商户传入，会在下发给用户的退款消息中体现退款原因(注意：若订单退款金额≤1元，且属于部分退款，则不会在退款消息中体现退款原因)",
        refund_account  = "string? // 退款资金来源: String(30)仅针对老资金流商户使用。" ..
                          " REFUND_SOURCE_UNSETTLED_FUNDS --- 未结算资金退款（默认使用未结算资金退款; " ..
                          " REFUND_SOURCE_RECHARGE_FUNDS  --- 可用余额退款 ",
        notify_url      = "string? // 退款结果通知url: 异步接收微信支付退款结果通知的回调地址，通知URL必须为外网可访问的url，不允许带参数，公网域名必须为https",
    },
    res = {
        "@SysCode", "@BiCode",
        -- 以下字段在return_code 和result_code都为SUCCESS的时候有返回
        transaction_id  = "string // 微信支付订单号",
        out_trade_no    = "string // 商户订单号",
        out_refund_no   = "string // 商户退款单号",
        refund_id       = "string // 微信退款单号",
        refund_fee      = "number // 退款金额: 退款总金额,单位为分,可以做部分退款",
        settlement_refund_fee = "number? // 应结退款金额: 去掉非充值代金券退款金额后的退款金额，退款金额=申请退款金额-非充值代金券退款金额，退款金额<=申请退款金额",
        total_fee       = "number // 标价金额: 订单总金额，单位为分，只能为整数",
        settlement_total_fee = "number? // 应结订单金额: 去掉非充值代金券金额后的订单总金额，应结订单金额=订单金额-非充值代金券金额，应结订单金额<=订单金额。",
        fee_type        = "string? // 标价币种: 订单金额货币类型，符合ISO 4217标准的三位字母代码，默认人民币：CNY",
        cash_fee        = "number // 现金支付金额: 现金支付金额，单位为分，只能为整数",
        cash_fee_type   = "string? // 现金支付币种: 货币类型，符合ISO 4217标准的三位字母代码，默认人民币：CNY",
        cash_refund_fee = "number? // 现金退款金额: 现金退款金额，单位为分，只能为整数",
        coupon_type_0   = "string? // 代金券类型: CASH--充值代金券，NO_CASH---非充值代金券",
        coupon_refund_fee = "number? // 代金券退款总金额: 代金券退款金额<=退款金额，退款金额-代金券或立减优惠退款金额为现金",
        coupon_refund_fee_0 = "number? // 单个代金券退款金额: 代金券退款金额<=退款金额，退款金额-代金券或立减优惠退款金额为现金",
        coupon_refund_count = "number? // 退款代金券使用数量: 退款代金券使用数量",
        coupon_refund_id_0  = "string? // 退款代金券ID: 退款代金券ID, $n为下标，从0开始编号",
    }
}
__.refund = function(t)

    local  wx_account, err = wxpay.ctx.get_pay_account()
    if not wx_account then return nil, err end

    t.transaction_id = utils.str.strip(t.transaction_id)    -- 若两个参数都传，优先级最高
    t.out_trade_no   = utils.str.strip(t.out_trade_no)

    if not t.transaction_id and not t.out_trade_no then
        return nil, "微信订单号，或商户订单号，不能为空"
    end

    t.total_fee = tonumber(t.total_fee)
    if not t.total_fee or t.total_fee<=0 then return nil, "支付金额必须大于0" end

    t.refund_fee = tonumber(t.refund_fee)
    if not t.refund_fee or t.refund_fee<=0 then return nil, "退款金额必须大于0" end

    -- 重要！！请求需要双向证书
--  local url = "https://api.mch.weixin.qq.com/secapi/pay/refund"
    local url = "http://127.0.0.1/proxy/" --【使用反向代理（带证书）】
             .. wx_account.pay_mch_id .. "/secapi/pay/refund"

    local body = {
        appid               = wx_account.pay_app_id,
        mch_id              = wx_account.pay_mch_id,
        sub_appid           = wx_account.sub_app_id,
        sub_mch_id          = wx_account.sub_mch_id,
        sign_type           = t.sign_type or "MD5",
        transaction_id      = t.transaction_id,
        out_trade_no        = t.out_trade_no,
        out_refund_no       = t.out_refund_no,
        total_fee           = t.total_fee * 100,    -- 金额（单位：分）
        refund_fee          = t.refund_fee * 100,   -- 金额（单位：分）
        refund_fee_type     = t.refund_fee_type or "CNY", -- 默认人民币
        refund_desc         = t.refund_desc,
        refund_account      = t.refund_account,
        notify_url          = t.notify_url
    }

    local obj, err = wxpay.ctx.request {
        url     = url,
        body    = body
    }
    if not obj then return nil, err end

    return obj
end

__.refund_query__ = {
    "查询退款",
 -- doc = "https://pay.weixin.qq.com/wiki/doc/api/wxa/wxa_api.php?chapter=9_5",
    doc = "https://pay.weixin.qq.com/wiki/doc/api/jsapi_sl.php?chapter=9_5",
    req = {
     -- appid       = "string // 公众账号ID或小程序ID: String(32)小程序ID或公众号ID",
     -- mch_id      = "string // 商户号: String(32)微信支付分配的商户号",
     -- nonce_str   = "string // 随机字符串：String(32)长度要求在32位以内。",
     -- sign        = "string // 签名: String(64)通过签名算法计算得出的签名值",
        sign_type   = "string?// 签名类型: String(32)签名类型，默认为MD5，支持HMAC-SHA256和MD5。",
        transaction_id  = "string? // 微信订单号: String(32)微信的订单号，优先使用",
        out_trade_no    = "string? // 商户订单号: String(32)商户系统内部订单号，要求32个字符内，只能是数字、大小写字母_-|*且在同一个商户号下唯一",
        out_refund_no   = "string? // 商户退款单号: String(64)商户系统内部的退款单号，商户系统内部唯一，只能是数字、大小写字母_-|*@ ，同一退款单号多次请求只退一笔。",
        refund_id       = "string? // 微信退款单号: String(32)微信生成的退款单号，在申请退款接口有返回",
        offset          = "number? // 偏移量: 偏移量，当部分退款次数超过10次时可使用，表示返回的查询结果从这个偏移量开始取记录",
    },
    res = {
        "@SysCode", "@BiCode",
        -- 以下字段在return_code 和result_code都为SUCCESS的时候有返回
        total_refund_count  = "number? // 订单总退款次数: 订单总共已发生的部分退款次数，当请求参数传入offset后有返回",
        transaction_id      = "string // 微信订单号",
        out_trade_no        = "string // 商户订单号",
        total_fee           = "number // 订单金额",
        settlement_total_fee = "number? // 应结订单金额: 当订单使用了免充值型优惠券后返回该参数，应结订单金额=订单金额-免充值优惠券金额。",
        fee_type            = "string? // 货币种类: 订单金额货币类型，符合ISO 4217标准的三位字母代码，默认人民币：CNY",
        cash_fee            = "number // 现金支付金额: 现金支付金额，单位为分，只能为整数",
        refund_count        = "number // 退款笔数: 当前返回退款笔数",
        out_refund_no_0     = "string // 商户退款单号: 商户系统内部的退款单号",
        refund_id_0         = "string // 微信退款单号",
        refund_channel_0    = [[string? // 退款渠道:
            ORIGINAL        — 原路退款,
            BALANCE         — 退回到余额,
            OTHER_BALANCE   — 原账户异常退到其他余额账户,
            OTHER_BANKCARD  — 原银行卡异常退到其他银行卡,
        ]],
        refund_fee_0        = "number // 申请退款金额: 退款总金额,单位为分,可以做部分退款",
        refund_fee          = "number // 退款总金额: 各退款单的退款金额累加",
        coupon_refund_fee   = "number // 代金券退款总金额: 各退款单的代金券退款金额累加",
        settlement_refund_fee_0 = "number? // 退款金额: 退款金额=申请退款金额-非充值代金券退款金额，退款金额<=申请退款金额",
        coupon_type_0_0     = "string? // 代金券类型: CASH--充值代金券，NO_CASH---非充值优惠券。开通免充值券功能，并且订单使用了优惠券后有返回（取值：CASH、NO_CASH）。$n为下标,$m为下标,从0开始编号",
        coupon_refund_fee_0 = "number? // 总代金券退款金额: 代金券退款金额<=退款金额，退款金额-代金券或立减优惠退款金额为现金",
        coupon_refund_count_0   = "number? // 退款代金券使用数量: 退款代金券使用数量 ,$n为下标,从0开始编号",
        coupon_refund_id_0_0    = "string? // 退款代金券ID: 退款代金券ID, $n为下标，$m为下标，从0开始编号",
        coupon_refund_fee_0_0   = "number? // 单个代金券退款金额: 单个退款代金券支付金额, $n为下标，$m为下标，从0开始编号",
        refund_status_0     = [[string // 退款状态:
            SUCCESS     — 退款成功
            REFUNDCLOSE — 退款关闭，指商户发起退款失败的情况。
            PROCESSING  — 退款处理中
            CHANGE      — 退款异常，退款到银行发现用户的卡作废或者冻结了，导致原路退款银行卡失败。
            $n为下标，从0开始编号。
        ]],
        refund_account_0     = [[string? // 退款资金来源:
            REFUND_SOURCE_RECHARGE_FUNDS    --- 可用余额退款/基本账户，
            REFUND_SOURCE_UNSETTLED_FUNDS   --- 未结算资金退款，
            $n为下标，从0开始编号]],
        refund_recv_accout_0 = [[string // 退款入账账户:
            取当前退款单的退款入账方,
            1）退回银行卡：{银行名称}{卡类型}{卡尾号}
            2）退回支付用户零钱: 支付用户零钱
            3）退还商户: 商户基本账户, 商户结算银行账户
            4）退回支付用户零钱通: 支付用户零钱通
        ]],
        refund_success_time_0 = "string? // 退款成功时间: 退款成功时间，当退款状态为退款成功时有返回。$n为下标，从0开始编号",
        cash_refund_fee = "number // 用户退款金额: 退款给用户的金额，不包含所有优惠券金额",
    }
}
__.refund_query = function(t)

    local  wx_account, err = wxpay.ctx.get_pay_account()
    if not wx_account then return nil, err end

    t.transaction_id = utils.str.strip(t.transaction_id)
    t.out_trade_no   = utils.str.strip(t.out_trade_no)
    t.out_refund_no  = utils.str.strip(t.out_refund_no)
    t.refund_id      = utils.str.strip(t.refund_id)

    -- 优先级 refund_id > out_refund_no > transaction_id > out_trade_no
    if not t.transaction_id and not t.out_trade_no and
       not t.out_refund_no  and not t.refund_id then
        return nil, "微信订单号，或商户订单号，或商户退款单号，或微信退款单号，不能为空"
    end

    local body = {
        appid               = wx_account.pay_app_id,
        mch_id              = wx_account.pay_mch_id,
        sub_appid           = wx_account.sub_app_id,
        sub_mch_id          = wx_account.sub_mch_id,
        sign_type           = t.sign_type or "MD5",
        transaction_id      = t.transaction_id,
        out_trade_no        = t.out_trade_no,
        out_refund_no       = t.out_refund_no,
        refund_id           = t.refund_id,
    }

    local obj, err = wxpay.ctx.request {
        url     = "https://api.mch.weixin.qq.com/pay/refundquery",
        body    = body
    }
    if not obj then return nil, err end

    return obj
end

__.micropay__ = {
    "付款码支付",
 -- doc = "https://pay.weixin.qq.com/wiki/doc/api/micropay.php?chapter=9_10&index=1",
    doc = "https://pay.weixin.qq.com/wiki/doc/api/micropay_sl.php?chapter=9_10&index=1",
    req = {
     -- appid       = "  // 公众账号ID或小程序ID: String(32)小程序ID或公众号ID",
     -- mch_id      = "  // 商户号: String(32)微信支付分配的商户号",
        device_info = "? // 端设备号：String(32)自定义参数，可以为终端设备号(门店号或收银设备ID)，PC网页或公众号内支付可以传'WEB'",
     -- nonce_str   = "  // 随机字符串：String(32)长度要求在32位以内。",
     -- sign        = "  // 签名: String(64)通过签名算法计算得出的签名值",
        sign_type   = "? // 签名类型: String(32)签名类型，默认为MD5，支持HMAC-SHA256和MD5。",
        body        = "  // 商品描述: String(127)商品简单描述",
        detail      = "? // 商品详情: String(6000)商品详细描述，对于使用单品优惠的商户，该字段必须按照规范上传",
        attach      = "any? // 附加数据: String(127)附加数据，在查询API和支付通知中原样返回，可作为自定义参数使用",
        out_trade_no = " // 商户订单号: String(32)商户系统内部订单号，要求32个字符内，只能是数字、大小写字母_-|*且在同一个商户号下唯一",
        total_fee   = "number // 订单金额: int订单总金额，单位为元 (特殊地，内部转换单位为分)",
        fee_type    = "? // 标价币种: String(16)符合ISO 4217标准的三位字母代码，默认人民币：CNY",
     -- spbill_create_ip = " // 终端IP: String(64)支持IPV4和IPV6两种格式的IP地址。调用微信支付API的机器IP",
        goods_tag   = "? // 订单优惠标记: String(32)订单优惠标记，使用代金券或立减优惠功能时需要的参数",
        limit_pay   = "? // 指定支付方式: String(32)上传此参数no_credit--可限制用户不能使用信用卡支付",
        time_start  = "? // 交易起始时间: String(14)订单生成时间，格式为yyyyMMddHHmmss",
        time_expire = "? // 交易结束时间: String(14)订单失效时间，格式为yyyyMMddHHmmss",
        receipt     = "? // 电子发票入口开放标识: String(8)Y，传入Y时，支付成功消息和支付详情页将出现开票入口。需要在微信支付商户平台或微信公众平台开通电子发票功能，传此字段才可生效",
        auth_code   = [[ // 付款码: String(128)扫码支付付款码，设备读取用户微信中的条码或者二维码信息
        （用户付款码规则：18位纯数字，前缀以10、11、12、13、14、15开头）]],
        scene_info  = "? // 场景信息: String(256)该字段常用于线下活动时的场景信息上报，支持上报实际门店信息，商户也可以按需求自己上报相关信息。该字段为JSON对象数据",
        profit_sharing = "? // 是否需要分账: String(16)Y-是，需要分账,N-否，不分账, 字母要求大写，不传默认不分账",
    },
    res = {
        "@SysCode", "@BiCode",
        -- 以下字段在return_code 和result_code都为SUCCESS的时候有返回
        openid              = "// 用户标识: 用户在商户appid 下的唯一标识",
        is_subscribe        = "// 是否关注公众账号: 用户是否关注公众账号，仅在公众账号类型支付有效，取值范围：Y或N;Y-关注;N-未关注",
        trade_type          = "// 交易类型: MICROPAY 付款码支付",
        bank_type           = "// 付款银行: 银行类型，采用字符串类型的银行标识",
        fee_type            = "?// 货币类型: 符合ISO 4217标准的三位字母代码，默认人民币：CNY",
        total_fee           = "number // 订单金额: 订单总金额，单位为分，只能为整数",
        settlement_total_fee = "number? // 应结订单金额: 当订单使用了免充值型优惠券后返回该参数，应结订单金额=订单金额-免充值优惠券金额。",
        coupon_fee          = "number? // 代金券金额: “代金券”金额<=订单金额，订单金额-“代金券”金额=现金支付金额",
        cash_fee_type       = "?//现金支付货币类型: 符合ISO 4217标准的三位字母代码，默认人民币：CNY",
        cash_fee            = "number// 现金支付金额: 订单现金支付金额",
        transaction_id      = "//微信支付订单号: 微信支付订单号",
        out_trade_no        = "//商户订单号: 商户系统内部订单号，要求32个字符内（最少6个字符），只能是数字、大小写字母_-|*且在同一个商户号下唯一",
        attach              = "?//商家数据包: 商家数据包，原样返回",
        time_end            = "//支付完成时间: 订单生成时间，格式为yyyyMMddHHmmss",
        promotion_detail    = "?//营销详情: 新增返回，单品优惠功能字段",
    }
}
__.micropay = function(t)

    local  wx_account, err = wxpay.ctx.get_pay_account()
    if not wx_account then return nil, err end

    t.total_fee = tonumber(t.total_fee)
    if not t.total_fee or t.total_fee<=0 then return nil, "支付金额必须大于0" end

    if type(t.attach) == "table" then t.attach = _encode(t.attach) end

    local body = {
        appid           = wx_account.pay_app_id,
        mch_id          = wx_account.pay_mch_id,
        sub_appid       = wx_account.sub_app_id,
        sub_mch_id      = wx_account.sub_mch_id,
        device_info     = t.device_info,
        sign_type       = t.sign_type or "MD5",
        body            = t.body,
        detail          = t.detail,
        attach          = t.attach,
        out_trade_no    = t.out_trade_no,
        total_fee       = t.total_fee * 100, -- 金额（单位：分）,
        fee_type        = t.fee_type or "CNY", -- 默认人民币,
        spbill_create_ip= t.spbill_create_ip or ngx.var.remote_addr,
        goods_tag       = t.goods_tag,
        limit_pay       = t.limit_pay,
        time_start      = t.time_start,
        time_expire     = t.time_expire,
        receipt         = t.receipt,
        auth_code       = t.auth_code,
        scene_info      = t.scene_info,
        profit_sharing  = t.profit_sharing,
    }

    return wxpay.ctx.request {
        url     = "https://api.mch.weixin.qq.com/pay/micropay",
        body    = body
    }
end

__.reverse__ = {
    "撤销订单(付款码支付)",
 -- doc = "https://pay.weixin.qq.com/wiki/doc/api/micropay.php?chapter=9_11&index=3",
    doc = "https://pay.weixin.qq.com/wiki/doc/api/micropay_sl.php?chapter=9_11&index=3",
    req = {
     -- appid           = "string // 公众账号ID或小程序ID: String(32)小程序ID或公众号ID",
     -- mch_id          = "string // 商户号: String(32)微信支付分配的商户号",
        transaction_id  = "string?// 微信订单号: String(32)微信的订单号，优先使用",
        out_trade_no    = "string // 商户订单号: String(32)商户系统内部订单号，要求32个字符内，只能是数字、大小写字母_-|*且在同一个商户号下唯一",
     -- nonce_str       = "string // 随机字符串：String(32)长度要求在32位以内。",
     -- sign            = "string // 签名: String(64)通过签名算法计算得出的签名值",
        sign_type       = "string?// 签名类型: String(32)签名类型，默认为MD5，支持HMAC-SHA256和MD5。",
    },
    res = { "@SysCode", "@BiCode",
        recall = "string //是否重调: 是否需要继续调用撤销，Y-需要，N-不需要"
    }
}
__.reverse = function(t)

    local  wx_account, err = wxpay.ctx.get_pay_account()
    if not wx_account then return nil, err end

    -- 重要！！请求需要双向证书
--  local url = "https://api.mch.weixin.qq.com/secapi/pay/reverse"
    local url = "http://127.0.0.1/proxy/" --【使用反向代理（带证书）】
              .. wx_account.pay_mch_id .. "/secapi/pay/reverse"

    local body = {
        appid           = wx_account.pay_app_id,
        mch_id          = wx_account.pay_mch_id,
        sub_appid       = wx_account.sub_app_id,
        sub_mch_id      = wx_account.sub_mch_id,
        transaction_id  = t.transaction_id,
        out_trade_no    = t.out_trade_no,
        sign_type       = t.sign_type or "MD5",
    }

    local obj, err = wxpay.ctx.request {
        url     = url,
        body    = body
    }
    if not obj then return nil, err end

    return obj
end

return __
