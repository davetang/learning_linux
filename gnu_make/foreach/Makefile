# Define the batches, their IDs, and their target directories
BATCHES = batch1 batch2
batch1_ID = ID1
batch2_ID = ID2
batch1_DIR = dir_batch1
batch2_DIR = dir_batch2

# All directories and files
all: $(foreach batch, $(BATCHES), $($(batch)_DIR))

# Rule to create directories and download files for a batch
$(BATCHES):
	@echo "Downloading files for $@ using ID $($@_ID) into $($@_DIR)"
	mkdir -p $($@_DIR)
	echo --id $($@_ID) --output-dir $($@_DIR)

# Directory targets to group rules
# This section of the Makefile is a group rule that connects the directory targets (e.g., dir_batch1, dir_batch2) with their corresponding batch targets (batch1, batch2).
#
# $(foreach batch, $(BATCHES), $($(batch)_DIR)):
#
# This expands to the list of directory targets for all batches. For example, if BATCHES = batch1 batch2 and batch1_DIR = dir_batch1, batch2_DIR = dir_batch2, this expands to: dir_batch1 dir_batch2
#
# The % in a rule is a pattern-matching wildcard in Makefiles. In this context, % represents any target that matches the current rule. For example, if dir_batch1 is the target being evaluated, % expands to dir_batch1.
#
# Essentially, the following makes it such that the directories are dependent on the batches
$(foreach batch, $(BATCHES), $($(batch)_DIR)): %: $(BATCHES)
	@true

# @true runs the true command, which does nothing and always succeeds. It effectively acts as a placeholder to satisfy the Makefile syntax and prevent errors.

# Cleanup rule
clean:
	rm -rf $(foreach batch, $(BATCHES), $($(batch)_DIR))
