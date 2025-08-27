.PHONY: all clean
SHELL := /bin/bash

all: first.txt second.txt third.txt fourth.txt fifth.txt sixth.txt

# --------------------------------------------------
# Example 1: Static multi-target rule
# --------------------------------------------------
# Both first.txt and second.txt are listed as targets.
# The recipe runs once per target; $@ expands to the current target name.
# make first.txt will create first.txt
first.txt second.txt:
	@echo "Generating: $@"
	touch $@

# --------------------------------------------------
# Example 2: Using a marker (sentinel file)
# --------------------------------------------------
# third.txt and fourth.txt both depend on "marker".
# The "marker" rule produces *both outputs at once*, plus the marker file.
third.txt fourth.txt: marker
marker:
	@echo "Run once for both third.txt and fourth.txt (and marker)"
	touch third.txt fourth.txt marker

# --------------------------------------------------
# Example 3: Grouped targets with "&:" (GNU Make 4.3+)
# --------------------------------------------------
# This syntax means the recipe is run *once* for all listed targets,
# without needing a separate marker file.
# Here we produce both fifth.txt and sixth.txt in a single recipe.
# if you type make fifth, both files are created together
fifth.txt sixth.txt &:
	@echo "Grouped target rule: generating $@ (together)"
	touch fifth.txt sixth.txt

clean:
	rm -f *.txt marker
