.PHONY: all
SHELL := /bin/bash

# --------------------------------------------------
# File discovery
# --------------------------------------------------

# $(wildcard pattern)
# Expands to all files matching the pattern.
BAMS := $(wildcard *.bam)

# --------------------------------------------------
# Transformation functions
# --------------------------------------------------

# $(patsubst pattern,replacement,text)
# Pattern substitution on a list of words.
BAIS := $(patsubst %,%.bai,$(BAMS))

# $(addprefix prefix,names...)
# Adds a prefix to each word in the list.
BAMS2 := $(addprefix raw-,$(BAMS))

# $(addsuffix suffix,names...)
# Adds a suffix to each word in the list.
BAIS2 := $(addsuffix .bai,$(BAMS))

# $(subst from,to,text)
# Simple string substitution (not pattern based).
BAMS_UNDERSCORE := $(subst -,_,${BAMS})

# --------------------------------------------------
# Filtering and selection
# --------------------------------------------------

# $(filter pattern...,text)
# Keeps only words matching the pattern(s).
BAMS_FILTERED := $(filter sample1%,${BAMS})

# $(filter-out pattern...,text)
# Removes words matching the pattern(s).
BAMS_EXCLUDE := $(filter-out sample1%,${BAMS})

# $(sort list)
# Sorts words and removes duplicates.
BAMS_SORTED := $(sort ${BAMS} ${BAMS})

# --------------------------------------------------
# File name components
# --------------------------------------------------

# $(notdir names...)
# Strips directory path.
BASENAMES := $(notdir ${BAMS})

# $(dir names...)
# Extracts directory path.
DIRS := $(dir ${BAMS})

# $(basename names...)
# Strips suffix.
BASENAMES_NOEXT := $(basename ${BAMS})

# $(suffix names...)
# Extracts suffix.
SUFFIXES := $(suffix ${BAMS})

# --------------------------------------------------
# Iteration and shell commands
# --------------------------------------------------

# $(foreach var,list,text)
# Expands text once for each word in list.
# Here: wrap each BAM in brackets.
BAMS_BRACKETS := $(foreach f,${BAMS},[${f}])

# $(shell command)
# Executes a shell command and captures output.
DATE := $(shell date +%F)

# --------------------------------------------------
# Demo target
# --------------------------------------------------

all:
	@echo "BAMS            = ${BAMS}"
	@echo "BAIS            = ${BAIS}"
	@echo "BAMS2           = ${BAMS2}"
	@echo "BAIS2           = ${BAIS2}"
	@echo "BAMS_UNDERSCORE = ${BAMS_UNDERSCORE}"
	@echo "BAMS_FILTERED   = ${BAMS_FILTERED}"
	@echo "BAMS_EXCLUDE    = ${BAMS_EXCLUDE}"
	@echo "BAMS_SORTED     = ${BAMS_SORTED}"
	@echo "BASENAMES       = ${BASENAMES}"
	@echo "DIRS            = ${DIRS}"
	@echo "BASENAMES_NOEXT = ${BASENAMES_NOEXT}"
	@echo "SUFFIXES        = ${SUFFIXES}"
	@echo "BAMS_BRACKETS   = ${BAMS_BRACKETS}"
	@echo "DATE            = ${DATE}"
