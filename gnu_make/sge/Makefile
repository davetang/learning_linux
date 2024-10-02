.PHONY: all
SHELL := /bin/bash

FILES := 1.txt 2.txt 3.txt 4.txt
all: $(FILES)

%.txt:
	@echo "Generating: $@"
	sleep 5
	touch $@

clean:
	rm -rf *.txt
