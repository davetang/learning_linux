.PHONY: all clean
SHELL := /bin/bash

all: hello multiline silent errors setting_vars canned_demo

# --------------------------------------------------
# Basic recipe
# --------------------------------------------------

# A recipe is the list of shell commands under a rule that Make executes to
# build the target. Each line in a recipe is run in its own shell.
hello:
	echo "Hello from a recipe!"

# --------------------------------------------------
# Multiline commands
# --------------------------------------------------

# Because each line runs in a separate shell, changing directory or setting a
# variable on one line has no effect on the next. Use backslash continuation
# or semicolons with && to chain commands in a single shell invocation.
multiline:
	@echo "--- separate shells (cd is lost) ---"
	cd /tmp
	pwd
	@echo "--- single shell with backslash continuation ---"
	@cd /tmp && \
		pwd

# --------------------------------------------------
# Silencing and echoing
# --------------------------------------------------

# By default Make prints (echoes) each command before running it.
# Prefix a line with @ to suppress echoing of that line.
# Prefix a line with - to ignore errors from that line.
silent:
	@echo "This line is silent (prefixed with @)"
	echo "This line is echoed by Make before running"

# --------------------------------------------------
# Error handling in recipes
# --------------------------------------------------

# By default Make stops at the first command that exits non-zero.
# Prefix a line with - to tell Make to ignore errors on that line.
errors:
	@echo "--- ignoring a failing command with - prefix ---"
	-false
	@echo "Make continued past 'false' because of the - prefix"

# --------------------------------------------------
# Passing Make variables to recipes
# --------------------------------------------------

GREETING := Hello
NAME := World

setting_vars:
	@echo "$(GREETING), $(NAME)!"
	@echo 'Make expands $$(GREETING) before the shell sees it'
	@SHELL_VAR="I am a shell variable"; echo "$$SHELL_VAR"

# --------------------------------------------------
# Canned recipes (define / endef)
# --------------------------------------------------

# A canned recipe is a reusable sequence of commands stored in a variable
# using define/endef. This avoids repeating the same commands across multiple
# rules.
# https://www.gnu.org/software/make/manual/html_node/Canned-Recipes.html

define log_start
	@echo "=== Starting: $@ ==="
	@date
endef

define log_end
	@date
	@echo "=== Finished: $@ ==="
endef

# A canned recipe can also contain multiple commands
define build_steps
	@echo "Step 1: compiling $@"
	@echo "Step 2: linking $@"
	@echo "Step 3: done with $@"
endef

canned_demo: canned_target_a canned_target_b
	@echo "Both targets built"

canned_target_a:
	$(log_start)
	$(build_steps)
	$(log_end)

canned_target_b:
	$(log_start)
	$(build_steps)
	$(log_end)

# --------------------------------------------------
# Clean
# --------------------------------------------------

clean:
	@echo "Nothing to clean in this demo"
