.PHONY: all
SHELL := /bin/bash

# the @ symbol at the beginning of a command tells Make to execute the command silently, meaning it won’t display the command itself in the output. Only any resulting output of the command will be shown.

VERBOSE ?= 0
ifeq ($(VERBOSE), 0)
	Q := @
else
	Q :=
endif

all:
	$(Q)printf "Hello, World!\n"
