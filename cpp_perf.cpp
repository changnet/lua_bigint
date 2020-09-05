#include "BigInt.hpp"
#include <chrono>
#include <string>
#include <random>
#include <iostream>

typedef std::chrono::steady_clock Clock;
typedef std::chrono::microseconds Microsec;

#define TEST_TIMES 10

#define TIME_BEG last = Clock::now()
#define TIME_END(name, what)    \
    do{\
        curr   = Clock::now();\
        auto ms = std::chrono::duration_cast<Microsec>(curr - last);\
        std::cout << name << " " << what << " time elapsed " \
        << ms.count() << "µs" << std::endl;\
    } while (0)

void test_faheel(const std::string &base, const std::string &mul, int seed)
{
    Clock::time_point last;
    Clock::time_point curr;

    const BigInt b(base);

    // test string to big int
    TIME_BEG;
    for (int i = 0;i < TEST_TIMES;i ++)
    {
        BigInt v(base);
    }
    TIME_END("faheel", "create");

    // test add
    TIME_BEG;
    BigInt sum;
    for (int i = 0;i < TEST_TIMES;i ++)
    {
        sum += base;
    }
    TIME_END("faheel", "add");

    // test dec
    TIME_BEG;
    for (int i = 0;i < TEST_TIMES;i ++)
    {
        sum -= base;
    }
    TIME_END("faheel", "dec");

    // test mul
    TIME_BEG;
    for (int i = 0;i < TEST_TIMES;i ++)
    {
        BigInt v(base);
        v = v * mul;
    }
    TIME_END("faheel", "mul");

    // test div
    TIME_BEG;
    for (int i = 0;i < TEST_TIMES;i ++)
    {
        BigInt v(base);
        v = v / mul;
    }
    TIME_END("faheel", "div");

    // test to_string
    TIME_BEG;
    for (int i = 0;i < TEST_TIMES;i ++)
    {
        std::string &&s = b.to_string();
    }
    TIME_END("faheel", "to_string");
}

int main()
{
    // random a very big number, make sure the first one is not 0
    std::string base = "9";

    std::default_random_engine e; 
    std::uniform_real_distribution<float> u(0, 9);
    for (size_t i = 0; i < 10000; ++i)
    {
        base.append(std::to_string(int(u(e))));
    }

    std::string mul = "1";
        for (size_t i = 0; i < 1000; ++i)
    {
        mul.append(std::to_string(int(u(e))));
    }

    int seed = int(u(e) * 10);

    // 测试加减法
    // 测试乘除法
    // 测试to_string

    test_faheel(base, mul, seed);
    return 0;
}
