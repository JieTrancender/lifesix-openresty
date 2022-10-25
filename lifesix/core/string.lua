local str_byte = string.byte


local _M = {
    version = 0.1,
}


function _M.rfind_char(s, ch, idx)
    local b = str_byte(ch)
    for i = idx or #s, 1, -1 do
        if str_byte(s, i, i) == b then
            return i
        end
    end
    return nil
end


return _M
