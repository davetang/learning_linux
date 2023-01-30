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

