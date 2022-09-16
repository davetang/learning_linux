Table of Contents
=================

   * [Expansion](#expansion)
      * [Arithmetic expansion](#arithmetic-expansion)
      * [Brace expansion.](#brace-expansion)
      * [Command substitution.](#command-substitution)
      * [<a href="https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html" rel="nofollow">Parameter expansion</a>](#parameter-expansion)
      * [Etc.](#etc)

Created by [gh-md-toc](https://github.com/ekalinin/github-markdown-toc)

## Expansion

The shell expands any qualifying characters on the command line before carrying
out a command. The `$` character introduces parameter expansion, command
substitution, or arithmetic expansion. The parameter name or symbol to be
expanded may be enclosed in braces, which are optional but serve to protect the
variable to be expanded from characters immediately following it which could be
interpreted as part of the name.

For the examples below, if you are using Vim, move the cursor to the line with
the command and type `:.w !bash` to run it.

### Arithmetic expansion

Only supports integers and a few operators but useful nonetheless.

```bash
echo $((2 ** 4 / 2 * 5 - 2 + 4))

echo $((9 / 5))
```

### Brace expansion.

Generate sequences.

```bash
echo {a..z}

# zero padded number iteration
echo {01..13}

# generate dates that you can use with mkdir
echo {2021..2022}-{01..12}
```

### Command substitution.

Extremely useful if you don't use this already.

```bash
file $(command -v curl)
```

### [Parameter expansion](https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html)

Substring expansion: `${parameter:offset:length}`.

```bash
letters=abcdefghijk ; echo ${letters:5:2}
```

Delete a pattern, useful for removing extensions.

```bash
infile=blah.fastq.gz ; echo ${infile%.f*q.gz}
infile=blah.fq.gz ; echo ${infile%.f*q.gz}

# cannot get it working with []
infile=blah.fq.gz ; echo ${infile%.f[ast]*q.gz}

# non-greedy
infile=blah.one.one.one ; echo ${infile%.one*}
# greedy
infile=blah.one.one.one ; echo ${infile%%.one*}
```

### Etc.

Suppress all expansions by using single quotes.

```bash
echo "$((2+2))"
echo '$((2+2))'
```

