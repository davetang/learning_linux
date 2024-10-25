.PHONY: all
SHELL := /bin/bash
CC := gcc

# compiler flags
# -Wall - enable all commonly used warning messages
# -Wextra - enables additional warnings beyond -Wall
CFLAGS := -Wall -Wextra

# assign if undefined
DEBUG ?= 0
ifeq ($(DEBUG), 1)
	# append -g which enables debugging information in the compiled program. The -g flag tells the compiler to include extra information (such as symbol names and source file information) in the output, which is essential for debugging with tools like gdb.
	CFLAGS += -g
endif

all:
	@echo $(CC) $(CFLAGS) main.c -o main
