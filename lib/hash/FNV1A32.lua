---Computes a strings hash.<br>
---32 bit Fowler-Noll-Vo hash function.<br>
---See http://www.isthe.com/chongo/tech/comp/fnv/index.html#FNV-1a for details.<br>
---See https://md5calc.com/hash/fnv1a32/Test for cross checking.<br>
---`assert(FNV1A32("Test") == 0x2ffcbe05)`
---@param s string
---@return integer hash
local function FNV1A32(s)
    local octets = table.pack(s:byte(1, #s))
    local hash = 2166136261
    for _, octet in ipairs(octets) do
        hash = (hash ~ octet) * 16777619 & 0xffffffff
    end
    return hash
end

return FNV1A32