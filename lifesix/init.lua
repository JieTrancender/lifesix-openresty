local redis = require "resty.redis"

local _M = {version = 0.1}


local function is_empty(s)
    return s == nil or s == '' or s == 'null' or s == 'NULL' or s == ngx.null
  end


function _M.dynamic_redirect()
    local nodeName = ngx.var.arg_nodeName
    local threadId = ngx.var.arg_threadId
    local platform = ngx.var.arg_platform

    if not nodeName or not threadId or not platform then
        ngx.log(ngx.ERR, "arguments are wrong, nodeName or threadId or platform is not exist")
        return ngx.exit(500)
    end
    
    local ngx_ctx = ngx.ctx
    local redis_cli = redis:new()
    redis_cli:set_timeouts(1000, 1000, 1000)

    local ok, err = redis_cli:connect("127.0.0.1", 6379)
    if not ok then
        ngx.log(ngx.ERR, "failed to connect redis, err: ", err)
        return ngx.exit(500)
    end

    -- ignore this if not auth
    -- local res, err = redis_cli:auth("123456")
    -- if not res then
    --     ngx.log(ngx.ERR, "failed to auth redis, err: ", err)
    --     return ngx.exit(500)
    -- end
    
    local backend_node, a, b, c = redis_cli:hget(table.concat({"game-server", platform, "node", nodeName}, "_"), threadId)
    if is_empty(backend_node) then
        ngx.log(ngx.ERR, "failed to get node info, key is ", table.concat({"game-server", platform, "node", nodeName}, "_"))
        return ngx.exit(500)
    end

    ngx.var.backend_node = backend_node
end


return _M
