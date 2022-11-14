
return {
--------------------------------------------------------------

    table_name  = "dd_cate"
,   table_desc  = "类别表"
,   table_index = {

}

,   field_list = {

        { "cate_id"         , "类别编码"    , pk = true     },
        { "cate_name"       , "类别名称"                    },
        { "cate_desc"       , "类别描述"                    },
        { "list_index"      , "类别排序"    , "int"         },
        { "stop_flag"       , "停用标识"    , "int"         },
        { "create_time"     , "创建时间"    , "datetime"    },
        { "update_time"     , "更新时间"    , "datetime"    },
    }

--------------------------------------------------------------
}

