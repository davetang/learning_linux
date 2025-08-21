# PHONY can be declared before the targets
# Use variables to avoid typing long targets
.PHONY: marker clean
SHELL := /usr/bin/bash

HOMEDIR := $(shell echo $$HOME)
MARKER  := $(HOMEDIR)/.local/share/R/my_package/marker

marker: $(MARKER)
$(MARKER):
	mkdir -p $(dir $@)
	touch $@

clean:
	rm -rf $(dir $(MARKER))
