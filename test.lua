local lbigint = require "lua_bigint"

local function EQ(got, expect)
    if expect == got then return end

    print("got:", got)
    print("expect：", expect)

    print(debug.traceback())
    os.exit(1)
end

local function NEQ(got, expect)
    if expect ~= got then return end

    print("got:", got)
    print("expect：", expect)

    print(debug.traceback())
    os.exit(1)
end

------- /////////////////////////// construct ////////////////////////////////
local function test_construct(val, expect, msg)
    if not msg then
        local i = lbigint(val)
        EQ(tostring(i), expect or tostring(val))
        return
    end

    -- test error
    xpcall(function() lbigint(val) end, function(emsg)
        -- this is a anonymous function call
        -- test.lua:32: Unexpected character encountered in input.
        -- remove then file line
        emsg = string.sub(emsg, string.len(emsg) - string.len(msg) + 1, -1)
        EQ(emsg, msg)
    end, i, val)
end

test_construct(nil, "0")
test_construct(0)
test_construct(-0, "0")

test_construct(10000001)
test_construct("10000000000000000000000000000000000000000000000000000000000002")
test_construct("0xFF", "255")
test_construct("-10000001")

test_construct("ll", nil, "Unexpected character encountered in input.")

------- /////////////////////////// assign /////////////////////////////////////
local function test_assign(val, expect, msg)
    local i = lbigint()

    if not msg then
        i:assign(val)
        EQ(tostring(i), expect or tostring(val))
        return
    end

    -- test error assign
    xpcall(i.assign, function(emsg)
        EQ(emsg, msg)
    end, i, val)
end

test_assign(10000001)
test_assign("10000000000000000000000000000000000000000000000000000000000000002")
test_assign("0xFF", "255")
test_assign("-10000001")
test_assign(lbigint("100000000000009"))

-- test self assign
local a0 = lbigint("100000000000000000000000009")
a0:assign(a0)
EQ(tostring(a0), "100000000000000000000000009")

-- error test
test_assign("ll", nil, "Unexpected character encountered in input.")
test_assign(false, nil, "can not convert boolean to big integer")

a0:set_const(true)
xpcall(a0.assign, function(emsg)
    EQ(emsg, "attemp to modify a const big integer")
end, a0, 100)

------- /////////////////////////// equal //////////////////////////////////////
EQ(lbigint(), lbigint())
EQ(lbigint("10000000000000000000005"), lbigint("10000000000000000000005"))

EQ(lbigint():equal(0), true)
EQ(lbigint():equal(1000), false)
EQ(lbigint(1):equal(1), true)
EQ(lbigint(0xFFFFFFFFFFFFFFFF):equal(0xFFFFFFFFFFFFFFFF), true)
EQ(lbigint("10000000000000000000005"):equal("10000000000000000000005"), true)
EQ(lbigint("10000000000000000005"):equal(lbigint("10000000000000000005")), true)

-- test equal with diffrent type, meta method __eq never get called, the result
-- is always false
NEQ(lbigint(1), 1)
NEQ(lbigint(1), "1")
NEQ(lbigint(1), {})

------- /////////////////////////// sign ///////////////////////////////////////
EQ(lbigint():sign(), 0)
EQ(lbigint(0):sign(), 0)
EQ(lbigint(-1):sign(), -1)
EQ(lbigint("-0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF"):sign(), -1)
EQ(lbigint("0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF"):sign(), 1)

------- ///////////////////////// unary minus //////////////////////////////////
EQ(tostring(-lbigint()), "0")
EQ(tostring(-lbigint(1)), "-1")
EQ(tostring(-lbigint("999999999999999999999999")), "-999999999999999999999999")
EQ(tostring(-lbigint("-999999999999999999999999")), "999999999999999999999999")

------- ///////////////////////// compare //////////////////////////////////////
assert(lbigint() > -1)
assert(1 < lbigint(2))
assert(lbigint(100000000001) > "100000000000")
assert("100000000000" < lbigint(100000000001))
assert(lbigint(100000000001) > lbigint(100000000000))

------- /////////////////////////// add ////////////////////////////////////////
local function test_add(v1, v2, expect, p)
    local c = v1 + v2
    EQ(tostring(c), tostring(expect))

    -- check pointer
    if 1 == p then
        EQ(c:to_pointer(), v1:to_pointer())
    elseif 2 == p then
        EQ(c:to_pointer(), v2:to_pointer())
    else
        NEQ(c:to_pointer(), v1:to_pointer())
        NEQ(c:to_pointer(), v2:to_pointer())
    end
end

-- test bigint + string
-- test int  + bigint
test_add(lbigint(0xFFFF), "0xFFFF", 0xFFFF + 0xFFFF, 1)
test_add(0xFFFF, lbigint(0xFFFF), 0xFFFF + 0xFFFF, 2)

-- test bigint + bigint
test_add(lbigint("0xFFFFFFFFFFFFFFFFFFFFFFFFFFF"), "0xFFFF",
    "324518553658426726783156020641790", 1)

-- test self add
local add0 = lbigint("0xFFFFFFFFFFFFFFFF")
test_add(add0, add0, "36893488147419103230", 1)

-- test const
local add1 = lbigint(100000099)
add1:set_const(true)

test_add(add1, lbigint(10000000), 100000099 + 10000000)
