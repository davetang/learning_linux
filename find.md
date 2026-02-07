## Search for files in a directory hierarchy

`find` recursively walks a directory tree, evaluating expressions against each
file and acting on the results. Unlike `ls` or shell globbing, `find` descends
into all subdirectories by default, understands file metadata (permissions,
timestamps, ownership, size), and can execute commands on matches.

```
find [path...] [expression]
```

Expressions are evaluated left-to-right. Each expression is a **test** (returns
true/false), an **action** (e.g., `-print`, `-delete`), or an **operator**
(`-and`, `-or`, `!`). When no action is given, `-print` is implied.

Some new `find` tricks I learned from [how to search for files in
Linux](https://www.freecodecamp.org/news/how-to-search-files-effectively-in-linux/)
and expanded on.

### Finding by name

The `-name` test matches the filename (not the full path) against a shell glob
pattern. It is case-sensitive; use `-iname` for case-insensitive matching.
**Always quote the pattern** to prevent the shell from expanding it before
`find` sees it.

```console
find /etc -name "*.conf"
find . -iname "readme*"
```

### Finding by type

Use `-type` to match specific file types:

| Flag | Meaning          |
|------|------------------|
| `f`  | Regular file     |
| `d`  | Directory        |
| `l`  | Symbolic link    |
| `b`  | Block device     |
| `c`  | Character device |
| `s`  | Socket           |
| `p`  | Named pipe       |

```console
find /var/log -type f -name "*.log"
find . -type d -empty
```

### Finding by permission

Search for files with a specific permission using `-perm`. The mode can be
specified as octal or symbolic.

```console
find . -perm 755
find . -perm u=rwx,go=rx
```

Search for files without a specific permission using `! -perm`.

```console
find . ! -perm 755
```

The exclamation mark works for every other expression. The example below finds
items that are not files, such as directories or symbolic links.

```console
find . ! -type f
```

Use `-perm -mode` (dash prefix) to find files where **all** of the specified
permission bits are set (files may have additional bits). Use `-perm /mode`
(slash prefix) to find files where **any** of the specified bits are set.

```console
# files where the owner, group, AND others all have execute set
find . -perm -111

# files where the owner, group, OR others have write set
find . -perm /222

# find world-writable files
find / -type f -perm -o=w 2>/dev/null

# find setuid executables
find /usr -type f -perm -4000
```

### Finding by size

Use `-size` with a `+` (greater than), `-` (less than), or exact value. Common
suffixes: `c` (bytes), `k` (kibibytes), `M` (mebibytes), `G` (gibibytes).

```console
# files larger than 100 MB
find / -type f -size +100M

# files smaller than 1 kB
find . -type f -size -1k

# empty files (equivalent to -empty for regular files)
find . -type f -size 0
```

### Finding by time

There are three timestamp categories, each with a minutes (`-Xmin`) and days
(`-Xtime`) variant:

| Timestamp  | Minutes  | Days     | Meaning              |
|------------|----------|----------|----------------------|
| Access     | `-amin`  | `-atime` | Last read            |
| Modify     | `-mmin`  | `-mtime` | Content last changed |
| Change     | `-cmin`  | `-ctime` | Metadata last changed (permissions, owner) |

Each accepts `+n` (more than n ago), `-n` (less than n ago), or `n` (exactly n
ago). For `-Xtime`, `n` counts in 24-hour periods.

```console
# files accessed in the last 20 minutes
find . -amin -20

# files modified more than 7 days ago
find . -type f -mtime +7

# files changed in the last 24 hours
find . -type f -mtime 0
```

Use `-newer` to find files that were modified more recently than a reference
file. This is useful for finding what changed since a known point in time (e.g.,
since the last backup or deployment).

```console
find . -newer README.md
```

You can create an arbitrary reference timestamp with `touch -t`:

```console
# find files modified since 1 Jan 2024
touch -t 202401010000 /tmp/ref
find . -newer /tmp/ref
rm /tmp/ref
```

### Finding empty files or directories

```console
find . -empty
find . -type f -empty
find . -type d -empty
```

### Limiting search depth

Use `-maxdepth` and `-mindepth` to control how deep `find` descends. These
must appear **before** other expressions.

```console
# only the current directory (no subdirectories)
find . -maxdepth 1 -type f

# only in subdirectories, not the current directory itself
find . -mindepth 1 -maxdepth 2 -type d
```

### Combining expressions

Expressions are implicitly joined with `-and`. Use `-or` for alternatives and
parentheses (escaped) for grouping. The `!` operator negates the next
expression.

```console
# .sh or .bash files
find . \( -name "*.sh" -or -name "*.bash" \) -type f

# files that are neither .log nor .tmp
find . -type f ! -name "*.log" ! -name "*.tmp"
```

### Regular expressions

Use `-regextype posix-extended -regex expr` for regular expressions. The
pattern is matched against the **entire path** (not just the filename), so it
must account for the leading `./` or `/`. The default engine uses Emacs Regular
Expressions, so use `posix-extended` for more regex support.

```console
find . -regextype posix-extended -regex "./[abcABC]{3}"

# match files ending in .log or .txt
find . -regextype posix-extended -regex ".*\.(log|txt)"
```

### Skipping directories with -prune

`-prune` stops `find` from descending into a matched directory. It is evaluated
as an action (always returns true), so combine it with `-or` to continue
matching other files.

```console
# search everywhere except .git directories
find . -name .git -prune -or -type f -print

# skip multiple directories
find . \( -name node_modules -or -name .git -or -name __pycache__ \) -prune -or -type f -print
```

### Acting on results with -exec

Use `-exec` to run a command on each match. `{}` is replaced with the current
filename. The command must end with `\;` (one invocation per file) or `+`
(batch as many filenames as possible into one invocation, like `xargs`).

```console
# print file details
find . -name "*.conf" -exec ls -lh {} \;

# batch mode (faster — fewer process spawns)
find . -name "*.log" -exec grep -l "ERROR" {} +

# delete old temp files (prompts for each)
find /tmp -type f -name "*.tmp" -mtime +30 -ok rm {} \;
```

`-ok` works like `-exec` but prompts for confirmation before running each
command.

### Deleting matches

The `-delete` action removes matching files. It implies `-depth` (process
directory contents before the directory itself). **Always test with `-print`
first.**

```console
# preview what would be deleted
find . -name "*.bak" -print

# then delete
find . -name "*.bak" -delete
```

### Custom output with -printf

The `-printf` action gives full control over the output format. Useful format
specifiers:

| Specifier | Meaning                            |
|-----------|------------------------------------|
| `%p`      | Filename (full path)               |
| `%f`      | Basename (filename only)           |
| `%s`      | File size in bytes                 |
| `%t`      | Last modification time             |
| `%u`      | Owner username                     |
| `%m`      | Permission bits (octal)            |
| `%h`      | Directory containing the file      |

```console
# list files with size and modification time
find . -type f -printf "%s\t%t\t%p\n"

# list permission and owner for all .sh files
find . -name "*.sh" -printf "%m %u %p\n"
```

### Tips

* **Quote glob patterns** — `find . -name *.log` breaks if there are `.log`
  files in the current directory because the shell expands the glob before
  `find` runs. Always use `find . -name "*.log"`.
* **Use `+` over `\;`** — `-exec cmd {} +` batches arguments and is
  significantly faster than `-exec cmd {} \;` for commands that accept multiple
  filenames (e.g., `grep`, `chmod`, `chown`).
* **Suppress permission errors** — append `2>/dev/null` when searching from `/`
  to hide "Permission denied" noise.
* **Prefer `-delete` over `-exec rm`** — `-delete` is safer (it implies
  `-depth`) and faster (no subprocess per file).
* **Combine with xargs for more control** — when `-exec` is not flexible
  enough, pipe through `xargs`. Use `-print0` with `xargs -0` to handle
  filenames containing spaces or special characters.

```console
find . -type f -name "*.log" -print0 | xargs -0 du -ch | tail -1
```
