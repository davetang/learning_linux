## Table of Contents

- [README](#readme)
  - [.PHONY](#phony)
  - [Variable assignment](#variable-assignment)
  - [Notes](#notes)
    - [Symlinks](#symlinks)

# README

Playing around with [GNU Make](https://www.gnu.org/software/make/).

```bash
mkdir data; for i in {1..4}; do echo ${i} > data/${i}.fa; done
```

## .PHONY

From
[SO](https://stackoverflow.com/questions/2145590/what-is-the-purpose-of-phony-in-a-makefile):

By default, Makefile targets are "file targets" - they are used to build files
from other files. Make assumes its target is a file, and this makes writing
Makefiles relatively easy:

```makefile
foo: bar
	create_one_from_the_other foo bar
```

However, sometimes you want your Makefile to run commands that do not represent
physical files in the file system. Good examples for this are the common
targets "clean" and "all". Chances are this isn't the case, but you may
potentially have a file named clean in your main directory. In such a case Make
will be confused because by default the clean target would be associated with
this file and Make will only run it when the file doesn't appear to be
up-to-date with regards to its dependencies.

These special targets are called phony and you can explicitly tell Make they're
not associated with files, e.g.:

```makefile
.PHONY: clean
clean:
	rm -rf *.o
```

Now `make clean` will run as expected even if you do have a file named clean.

In terms of Make, a phony target is simply a target that is **always
out-of-date**, so whenever you ask make <phony_target>, it will run,
independent from the state of the file system. Some common make targets that
are often phony are: all, install, clean, distclean, TAGS, info, check.

## Variable assignment

[What is the
difference?](https://stackoverflow.com/questions/448910/what-is-the-difference-between-the-gnu-makefile-variable-assignments-a) between:

1. VARIABLE = value

> Lazy set: Normal setting of a variable, but any other variables mentioned
  with the `value` field are recursively expanded with their value at the point
  at which the variable is used, not the one it had when it was declared.

```makefile
HELLO = world
HELLO_WORLD = $(HELLO) world!

# This echoes "world world!"
echo $(HELLO_WORLD)

HELLO = hello

# This echoes "hello world!"
echo $(HELLO_WORLD)
```

2. VARIABLE ?= value

> Immediate set: Setting of a variable with simple expansion of the values
  inside - values within it are expanded at declaration time.

3. VARIABLE := value

> Lazy set if absent: Setting of a variable only if it does not have a value.
  `value` is always evaluated when `VARIABLE` is accessed.

```makefile
HELLO = world
HELLO_WORLD := $(HELLO) world!

# This echoes "world world!"
echo $(HELLO_WORLD)

HELLO = hello

# Still echoes "world world!"
echo $(HELLO_WORLD)

HELLO_WORLD := $(HELLO) world!

# This echoes "hello world!"
echo $(HELLO_WORLD)
```

4. VARIABLE += value

> Append: Appending the supplied value to the existing value (or setting to
  that value if the variable didn't exist)

```makefile
HELLO_WORLD = hello
HELLO_WORLD += world!

# This echoes "hello world!"
echo $(HELLO_WORLD)
```

## Notes

When using `$` in a Makefile, it might be processed as a special character, e.g., Make might interpret it as a variable. Therefore, use `$$` instead.

### Symlinks

When the target is a symlink, Make does not look at the mtime of the symlink but rather, it looks at the mtime of the linked file. Therefore, if your Makefile (or dependency) has a more recent mtime, this step will always run until the linked file is updated with a more recent mtime.
