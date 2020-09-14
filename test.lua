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

local a = lbigint(1000)

test_set(10000001)
test_set(10000002)
test_set("0xFF", "255")
test_set("-10000001")

-- error test
test_set("ll", nil, "Unexpected character encountered in input.")
test_set(false, nil, "can not convert boolean to big integer")
