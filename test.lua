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

------- ///////////////////////// pow //////////////////////////////////////////
EQ(tostring(lbigint()^2), "0")
EQ(tostring(lbigint(100)^10), string.format("%.0f", math.floor(100^10)))

------- //////////////////// arithmetic + - * //////////////////////////////////
local function test_arithmetic(sym, v1, v2, expect, p)
    local c
    if "+" == sym then
        c = v1 + v2
    elseif "-" == sym then
        c = v1 - v2
    elseif "*" == sym then
        c = v1 * v2
    elseif "/" == sym then
        c = v1 / v2
    else
        assert(false)
    end
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

--------------------------------- add ------------------------------------------
local function test_add(v1, v2, expect, p)
    return test_arithmetic("+", v1, v2, expect, p)
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

--------------------------------- sub ------------------------------------------
local function test_sub(v1, v2, expect, p)
    return test_arithmetic("-", v1, v2, expect, p)
end

-- test bigint - string
-- test int - bigint
test_sub(lbigint(0xFFFF), "0xFFFF", 0xFFFF - 0xFFFF, 1)
test_sub(0xFFFF, lbigint(0xFFFF), 0xFFFF - 0xFFFF, 2)

-- test bigint - bigint
test_sub(lbigint("0xFFFFFFFFFFFFFFFFFFFFFFFFFFF"), "0xFFFF",
    "324518553658426726783156020510720", 1)

-- test self sub
local sub0 = lbigint("0xFFFFFFFFFFFFFFFF")
test_sub(sub0, sub0, 0, 1)

-- test const
local sub1 = lbigint(100000099)
sub1:set_const(true)

test_sub(sub1, lbigint(10000000), 100000099 - 10000000)

--------------------------------- mul ------------------------------------------
local function test_mul(v1, v2, expect, p)
    return test_arithmetic("*", v1, v2, expect, p)
end

-- test bigint * string
-- test int * bigint
test_mul(lbigint(0xFFFF), "0xFFFF", 0xFFFF * 0xFFFF, 1)
test_mul(0xFFFF, lbigint(0xFFFF), 0xFFFF * 0xFFFF, 2)

-- test bigint * bigint
test_mul(lbigint("0xFFFFFFFFFFFFFFFFFFFFFFFFFFF"), "0xFFFF",
    "21267323414004995539734129808464871425", 1)

-- test self sub
local mul0 = lbigint("0xFFFFFFFFFFFFFFFF")
test_mul(mul0, mul0, "340282366920938463426481119284349108225", 1)

-- test const
local mul1 = lbigint(100000099)
mul1:set_const(true)

test_mul(mul1, lbigint(10000000), 100000099 * 10000000)

--------------------------------- mul ------------------------------------------
local function test_div(v1, v2, expect, p)
    test_arithmetic("/", v1, v2, expect, p)
end

-- test bigint / string
-- test int / bigint
test_div(lbigint(0xFFFF), "0xFFFF", 1, 1)
test_div(0xFFFF, lbigint(-0xFFFF), -1, 2)

-- test bigint / bigint
test_div(lbigint("0xFFFFFFFFFFFFFFFFFFFFFFFFFFF"), "0xFFFF",
    "4951835716158186110981246976", 1)

-- test self div
local div0 = lbigint("0xFFFFFFFFFFFFFFFF")
test_div(div0, div0, 1, 1)

-- test const
local div1 = lbigint(100000099)
div1:set_const(true)

test_div(div1, lbigint(10000000), math.floor(100000099 / 10000000))

test_div(lbigint(), 1, 0, 1)

-- Integer Division by zero.
xpcall(function() local d = lbigint(1) / 0 end, function(emsg)
    -- this is a anonymous function call
    -- test.lua:32: Unexpected character encountered in input.
    -- remove then file line
    emsg = string.sub(emsg, string.len(emsg) - string.len(msg) + 1, -1)
    EQ(emsg, "Integer Division by zero.")
end)

--------------------------- arithmetic + - * -----------------------------------
local arithmetic_0 = lbigint(100000)
local arithmetic_1 = lbigint(10)
local a = 1 + arithmetic_0 / 10 * arithmetic_1 - 99 + "200"
EQ(tostring(a), tostring(math.floor(1 + 100000 / 10 * 10 - 99 + 200)))
EQ(a:to_pointer(), arithmetic_0:to_pointer())
EQ(tostring(arithmetic_1), "10")

------- //////////////////// performance ///////////////////////////////////////
local MUL_BIT = 1000
local BASE_BIT = 10000
local TEST_TIMES = 10000

local NAME = "lua_bigint"
math.randomseed(os.time())

local base = {9}
for i = 1, BASE_BIT do table.insert(base, math.random(0, 9)) end

local mul = {1}
for i = 1, MUL_BIT do table.insert(mul, math.random(0, 9)) end

local str_base = table.concat(base)
local str_mul  = table.concat(mul)

local b = lbigint(str_base)
local m = lbigint(str_mul)
b:set_const(true)
m:set_const(true)

-- create
local beg = os.clock()
for i = 1, TEST_TIMES do lbigint(str_base) end
print(NAME, "create", "time elapsed", os.clock() - beg)

-- add
local sum = 0
local beg = os.clock()
for i = 1, TEST_TIMES do sum = sum + b end
print(NAME, "add", "time elapsed", os.clock() - beg)

-- dec
local beg = os.clock()
for i = 1, TEST_TIMES do sum = sum - b end
print(NAME, "dec", "time elapsed", os.clock() - beg)

-- mul
local beg = os.clock()
for i = 1, TEST_TIMES do
    local l = lbigint(b)
    l = l * m
end
print(NAME, "mul", "time elapsed", os.clock() - beg)

-- div
local beg = os.clock()
for i = 1, TEST_TIMES do
    local d = lbigint(b)
    d = d / m
end
print(NAME, "div", "time elapsed", os.clock() - beg)

-- tostring
local beg = os.clock()
for i = 1, TEST_TIMES do tostring(b) end
print(NAME, "tostring", "time elapsed", os.clock() - beg)

print(string.format(
    "perf done, TIMES = %d, BASE BIT = %d, MUL BIT = %d",
    TEST_TIMES, BASE_BIT, MUL_BIT))
--//////////////////////////////////////////////////////////////////////////////

print("ALL TEST PASS")
