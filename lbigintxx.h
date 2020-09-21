#ifndef __LBIGINTXX_H__
#define __LBIGINTXX_H__

// keep this separate from lbigint.h, so dont need to install boost when link
// lbigint as a library.
#include <lua.hpp>
extern "C"
{
    // open lua_bigint lib in cpp
    extern void open_lua_bigint(lua_State *L);

    // open lua_bigint lib in lua
    extern int luaopen_lua_bigint(lua_State *L);
}

#endif /* __LBIGINTXX_H__ */
