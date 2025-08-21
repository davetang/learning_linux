# Demonstrate = (recursive/late) versus := (simple/early)

.PHONY: all demo
all: demo

BAR := initial
SIMP := $(BAR)   # simple (:=) set now, so it does not change
REC = $(BAR)     # recursive (=) set later
BAR := changed   # overwrite BAR after defining REC and SIMP

NOW_EQ = $(shell date +%s)       # re-evaluated at each expansion
NOW_SIMPLE := $(shell date +%s)  # fixed at parse time

demo: print_vars time_eq2 time_simp2

print_vars:
	@echo '--- Late vs Early Binding -------------------------------'
	@echo "BAR          -> $(BAR)"
	@echo "SIMP  (:= )  -> $(SIMP)"
	@echo "REC   ( = )  -> $(REC)"
	@echo

# Chain the SIMPLE steps; value should be identical both times.
time_simp2: time_simp1
time_simp1:
	@echo '--- Snapshot (NOW_SIMPLE) --------------------------------'
	@echo "NOW_SIMPLE first:  $(NOW_SIMPLE)"
	@sleep 1
time_simp2:
	@echo "NOW_SIMPLE second: $(NOW_SIMPLE)"

# Chain the EQ steps so make expands them at different times.
time_eq2: time_eq1
time_eq1:
	@echo '--- Re-expansion vs Snapshot (NOW_EQ) --------------------'
	@echo "NOW_EQ first:  $(NOW_EQ)"
	@sleep 1
time_eq2:
	@echo "NOW_EQ second: $(NOW_EQ)"
	@echo
