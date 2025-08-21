# A quick demo

# -------------------
# Variables
# -------------------
GREETING := "Hello from Make!"
DATE     := $(shell date +%F)
FILES    := file1.txt file2.txt result.txt

# -------------------
# Phony targets
# -------------------
.PHONY: all clean hello show-vars chain

# The "default" target (first in file)
all: hello $(FILES) chain show-vars
	@echo "All tasks are done!"

# -------------------
# Simple recipe
# -------------------
hello:
	@echo $(GREETING)

# -------------------
# Pattern rule
# Demonstrates how %.txt can be generated.
# $@ = target name, $< = first prerequisite
# -------------------
%.txt:
	@echo "Generating $@"
	@echo "This is $@ created on $(DATE)" > $@

# -------------------
# Explicit rule with multiple prerequisites
# -------------------
result.txt: file1.txt file2.txt
	@echo "Combining $^ into $@"
	@cat $^ > $@
	@echo "--- end of result ---" >> $@

# -------------------
# Showing variables
# -------------------
show-vars:
	@echo "Showing variables in Makefile"
	@echo "GREETING = $(GREETING)"
	@echo "DATE     = $(DATE)"
	@echo "FILES    = $(FILES)"

# -------------------
# A chain of dependencies
# -------------------
chain: step3
	@echo "Running final step (target: $@, prereq: $<)"
	@echo "Finished dependency chain!"

step3: step2
	@echo "Running step 3 (target: $@, prereq: $<)"

step2: step1
	@echo "Running step 2 (target: $@, prereq: $<)"

step1:
	@echo "Running step 1 (target: $@)"

# -------------------
# Cleanup
# -------------------
clean:
	@echo "Cleaning up..."
	@rm -f $(FILES)
