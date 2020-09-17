#include "lbigint.h"

#define LIB_NAME "lua_bigint"

static inline lbigint *luaL_checklbigint(lua_State *L, int index)
{
    lbigint **lbi = (lbigint **)luaL_checkudata(L, index, LIB_NAME);
    if (!lbi || !(*lbi))
    {
        luaL_error(L, "encode argument #%d expect %s", index, LIB_NAME);
        return nullptr;
    }

    return *lbi;
}

/**
 * 把一个lbigint对象push到栈上
 * 注意不要把同一个对象多次push到lua，因为userdata执行gc的时候会被销毁导致多次delete
 * 把一个已经在lua中的对象push到栈上，使用lua_pushvalue
 */
static inline void lua_pushlbigint(lua_State *L, const lbigint *i)
{
    const lbigint **ptr = (const lbigint **)lua_newuserdata(L, sizeof(lbigint *));

    *ptr = i;

    // mush call luaopen_lua_bigint before
    int type = luaL_getmetatable(L, LIB_NAME);
    assert(LUA_TTABLE == type);

    lua_setmetatable(L, -2);
}

/* like lua_topointer */
static int to_pointer(lua_State *L)
{
    lbigint *lbi = luaL_checklbigint(L, 1);

    lua_pushinteger(L, (lua_Integer)lbi);
    return 1;
}

/* like lua_topointer */
static int set_const(lua_State *L)
{
    lbigint *lbi = luaL_checklbigint(L, 1);
    bool c = lua_toboolean(L, 2);

    lbi->set_const(c);
    return 0;
}

/**
 * 从 string、integer、bigint 设置当前的值，i:assign(0)即置0
 */
static int assign(lua_State *L)
{
    lbigint *lbi = luaL_checklbigint(L, 1);

    if (lbi->is_const())
    {
        return luaL_error(L, "attemp to modify a const big integer");
    }

    int type = lua_type(L, 2);
    if (LUA_TNUMBER == type)
    {
        *lbi = lua_tointeger(L, 2);
    }
    else if (LUA_TSTRING == type)
    {
        try
        {
            *lbi = lua_tostring(L, 2);
        }
        catch (const std::exception &e)
        {
            luaL_error(L, e.what());
        }
    }
    else if (LUA_TUSERDATA == type)
    {
        const lbigint *lbi_o = luaL_checklbigint(L, 2);

        if (lbi != lbi_o) // self assign check
        {
            *lbi = *lbi_o;
        }
    }
    else
    {
        luaL_error(L,
                   "can not convert %s to big integer", lua_typename(L, type));
    }

    return 0;
}

// check two big int equal
static int equal(lua_State *L)
{
    // in lua, a integer or string compare to a userdata, the userdata's __eq
    // meta method never get called, it just return false
    //  100 == lbigint(100) is always false
    // however, we can call equal manually
    const lbigint *lbi = luaL_checklbigint(L, 1);

    bool e = false;
    int type = lua_type(L, 2);
    if (LUA_TNUMBER == type)
    {
        e = ((*lbi) == lua_tointeger(L, 2));
    }
    else if (LUA_TSTRING == type)
    {
        try
        {
            const bigint_t bi_o(lua_tostring(L, 2));
            e = ((*lbi) == bi_o);
        }
        catch (const std::exception &e)
        {
            luaL_error(L, e.what());
        }
    }
    else if (LUA_TUSERDATA == type)
    {
        const bigint_t *lbi_o = luaL_checklbigint(L, 2);

        e = ((*lbi) == (*lbi_o));
    }
    else
    {
        luaL_error(L,
                   "can not convert %s to big integer", lua_typename(L, type));
    }

    // _const is not consider, just compare value
    lua_pushboolean(L, e);
    return 1;
}

// check two big int less than
static int less(lua_State *L)
{
    int index_a = 1;
    int index_b = 2;
    if (LUA_TUSERDATA != lua_type(L, 1))
    {
        index_a = 2;
        index_b = 1;
    }

#define COMP(a, b) (1 == index_a ? ((a) < (b)) : ((b) < (a)))

    const lbigint *lbi = luaL_checklbigint(L, index_a);

    bool e = false;
    int type = lua_type(L, index_b);
    if (LUA_TNUMBER == type)
    {
        e = COMP(*lbi, lua_tointeger(L, index_b));
    }
    else if (LUA_TSTRING == type)
    {
        try
        {
            const bigint_t bi_o(lua_tostring(L, index_b));
            e = COMP(*lbi, bi_o);
        }
        catch (const std::exception &e)
        {
            luaL_error(L, e.what());
        }
    }
    else if (LUA_TUSERDATA == type)
    {
        const bigint_t *lbi_o = luaL_checklbigint(L, index_b);

        e = COMP(*lbi, *lbi_o);
    }
    else
    {
        luaL_error(L,
                   "can not convert %s to big integer", lua_typename(L, type));
    }

    // _const is not consider, just compare value
    lua_pushboolean(L, e);
    return 1;

#undef COMP
}

// unary minus, the - operation
static int unm(lua_State *L)
{
    lbigint *lbi = luaL_checklbigint(L, 1);

    if (lbi->is_const())
    {
        return luaL_error(L, "attemp to modify a const big integer");
    }

    // -(*lbi);
    lbi->backend().negate();

    // return itself
    lua_settop(L, 1);
    return 1;
}

