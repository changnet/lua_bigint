# lua_bigint
Arbitrary integer for lua, base on [boost multiprecision](https://www.boost.org/doc/libs/1_74_0/libs/multiprecision/doc/html/boost_multiprecision/intro.html)

## Compile

### Linux
1. install [lua 5.3+](http://www.lua.org/)
2. install [boost](https://www.boost.org/)
3. install GCC(>= C++11) 
4. make lua_bigint
```shell
git clone https://github.com/changnet/lua_bigint.git
cd lua_bigint
make
make test
```
then load `lua_bigint.so` from lua script or open it in C++
```cpp
#include <lbigintxx.h>

open_lua_bigint(L); // link against -llua_bigint
```
Enjoy!

### Other platform
Untested! But lua and boost are cross-platform, should not need too much adjustment.

### Using bundled boost
Boost is a large library. However, multiprecision is header-only, only some
header files needed. All needed files are already being copy into directory 
`boost` from `boost 1.74.0` by script `make_boost.sh`.

run `make bundled` instead of `make` if using bundled boost. This only test
under debian & gcc, other platform or complier may not work.

## Usage
```lua
local lbigint = require "lua_bigint"

local i0 = lbigint(10000000) -- construct from integer
local i1 = lbigint("-10000000") -- construct from string
local i2 = lbigint("0xFFFFFFFFFF") -- construct from hex string
local i3 = lbigint(i0) -- construct from other bigint

i0:assign(10000000) -- assign from integer
i1:assign("-10000000") -- assign from string
i2:assign("0xFFFFFFFFFF") -- assign from hex string
i3:assign(i0) -- assign from other bigint

tostring(i0) -- 10000000

-- get pointer address, typically this function is used only
-- for hashing and debug information
i0:to_pointer() -- 93943009449888

i0:set_const(true) -- set as const(immutable)

assert(lbigint(100) == lbigint(100)) -- test equal
-- test equal with diffrent type, meta method __eq never get called,
-- the result is always false, however, equal can be called manually
assert(lbigint(100) ~= 100)
assert(lbigint(100):equal(100))
assert(lbigint(100):equal("100"))
assert(lbigint(100):equal(lbigint(100)))

-- test sign
assert(lbigint(0):sign() == 0)
assert(lbigint(1):sign() == 1) -- >0 return 1
assert(lbigint(-1):sign() == -1) -- <0 return -1

-- compare
assert(lbigint() > -1)
assert(lbigint(100000000001) > "100000000000")
assert(lbigint(100000000001) > lbigint(100000000000))

-- unary minus
assert(-lbigint(1) == lbigint(-1))

-- pow
assert(lbigint(2)^10 == lbigint(2^10))

-- arithmetic + - * /
assert(lbigint(1) + 1)
assert(lbigint(1) - "100")
assert(lbigint(1) * lbigint(100))
local a = 1 + lbigint(2) - "3" * lbigint(4) / 100
```

## Mutable
Usually variables in arithmetic are immutable, e.g.
```lua
local a = 100
local b = 50

local c = a + b -- this is it, a still 100 and b still 50
```
this is very efficient. But when it comes to big integer, can be very slow, e.g.
```lua
local a = lbigint("100000000000000...") -- a 10000-0 long string
a = a + 1
```
If `a` is immutable, a temporary variable will be cloned from `a`, and the cloned
process is quit slow. in this case the `a` is expected to be mutable, the cloned
is total waste of time.

As default, in any big integer arithmetic, variables are all mutable, unless they
are immutable(use `set_const(true)`) or create a temporary variable manually. e.g.
```lua
local a = lbigint("1000000000")

local d = lbigint(a) + 10000000 -- create a temporary variable manually

a:set_const(true)
local c = a + 1000000 -- a still 1000000000
```

## lib_perf

A simple performace test for serveral big integer library, 
[here is the result](lib_perf/README.md). Files in lib_perf are irrelevant to
this library.

## TODO
* performance test
* ci build
