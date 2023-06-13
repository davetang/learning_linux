# README

Playing around with [GNU Make](https://www.gnu.org/software/make/).

```bash
mkdir data; for i in {1..4}; do echo ${i} > data/${i}.fa; done
```

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
