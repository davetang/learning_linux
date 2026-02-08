## The Kernel

* The kernel is the core of the OS; it mediates between hardware and all running programs, executing in privileged **kernel mode**.
* It manages four key areas:
    1. **processes** (scheduling, context switching),
    2. **memory** (allocation, isolation, virtual memory),
    3. **device drivers** (hardware abstraction), and
    4. **system calls** (the user-space-to-kernel interface).
* Check your running kernel with `uname -r`; view boot/hardware messages with `dmesg`.
* Loadable **kernel modules** (`lsmod`, `modprobe`) let you add driver/feature support without rebooting.
* Runtime kernel parameters are tuned via `sysctl` and `/proc/sys/`; the `/proc` filesystem exposes live kernel and process information.

---

The kernel is the core of the operating system. It is software residing in
memory that acts as a mediator between the hardware (especially main memory)
and any running program. The kernel runs in kernel mode and has unrestricted
access to the processor and main memory. The memory area that only the kernel
can access is called the _kernel space_.

The kernel is in charge of managing tasks in four general system areas:

1. Processes - the kernel determines which processes are allowed to use the CPU.

Only one process can actually use the CPU at any given time. In practice, each
process uses the CPU for a small fraction of time, then pauses; then another
process uses the CPU, and so on. _Context switching_ is when one process gives
up control of the CPU to another process. Each piece of time is called a _time
slice_ and provides a process computational time. The kernel is responsible for
context switching.

2. Memory - the kernel keeps track of all memory; what is currently allocated,
   what is shared, and what is free.

The kernel must manage memory during a context switch and in order to carry out
this complex job the following conditions must hold:

* The kernel must have its own private area in memory that user processes can't
  access.
* Each user process needs its own section of memory.
* One user process may not access the private memory of another process.
* User processes can share memory.
* Some memory in user processes can be read-only.
* The system can use memory than is physically present by using disk space.

3. Device drivers - the kernel acts as an interface between hardware and
   processes. It is usually the kernel's job to operate the hardware.

A device is typically accessible only in kernel mode but a notable difficulty
is that different devices rarely have the same programming interface.

4. System calls and support - processes normally use system calls to
   communicate with the kernel.

_System calls_ perform specific tasks that a user process alone cannot do well
or at all. For example opening, reading, and writing files all involve system
calls. Two examples of system calls include:

* `fork()` - when a process calls `fork()`, the kernel creates a nearly
  identical copy of the process
* `exec()` - when a process calls `exec(program)`, the kernel loads and starts
  `program`, replacing the current process.

The kernel also supports user processes with features other than traditional
system calls, the most common of which are _pseudodevices_, which look like
devices to user processes but are implemented purely in software. An example is
the kernel random number generator device (`/dev/random`).

### Kernel version

Use `uname` to display information about the running kernel.

```console
uname -r
```
```
6.1.0-41-amd64
```

```console
uname -a
```
```
Linux pd2 6.1.0-41-amd64 #1 SMP PREEMPT_DYNAMIC Debian 6.1.158-1 (2025-11-09) x86_64 GNU/Linux
```

The version string follows the format `major.minor.patch`. The `-amd64` suffix is a distribution-specific build identifier.

### Kernel modules

The Linux kernel is modular - drivers and features can be loaded and unloaded at runtime as **loadable kernel modules** (LKMs) without rebooting.

```console
# List currently loaded modules
lsmod

Module                  Size  Used by
ext4                  802816  1
mbcache                16384  1 ext4

# Get information about a module
$ modinfo ext4

# Load a module (and its dependencies)
$ sudo modprobe <module_name>

# Remove a module
$ sudo modprobe -r <module_name>
```

Module files live under `/lib/modules/$(uname -r)/` and are configured in `/etc/modprobe.d/`.

### Kernel ring buffer (dmesg)

The kernel logs messages to an internal ring buffer. These messages include hardware detection, driver loading, and errors during boot and runtime.

```console
# View the kernel ring buffer
$ dmesg | head
[    0.000000] Linux version 6.1.0-41-amd64 ...
[    0.000000] Command line: BOOT_IMAGE=/vmlinuz-6.1.0-41-amd64 root=...

# Follow new kernel messages in real time
$ dmesg -w

# Show human-readable timestamps
$ dmesg -T
```

On systems with `systemd`, `journalctl -k` shows the same kernel messages.

### The /proc filesystem

`/proc` is a virtual filesystem that exposes kernel and process information as files. Nothing in `/proc` exists on disk — it is generated on the fly by the kernel.

```console
# Kernel version (same as uname -r)
$ cat /proc/version

# CPU information
$ cat /proc/cpuinfo

# Memory statistics
$ cat /proc/meminfo

# Per-process information (replace <pid>)
$ ls /proc/<pid>/
cmdline  cwd  environ  fd  maps  status  ...
```

### Kernel parameters (sysctl)

Runtime kernel parameters are exposed under `/proc/sys/` and can be read or changed with `sysctl`.

```console
# List all parameters
$ sysctl -a

# Read a specific parameter
$ sysctl net.ipv4.ip_forward
net.ipv4.ip_forward = 0

# Set a parameter at runtime (non-persistent)
$ sudo sysctl -w net.ipv4.ip_forward=1
```

To make changes persistent across reboots, add them to `/etc/sysctl.conf` or a
file in `/etc/sysctl.d/`.

### Interrupts

When a hardware device needs attention (e.g., a keypress or a network packet arriving), it sends an **interrupt** to the CPU. The CPU pauses its current work, the kernel runs the appropriate **interrupt handler**, then execution resumes. You can view interrupt counts in `/proc/interrupts`.

```console
$ cat /proc/interrupts
           CPU0       CPU1
  0:         48          0   IO-APIC   2-edge      timer
  1:          3          0   IO-APIC   1-edge      i8042
...
```
