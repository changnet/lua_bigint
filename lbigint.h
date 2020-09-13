#ifndef __LBIGINT_H__
#define __LBIGINT_H__

// #include <lua.hpp>
// extern "C"
// {
// extern int luaopen_lua_bigint(lua_State *L);
// }

// TODO 外部调用看能不能避免引用boost，头文件实在太多，不好管理

#include <boost/multiprecision/cpp_int.hpp>

typedef boost::multiprecision::cpp_int bigint_t;

class lbigint
{
public:
    bigint_t i;
};

#endif /* __LBIGINT_H__ */
