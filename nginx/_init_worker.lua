
local pok, err = pcall(require, "app.comm._init_worker")
if not pok then
    ngx.log(ngx.ERR, err)
    return
end
