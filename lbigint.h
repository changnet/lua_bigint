#ifndef __LBIGINT_H__
#define __LBIGINT_H__

#include <boost/multiprecision/cpp_int.hpp>

typedef boost::multiprecision::cpp_int bigint_t;

class lbigint : public bigint_t
{
public:
    explicit lbigint()
    {
        _const = false;
    }
    explicit lbigint(const int64_t o) : bigint_t(o)
    {
        _const = false;
    }
    explicit lbigint(const char *o) : bigint_t(o)
    {
        _const = false;
    }
    explicit lbigint(const lbigint &o) : bigint_t(o)
    {
        _const = o._const;
    }
    explicit lbigint(const lbigint &&o) : bigint_t(std::move(o))
    {
        _const = o._const;
    }

    lbigint &operator=(const int64_t v)
    {
        bigint_t::operator=(v);
        return *this;
    }
    lbigint &operator=(const char *v)
    {
        // bigint_t::operator=(v);
        assign(v);
        return *this;
    }
    lbigint &operator=(const lbigint &v)
    {
        _const = v._const;
        bigint_t::operator=((bigint_t)v);
        return *this;
    }
    lbigint &operator=(const lbigint &&v)
    {
        _const = v._const;
        bigint_t::operator=(std::move((bigint_t)v));
        return *this;
    }

    inline bool is_const() const
    {
        return _const;
    }
    inline void set_const(bool c)
    {
        _const = c;
    }

private:
    /**
     * This mask is intent to use in lua, so C++ function(e.g. operator=) will
     * not check this mask. In C++, use const keyword if a variable is const.
     */
    bool _const;
};

#endif /* __LBIGINT_H__ */
