.PHONY: all

all: my_symlink

my_symlink: dep.txt
	DS=$(shell date +%Y%m%d_%H%M%S) \
		&& cat $< > $$DS \
		&& ln -fs $$DS $@

clean:
	rm my_symlink 20*
