## Devices

Notes from Chapter 3 of [How Linux Works, 3rd
Edition](https://nostarch.com/howlinuxworks3).

Introduction to the kernel-provided device infrastructure in Linux by noting
how the kernel provides device configuration information through `sysfs`. The
goal is to become able to extract information about devices on a system in
order to understand a few rudimentary operations. It is important to understand
how the kernel interacts with user space when presented with new devices. The
`udev` system enables user-space programs to automatically configure and use
new devices.

### Device Files

The kernel presents many of the device I/O interfaces to user processes as
files called _device files_, which are sometimes called _device nodes_, and are
present in `/dev`. Regular file operations work with devices as well as standard
programs like `cat` that can access device files. However, there is a limit to
what you can do with a file interface, so not all device capabilities are
accessible with standard file I/O.

Consider the following command that redirects output from the standard output
to a file.

    echo blah > /dev/null

However, the file `/dev/null` is a device, so the kernel bypasses its usual
file operations and uses a device driver on data written to this device. In
this case, the kernel simply accepts the input data and throws it away.

Below are some examples of device types.

```bash
# create a named pipe
# mkfifo named_pipe
brw-rw----  1 root disk      8,   0 Jan 30 01:30 sda
brw-rw----  1 root disk      8,   1 Jan 30 01:30 sda1
crw-rw-rw-  1 root root      1,   3 Jan 18 10:11 null
prw-rw-r--  1 root root           0 Jan 30 09:21 named_pipe
srw-rw-rw-  1 root root           0 Jan 18 10:11 log
```

The first character of each line indicates the type of file device:

* b = block
* c = character
* p = pipe
* s = socket

The numbers before the dates are the _major_ and _minor_ device numbers that
the kernel uses to identify the device. Similar devices usually have the same
major number, such as `sda` and `sda1`.

Programs access data from a block device in fixed chunks. The `sda1` example
above is a _disk device_, which is a type of block device. Disks can be easily
split up into blocks of data because a block device's total size is fixed and
easy to index. Processes have quick random access to any block in the device
with the help of the kernel.

Character devices work with data streams, where you can only read characters
from or write characters to character devices; character devices don't have a
size. Printers directly attached to your computer are represented by character
devices. It is important to note that hen interacting with a character device,
the kernel cannot back up and re-examine the data stream after it has passed
data to a device.

Named pipes are like character devices, with another process at the other end
of the I/O stream instead of a kernel driver.

Sockets are special-purpose interfaces that are frequently used for
interprocess communication. Socket files represent Unix domain sockets.

However, not all devices have device files because the block and character
device I/O interfaces are not appropriate in all cases. For example, network
interfaces do not have device files.

### The `sysfs` Device Path

The Linux kernel offers the `sysfs` interface, through a system of files and
directories, as a uniform view for attach devices based on their actual
hardware attributes. The base path for devices is `/sys/devices`.

While the `/dev` file enables user processes to use the device, the
`/sys/devices` path is used for viewing information and for managing the
device. However, the files and subdirectories in `/sys/devices` are meant to be
read primarily by programs. Despite this, you can get useful information. For
example, `/sys/block` should contain all the block devices available on a
system and use `ls -l` to find the `sysfs` path of the devices.

Use `udevadm` to show the path and attributes of a device:

    udevadm info --query=all --name=/dev/sda

### dd and Devices

The sole function of `dd` is to read from an input file or stream and write to
an output file or stream. One useful `dd` feature with respect to block devices
is that you can process a chunk of data in the middle of a file, ignoring the
start and the end. **`dd` can easily corrupt files and data on devices, so be
careful when using it.**

`dd` copies data in blocks of a fixed size. The command below shows how to use
`dd` with a character device. It copies a single 1,024-byte block from
`/dev/zero` (a continuous stream of zero bytes) to `new_file`.

    dd if=/dev/zero of=new_file bs=1024 count=1

The `dd` option format differs from the option formats of most Unix commands
because it is based on an old IBM Job Control Language (JCL) style. Below are
some important `dd` options:

* `if=file` - the input file. The default is the standard input.
* `of=file` - the output file. The default is the standard output.
* `bs=size` - the block size. `dd` reads and writes this many bytes of data at
a time. To abbreviate large chunks of data, you can use `b` and `k` to signify
512 and 1,024 bytes, respectively. The example above could have been `bs=1k`.
* `ibs=size,obs=size` - the input and output block sizes. If you can use the
same block size for both input and output, use the `bs` option; if not, use
`ibs` and `obs` for input and output, respectively.
* `count=num` - the total number of blocks to copy. When working with a huge
file, or with a device that supplies an endless stream of data such as
`/dev/zero`, you want `dd` to stop at a fixed point because otherwise, you
could waste a lot of disk space, CPU time, or both. Use `count` with the `skip`
parameter to copy a small piece from a large file or device.
* `skip=num` - skip past the first `num` blocks in the input file or stream,
and do not copy them to the output.

### Device Name Summary

Here are a few ways to find the name of a device:

* Query udevd using `udevadm`
* Look for the device in the `/sys` directory
* Guess the name from the output of the `journalctl -k` command or the kernel
system log. The output may contain a description of the devices on your system.
* For a disk device that is already visible to the system, check the output
from `mount`
* Run `cat /proc/devices` to see the block and character devices for which your
system currently has drivers. Each line consists of a number and name. The
number is the major number of the device. Look in `/dev` for the character or
block devices with the corresponding major number.

```
Character devices:
  1 mem
  4 /dev/vc/0
  4 tty
  4 ttyS
  5 /dev/tty
```

#### Hard Disks

Most hard disks attached to Linux have device names prefixed with `sd`, such as
`/dev/sda`, `/dev/sdb`, etc. These devices represent entire disks and the
kernel makes separate device files, such as `/dev/sda1` and `/dev/sda2` for the
partitions on a disk.

The `sd` portion of the name stands for Small Computer System Interface (SCSI)
disk and was originally developed as a hardware and protocol standard for
communication between devices such as disks and other peripherals. Although
traditional SCSI hardware is not used in most modern machines, the SCSI
protocol is everywhere due to its adaptability. For example, USB storage
devices use it to communicate. Serial ATA (SATA) is a common storage bus but
the Linux kernel still uses SCSI commands at certain points to communicate to
SATA devices.

To list SCSI devices, use `lsscsi`.

```bash
lsscsi
[0:0:0:0]  disk  ATA   WDC WD3200AAJS-2 01.0 /dev/sda
[2:0:0:0]  disk  FLASH Drive UT_USB20   0.00 /dev/sdb
```

1. The first column identifies the address of the device on the system.
2. The second column describes the kind of device.
3. The last column indicates where to find the device file.

The columns in between is vendor information.

Linux assigns devices to device files in the order in which its drivers
encounter the devices. Unfortunately, this device assignment scheme has
traditionally caused problems when reconfiguring hardware. For example, imagine
a system with three disks: `/dev/sda`, `/dev/sdb`, and `/dev/sdc`. If
`/dev/sdb` is removed, `/dev/sdc` moves to `/dev/sdb`. If you were referring to
device names directly say in the `fstab` file, you'd have to make some changes.
To solve this problem, Linux use the Universally Unique Identifier (UUID)
and/or the Logical Volume Manager (LVM) stable disk device mapping.

#### Other devices

Some disk devices are optimised for virtual machines. The Xen virtualisation
system uses the `/dev/xvd` prefix, and `/dev/vd` is a similar type.

The Non-Volatile Memory Express (NVMe) interface is used to communicate with
solid-state storage. In Linux, these devices show up at `/dev/nvme*` and you
can use `nvme list` to list these devices.

A level up from disks and other direct block storage on some systems is the
LVM, which uses a kernel system called the device mapper; these block devices
start with `/dev/dm-` and are symbolic links in `/dev/mapper`.

Linux recognises most optical storage drives as the SCSI devices `/dev/sr0`,
`/dev/sr1`, etc. The `/dev/sr*` devices are read only and they are used only
for reading from discs. For the write and rewrite capabilities of optical
devices, use the generic SCSI devices such as `/dev/sg0`.

Parallel ATA (PATA) is an older type of storage bus. The Linux block devices
`/dev/hda`, `/dev/hdb`, etc. are common on older versions of the Linux kernel
and with older hardware. These are fixed assignments based on the device pairs
on interfaces 0 and 1. Sometimes you may find a SATA drive recognised as one of
these disks and this means that the SATA drive is running in compatibility
mode, which hinders its performance. Check your BIOS settings to see if you can
switch the SATA controller to its native mode.

Terminals are devices for moving characters between a user process and an I/O
device, usually for text output to a terminal screen. The terminal device
interface goes back to the days when terminals were typewriter-based devices
and many were attached to a single machine. Most terminals are _pseudoterminal_
devices, which are emulated terminals that understand the I/O features of real
terminals. The kernel presents the I/O interface to a piece of software, such
as the shell terminal window that you probably type most of your commands into.

Two common terminal devices are `/dev/tty1` (the first virtual console) and
`/dev/pts/0` (the first pseudoterminal device). The `/dev/pts` directory itself
is a dedicated filesystem. The `/dev/tty` device is the controlling terminal of
the current process. If a program is currently reading from and writing to a
terminal, this device is a synonym for that terminal. A process does not need
to be attached to a terminal.
