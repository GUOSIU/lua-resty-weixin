
local _hex      = require "resty.string".to_hex
local _random   = require "resty.random".bytes
local _concat   = table.concat
local _md5      = ngx.md5
local _sha1     = ngx.sha1_bin
local _upper    = string.upper

local utils         = require "app.utils"
local _request      = utils.request
local _args         = ngx.encode_args

local _T = {}
local __ = { types = _T }

__.set__ = {
    req = {
        { "appid"   , "公众账号ID或小程序ID"    },
        { "mchid"   , "商户编码"                },
        { "mchkey"  , "商户秘钥"                },
    }
}
__.set = function(t)

    local ctx = ngx.ctx[__]
    if not ctx then
        ctx = {}
        ngx.ctx[__] = ctx
    end

    ctx.appid   = t.appid
    ctx.mchid   = t.mchid
    ctx.mchkey  = t.mchkey

end

local function get_ctx_val(key)
    local  ctx = ngx.ctx[__]
    return ctx and ctx[key] or nil
end

-- 公众账号ID或小程序ID
__.get_appid = function()
    return get_ctx_val("appid")
end

-- 商户编码
__.get_mchid = function()
    return get_ctx_val("mchid")
end

-- 商户秘钥
__.get_mchkey = function()
    return get_ctx_val("mchkey")
end

-- 生成随机码
__.gen_nonce = function(length)

    length = tonumber(length) or 32 -- 默认32位
    length = length / 2

    return _hex( _random(length) )
end

-- 生成签名
__.gen_sign = function(t, use_sha1, is_upper)
-- @t        : table   // 待签名的内容
-- @use_sha1 : boolean // 是否使用sha1签名
-- @is_upper : boolean // 是否大写
-- @return   : string

    local key = __.get_mchkey()

    -- 清除空字符串
    for k, v in pairs(t) do
        if v == "" then t[k] = nil end
    end

    local s, i = {}, 0
        for k, v in pairs(t) do
            if k ~= "sign" then
                i=i+1; s[i] = k .. "=" .. v
            end
        end
        table.sort(s) -- 按key排序
        if key then
            i=i+1; s[i] = "key=" .. key
        end
    local sign = _concat(s, "&")

    -- use_sha1是否使用sha1加密，jsApi调用 v17.10.26
    sign = use_sha1 and _hex(_sha1(sign)) or _md5(sign)

    -- 沙箱环境使用大写，正式环境使用小写
    if is_upper then sign = _upper(sign) end

    return sign

end

__.request__ = {
    "http请求",
    req = {
        { "url"         , "请求路径"                },
        { "args?"       , "请求args"    , "object"  },
        { "body?"       , "请求body"    , "object"  },
    },
    res = "object"
}
__.request = function(t)

    local body = t.body

    -- 转成xml格式， 微信 2.0 接口使用xml
    if type(body) == "table" then

        -- 随机字符串
        if not body.nonce_str then body.nonce_str = __.gen_nonce(32) end

        -- 签名
        if not body.sign then body.sign = __.gen_sign(body) end

        body = utils.xml.to_xml(body)
    end

    local res, err = _request (t.url, {
            ssl_verify  = false -- 不校验证书
        ,   method      = body and "POST" or "GET"
        ,   body        = body
        ,   query       = t.args and _args(t.args)
        ,   headers     = {
            ["Content-Type"] = "application/x-www-form-urlencoded; charset=utf-8"
        }
    })
    if err then return nil, err end

    if res.status ~= ngx.HTTP_OK then
        return nil, '连接微信服务器失败：' .. res.status
    end

    local  obj = utils.xml.from_xml(res.body)
    if not obj then return nil, "XML解码失败" end

    if obj.return_code ~= "SUCCESS" then return nil, obj.return_msg   end
    if obj.result_code ~= "SUCCESS" then return nil, obj.err_code_des end

    return obj -- 返回对象
end

return __
