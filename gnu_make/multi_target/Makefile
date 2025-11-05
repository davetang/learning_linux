.PHONY: all clean
SHELL := /bin/bash

all: first.txt second.txt fifth.txt sixth.txt

# --------------------------------------------------
# Static multi-target rule
# --------------------------------------------------
# Both first.txt and second.txt are listed as targets.
# The recipe runs once per target; $@ expands to the current target name.
# make first.txt will create first.txt
first.txt second.txt:
	@echo "Generating: $@"
	touch $@

# --------------------------------------------------
# Grouped targets with "&:" (GNU Make 4.3+)
# --------------------------------------------------
# This syntax means the recipe is run *once* for all listed targets,
# without needing a separate marker file.
# Here we produce both fifth.txt and sixth.txt in a single recipe.
# if you type make fifth.txt, both files are created together
TARGETS := fifth.txt sixth.txt
$(TARGETS) &:
	@echo "Grouped target rule: generating $(TARGETS) (together)"
	touch $(TARGETS)

clean:
	rm -f *.txt marker
