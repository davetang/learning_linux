.PHONY: all

all: check_version echo_stuff scoping
scoping: scoping_global scoping_local scoping_check pattern

need := 3.81
ok := $(filter $(need),$(firstword $(sort $(MAKE_VERSION) $(need))))

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
override USER := Mr. President
echo_stuff:
	@echo Hello $(USER) your home directory is $(HOME)
	@echo this Makefile was created on $(today)

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

