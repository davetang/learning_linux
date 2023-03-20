# Log files

Modern Linux distributions use `systemd`, which has a log-collection mechanism
called the `journal` that collects log events from multiple sources like
`syslog`, `auth.log`, and `kern.log`. This makes is convenient to view and
search logs in a single stream.

Most system and application logs are stored in `/var/log` and the most useful
logs for troubleshooting are `syslog`, `auth.log`, `kern.log`, and `dmesg`.
These log file names may be different depending on the Linux distribution.

## `/var/log/syslog`

The `syslog` (or `messages` on Red Hat family distros) file contains general
global system messages. Below is an example indicating that log rotate has
finished.

    Jun 11 00:00:03 box systemd[1]: Finished Rotate log files.

The line begins with a timestamp, followed by the host (`box`), the process
(`systemd`) that is reporting the log event, and a text message. This
structured line format, also called `syslog`, is the default protocol for
logging on Linux.

## `/var/log/auth.log`

The `auth.log` (or `secure` on Red Hat family distros) file contains
information regarding authorisation and authentication events. This can be used
to investigate user logins, brute-force attacks, and to track a user's `sudo`
commands.

    Jan 15 20:57:35 box sshd[27162]: Invalid user aiden from 192.168.1.133 port 59876

The above message shows a failed login attempt over SSH for the user `aiden`
from the 192.168.1.133.

## `/var/log/kern.log`

The `kern.log` file contains kernel messages, such as hardware issues or
general information related to the kernel. The following log line shows the OOM
in action.

    Jan 16 19:18:47 box kernel: [2397.472979] Out of memory: Killed process 20371 (nginx) total-vm:571408kB, anon-rss:524540kB, file-rss:456kB, shmem-rss:8kB, UID:0 pgtables:1100kB oom_score_adj:1000

Process 20371 was killed because the system was running low on memory.

## `/var/log/dmesg`

The `dmesg` log contains bootup messages since the last boot time. Use `dmesg`
to view the kernel ring buffer in real time. It can show information after
bootup as well. Use `-T` to print human readable timestamps although the
timestamp could be inaccurate.

## Common `journalctl` Commands

A host using `systemd` stores all common logs in a single binary stream called
a journal, which is orchestrated by the `journald` daemon. Use `journalctl` to
access the journal, which is a handy troubleshooting tool since it combines
multiple logs together.

Use `-r` to show the newest lines first.

```console
sudo journalctl -r
```

Use `--since` to view logs within a certain time frame.

```console
sudo journalctl -r --since "2 hours ago"
```

Filter logs based on a systemd service name by using `-u`.

```console
sudo journalctl -r -u ssh
```

Use `-p` to choose the priority level using keywords like `info`, `err`, `debug`, or `crit`.

```console
# show error log
sudo journalctl -r -u ssh -p err
```

Use the pattern-matching flag `-g` to match messages (or just pipe to `grep`).

```console
sudo journalctl -r -u ssh -g "session opened"
```
