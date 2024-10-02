# Originally I wanted to create a list of files with unknown names
# Then after creating them, I wanted Make to not re-run the step
# But perhaps this is not possible and bad practice to not know the targets beforehand
# Because imagine the case where 2 files are created but we expected 5
#
# The following is not ideal as once $(FILES) has been created, Make will not re-run %.txt even if I've made changes
.PHONY: all
SHELL := /bin/bash

FILES := 1.txt 2.txt 3.txt
MORE_FILES := $(shell cat files_to_create.csv | cut -f1 -d',')
all: $(FILES) $(MORE_FILES) final.txt

%.txt:
	@echo "Generating: $@"
	touch $@

# use variable for dependency
final.txt: $(FILES) $(MORE_FILES)
	touch $@

clean:
	rm -rf *.txt
