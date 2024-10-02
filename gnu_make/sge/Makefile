.PHONY: all
SHELL := /bin/bash

FILES := 1.txt 2.txt 3.txt 4.txt
all: $(FILES) merged.txt

%.txt:
	@echo "Generating: $@"
	sleep 5
	echo $(basename $@) > $@

merged.txt: $(FILES)
	cat $^ | sort > $@

clean:
	rm -rf *.txt
