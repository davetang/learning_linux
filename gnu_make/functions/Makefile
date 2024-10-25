.PHONY: all
SHELL := /bin/bash

# expand to list based on the pattern
BAMS := $(wildcard *.bam)

# search-and-replace on a given text
# $(patsubst pattern,replacement,text)
BAIS := $(patsubst %,%.bai,$(BAMS))

# $(addprefix prefix,names...)
# $(addsuffix suffix,names...)
BAMS2 := $(addprefix 0,$(BAMS))
BAIS2 := $(addsuffix .bai,$(BAMS))

all:
	@echo $(BAMS)
	@echo $(BAMS2)
	@echo $(BAIS)
	@echo $(BAIS2)
