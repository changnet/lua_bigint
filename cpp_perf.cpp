#include "./faheel/BigInt.hpp"
#include "./kasparsklavins/bigint.h"
#include "./kedixa/unsigned_bigint.h"
#include <boost/multiprecision/cpp_int.hpp>

#include <gmpxx.h>

#include <chrono>
#include <string>
#include <random>
#include <iostream>

typedef std::chrono::steady_clock Clock;
typedef std::chrono::microseconds Microsec;

#define TEST_TIMES 10
#define BASE_BIT 10000
#define MUL_BIT 1000

#define TIME_BEG last = Clock::now()
#define TIME_END(name, what)                                         \
    do                                                               \
    {                                                                \
        curr = Clock::now();                                         \
        auto ms = std::chrono::duration_cast<Microsec>(curr - last); \
        std::cout << name << " " << what << " time elapsed "         \
                  << ms.count() << "us" << std::endl;                \
    } while (0)

template <class T>
void test(const char *name,
          const std::string &base, const std::string &mul, int seed)
{
    Clock::time_point last;
    Clock::time_point curr;

    const T b(base);
    const T m(mul);

    // test string to big int
    TIME_BEG;
    for (int i = 0; i < TEST_TIMES; i++)
    {
        T v(base);
    }
    TIME_END(name, "create");

    // test add
    TIME_BEG;
    T sum;
    for (int i = 0; i < TEST_TIMES; i++)
    {
        sum += b;
    }
    TIME_END(name, "add");

    // test dec
    TIME_BEG;
    for (int i = 0; i < TEST_TIMES; i++)
    {
        sum -= b;
    }
    TIME_END(name, "dec");

    // test mul
    TIME_BEG;
    for (int i = 0; i < TEST_TIMES; i++)
    {
        T v(base);
        v = v * m;
    }
    TIME_END(name, "mul");

    // test div
    TIME_BEG;
    for (int i = 0; i < TEST_TIMES; i++)
    {
        T v(base);
        v = v / m;
    }
    TIME_END(name, "div");

    // test to_string
    TIME_BEG;
    for (int i = 0; i < TEST_TIMES; i++)
    {
        b.to_string();
    }
    TIME_END(name, "to_string");
}

template <class T>
void test_boost(const char *name,
                const std::string &base, const std::string &mul, int seed)
{
    Clock::time_point last;
    Clock::time_point curr;

    const T b(base);
    const T m(mul);

    // test string to big int
    TIME_BEG;
    for (int i = 0; i < TEST_TIMES; i++)
    {
        T v(base);
    }
    TIME_END(name, "create");

    // test add
    TIME_BEG;
    T sum;
    for (int i = 0; i < TEST_TIMES; i++)
    {
        sum += b;
    }
    TIME_END(name, "add");

    // test dec
    TIME_BEG;
    for (int i = 0; i < TEST_TIMES; i++)
    {
        sum -= b;
    }
    TIME_END(name, "dec");

    // test mul
    TIME_BEG;
    for (int i = 0; i < TEST_TIMES; i++)
    {
        T v(base);
        v = v * m;
    }
    TIME_END(name, "mul");

    // test div
    TIME_BEG;
    for (int i = 0; i < TEST_TIMES; i++)
    {
        T v(base);
        v = v / m;
    }
    TIME_END(name, "div");

    // test to_string
    TIME_BEG;
    for (int i = 0; i < TEST_TIMES; i++)
    {
        b.str();
    }
    TIME_END(name, "to_string");
}

void test_kasparsklavins(
    const std::string &base, const std::string &mul, int seed)
{
    Clock::time_point last;
    Clock::time_point curr;

    const char *name = "kasparsklavins";

    const Dodecahedron::Bigint b(base);
    const Dodecahedron::Bigint m(mul);

    // test string to big int
    TIME_BEG;
    for (int i = 0; i < TEST_TIMES; i++)
    {
        Dodecahedron::Bigint v(base);
    }
    TIME_END(name, "create");

    // test add
    TIME_BEG;
    Dodecahedron::Bigint sum;
    for (int i = 0; i < TEST_TIMES; i++)
    {
        sum += b;
    }
    TIME_END(name, "add");

    // test dec
    TIME_BEG;
    for (int i = 0; i < TEST_TIMES; i++)
    {
        sum -= b;
    }
    TIME_END(name, "dec");

    // test mul
    TIME_BEG;
    for (int i = 0; i < TEST_TIMES; i++)
    {
        Dodecahedron::Bigint v(base);
        v = v * m;
    }
    TIME_END(name, "mul");
    /*
    // no division in kasparsklavins
    // test div
    TIME_BEG;
    for (int i = 0;i < TEST_TIMES;i ++)
    {
        T v(base);
        v = v / m;
    }
    TIME_END(name, "div");
*/
    // test to_string
    TIME_BEG;
    for (int i = 0; i < TEST_TIMES; i++)
    {
        Dodecahedron::to_string(b);
    }
    TIME_END(name, "to_string");
}

template <class T>
void test_gmp(const char *name,
              const std::string &base, const std::string &mul, int seed)
{
    Clock::time_point last;
    Clock::time_point curr;

    const T b(base);
    const T m(mul);

    // test string to big int
    TIME_BEG;
    for (int i = 0; i < TEST_TIMES; i++)
    {
        T v(base);
    }
    TIME_END(name, "create");

    // test add
    TIME_BEG;
    T sum;
    for (int i = 0; i < TEST_TIMES; i++)
    {
        sum += b;
    }
    TIME_END(name, "add");

    // test dec
    TIME_BEG;
    for (int i = 0; i < TEST_TIMES; i++)
    {
        sum -= b;
    }
    TIME_END(name, "dec");

    // test mul
    TIME_BEG;
    for (int i = 0; i < TEST_TIMES; i++)
    {
        T v(base);
        v = v * m;
    }
    TIME_END(name, "mul");

    // test div
    TIME_BEG;
    for (int i = 0; i < TEST_TIMES; i++)
    {
        T v(base);
        v = v / m;
    }
    TIME_END(name, "div");

    // test to_string
    TIME_BEG;
    for (int i = 0; i < TEST_TIMES; i++)
    {
        b.get_str();
    }
    TIME_END(name, "to_string");
}

int main()
{
    // random a very big number, make sure the first one is not 0
    std::string base = "9";

    std::default_random_engine e;
    std::uniform_real_distribution<float> u(0, 9);
    for (size_t i = 0; i < BASE_BIT; ++i)
    {
        base.append(std::to_string(int(u(e))));
    }

    std::string mul = "1";
    for (size_t i = 0; i < MUL_BIT; ++i)
    {
        mul.append(std::to_string(int(u(e))));
    }

    int seed = int(u(e));

    // 测试加减法
    // 测试乘除法
    // 测试to_string

    test<BigInt>("faheel", base, mul, seed);
    // test<Dodecahedron::Bigint>("kasparsklavins", base, mul, seed);
    test_kasparsklavins(base, mul, seed);
    test<kedixa::unsigned_bigint>("kedixa", base, mul, seed);
    test_boost<boost::multiprecision::cpp_int>("boost", base, mul, seed);
    test_gmp<mpz_class>("gmp", base, mul, seed);

    std::cout << "test done, TIMES = " << TEST_TIMES
              << ", BASE BIT = " << BASE_BIT
              << ", MUL BIT = " << MUL_BIT << std::endl;

    return 0;
}
