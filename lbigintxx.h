#ifndef __LBIGINTXX_H__
#define __LBIGINTXX_H__

// keep this separate from lbigint.h, so dont need to install boost when link
// lbigint as a library.
#include <lua.hpp>
extern "C"
{
    extern int luaopen_lua_bigint(lua_State *L);
}

#endif /* __LBIGINTXX_H__ */