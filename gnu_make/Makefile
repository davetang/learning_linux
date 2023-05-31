.PHONY: all

all: check_version echo_before_override echo_stuff scoping bams autovar iterate_list get_dir
scoping: scoping_global scoping_local scoping_check pattern

need := 3.81
ok := $(filter $(need),$(firstword $(sort $(MAKE_VERSION) $(need))))

DATADIR := data
RESULTDIR := result

fastas := $(wildcard $(DATADIR)/*.fa)

check_version:
	@echo Make version $(MAKE_VERSION) is $(if $(ok),,not) compatiable with this Makefile

# will quit if command is not present
assert-command-present = $(if $(shell command -v $1),,$(error '$1' missing and needed for this build))
# check for cat command
$(call assert-command-present,cat)

# user-defined functions
make_date = $1-$2-$3
today := $(call make_date,2022,09,15)

# environmental variables
# Run `export PACIFIC=ocean` in terminal
# We do not even need `export` as `PACIFIC=ocean` works too
echo_before_override:
	@echo Hello $(USER) your home directory is $(HOME) before override
	@echo This env does not exist [$(DOESNOTEXIST)]
	@echo Exported env PACIFIC=[$(PACIFIC)]

# https://stackoverflow.com/questions/10858261/how-to-abort-makefile-if-variable-not-set
# use error to exit if variable is not set
ifndef PACIFIC
$(error Variable PACIFIC is not set)
endif

# even without override, $(HOME) is set as below
HOME := /home/sweet/home
override USER := Mr. President
echo_stuff:
	@echo Hello $(USER) your home directory is $(HOME) after override
	@echo this Makefile was created on $(today)
	@echo with parentheses $(fastas)
	@echo with braces ${fastas}
	@echo ${fastas2}

VAR = global scope
scoping_global:
	@echo In $@ VAR is $(VAR)

scoping_local: VAR = local scope
scoping_local:
	@echo In $@ VAR is $(VAR)

scoping_check:
	@echo In $@ VAR is $(VAR)

pattern:
	@echo In $@ VAR is $(VAR)

# VAR is set for any target beginning with p and followed by anything else (%
# is like *)
p%: VAR = set with wildcard

# this uses all the FASTAs as prereqs for each BAM file
# $(RESULTDIR)/%.bam: $(fastas)
# 	@echo $@ $^
#
# this is what I want
$(RESULTDIR)/%.bam: $(DATADIR)/%.fa
	@echo $@ $^

# https://www.gnu.org/software/make/manual/html_node/Text-Functions.html
# https://stackoverflow.com/questions/1633527/wildcard-targets-in-a-makefile
# $(patsubst pattern,replacement,text)
bams: $(patsubst %, $(RESULTDIR)/%.bam, $(basename $(notdir $(fastas)) .fa))
	@echo $@ $^

# this works for iterating over a list but I want to use a Makefile approach
iterate_list:
	@echo -e; \
	for f in $(fastas); \
		do echo $$f; \
	done

# https://www.gnu.org/software/make/manual/html_node/Automatic-Variables.html
# https://stackoverflow.com/questions/12284584/can-i-obtain-just-the-second-prerequisite-in-gnu-make
NUM = one two three four five six seven eight nine ten
.PHONY: $(NUM)
autovar: $(NUM)
	@echo -e
	@echo $$\@ is the name of the target: $@
	@echo $$\< is the name of the first prereq: $<
	@echo $$\^ is the name of all prereqs: $^
	@echo $$\? is the name of all prereqs newer than the target: $?
	@echo $$\(word 2,$$\^\) is the second prereq: $(word 2,$^)
	@echo $$\(word 7,$$\^\) is the seventh prereq: $(word 7,$^)
	@echo $$\(filter-out $$\<\,$$\^\) filters out the first prereq: $(filter-out $<,$^)

# used to test whether $(dir) can return deeper levels
$(DATADIR)/test/blah:
	@echo blah

# sometimes a tool needs the name of the directory containing the necessary
# files; use $(dir) to get it
get_dir: $(DATADIR)/test/blah
	@echo $(dir $<)
