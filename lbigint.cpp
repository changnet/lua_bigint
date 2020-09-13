#include "lbigint.h"


#define LIB_NAME "lua_bigint"

static inline class lbigint *luaL_checklbigint(lua_State *L, int index)
{
    class lbigint** lbi = (class lbigint**)luaL_checkudata(L, 1, LIB_NAME);
    if (!lbi || !(*lbi))
    {
        luaL_error(L, "encode argument #%d expect %s", index, LIB_NAME);
        return nullptr;
    }

    return *lbi;
}

/**
 * 从 string、integer、bigint 设置当前的值，i:set(0)即置0
 */
static int set(lua_State *L)
{
    class lbigint *lbi = luaL_checklbigint(L, 1);

    return 0;
}

/* ====================LIBRARY INITIALISATION FUNCTION======================= */

/* create a C++ object and push to lua stack */
static int __call(lua_State* L)
{
    /* lua调用__call,第一个参数是该元表所属的table.取构造函数参数要注意 */
    class lbigint* obj = new class lbigint();

    lua_settop( L,1 ); /* 清除所有构造函数参数,只保留元表 */

    class lbigint** ptr =
        (class lbigint**)lua_newuserdata(L, sizeof(class lbigint*));
    *ptr = obj;

    /* 把新创建的userdata和元表交换堆栈位置 */
    lua_insert(L,1);

    /* 弹出元表,并把元表设置为userdata的元表 */
    lua_setmetatable(L, -2);

    return 1;
}

/* 元方法,__tostring */
static int __tostring(lua_State* L)
{
    class lbigint *lbi = luaL_checklbigint(L, 1);
    if(lbi)
    {
        lua_pushstring(L, lbi->str().c_str());
        return 1;
    }
    return 0;
}

/*  元方法,__gc */
static int __gc(lua_State* L)
{
    class lbigint** ptr = (class lbigint**)luaL_checkudata(L, 1,LIB_NAME);
    if (*ptr != nullptr)
    {
        delete *ptr;
    }
    *ptr = nullptr;

    return 0;
}

int luaopen_lua_bigint(lua_State *L)
{
    if (0 == luaL_newmetatable(L,LIB_NAME))
    {
        assert(false);
        return 0;
    }

    // custom api
    // lua_pushcfunction(L, encode);
    // lua_setfield(L, -2, "encode");

    // lua_pushcfunction(L, decode);
    // lua_setfield(L, -2, "decode");

    // lua meta api
    lua_pushcfunction(L, __gc);
    lua_setfield(L, -2, "__gc");

    lua_pushcfunction(L, __tostring);
    lua_setfield(L, -2, "__tostring");

    /* metatable as value and pop metatable */
    lua_pushvalue( L,-1 );
    lua_setfield(L, -2, "__index");

    lua_newtable( L );
    lua_pushcfunction(L, __call);
    lua_setfield(L, -2, "__call");
    lua_setmetatable( L,-2 );

    return 1;  /* return metatable */
}
