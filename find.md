## Search for files in a directory hierarchy

Some new `find` tricks I learned from [how to search for files in
Linux](https://www.freecodecamp.org/news/how-to-search-files-effectively-in-linux/)
and expanded on.

Recall the `find` syntax.

    find [-H] [-L] [-P] [-D debugopts] [-Olevel] [path...] [expression]

Search for files with a specific permission using `-perm`.

```console
find . -perm 755
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

Use `newer` to find files that were modified more recently than some file.

```console
find . -newer README.md
```

Find file/s last accessed `n` minutes ago using `-amin`, where:

* `+n` - for greater than n.
* `-n` - for less than n.
* `n`  - for exactly n.

```console
find . -amin -20
```

Find empty files or directories.

```console
find . -empty
```

Use `-regextype posix-extended -regex expr` for regular expressions. The
default engine uses the Emacs Regular Expressions, so use `posix-extended` for
more regex support.

```console
find . -regextype posix-extended -regex "./[abcABC]{3}"
```
