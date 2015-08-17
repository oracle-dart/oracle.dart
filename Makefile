.PHONY: all check-env clean

CC := clang
CFLAGS = -std=c++11 -Wall -fPIC

ifdef COVERAGE
	CC = gcc
	CFLAGS += --coverage
endif

SRC_DIR=$(CURDIR)/lib/src
TARGETS=$(wildcard $(SRC_DIR)/*.cc)
OBJECTS=$(TARGETS:%.cc=%.o)

# fallback to gcc if clang is not present
ifeq (, $(shell which clang))
	CC = gcc
endif

all: $(OBJECTS)
	$(CC) $(CFLAGS) $(OBJECTS) \
		-rdynamic \
		-shared \
		-I $(DART_SDK)/include \
		-I $(ORACLE_INCLUDE) \
		-I $(SRC_DIR) \
		-L $(ORACLE_LIB) \
		-olib/src/libocci_extension.so \
		-locci \
		-lclntsh

%.o: %.cc
	$(CC) $(CFLAGS) \
		-c \
		-I $(ORACLE_INCLUDE) \
		-I $(DART_SDK)/include \
		-I $(SRC_DIR) \
		-DDART_SHARED_LIB \
		$< -o $@

clean:
	rm -f $(SRC_DIR)/*.o
	rm -f $(SRC_DIR)/*.so
