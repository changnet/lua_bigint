local lbigint = require "lua_bigint"

local function test_set(val, expect, msg)
    local i = lbigint()

    if not msg then
        i:set(val)
        assert(tostring(i) == (expect or tostring(val)))
        return
    end

    -- test error set
    xpcall(i.set, function(emsg)
        asert(emsg == msg)
    end, i, val)
end

local a = lbigint()
assert(tostring(a) == "0")

test_set(10000001)
test_set("10000000000000000000000000000000000000000000000000000000000000000002")
test_set("0xFF", "255")
test_set("-10000001")

local b = lbigint("100000000000009")
test_set(b)

-- error test
test_set("ll", nil, "Unexpected character encountered in input.")
test_set(false, nil, "can not convert boolean to big integer")

local b = lbigint()
local c = b + 100000
print(b, c, b == c)