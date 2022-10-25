local str_byte   = string.byte
local core_str   = require("lifesix.core.string")
local rfind_char = core_str.rfind_char
local sub_str        = string.sub
local str_byte       = string.byte

local _M = {
    version = 0.1,
}

local function _parse_ipv4_or_host(addr)
    local pos = rfind_char(addr, ":", #addr - 1)
    if not pos then
        return addr, nil
    end

    local host = sub_str(addr, 1, pos - 1)
    local port = sub_str(addr, pos + 1)
    return host, tonumber(port)
end


local function _parse_ipv6_without_port(addr)
    return addr
end


-- parse_addr parses 'addr' into the host and the port parts. If the 'addr'
-- doesn't have a port, nil is used to return.
-- For IPv6 literal host with brackets, like [::1], the square brackets will be kept.
-- For malformed 'addr', the returned value can be anything. This method doesn't validate
-- if the input is valid.
function _M.parse_addr(addr)
    if str_byte(addr, 1) == str_byte("[") then
        -- IPv6 format, with brackets, maybe with port
        local right_bracket = str_byte("]")
        local len = #addr
        if str_byte(addr, len) == right_bracket then
            -- addr in [ip:v6] format
            return addr, nil
        else
            local pos = rfind_char(addr, ":", #addr - 1)
            if not pos or str_byte(addr, pos - 1) ~= right_bracket then
                -- malformed addr
                return addr, nil
            end

            -- addr in [ip:v6]:port format
            local host = sub_str(addr, 1, pos - 1)
            local port = sub_str(addr, pos + 1)
            return host, tonumber(port)
        end

    else
        -- When we reach here, the input can be:
        -- 1. IPv4
        -- 2. IPv4, with port
        -- 3. IPv6, like "2001:db8::68" or "::ffff:192.0.2.1"
        -- 4. Malformed input
        -- 5. Host, like "test.com" or "localhost"
        -- 6. Host with port
        local colon = str_byte(":")
        local colon_counter = 0
        local dot = str_byte(".")
        for i = 1, #addr do
            local ch = str_byte(addr, i, i)
            if ch == dot then
                return _parse_ipv4_or_host(addr)
            elseif ch == colon then
                colon_counter = colon_counter + 1
                if colon_counter == 2 then
                    return _parse_ipv6_without_port(addr)
                end
            end
        end

        return _parse_ipv4_or_host(addr)
    end
end


return _M
