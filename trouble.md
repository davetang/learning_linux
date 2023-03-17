Table of Contents
=================

* [Troubleshooting hosts](#troubleshooting-hosts)
   * [Scenario: High Load Average](#scenario-high-load-average)
   * [Scenario: High Memory Usage](#scenario-high-memory-usage)
   * [Scenario: High iowait](#scenario-high-iowait)
   * [Scenario: Hostname Resolution Failure](#scenario-hostname-resolution-failure)
   * [Scenario: Out of Disk Space](#scenario-out-of-disk-space)
   * [Scenario: Connection Refused](#scenario-connection-refused)

Created by [gh-md-toc](https://github.com/ekalinin/github-markdown-toc)

# Troubleshooting hosts

Notes from Chapter 10 of [DevOps for the
Desperate](https://nostarch.com/devops-desperate).

Troubleshooting is the process of analysing the system and rooting out
potential causes of trouble. Debugging is the process of discovering the cause
of trouble and possibly implementing steps to remedy it. Debugging can be
considered a subset of troubleshooting.

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
