local lbigint = require "lua_bigint"

local function EQ(got, expect)
    if expect == got then return end

    print("got:", got)
    print("expect：", expect)

    assert(false)
end

local function test_construct(val, expect, msg)
    if not msg then
        local i = lbigint(val)
        EQ(tostring(i), expect or tostring(val))
        return
    end

    -- test error
    xpcall(function() lbigint(val) end, function(emsg)
        asert(emsg == msg, emsg)
    end, i, val)
end

local function test_assign(val, expect, msg)
    local i = lbigint()

    if not msg then
        i:assign(val)
        EQ(tostring(i), expect or tostring(val))
        return
    end

    -- test error assign
    xpcall(i.assign, function(emsg)
        asert(emsg == msg, emsg)
    end, i, val)
end

------- /////////////////////////// construct ////////////////////////////////

test_construct(nil, "0")
test_construct(0)
test_construct(-0, "0")

test_construct(10000001)
test_construct("10000000000000000000000000000000000000000000000000000000000002")
test_construct("0xFF", "255")
test_construct("-10000001")

test_assign("ll", nil, "Unexpected character encountered in input.")

------- /////////////////////////// assign      ////////////////////////////////

test_assign(10000001)
test_assign("10000000000000000000000000000000000000000000000000000000000000002")
test_assign("0xFF", "255")
test_assign("-10000001")

local b = lbigint("100000000000009")
test_assign(b)

-- error test
test_assign("ll", nil, "Unexpected character encountered in input.")
test_assign(false, nil, "can not convert boolean to big integer")

local c = lbigint(100000099)
c:set_const(true)

local b = lbigint()
local c = b + 100000
print(b, c, b == c, b:to_pointer(), c:to_pointer())