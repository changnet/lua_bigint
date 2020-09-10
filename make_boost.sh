#!/bin/bash

# sh do NOT support array，do run this script with sh

SRC=../boost_1_74_0
DST="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# clear directory if not empty
# if [ ! -z "$(ls -A ./boost)" ]; then
#    rm -R ./boost
# fi

FILES=(
"boost/multiprecision/cpp_int.hpp"

"boost/cstdint.hpp"
"boost/multiprecision/number.hpp"
"boost/multiprecision/detail/integer_ops.hpp"
"boost/multiprecision/detail/rebind.hpp"
"boost/core/empty_value.hpp"
"boost/array.hpp"
"boost/type_traits/is_integral.hpp"
"boost/type_traits/is_floating_point.hpp"
"boost/multiprecision/cpp_int/cpp_int_config.hpp"
"boost/multiprecision/rational_adaptor.hpp"
"boost/multiprecision/traits/is_byte_container.hpp"
"boost/predef/other/endian.h"
"boost/integer/static_min_max.hpp"
"boost/type_traits/common_type.hpp"
"boost/type_traits/make_signed.hpp"
"boost/multiprecision/cpp_int/checked.hpp"
"boost/multiprecision/detail/constexpr.hpp"
"boost/multiprecision/cpp_int/value_pack.hpp"
)

cd $SRC
for F in ${FILES[@]}; do
    echo $F
    cp --parent $F $DST
done