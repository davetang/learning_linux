.PHONY: all
SHELL := /bin/bash

all: first.txt second.txt third.txt fourth.txt

first.txt second.txt:
	@echo "Generating: $@"
	touch $@

third.txt fourth.txt: marker

marker:
	@echo "Run once for both third.txt and fourth.txt"
	touch third.txt fourth.txt marker

clean:
	rm -rf *.txt marker
