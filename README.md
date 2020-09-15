# lua_bigint
big integer for lua

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
i0:topointer() -- 93943009449888

-- arithmetic + - * /

```

## TODO
```cpp
    namespace mp = boost::multiprecision;
    mp::cpp_int x = mp::pow(mp::cpp_int(2), 1024);
    std::cout << x << "\n";
```