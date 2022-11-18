-- @@ api : openresty-vsce

local pay = {}

require "app.comm.apix".new(pay)

return pay
