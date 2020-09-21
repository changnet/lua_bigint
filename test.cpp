#include <lua.hpp>
#include "lbigintxx.h"

#include <iostream>

int main()
{
    lua_State *L = luaL_newstate();
    if (!L)
    {
        std::cerr << "open lua state fail" << std::endl;
        return 1;
    }

    luaL_openlibs(L);
    open_lua_bigint(L);
    if (LUA_OK != luaL_loadfile(L, "test.lua"))
    {
        lua_close(L);
        std::cerr << "load file error" << std::endl;
        return 1;
    }

    if (LUA_OK != lua_pcall(L, 0, 0, 0))
    {
        std::cerr << lua_tostring(L, -1) << std::endl;

        lua_close(L);
        return 1;
    }

    lua_close(L);

    return 0;
}