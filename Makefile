.PHONY: all check-env clean

TARGETS=$(wildcard lib/src/*.cc)
OBJECTS=$(TARGETS:%.cc=%.o)

SRC_DIR=$(CURDIR)/lib/src

all: $(TARGETS:.cc=.o)
	clang $(OBJECTS) \
		-std=c++11 \
		-Wall \
		-fPIC \
		-rdynamic \
		-shared \
		-I $(DART_SDK)/include \
		-I $(ORACLE_INCLUDE) \
		-I $(SRC_DIR) \
		-DDART_SHARED_LIB \
		-L $(ORACLE_LIB) \
		-olib/src/libocci_extension.so \
		-locci \
		-lclntsh

%.o: %.cc
	clang \
		-std=c++11 \
		-Wall \
		-fPIC \
		-c \
		-I $(ORACLE_INCLUDE) \
		-I $(DART_SDK)/include \
		-I $(SRC_DIR) \
		-DDART_SHARED_LIB \
		$< -o $@

clean:
	rm $(SRC_DIR)/*.o
