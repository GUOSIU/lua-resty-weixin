
local _decode       = require "cjson.safe".decode
local _encode       = require "cjson.safe".encode
local _args         = ngx.encode_args

local utils         = require "resty.utils"
local WX_ERROR_CODE = require "resty.weixin.error_code" -- 微信错误编码

local USE_PROXY     = {} -- 使用代理服务器

local __ = { _VERSION = "22.11.01" }

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

__.send__ = {
    "http请求",
    req = {
        { "url"     , "请求路径"                    },

        { "appid"   , "第三方用户唯一凭证"          },
        { "secret?" , "第三方用户唯一凭证密钥"      },
        { "token?"  , "是否需要token"   , "boolean" },

        { "args?"   , "请求args"        , "object"  },
        { "body?"   , "请求body"        , "string"  },
        { "xml?"    , "返回xml字符串"   , "boolean" },
        { "bin?"    , "返回二进制数据"  , "boolean" },
        { "reload?" , "重新获取token"   , "boolean" },
    },
    res = "object"
}
__.send = function(t)

    t.secret = utils.strip(t.secret)

    -- 获取 access_token
    if t.token then
        if not t.secret then return nil, "secret不能为空" end
        local  token, err = __.get_access_token(t)
        if not token then return nil, err end
        t.args = t.args or {}
        t.args.access_token = token
    end

    local app_url = "[" .. t.appid .. "]" .. t.url

    -- 是否使用代理服务器
    if USE_PROXY[app_url] then
        t.url = utils.str.gsub(t.url,
               "https://api.weixin.qq.com/",
               "http://ngx.weimember.cn/weixin_api/")
    end

    local body, boundary = get_img_body(t)
    if not body and type(t.body) == "table" then t.body = _encode(t.body) end

    local res, err = utils.net.request(t.url, {
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

    -- IP地址不在白名单中：使用代理模式
    if code == 40164 and not USE_PROXY[app_url] then
     -- ngx.log(ngx.ERR, "use proxy: ", app_url)
        USE_PROXY[app_url] = true
        return __.send(t)
    end

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

__.get_access_token__ = {
    "获取Access token",
    doc = "https://developers.weixin.qq.com/doc/offiaccount/Basic_Information/Get_access_token.html",
    req = {
        { "appid"   , "第三方用户唯一凭证"              },
        { "secret"  , "第三方用户唯一凭证密钥"          },
        { "reload?" , "是否重新获取token"   , "boolean" },
    },
    res = "string"
}
__.get_access_token = function(t)

    local key = t.appid .. "/token"

    if t.reload then utils.cache.del(key) end

    return utils.cache.load ( key, function()

        local res, err = __.send {
                url     = "https://api.weixin.qq.com/cgi-bin/token"
            ,   appid   = t.appid
            ,   args    = {
                    grant_type  = "client_credential"
                ,   appid       = t.appid
                ,   secret      = t.secret }
        }
        if not res then return nil, err end

        return res.access_token

    end, 3600 ) -- 缓存1小时

end

return __
