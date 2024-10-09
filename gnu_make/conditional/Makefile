.PHONY: all
SHELL := /bin/bash

COND1 = 23
COND2 = 23

all: my_target

my_target:
ifeq ($(COND1),1)
	echo Condition 1
else ifeq ($(COND2),2)
	echo Condition 2
else
	echo Condition else
endif