// test sign
static int sign(lua_State *L)
{
    const lbigint *lbi = luaL_checklbigint(L, 1);

    // misc.hpp
    // eval_is_zero(val) ? 0 : val.sign() ? -1 : 1;
    lua_pushinteger(L, lbi->sign());
    return 1;
}

/**
 * 加法，支持 string、integer、bigint
 */
static int add(lua_State *L)
{
    // 大整数有可能在左边，也有可能在右边
    int index_a = 1;
    int index_b = 2;
    if (LUA_TUSERDATA != lua_type(L, 1))
    {
        index_a = 2;
        index_b = 1;
    }

    lbigint *lbi = luaL_checklbigint(L, index_a);
    // const variable, create a temporary variables
    if (lbi->is_const())
    {
        index_a = -1;
        lbi = new lbigint(*lbi);
    }

    int type = lua_type(L, index_b);
    if (LUA_TNUMBER == type)
    {
        *lbi += lua_tointeger(L, index_b);
    }
    else if (LUA_TSTRING == type)
    {
        try
        {
            *lbi += bigint_t(lua_tostring(L, index_b));
        }
        catch (const std::exception &e)
        {
            if (-1 == index_a)
            {
                delete lbi;
            }
            luaL_error(L, e.what());
        }
    }
    else if (LUA_TUSERDATA == type)
    {
        const bigint_t *lbi_o = luaL_checklbigint(L, index_b);

        *lbi += *lbi_o;
    }
    else
    {
        if (-1 == index_a)
        {
            delete lbi;
        }
        luaL_error(L,
                   "can not convert %s to big integer", lua_typename(L, type));
    }

    if (-1 == index_a)
    {
        lua_pushlbigint(L, lbi);
    }
    else
    {
        lua_settop(L, index_a); // left the user data at stack top to return it
    }
    return 1;
}

/* ====================LIBRARY INITIALISATION FUNCTION======================= */

/* create a C++ object and push to lua stack */
static int __call(lua_State *L)
{
    /* lua调用__call,第一个参数是该元表所属的table.取构造函数参数要注意 */
    lbigint *obj = nullptr;

    int type = lua_type(L, 2);
    if (LUA_TNUMBER == type)
    {
        obj = new lbigint(lua_tointeger(L, 2));
    }
    else if (LUA_TSTRING == type)
    {
        try
        {
            obj = new lbigint(lua_tostring(L, 2));
        }
        catch (const std::exception &e)
        {
            luaL_error(L, e.what());
        }
    }
    else if (LUA_TUSERDATA == type)
    {
        const lbigint *lbi_o = luaL_checklbigint(L, 2);
        obj = new lbigint(*lbi_o);
    }
    else
    {
        obj = new lbigint();
    }

    lua_settop(L, 1); /* 清除所有构造函数参数,只保留元表 */

    lbigint **ptr =
        (lbigint **)lua_newuserdata(L, sizeof(lbigint *));
    *ptr = obj;

    /* 把新创建的userdata和元表交换堆栈位置 */
    lua_insert(L, 1);

    /* 弹出元表,并把元表设置为userdata的元表 */
    lua_setmetatable(L, -2);

    return 1;
}

/* 元方法,__tostring */
static int __tostring(lua_State *L)
{
    lbigint *lbi = luaL_checklbigint(L, 1);
    if (lbi)
    {
        lua_pushstring(L, lbi->str().c_str());
        return 1;
    }
    return 0;
}

/*  元方法,__gc */
static int __gc(lua_State *L)
{
    lbigint **ptr = (lbigint **)luaL_checkudata(L, 1, LIB_NAME);
    if (*ptr != nullptr)
    {
        delete *ptr;
    }
    *ptr = nullptr;

    return 0;
}

int luaopen_lua_bigint(lua_State *L)
{
    if (0 == luaL_newmetatable(L, LIB_NAME))
    {
        assert(false);
        return 0;
    }

    lua_pushcfunction(L, to_pointer);
    lua_setfield(L, -2, "to_pointer");

    lua_pushcfunction(L, set_const);
    lua_setfield(L, -2, "set_const");

    lua_pushcfunction(L, assign);
    lua_setfield(L, -2, "assign");

    lua_pushcfunction(L, sign);
    lua_setfield(L, -2, "sign");

    lua_pushcfunction(L, equal);
    lua_setfield(L, -2, "equal");

    lua_pushcfunction(L, equal);
    lua_setfield(L, -2, "__eq");

    lua_pushcfunction(L, less);
    lua_setfield(L, -2, "__lt");

    lua_pushcfunction(L, unm);
    lua_setfield(L, -2, "__unm");

    lua_pushcfunction(L, add);
    lua_setfield(L, -2, "__add");

    lua_pushcfunction(L, __gc);
    lua_setfield(L, -2, "__gc");

    lua_pushcfunction(L, __tostring);
    lua_setfield(L, -2, "__tostring");

    /* metatable as value and pop metatable */
    lua_pushvalue(L, -1);
    lua_setfield(L, -2, "__index");

    lua_newtable(L);
    lua_pushcfunction(L, __call);
    lua_setfield(L, -2, "__call");
    lua_setmetatable(L, -2);

    return 1; /* return metatable */
}
