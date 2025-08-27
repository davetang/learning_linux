CC      := gcc

# -Wall
# enable all useful warnings.
# -O2
# Optimisation level 2; optimise code for speed without taking a very long time to compile
CFLAGS  := -Wall -O2

.PHONY: clean

# --------------------------------------------------
# 1. Pattern rule (explicit)
# --------------------------------------------------
# take C source files (*.c), translate them to machine code, and write as an object files (*.o)
# any *.o file can be built from a *.c with the rule below
# -c is to compile only, i.e., do not link
%.o: %.c
	@echo "Pattern rule compiling $< -> $@"
	$(CC) $(CFLAGS) -c $< -o $@

# --------------------------------------------------
# 2. Implicit rule (built-in)
# --------------------------------------------------
# we defined how to make *.o from *.c, so here we just rely on the built-in implicit rule to build hello
# the linker combines objects and the stdio standard library into a single, self-contained binary
hello: main.o util.o
	@echo "Linking $@"
	$(CC) $(CFLAGS) $^ -o $@

# --------------------------------------------------
# 3. Example files
# --------------------------------------------------
# generate some files for this demo
main.c:
	@echo '#include <stdio.h>'                 >  $@
	@echo 'extern void util(void);'            >> $@
	@echo 'int main(){'                        >> $@
	@echo '    printf("Hello from main!\\n");' >> $@
	@echo '    util();'                        >> $@
	@echo '    return 0;'                      >> $@
	@echo '}'                                  >> $@

util.c:
	@echo '#include <stdio.h>'                 >  $@
	@echo 'void util(void){'                   >> $@
	@echo '    printf("Hello from util!\\n");' >> $@
	@echo '}'                                  >> $@

clean:
	rm -f hello *.o *.c
