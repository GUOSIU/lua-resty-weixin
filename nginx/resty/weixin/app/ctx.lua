
local utils         = require "app.utils"
local _request      = utils.request
local cjson         = require "cjson.safe"
local _decode       = cjson.decode
local _encode       = cjson.encode
local _args         = ngx.encode_args
local WX_ERROR_CODE = require "resty.weixin.error_code" -- 微信错误编码

local _T = {}
local __ = { types = _T }

__.set__ = {
    req = {
        { "appid"  , "公众号或小程序ID"     },
        { "secret" , "公众号或小程序秘钥"   },
    }
}
__.set = function(t)

    local ctx = ngx.ctx[__]
    if not ctx then
        ctx = {}
        ngx.ctx[__] = ctx
    end

    ctx.appid   = t.appid
    ctx.secret  = t.secret

end

local function get_ctx_val(key)
    local  ctx = ngx.ctx[__]
    return ctx and ctx[key] or nil
end

-- 公众号或小程序ID
__.get_appid = function()
    return get_ctx_val("appid")
end

-- 公众号或小程序秘钥
__.get_secret = function()
    return get_ctx_val("secret")
end

local function get_img_body(t)

    local  data = t.image_content
    if not data then return end

    local image_type = t.image_type or "jpg"

    local filename = ngx.now()*1000 .. '.' .. image_type

    local boundary = "-----------------------------" .. ngx.now()*1000

    local body = "--" .. boundary .. "\r\n"
              .. 'Content-Disposition: form-data; name="media"; '
              .. 'filename="'.. filename ..'"' .. '\r\n'
              .. 'Content-Type: image/' .. image_type .. '\r\n' .. '\r\n'
              .. data .. '\r\n'
              .. "--" .. boundary .. "--"

    t.image_type    = nil
    t.image_content = nil

    return body, boundary
end

__.request__ = {
    "http请求",
    req = {
        { "url"     , "请求路径"                    },
        { "token?"  , "是否需要token"   , "boolean" },

        { "args?"   , "请求args"        , "object"  },
        { "body?"   , "请求body"        , "any"     },
        { "xml?"    , "返回xml字符串"   , "boolean" },
        { "bin?"    , "返回二进制数据"  , "boolean" },
        { "reload?" , "重新获取token"   , "boolean" },

        { "image_type?"     , "上传文件类型"   },
        { "image_content?"  , "上传文件内容"   },
    },
    res = "object"
}
__.request = function(t)

    -- 获取 access_token
    if t.token then
        local  token, err = __.get_access_token(t.reload)
        if not token then return nil, err end
        t.args = t.args or {}
        t.args.access_token = token
    end

    local  body, boundary = get_img_body(t)
    if not body and type(t.body) == "table" then t.body = _encode(t.body) end

    local res, err = _request(t.url, {
            ssl_verify  = false -- 不校验证书
        ,   method      = (body or t.body) and "POST" or "GET"
        ,   body        = (body or t.body)
        ,   query       = t.args and _args(t.args)
        ,   headers     = {
            ["Content-Type"] =  body
                and ("multipart/form-data; boundary="..boundary)
                or  "application/x-www-form-urlencoded; charset=utf-8"
        }
    })
    if err then return nil, err end

    if res.status ~= ngx.HTTP_OK then
        return nil, '连接微信服务器失败：' .. res.status
    end

    -- 返回字符串（XML）
    if t.xml then return res.body end

    local  obj = _decode(res.body)
    if not obj then
        if t.bin then
            return res.body -- 直接返回二进制数据
        else
            return nil, "JSON解码失败"
        end
    end

    -- 错误消息及编码
    local err  = obj.errmsg  or obj.errMsg
    local code = obj.errcode or obj.errCode
          code = tonumber(code) or 0

    if code ~= 0 then

        if  t.token and not t.reload and (
            code==40001 or code==40014 or
            code==42001 or code==42007 ) then

            t.reload = true -- 重新生成 access_token 并重发
            return __.send(t)

        else
            err = WX_ERROR_CODE[code] or err or "微信未知错误"
            err = err .. ' ( ' .. code .. ' )'
            return nil, err
        end
    end

    return obj -- 返回对象

end

-- 取得微信公众号token
-- https://developers.weixin.qq.com/doc/offiaccount/Basic_Information/Get_access_token.html
__.get_access_token = function(is_reload)
-- @is_reload : boolean // 是否重试
-- @return : string // 公众号token

    local appid  = __.get_appid()
    local secret = __.get_secret()

    if not appid  then return nil, "appid不能为空"    end
    if not secret then return nil, "secret不能为空"   end

    local key = appid .. "/token"

    if is_reload then utils.mlcache.del(key) end

    return utils.mlcache.load ( key, function()

        local res, err = __.request {
                url     = "https://api.weixin.qq.com/cgi-bin/token"
            ,   args    = {
                    grant_type  = "client_credential"
                ,   appid       = appid
                ,   secret      = secret }
        }
        if not res then return nil, err end

        return res.access_token

    end, 3600 ) -- 缓存1小时
end

return __
