# this will always rebuild hello and it won't be obvious in a large Makefile and in the output because main.o never gets run
.PHONY: all

all: hello

hello: main.o
	touch $@

main.o:
ifeq (false,true)
	echo $@
endif
