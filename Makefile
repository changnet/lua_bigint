##### Build defaults #####
MAKE = make
CXX = g++

TARGET_SO =         lua_bigint.so
TARGET_A  =         liblua_bigint.a
# CFLAGS =            -std=c++11 -g3 -O0 -Wall -pedantic -fno-inline
CFLAGS =            -std=c++11 -g -O2 -Wall -pedantic #-DNDEBUG

SHAREDDIR = .sharedlib
STATICDIR = .staticlib

# AR= ar rcu # ar: `u' modifier ignored since `D' is the default (see `U')

AR= ar rc
RANLIB= ranlib

OBJS = lbigint.o

SHAREDOBJS = $(addprefix $(SHAREDDIR)/,$(OBJS))
STATICOBJS = $(addprefix $(STATICDIR)/,$(OBJS))

DEPS := $(SHAREDOBJS + STATICOBJS:.o=.d)

# The dash at the start of '-include' tells Make to continue when the .d file
# doesn't exist (e.g. on first compilation)
-include $(DEPS)

.PHONY: all bundled clean test staticlib sharedlib memcheck libperf

$(SHAREDDIR)/%.o: %.cpp
	@[ ! -d $(SHAREDDIR) ] & mkdir -p $(SHAREDDIR)
	$(CXX) -c $(CFLAGS) -fPIC -MMD -MP -MF"$(@:%.o=%.d)" -o $@ $<

$(STATICDIR)/%.o: %.cpp
	@[ ! -d $(STATICDIR) ] & mkdir -p $(STATICDIR)
	$(CXX) -c $(CFLAGS) -MMD -MP -MF"$(@:%.o=%.d)" -o $@ $<

all: $(TARGET_SO) $(TARGET_A)

# target-specific variable value
# https://www.gnu.org/software/make/manual/make.html#Target_002dspecific
bundled: CFLAGS += -I.
bundled: all

staticlib: $(TARGET_A)
sharedlib: $(TARGET_SO)


# -Wl,-E
# When creating a dynamically linked executable, using the -E option or the
# --export-dynamic option causes the linker to add all symbols to the dynamic
# symbol table. The dynamic symbol table is the set of symbols which are visible
# from dynamic objects at run time
# -Wl,--whole-archive /usr/local/lib/libflatbuffers.a -Wl,--no-whole-archive
$(TARGET_SO): $(SHAREDOBJS)
	$(CXX) $(LDFLAGS) -shared -o $@ $(SHAREDOBJS) $(LUA_FLATBUFFERS_DEPS)

$(TARGET_A): $(STATICOBJS)
	$(AR) $@ $(STATICOBJS)
	$(RANLIB) $@

test: $(TARGET_SO)
	lua test.lua
	lua perf.lua "lua_bigint"

# valgrind report a at std::runtime_error, I checked the code but don't find anything
# It seems to relate with this: https://gcc.gnu.org/bugzilla/show_bug.cgi?id=39366
memcheck: $(TARGET_SO)
	 valgrind --leak-check=full --show-leak-kinds=all \
	 	--suppressions=valgrind.suppressions \
		--gen-suppressions=all \
		lua test.lua


# export BOOST_INC=../boost_1_74_0

# install gmp: https://gmplib.org/
# tar -xf gmp-6.2.0.tar.xz
# cd gmp-6.2.0
# ./configure --enable-cxx
# make
# make check
# make install
libperf:
	g++ -std=c++11 -I$(BOOST_INC) -Wall -g3 -O2 -o test_lib_perf \
		./lib_perf/kedixa/unsigned_bigint.cpp \
		./lib_perf/kasparsklavins/bigint.cpp \
		./lib_perf/lib_perf.cpp \
		-lgmpxx -lgmp
	g++ -std=c++11 -g3 -O2 -shared -fPIC  -o jorjbauer.so \
		./lib_perf/jorjbauer/BigInt.cpp \
		./lib_perf/jorjbauer/mainlib.c \
		./lib_perf/jorjbauer/bigint-glue.cpp

	lua perf.lua "jorjbauer"
	./test_lib_perf


clean:
	rm -f -R $(SHAREDDIR) $(STATICDIR) $(TARGET_SO) $(TARGET_A)
