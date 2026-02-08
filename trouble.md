Table of Contents
=================

* [Troubleshooting hosts](#troubleshooting-hosts)
   * [General approach](#general-approach)
   * [Scenario: High Load Average](#scenario-high-load-average)
   * [Scenario: High CPU Usage](#scenario-high-cpu-usage)
   * [Scenario: High Memory Usage](#scenario-high-memory-usage)
   * [Scenario: OOM Killer](#scenario-oom-killer)
   * [Scenario: High iowait](#scenario-high-iowait)
   * [Scenario: Out of Disk Space](#scenario-out-of-disk-space)
   * [Scenario: Inode Exhaustion](#scenario-inode-exhaustion)
   * [Scenario: Read-Only Filesystem](#scenario-read-only-filesystem)
   * [Scenario: Hostname Resolution Failure](#scenario-hostname-resolution-failure)
   * [Scenario: Network Unreachable](#scenario-network-unreachable)
   * [Scenario: Connection Refused](#scenario-connection-refused)
   * [Scenario: Service Failure](#scenario-service-failure)
   * [Scenario: Zombie Processes](#scenario-zombie-processes)
   * [Scenario: Permission Denied](#scenario-permission-denied)

# Troubleshooting hosts

Notes from Chapter 10 of [DevOps for the
Desperate](https://nostarch.com/devops-desperate).

Troubleshooting is the process of analysing the system and rooting out
potential causes of trouble. Debugging is the process of discovering the cause
of trouble and possibly implementing steps to remedy it. Debugging can be
considered a subset of troubleshooting.

## General approach

A systematic approach to troubleshooting avoids wasted effort:

1. **Gather symptoms** — what is the user actually experiencing? Slow response,
   errors, total outage?
2. **Check the obvious first** — is the service running? Is the disk full? Is
   the network up? Simple checks eliminate common causes quickly.
3. **Reproduce the issue** — can you trigger it on demand? A reproducible
   problem is far easier to diagnose.
4. **Narrow the scope** — use `uptime`, `free`, `df`, `ss`, and `journalctl` to
   quickly classify whether the bottleneck is CPU, memory, disk, network, or
   application-level.
5. **Read the logs** — most answers are in the logs. Start with `journalctl -xe`
   for recent systemd messages or check application-specific logs under
   `/var/log/`.
6. **Change one thing at a time** — make a single change, test, and observe.
   Changing multiple variables at once makes it impossible to know which fix
   worked.
7. **Document what you find** — record the root cause and the fix so the next
   person (or future you) benefits.

A quick first-pass checklist:

```console
# System overview in one shot
uptime              # load average
free -h             # memory / swap
df -h               # disk space
ss -tlnp            # listening ports
journalctl -xe      # recent errors
```

## Scenario: High Load Average

Load average indicates how busy a host is and takes into account the CPU and
I/O. The load of a system is displayed in 1-minute, 5-minute, and 15-minute
averages. A high load does not always indicate that the host is in a degraded
state.

Use `uptime` to display how long a host has been running, the number of
logged-in users, and the system load in 1-minute, 5-minute, and 15-minute
averages. The 1-minute load average below is 8.05, while the 5-minute load
average is 1.01 indicating that the load has been increasing in the last 5
minutes.

```console
uptime
# 09:30:38 up 47 days, 31 min, 2 users, load average: 8.05, 1.01, 0.00
```

Use `top` to launch an interactive real-time dashboard showing system
information just as CPU usage, load average, memory, and process information.
This should identify the offending process to which you can further
investigate.

## Scenario: High CPU Usage

High CPU usage differs from high load average — load includes processes waiting
on I/O, while CPU usage only reflects compute-bound work.

Use `top` or `htop` and press `P` to sort by CPU. The `%CPU` column shows per-process
usage; values above 100% are possible on multi-core systems (100% per core).

```console
# Snapshot of the top CPU consumers
ps -eo pid,ppid,user,%cpu,%mem,comm --sort=-%cpu | head
#   PID  PPID USER     %CPU %MEM COMMAND
# 12345     1 root     99.0  1.2 cpu-hog
#   672     1 root      2.1  0.5 snapd
```

For per-core breakdown, use `mpstat` (from `sysstat`):

```console
mpstat -P ALL 1 5
# ...per-CPU stats over 5 seconds...
```

Once you identify the offending process, you can lower its priority with `renice`
or inspect what it is doing with `strace -p <pid>`.

## Scenario: High Memory Usage

The `free`, `vmstat`, and `ps` commands are useful for indicating how much
memory is being used and to find processes consuming a lot of memory. Note that
Linux uses memory for caches and buffers, so it may appear that memory is low
but the kernel can reallocate cached memory when necessary.

The output below indicates that the system has 981Mi of total memory and 838Mi
of memory is being used, with 95Mi free. The `buff/cache` indicates how much
memory is cached, which is used for fast retrieval; Linux tries to use all
system memory instead of letting it sit idle. However, when running low on
memory, the host will swap data out of memory and write it to disk.

If the `free` column for `Swap` is ever low, the host may be performing slower
than normal. With `free` use the information provided by `available` for
checking how much memory is actually available.

```console
free -hm
#               total        used        free      shared  buff/cache   available
# Mem:          981Mi       838Mi        95Mi       3.0Mi        47Mi        43Mi
# Swap:         1.0Gi       141Mi       882Mi
```

The `vmstat` command provides useful information about processes, memory, IO,
disks, and CPU activity. It can report data over a period of time by providing
two parameters: the delay (time delay between each poll) and count (number of
times to fetch data).

The `vmstat` report is divided into multiple categories that groups the
columns. The first row of data is an average of each statistic since the last
boot time. The `memory` and `swap` sections are useful for finding memory
issues.

Under the `swap` section are two columns: `si` (swapped in) and `so` (swapped
out). These columns indicate that memory is being moved to and from the disk.
There is usually a memory bottleneck when the host is low on memory and
swapping is occurring.

The `r` and `b` columns indicate the number of running (or waiting-to-run)
processes and the number of processes in uninterruptable sleep. If the number
in `b` is high, it may indicate that there are processes waiting on resources
like disk or network IO.

```console
vmstat 1 5
# procs ---------memory--------  --swap-- -----io---- -system- ---cpu--------
# r b    swpd   free buff  cache  si   so   bi    bo   in   cs us sy id wa st
# 2 0   54392  74068 7260 117804   0   10   84   432   81  158  3  1 96  0  0
# 1 0   54392  73864 7260 117852   0    0    8     0  379  104 44  0 56  0  0
# 1 2   54392  71768  484  38724 104    0  496   196  469  327 41  1 57  1  0
# 1 0   54392  71508  484  39768  20    0 1024     0  357   82 44  0 56  0  0
# 1 0   54392  71508  484  39768   4    0    0     0  370   43 46  0 54  0  0
```

Use `ps` to identify all current processes on the host. The `-efly` and
`--sort=-rss` flags below are used to show all the processes in long format.
The `RSS` (resident set size) column shows the amount of non-swappable physical
memory a process uses (in kilobytes), in descending numerical order. The
`memory-hog` command is using around 890MB of physical memory according to the
`RSS` column.

```console
ps -efly --sort=-rss | head
# S UID   PID PPID  C PRI  NI   RSS     SZ WCHAN STIME TTY TIME CMD
# R root  931 930  93  80   0 890652 209077 -    05:56 ?   ...  memory-hog
# S root  469   1   0 -40   - 18212  86454 -     Jan16 ?   ...  /sbin/multipathd
# S root  672   1   0  80   0 10420 233460 -     Jan16 ?   ...  /usr/lib/snapd
# S root  350   1   0  79  -1  7416  12919 -     Jan16 ?   ...  /lib/systemd
```

## Scenario: OOM Killer

When the system runs critically low on memory and swap, the kernel's
Out-Of-Memory (OOM) Killer selects and terminates processes to free memory and
keep the system alive. This often kills important services with little warning.

Check whether the OOM killer has been active:

```console
dmesg | grep -i "oom"
# [12345.678901] Out of memory: Killed process 4321 (my-app) total-vm:...

# Or via journalctl
journalctl -k | grep -i "oom"
```

Each process has an OOM score under `/proc/<pid>/oom_score` — higher scores mean
the process is more likely to be killed. You can influence this via
`oom_score_adj` (range -1000 to 1000):

```console
# Make a critical process less likely to be killed
echo -500 | sudo tee /proc/<pid>/oom_score_adj

# View current score
cat /proc/<pid>/oom_score
```

Prevention strategies:

* Add swap space or increase existing swap.
* Set memory limits on services via systemd (`MemoryMax=` in the unit file).
* Monitor memory trends so you can act before the OOM killer does.

## Scenario: High iowait

High iowait is when a host is spending a lot of time waiting for disk I/O. To
measure iowait, check the percentage of time that CPUs are idle because the
system has unfinished disk I/O requests that are blocking processes.
Significant iowait usually results in having an increased load and higher
reported CPU usage because the CPU is waiting and has less time to perform
other requests.

High iowait can indicate an aging, slow, or failing disk. Another culprit could
be an application that is performing heavy disk reads and writes. Slow
network-attached storage can also cause high iowait.

The `iostat` command reports CPU and I/O stats for devices. The first report
from `iostat` is from the last time the host was booted. The `-xz` flag shows
only active devices using an extended stat format. The `w/s` column shows that
the `vda` device is executing a lot of write requests per second. The CPU is
waiting on outstanding disk requests around 66.67% of the time (`%iowait`). The
`%util` (percent utilisation) shows that the disk is utilised at 100%.

```console
iostat -xz 1 20
# --snip--
# avg-cpu:  %user   %nice %system %iowait  %steal %idle
#            6.25    0.00   27.08   66.67    0.00  0.00
#
# Device             r/s    rkB/s      w/s     wkB/s   %util ...
# vda               0.00     0.00  1179.00 712388.00  100.00 ...
```

The `iotop` command displays I/O usage in a `top`-like format. The command
requires admin privileges and should be run in batch mode. Use the `-oPab`
flags to make `iotop` show only processes performing I/O with accumulative
stats in batch mode.

```console
sudo iotop -oPab
```

## Scenario: Inode Exhaustion

A filesystem can run out of inodes even when `df -h` shows free space. Each file
or directory consumes one inode, so millions of tiny files can exhaust the inode
table.

```console
# Check inode usage
df -i
# Filesystem      Inodes  IUsed   IFree IUse% Mounted on
# /dev/sda1      6553600 6553600       0  100% /

# Find directories with the most files
sudo find / -xdev -printf '%h\n' | sort | uniq -c | sort -rn | head
```

Symptoms look identical to "disk full" — writes fail with `No space left on
device` — but `df -h` shows plenty of space. Always check `df -i` as well.

Fix by removing unnecessary files (old session files, temp caches, stale logs).

## Scenario: Read-Only Filesystem

A filesystem may be remounted read-only by the kernel when it detects errors
(e.g., disk corruption or a failing drive). Writes will fail with `Read-only
file system`.

```console
# Check mount status
mount | grep ' / '
# /dev/sda1 on / type ext4 (ro,relatime)   <-- "ro" means read-only

# Check for filesystem errors in the kernel log
dmesg | grep -i "error\|readonly\|remount"
```

If the underlying disk is healthy, you can remount read-write:

```console
sudo mount -o remount,rw /
```

If errors are present, run a filesystem check (requires unmounting or booting
from a rescue disk):

```console
sudo fsck /dev/sda1
```

A read-only remount is often a sign of hardware trouble — check `smartctl` from
the `smartmontools` package to assess drive health.

## Scenario: Hostname Resolution Failure

The `/etc/resolv.conf` file provides information on what DNS servers to query
and includes any special options that are needed (like timeout or security).
The following comes from a typical Ubuntu host.

```
# This file is managed by man:systemd-resolved(8). Do not edit.
#
# This is a dynamic resolv.conf file for connecting local clients to the
# internal DNS stub resolver of systemd-resolved. This file lists all
# configured search domains.
#
# Run "resolvectl status" to see details about the uplink DNS servers
# currently in use.
#
# Third party programs must not access this file directly, but only through
# the symlink at /etc/resolv.conf. To manage man:resolv.conf(5) in a
# different way, replace this symlink by a static file or a different
# symlink.
#
# See man:systemd-resolved.service(8) for details about the supported
# modes of operation for /etc/resolv.conf.

nameserver 127.0.0.53
options edns0 trust-ad
```

The file is controlled by the `systemd-resolved` service provided by `systemd`.
The `nameserver` is where DNS requests are sent. If the local `resolves` does
not know a query, it will forward the request to an upstream DNS server.

The `options` keyword is used to set options. The `edns0` option enables
expanded features to the DNS protocol. The `trust-ad` or authenticated data
(AD) bit option will include the authenticated data on all outbound DNS queries
and preserve the authenticated data in the response. This will allow the client
and server to validate the exchange between each other and is part of a larger
set of extensions that add security to DNS.

The DNS server in the example is set to 127.0.0.53, which is a local resolver
that proxies any DNS request it does not know about. Each DNS server typically
will have an upstream server that it forwards unknown requests to. Use
`resolvectl` to interact with the local resolver.

The `dig` tool queries DNS servers and displays the results; just supply the
hostname to `dig`.

## Scenario: Out of Disk Space

Use `df` to display the free disk space on all mounted filesystems. Use `find`
to look for large files.

```console
sudo find / -type f -size +100M -exec du -ah {} + | sort -hr | head
```

Use `lsof` to list open files on a host and can be used to find a process
writing to a specific file.

## Scenario: Network Unreachable

When a host cannot reach other machines, work from the bottom of the network
stack upward: link, IP, routing, then DNS.

```console
# 1. Is the interface up?
ip link show
# 2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> ...   <-- look for UP

# 2. Does the interface have an IP?
ip addr show eth0

# 3. Can you reach the gateway?
ip route show              # find the default gateway
ping -c 3 <gateway-ip>

# 4. Can you reach an external IP? (bypasses DNS)
ping -c 3 8.8.8.8

# 5. Can you resolve names? (tests DNS)
ping -c 3 google.com
```

If step 4 works but step 5 fails, the problem is DNS (see Hostname Resolution
Failure below). If step 3 fails, the problem is local networking or the gateway
itself.

`traceroute` (or `mtr` for a continuous view) shows every hop between you and
the destination, helping pinpoint where packets are being dropped:

```console
traceroute 8.8.8.8

# mtr combines ping + traceroute into a live updating display
mtr 8.8.8.8
```

Also check whether a firewall is blocking traffic:

```console
sudo iptables -L -n -v      # legacy iptables
sudo nft list ruleset        # nftables (newer)
```

## Scenario: Connection Refused

Use `curl` to check whether a web server is responding to requests.

The `ss` (socket statistics) command is used to dump socket information on a
host. This can be used to check whether any application on the host is bound
(or listening) to requests on a specific port. (`netstat` is the precursor to
`ss` but is considered obsolete.)

* `-l` is used to show all the listening sockets
* `-n` instructs `ss` not to resolve any service names
* `-p` shows the process that is using the socket

```console
sudo ss -l -n -p | grep 8888
```

The command `tcpdump` can be used to verify network traffic on a host; it is
also a useful tool for security auditing. It can be used to capture network
traffic and will let you know whether traffic is reaching its target.

The `-n` flag makes sure host or port names are not resovled and the `-i` flag
tells `tcpdump` the network interface on which to listen; the `any` term means
listen on all interfaces. The command below will capture all packets destined
for port 8888 and will include packets from both the client and the server.

```console
sudo tcpdump -ni any tcp port 8888

# snipped
# 502 packets captured
# 502 packets received by filter
# 0 packets dropped by kernel
```

## Scenario: Service Failure

On systemd-based systems, `systemctl` and `journalctl` are the primary tools for
diagnosing service problems.

```console
# Check the status of a service (shows active/inactive/failed + recent logs)
systemctl status nginx
# ● nginx.service - A high performance web server
#    Loaded: loaded (/lib/systemd/system/nginx.service; enabled)
#    Active: failed (Result: exit-code) since ...

# View the full logs for a service
journalctl -u nginx --no-pager

# Follow logs in real time
journalctl -u nginx -f

# Show only errors and above
journalctl -u nginx -p err
```

Common checks:

* **Is the service enabled?** `systemctl is-enabled nginx` — if `disabled`, it
  won't start on boot.
* **Did it crash recently?** `systemctl --failed` lists all failed units on the
  system.
* **Configuration error?** Many services have a config-test mode
  (e.g., `nginx -t`, `apachectl configtest`, `sshd -t`). Run this before
  restarting.

To restart a failed service:

```console
sudo systemctl restart nginx
# then verify
systemctl status nginx
```

## Scenario: Zombie Processes

A zombie (defunct) process has finished executing but still has an entry in the
process table because its parent has not yet read its exit status via `wait()`.
Zombies consume no CPU or memory but do occupy a PID slot.

```console
# Find zombie processes
ps aux | grep 'Z'
#  USER  PID %CPU %MEM   VSZ  RSS TTY STAT START TIME COMMAND
#  root 5678  0.0  0.0     0    0 ?   Z    09:10 0:00 [my-app] <defunct>
```

The `STAT` column shows `Z` for zombies. A handful are usually harmless, but
a large number can exhaust available PIDs.

To clear zombies, signal the **parent** process (not the zombie itself):

```console
# Find the parent PID (PPID)
ps -o pid,ppid,stat,comm -p 5678
#   PID  PPID STAT COMMAND
#  5678  1234 Z    my-app

# Ask the parent to reap its children
kill -SIGCHLD 1234

# If that doesn't work and the parent is misbehaving, killing the parent
# will cause init/systemd (PID 1) to adopt and reap the zombies
kill 1234
```

## Scenario: Permission Denied

"Permission denied" errors fall into several categories:

**File permissions** — the most common case. Check with `ls -la`:

```console
ls -la /etc/shadow
# -rw-r----- 1 root shadow 1234 Jan 10 12:00 /etc/shadow
```

The permission bits are `owner/group/other`. If your user is neither the owner
nor in the group and the "other" bits don't allow access, you'll get denied.

```console
# Check which groups you belong to
id
# uid=1000(dave) gid=1000(dave) groups=1000(dave),27(sudo)

# Fix by adding your user to the required group (requires logout/login)
sudo usermod -aG shadow dave
```

**SELinux / AppArmor** — mandatory access control may block access even when
regular file permissions allow it. Check with:

```console
# SELinux (RHEL/CentOS/Fedora)
getenforce                    # Enforcing, Permissive, or Disabled
sudo ausearch -m AVC -ts recent

# AppArmor (Debian/Ubuntu)
sudo aa-status
journalctl | grep apparmor
```

**Capabilities and setuid** — some operations require specific Linux
capabilities rather than full root. For example, binding to port 80 requires
`CAP_NET_BIND_SERVICE`:

```console
# Check capabilities on a binary
getcap /usr/bin/ping
# /usr/bin/ping cap_net_raw=ep
```

**Sudoers misconfiguration** — if `sudo` itself denies you, check
`/etc/sudoers` (always edit via `visudo`):

```console
sudo -l    # list what commands your user is allowed to run
```
