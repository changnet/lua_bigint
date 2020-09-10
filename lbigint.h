#ifndef __LBIGINT_H__
#define __LBIGINT_H__

#include <boost/multiprecision/cpp_int.hpp>

typedef boost::multiprecision::cpp_int bigint_t;

class lbigint
{
public:
    bigint_t i;
};

#endif /* __LBIGINT_H__ */
