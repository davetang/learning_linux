## Using strace

The `strace` command line tool traces system calls and signals, allowing you to
"attach" to a process and find out what is going on in real time. Every
application uses system calls to request the Linux kernel to perform tasks such
as opening a network socket, reading and writing a file, or creating a child
process. Below are some system calls (but many are available):

* `open()` - Create or open files.
* `read()` - Read from a file descriptor.
* `write()` - Write to a file.
* `connect()` - Open a connection.
* `futex()` - Wait or wake up threads when a condition becomes true (blocking
  lock).

The following command attaches to the running process `19419` using `-p` and
prints out any system calls that are happening. The `-s` flag sets the message
output size to 128 bytes.

```console
sudo strace -s 128 -p 19419
# strace: Process 19419 attached
# --snip--
# accept4(5, {sa_family=AF_INET, sin_port=htons(64221), sin_addr=inet_addr("172.28.128.1")},
# [16], SOCK_CLOEXEC) = 9
# --snip--
# recvfrom(9, "GET / HTTP/1.1\r\nHost: 172.28.128"..., 8192, 0, NULL, NULL) = 82
# getpeername(9, {sa_family=AF_INET, sin_port=htons(64221), sin_addr=inet_addr("172.28.128.1")},
# [16]) = 0
# --snip--
# sendto(9, "HTTP/1.1 200 OK\r\nServer: gunicorn/20.0.4\r\nDate: Mon, 01 Feb 2022 22:03:12 GMT\r\
# nConnection: close\r\nContent-Type: text/html; chars"..., 160, 0, NULL, 0) = 160
# sendto(9, "<h1 style='color:green'>Greetings!</h1>", 39, 0, NULL, 0) = 39
# --snip--
# write(1, "172.28.128.1 - - [01/Feb/2022:21"..., 88) = 88
# close(9) = 0
# --snip--
```

The `accept4` system call created a new connection from IP address 172.28.128.1
and returned file descriptor 9.

The `recvfrom` system call receives an HTTP GET request from a socket with file
descriptor 9.

The first `sendto` system call sends an HTTP header response from the web
server back over the socket. The following `sendto` system call transmits the
body of the HTTP GET response back to the socket as well.

The `write` system call writes what appears to be a `syslog` line to file
descriptor 1. Finally, the `close` system call is executed, closing the
previous socket file descriptor 9, which closes the network connection. This is
a typical transaction between an HTTP client and an HTTP server for a GET
request.

The summary flag (`-c`) for `strace` can provide an overview of what system
calls are being executed, how long each one is taking, and any errors that
those calls return. Once the command is run, it will pause in the foreground
while it collects data and results will be shown after stopping the command
(CTRL+C). The longer is runs, the more data it will accumulate. The summary
will provide a `% time` column that shows the percentage of time each call made
up during the trace capture. The `calls` column will show how many times the
system call was executed. The `errors` column will show the number errors of a
system call. The syscall (`-e`) flag will only track specific system calls and
can be used to focus on the errors.

The follow (`-f`) flag can be used to follow any new processes created (forked)
from the parent.

The output (`-o`) flag can store the trace output.

## [A zine about strace](https://jvns.ca/blog/2015/04/14/strace-zine/).

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

Check out [Julia's blog](https://jvns.ca/categories/strace/) for more posts on
`strace`.

## Related

See `ltrace`, which is like `strace` but it reports on dynamic library calls
made. The `dtrace` framework is also like `strace` but traces kernel-level
issues as well.
