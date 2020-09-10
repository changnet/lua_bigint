A simple test for several big integer library. kasparsklavins do not support division.
gmp is install as a library, so it does not matter optimize is O0 or O2 for gmp test.

to run this test, boost and gmp need to be installed.

- [faheel](https://github.com/faheel/BigInt)
- [kasparsklavins](https://github.com/kasparsklavins/bigint)
- [kedixa](https://github.com/kedixa/klibcpp)
- [boost](https://www.boost.org)
- [gmp](https://gmplib.org/)


## Eviroment
CPU: I5-7200u @2.5G

OS: debian 9 @ VritualBox

## optimize=O0 TIMES=1000 (faheel too slow to run this test)
```
# make libperf
g++ -std=c++11 -I../boost_1_74_0 -Wall -g3 -O0 -o test_lib_perf \
        ./lib_perf/kedixa/unsigned_bigint.cpp \
        ./lib_perf/kasparsklavins/bigint.cpp \
        ./lib_perf/lib_perf.cpp \
        -lgmpxx -lgmp
./test_lib_perf
kasparsklavins create time elapsed 461929us
kasparsklavins add time elapsed 103803us
kasparsklavins dec time elapsed 122182us
kasparsklavins mul time elapsed 30136760us
kasparsklavins to_string time elapsed 317977us
kedixa create time elapsed 9837581us
kedixa add time elapsed 15611us
kedixa dec time elapsed 15181us
kedixa mul time elapsed 11439598us
kedixa div time elapsed 11520902us
kedixa to_string time elapsed 11389921us
boost create time elapsed 705195us
boost add time elapsed 2669us
boost dec time elapsed 2616us
boost mul time elapsed 1089885us
boost div time elapsed 4029627us
boost to_string time elapsed 17380148us
gmp create time elapsed 92522us
gmp add time elapsed 320us
gmp dec time elapsed 439us
gmp mul time elapsed 116910us
gmp div time elapsed 111008us
gmp to_string time elapsed 154568us
test done, TIMES = 1000, BASE BIT = 10000, MUL BIT = 1000
```

## optimize=O2 TIMES=1000 (faheel too slow to run this test)
```
# make libperf
g++ -std=c++11 -I../boost_1_74_0 -Wall -g3 -O2 -o test_lib_perf \
        ./lib_perf/kedixa/unsigned_bigint.cpp \
        ./lib_perf/kasparsklavins/bigint.cpp \
        ./lib_perf/lib_perf.cpp \
        -lgmpxx -lgmp
./test_lib_perf
kasparsklavins create time elapsed 23192us
kasparsklavins add time elapsed 12355us
kasparsklavins dec time elapsed 12092us
kasparsklavins mul time elapsed 7027907us
kasparsklavins to_string time elapsed 188498us
kedixa create time elapsed 552214us
kedixa add time elapsed 836us
kedixa dec time elapsed 1122us
kedixa mul time elapsed 654559us
kedixa div time elapsed 698997us
kedixa to_string time elapsed 1387390us
boost create time elapsed 191679us
boost add time elapsed 883us
boost dec time elapsed 869us
boost mul time elapsed 244133us
boost div time elapsed 1023895us
boost to_string time elapsed 13701247us
gmp create time elapsed 90719us
gmp add time elapsed 389us
gmp dec time elapsed 292us
gmp mul time elapsed 114872us
gmp div time elapsed 112614us
gmp to_string time elapsed 154037us
test done, TIMES = 1000, BASE BIT = 10000, MUL BIT = 1000
```

## optimize=O2 TIMES=10
```
# make libperf
g++ -std=c++11 -I../boost_1_74_0 -Wall -g3 -O2 -o test_lib_perf \
        ./lib_perf/kedixa/unsigned_bigint.cpp \
        ./lib_perf/kasparsklavins/bigint.cpp \
        ./lib_perf/lib_perf.cpp \
        -lgmpxx -lgmp
./test_lib_perf
faheel create time elapsed 98us
faheel add time elapsed 38256us
faheel dec time elapsed 43456us
faheel mul time elapsed 12309486us
faheel div time elapsed 191761534us
faheel to_string time elapsed 96us
kasparsklavins create time elapsed 232us
kasparsklavins add time elapsed 325us
kasparsklavins dec time elapsed 119us
kasparsklavins mul time elapsed 71310us
kasparsklavins to_string time elapsed 2100us
kedixa create time elapsed 5383us
kedixa add time elapsed 8us
kedixa dec time elapsed 11us
kedixa mul time elapsed 6604us
kedixa div time elapsed 6813us
kedixa to_string time elapsed 14514us
boost create time elapsed 1914us
boost add time elapsed 203us
boost dec time elapsed 12us
boost mul time elapsed 2625us
boost div time elapsed 10304us
boost to_string time elapsed 137713us
gmp create time elapsed 909us
gmp add time elapsed 9us
gmp dec time elapsed 6us
gmp mul time elapsed 1294us
gmp div time elapsed 1176us
gmp to_string time elapsed 1564us
test done, TIMES = 10, BASE BIT = 10000, MUL BIT = 1000
```