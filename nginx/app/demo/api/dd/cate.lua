
local dd_cate           = _load "$dd_cate"
local utils             = _load "%utils"
local _quote            = ngx.quote_sql_str

local __ = { ver = "v22.04.28" }

-- 重名检查
local function check_name(t, is_add)
-- @t : $dd_cate

    t.cate_id    = utils.strip(t.cate_id)
    t.cate_name  = utils.strip(t.cate_name)

    if not t.cate_id   then return nil, "类别编码不能为空" end
    if not t.cate_name then return nil, "类别名称不能为空" end

    if is_add then
       local res, err = dd_cate.get { cate_id = t.cate_id }
       if err then return nil, "服务器忙，请稍候再试"   end
       if res then return nil, "类别编码不能重复"       end
    end

    local res, err = dd_cate.get {
        cate_name = t.cate_name,
        "cate_id <> " .. _quote(t.cate_id)
    }
    if err then return nil, "服务器忙，请稍候再试"  end
    if res then return nil, "类别名称不能重复"      end

    return true

end

__.get__ = {
    "获取类别",
    req = {
        { "cate_id"   , "类别编码" },
    },
    res = "$dd_cate"
}
__.get = function(t)

    local  res, err = dd_cate.get { cate_id = t.cate_id }
    if not res then return nil, err and "服务器忙，请稍候再试" or "类别不存在" end

    return res

end

__.list__ = {
    "类别列表",
    res = "$dd_cate[]"
}
__.list = function()

    local  res = dd_cate.list { "1=1" }
    if not res then return nil, "服务器忙，请稍候再试" end

    return res

end

__.add__ = {
    "添加类别",
    log = true,
    req = {
        { "cate_id"         , "类别编码"                    },
        { "cate_name"       , "类别名称"                    },
        { "cate_desc?"      , "类别描述"                    },
        { "list_index?"     , "类别排序"    , "number"      },
        { "stop_flag?"      , "停用标识"    , "number"      },
    },
    res = "$dd_cate"
}
__.add = function(t)

    -- @t : $dd_cate

    t.cate_name = utils.strip_name(t.cate_name)

    -- 检查类别不能重名
    local  ok, err = check_name(t, true)
    if not ok then return nil, err end

    t.create_time = ngx.localtime()
    t.update_time = ngx.localtime()

    local  ok, err = dd_cate.add (t)
    if not ok then return nil, err end

    return __.get(t)

end

__.set__ = {
    "修改类别",
    log = true,
    req = {
        { "cate_id"         , "类别编码"                    },
        { "cate_name?"      , "类别名称"                    },
        { "cate_desc?"      , "类别描述"                    },
        { "list_index?"     , "类别排序"    , "number"      },
        { "stop_flag?"      , "停用标识"    , "number"      },
    },
    res = "$dd_cate"
}
__.set = function(t)

    -- @t : $dd_cate
    t.cate_name = utils.strip_name(t.cate_name)

    local  tOld, err = __.get(t)
    if not tOld then return nil, err end

    -- 生成待更新的数据
    -- @d : $dd_cate
    local  d, wh = utils.gen_update(t, tOld, "cate_id" )
    if not d then return tOld end

    -- 检查类别不能重名
    if d.cate_name then
        local  ok, err = check_name(t)
        if not ok then return nil, err end
    end

    t.update_time = ngx.localtime()

    local  ok, err = dd_cate.set(wh)
    if not ok then return nil, err end

    return __.get(t)

end

__.del__ = {
    "删除类别",
    log = true,
    req = {
        { "cate_id", "类别编码" },
    },
    res = "boolean"
}
__.del = function(t)

    local  ok, err = dd_cate.del { cate_id = t.cate_id }
    if not ok then return nil, err end

    return true

end

return __
