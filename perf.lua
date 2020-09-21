local NAME = ...
local lbigint = require(NAME)

-- /////////////////////////////////////////////////////////////////////////////
-- compatible
local mt = getmetatable(lbigint) or lbigint
if not mt.__call then
    mt.__call = mt.new
end

if not mt.set_const then
    mt.set_const = function() end
end
setmetatable(lbigint, mt)
-- /////////////////////////////////////////////////////////////////////////////
local MUL_BIT = 1000
local BASE_BIT = 10000
local TEST_TIMES = 10000

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
    "%s perf done, TIMES = %d, BASE BIT = %d, MUL BIT = %d",
    NAME, TEST_TIMES, BASE_BIT, MUL_BIT))