
local pok, sslx = pcall(require, "app.comm.sslx")
if not pok then
    ngx.log(ngx.ERR, sslx)
    return
end

-- 动态加载证书和秘钥以及OCSP
local pok, err = pcall(sslx.cert.set_cert)
if not pok then
    ngx.log(ngx.ERR, err)
    return
end
