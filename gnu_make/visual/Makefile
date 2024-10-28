# Simple Makefile Example

# Default target
all: build test clean

# Build target
build: compile link
	@echo "Building the project..."

# Compile target
compile: init
	@echo "Compiling source files..."

# Link target
link: init
	@echo "Linking objects..."

# Test target
test: build
	@echo "Running tests..."

# Clean target
clean:
	@echo "Cleaning up..."

# Init target (independent target)
init:
	@echo "Initializing the build environment..."
