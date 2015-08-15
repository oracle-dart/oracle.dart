.PHONY: all

TARGETS=$(wildcard lib/src/*.cc)
OBJECTS=$(TARGETS:%.cc=%.o)


%.o: %.cc
	clang $< -std=c++11 -Wall -fPIC -c -I /opt/dart-sdk/include -I /usr/include/oracle/12.1/client64 -I lib/src -DDART_SHARED_LIB -o $@

all: $(TARGETS:.cc=.o)
	clang $(OBJECTS) -std=c++11 -Wall -fPIC -rdynamic -shared -I /opt/dart-sdk/include -I /usr/include/oracle/12.1/client64 -I lib/src -DDART_SHARED_LIB -L /usr/lib/oracle/12.1/client64/lib -olib/src/libocci_extension.so -locci -lclntsh

clean:
	rm lib/src/*.o
