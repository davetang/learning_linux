## Using strace

Notes from [A zine about strace](https://jvns.ca/blog/2015/04/14/strace-zine/).

`strace` is a program that let's you inspect what a program is doing without a
debugger, looking at the source code, or even knowing the programming language
at all. For example, `strace` can let you know what config file `bash` opens
when it starts (`.bashrc`). But first we need a little background.

System calls are the API for your operating system. You can use `open`, `read`,
and `write` to work with files; `connect`, `send`, and `recv` to work with
networks. Every program uses system calls to manage memory, write files, etc.

Create a test file.

    echo hello > test.txt

Run `strace ls test.txt` to get started.

    execve("/usr/bin/ls", ["ls", "test.txt"], [/* 70 vars */]) = 0

* `execve` is the name of the system call and is used to start programs
* `("/usr/bin/ls", ["ls", "test.txt"], [/* 70 vars */])` are the system call's
arguments, which in this case are a program to start and the arguments to start
it with
* `0` is the return value

Below is an example of an `open` system call.

    open("/etc/ld.so.cache", O_RDONLY|O_CLOEXEC) = 3

* `open` is the system call name
* `"/etc/ld.so.cache"` is the file to open
* `O_RDONLY|O_CLOEXEC)` open the file read-only bitwise-or'd with the close-on-exec flag
* `3` is the file descriptor number

Internally, Linux tracks open files with numbers. You can see all the file
descriptors for process ID 42 and what they point to by running:

    ls -l /proc/42/fd

Below is an example from `strace` when a program reads from a file

    read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\360\25\0\0\0\0\0\0"..., 832) = 832

The `3` is the file descriptor, followed by what was read, and the number of
bytes read (832).

Read the man page for more information.

    man 2 open

### Examples

Find out what configuration files a program is using.

```bash
strace -f -e open ls test.txt

open("/etc/ld.so.cache", O_RDONLY|O_CLOEXEC) = 3
open("/lib64/libselinux.so.1", O_RDONLY|O_CLOEXEC) = 3
open("/lib64/libcap.so.2", O_RDONLY|O_CLOEXEC) = 3
open("/lib64/libacl.so.1", O_RDONLY|O_CLOEXEC) = 3
open("/lib64/libc.so.6", O_RDONLY|O_CLOEXEC) = 3
open("/lib64/libpcre.so.1", O_RDONLY|O_CLOEXEC) = 3
open("/lib64/libdl.so.2", O_RDONLY|O_CLOEXEC) = 3
open("/lib64/libattr.so.1", O_RDONLY|O_CLOEXEC) = 3
open("/lib64/libpthread.so.0", O_RDONLY|O_CLOEXEC) = 3
open("/proc/filesystems", O_RDONLY)     = 3
open("/usr/lib/locale/locale-archive", O_RDONLY|O_CLOEXEC) = 3
test.txt
+++ exited with 0 +++
```

Find out what a program is writing (such as logs).

```bash
strace -f -e write cat test.txt


write(1, "hello\n", 6hello
)                  = 6
+++ exited with 0 +++
```

Find out which machine a program is sending network requests to by using `connect`.

```bash
strace -e connect wget -q https://jvns.ca/strace-zine-portrait.pdf
```

Use `sendto` and `recvfrom` to find out what is being sent over a network.

Find out which commands are causing problems in a script.

    strace -f -e execve ./script.pl

If a program start subprocesses, include the `-f` flag.

You can `strace` a program that has already started by finding its process ID
and then including it with `-p`.

    strace -p PID

Use `-o strace_output.txt` to output to a file.

Get more information on SSH.

    strace -f -o ssh_out.txt ssh -T git@github.com

Check out [Julia's blog](https://jvns.ca/categories/strace/) for more posts on `strace`.
