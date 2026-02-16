# README

In GNU Make, a **recipe** is the set of shell commands that Make executes to update a target. Recipes appear indented under a rule and each line must begin with a tab character (not spaces).

```makefile
target: prerequisites
	command1
	command2
```

See the [GNU Make manual on recipes](https://www.gnu.org/software/make/manual/html_node/Recipes.html) for the full reference.

## Key concepts

### Each line is a separate shell

By default, Make runs each recipe line in its own shell. This means `cd`, shell variable assignments, and other state do not carry over between lines.

```makefile
broken:
	cd /tmp
	pwd          # prints the original directory, NOT /tmp

working:
	cd /tmp && pwd   # prints /tmp
```

Use backslash (`\`) at the end of a line to continue the command in the same shell:

```makefile
also_working:
	cd /tmp && \
		pwd
```

### .ONESHELL

GNU Make 3.82+ supports the `.ONESHELL:` directive, which runs the entire recipe in a single shell invocation. This lets you write multi-line recipes that share state naturally.

```makefile
.ONESHELL:
my_target:
	cd /tmp
	pwd          # now this prints /tmp
```

**Note:** `.ONESHELL` is a global directive — it affects **all** recipes in the Makefile, not just the one below it. Because of this, it cannot be mixed with demos that rely on separate-shell behavior. Use it in Makefiles where you want all recipes to share shell state.

### Line prefixes

Recipe lines support three special prefixes:

| Prefix | Effect |
|--------|--------|
| `@` | Suppress echoing of the command |
| `-` | Ignore errors (non-zero exit) from the command |
| `+` | Run the command even under `make -n` (dry run) |

These can be combined, e.g. `-@command` silences and ignores errors.

### Canned recipes (define / endef)

A **canned recipe** is a reusable sequence of commands stored in a variable using `define`/`endef`. This is useful when multiple rules need to execute the same commands — instead of duplicating them, you define them once and expand them with `$(name)`.

```makefile
define log_start
	@echo "=== Starting: $@ ==="
	@date
endef

define log_end
	@date
	@echo "=== Finished: $@ ==="
endef

target_a:
	$(log_start)
	@echo "Building target_a"
	$(log_end)

target_b:
	$(log_start)
	@echo "Building target_b"
	$(log_end)
```

Automatic variables like `$@` inside a canned recipe are expanded when the recipe runs, so they refer to the calling rule's target.

See the [GNU Make manual on canned recipes](https://www.gnu.org/software/make/manual/html_node/Canned-Recipes.html) for more details.

### Variable expansion

Make expands `$(VAR)` and `${VAR}` in recipes **before** passing them to the shell. To use a literal `$` in shell commands (for shell variables, `awk`, etc.), escape it as `$$`.

```makefile
demo:
	@echo "Make variable: $(MY_VAR)"
	@SHELL_VAR="hello"; echo "Shell variable: $$SHELL_VAR"
```
