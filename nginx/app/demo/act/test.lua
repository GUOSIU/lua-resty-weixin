
local api = _load "api"

local __ = {}
__.ver   = "22.11.10"
__.name  = "api测试"
------------------------------------------------------

__.actx = function()

    ngx.header["content-type"] = "text/plain"

    api.dd.cate.add { cate_id = "1101", cate_name = "热菜" }
    api.dd.cate.add { cate_id = "1102", cate_name = "凉菜" }

    local cates, err = api.dd.cate.list()
    if not cates then return ngx.say(err) end

    for i, c in ipairs(cates) do
        ngx.say(i, ") ", c.cate_id, " - ", c.cate_name)
    end

end

------------------------------------------------------
return __ -- 返回模块
