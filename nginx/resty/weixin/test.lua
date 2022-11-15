
local cjson_pretty  = require "resty.prettycjson"

local __ = {}

__.echo = function(...)

    ngx.header["language"] = "lua"

    for _, v in ipairs({...}) do
        if type(v) == "table" then
            ngx.say(cjson_pretty(v))
        else
            ngx.say(v)
        end
    end

    ngx.say ""

end

return __
