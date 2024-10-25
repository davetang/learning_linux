.PHONY: all
SHELL := /bin/bash

all: first.txt second.txt

first.txt second.txt:
	@echo "Generating: $@"
	touch $@

clean:
	rm -rf *.txt
