# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repository Is

A personal knowledge base of Linux administration notes and GNU Make examples. There is no build system, test suite, or linter — it is a collection of Markdown documentation and working Makefile demos.

## Repository Structure

- **Top-level `.md` files** — Notes on Linux topics (networking, disk management, cron, kernel, strace, troubleshooting, etc.)
- **`gnu_make/`** — GNU Make learning examples, each subdirectory demonstrates a specific concept:
  - `gnu_make/Makefile` — Main Makefile covering variables (recursive vs simply expanded), conditionals, automatic variables, pattern rules, `include`, scoping, built-in functions (`patsubst`, `wildcard`, `filter`, `dir`, `word`)
  - `gnu_make/alias/` — Using Make targets as aliases for long filenames
  - `gnu_make/symlink/` — Creating timestamped files with symlinks via Make
  - `gnu_make/wildcard/` — Dynamic file list creation with pattern rules
  - `gnu_make/debug/dragmap/` — Debugging Boost library paths (`CPPFLAGS`/`LDFLAGS`) via `config.mk` and `include`
- **`scripts/`** — Shell scripts (e.g., `backup.sh` for incremental/full backups using `pax`)
- **`tlcl2/`** — Notes from *The Linux Command Line* book

## Running GNU Make Examples

```bash
# Run the main Makefile (from gnu_make/ directory)
cd gnu_make && make

# Run a specific target
cd gnu_make && make autovar

# Run subdirectory examples
cd gnu_make/alias && make
cd gnu_make/symlink && make
cd gnu_make/wildcard && make

# Clean generated files in subdirectories
cd gnu_make/alias && make clean
cd gnu_make/symlink && make clean
cd gnu_make/wildcard && make clean
```

The main `gnu_make/Makefile` expects a `data/` directory with `.fa` files (already present) and creates output in a `result/` directory. It uses `SHELL := /usr/bin/bash`.

## Conventions

- Markdown files use console/bash fenced code blocks with example command output inline
- Makefiles use `@echo` to suppress command echoing and demonstrate concepts via printed output
- The `tool_versions` file is included by the main Makefile to set version variables
