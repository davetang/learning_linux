# Order-only prerequisites
#
# We need a build directory to exist before writing output, but we don’t want Make to rebuilt just because the directory timestamp changed.
#
.PHONY: all clean

all: build/output.txt
	@echo "All done."

# Normal rule: output depends on input.txt
# Also requires the build directory, but as order-only (| build)
# If build has a later timestamp, build/output.txt is not rebuilt
build/output.txt: input.txt | build
	@echo "Building $@ from $<"
	cp $< $@

# Order-only prerequisite: just make sure dir exists
build:
	@echo "Creating directory $@"
	mkdir -p $@

# Input file will be created if missing
input.txt:
	@echo "This is the input file." > $@

# Clean
clean:
	@echo "Cleaning up..."
	rm -rf build input.txt
