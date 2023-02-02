## Disks

Notes from Chapter 4 of [How Linux Works, 3rd
Edition](https://nostarch.com/howlinuxworks3).

How to work with disks on Linux, specifically how to partition disks, create
and maintain the filesystems inside disk partitions, and work with swap space.
Recall that disk devices have names like `/dev/sda`, the first SCSI subsystem
disk. This kind of block device represents the entire disk, but there are many
different components and layers inside a disk.

A typical Linux disk schematic is made up of a **Partition Table** (also known
as a disk label) with one or more defined **Partitions**, which are
subdivisions of the whole disk. On Linux, they are denoted with a number after
the whole block device, like `/dev/sda1` or `/dev/sdb3`. The kernel presents
each partition as a block device, just as it would an entire disk. Each
partition contains **Filesystem Data Structures** that contains the **File
Data**.

Multiple data partitions are common on systems with large disks because older
computers could boot only from certain parts of the disk. Admins also used
partitions to reserve a certain amount of space for operating system areas; for
example, they didn't want users to be able to fill up the entire system and
prevent critical services from working. In addition, most systems have a
separate swap partition.

The kernel makes it possible for you to access both an entire disk and one of
its partitions at the same time, but you wouldn't normally do so unless you
were copying the entire disk. The Linux _Logical Volume Manager_ (LVM) adds
more flexibility to traditional disk devices and partitions and is now in use
in many systems. The next layer down from the partition is the _filesystem_,
the database of files and directories that users interact with in user space.
To access data in a file requires the use of the appropriate partition location
from the partition table and a search of the filesystem database on the
partition for the desired file data.

The Linux kernel uses a system of layers to access data on a disk. The SCSI
Subsystem and other drivers communicate with the storage device, and Block
Device Interface and Partition Mapping, which communicates with the Filesystem
and Device Files (nodes). System calls are used to interact with the Filesystem
and Device Files, which are called by User Processes.

### Partitioning Disk Devices

There are many kinds of partition tables and they are just a bunch of data that
indicates how the blocks on the disk are divided. The traditional table is the
one found inside the _Master Boot Record_ (MBR) but it has many limitations.
Most newer systems use the _Globally Unique Identifier Partition Table_ (GPT).
Below are a few of the many Linux partitioning tools:

* `parted` (partition editor) - a text-based tool that supports both MBR and GPT.
* `gparted` - a graphical version of `parted`.
* `fdisk` - the traditional text-based Linux disk partitioning tool. Recent
versions of `fdisk` support the MBR, GPT, and many other kinds of partition
tables but older versions were limited to MBR support.

Note that there is a critical difference between partitioning and filesystem
manipulation: the partition table defines simple boundaries on the disk,
whereas a filesystem is a much more involved data system.

To view the system's partition table, use `sudo parted -l`. The sample output
shows two disk devices with two different kinds of partition tables.

```bash
sudo parted -l
# Model: ATA KINGSTON SM2280S (scsi)
# Disk /dev/sda: 240GB
# Sector size (logical/physical): 512B/512B
# Partition Table: msdos
# Disk Flags:
# Number Start  End   Size   Type     File system   Flags
# 1      1049kB 223GB 223GB  primary  ext4          boot
# 2      223GB  240GB 17.0GB extended
# 5      223GB  240GB 17.0GB logical  linux-swap(v1)

# Model: Generic Flash Disk (scsi)
# Disk /dev/sdf: 4284MB
# Disks and Filesystems 73
# Sector size (logical/physical): 512B/512B
# Partition Table: gpt
# Disk Flags:
# Number Start  End    Size   Type     File system  Name     Flags
# 1      1049kB 1050MB 1049MB                       myfirst
# 2      1050MB 4284MB 3235MB                       mysecond
```

The first device (`/dev/sda`) uses the traditional MBR partition table (which
`parted` called `msdos`) and the second (`/dev/sdf`) contains a GPT. The MBR
table above contains primary, extended, and logical partitions. A _primary
partition_ is a normal subdivision of the disk. The basic MBR has a limit of
four primary partitions and any additional partitions need to be designated as
an _extended partition_. An extended partition breaks down into _logical
partitions_, which the operating system can then use as it would any other
partition. In the example, partition 2 is an extended partition that contains
logical partition 5.

Altering partition tables is relatively easy but making these changes to the
disk involves risk, so keep the following in mind:

* Changing the partition table makes it quite difficult to recover any data on
partitions that you delete or refine because you can erase the location of the
filesystems on those partitions. Make sure you have a backup if the disk
beforehand.
* Ensure that no partitions on your target disk are currently in use. This is a
concern because most Linux distributions automatically mount any detected
filesystem.

`fdisk` and `parted` can be used to create/alter partition tables but there is
a major difference between the two. With `fdisk`, you design your new partition
table before making the actual changes to the disk, and it makes the changes
only when you exit the program. With `parted` partitions are created, modified,
and removed _as you issue the commands_. You do not get the chance to review
the partition table before you change it.

The kernel must read partition tables in order to present the partitions as
block devices so you can use them. The `fdisk` utility uses a relatively simple
method. After modifying the partition table, `fdisk` issues a single system
call to tell the kernel that it should reread the disk's partition table. The
kernel then generates debugging output, which you can view with `journalctl
-k`.

The `parted` tools do not use this disk-wide system call; instead, they signal
the kernel when individual partitions are altered. After processing a single
partition change, the kernel does not produce the preceding debugging output.
There are a few ways to observe partition changes:

* Use `udevadm` to watch the kernel event changes. For example, the command
`udevadm monitor --kernel` will show the old partition devices being removed
and the new ones being added.
* Check `/proc/partitions` for full partition information.
* Check `/sys/block/device/` for altered partition system interfaces or `/dev`
for altered partition devices.

To force the kernel to reload the partition table on `/dev/sdf`:

    blockdev --rereadpt /dev/sdf

#### Creating a Partition Table

The following example creates a new partition table on a new empty disk with
the following properties:

* 4GB disk, like a small USB flash device
* MBR-style partition table
* Two partitions intended to the populated with an ext4 filesystem: 200MB and
3.8GB
* Disk device at `/dev/sdd` (use `lsblk` to find the device location)

After ensuring that nothing on the disk is mounted, start with the device name:

```bash
fdisk /dev/sdd
```

Press `p` to print the current table and `d` to delete an existing partition.
Recall that `fdisk` does not make changes until you explicitly write the
partition table, so nothing has been modified. If you make a mistake, use the
`q` command to quit `fdisk` without writing the changes.

Press `n` to create a new partition and enter the Partition type when prompted,
which is `p` for primary and then the partition number `1`. Enter `2048` for
the First sector and `+200M` as the Last sector.

Another partition can be added in the same manner and once the laying out has
been set, press `p` to review. Finally, press `w` to write the partition table.
Use `journalctl -k` to view additional diagnostic messages.

### Filesystems

The _filesystem_ is the link between the kernel and user space for disks and if
a form of database that supplies the structure to transform a simple block
device into the sophisticated hierarchy of files and subdirectories that users
work with.

All filesystems resided on disks and other physical media that were intended to
be used exclusively for data storage. However, the tree-like directory
structure and I/O interface of filesystems are quite versatile, so filesystems
now perform a variety of tasks, such as the system interfaces that you see in
`/sys` and `/proc`. Filesystems are traditionally implemented in the kernel,
but the innovation of 9P from Plan 9 has inspired the development of user-space
filesystems. The File System in User Space (FUSE) feature allows user-space
filesystems in Linux.

The Virtual File System (VFS) abstraction layer completes the filesystem
implementation. Much as the SCSI subsystem standardises communication between
different device types and kernel control commands, VFS ensures that all
filesystem implementations support a standard interface so that user-space
applications access files and directories in the same manner. VFS support has
enabled Linux to support an extraordinarily large number of filesystems.

#### Filesystem Types

Linux filesystem support includes native designs optimised for Linux, foreign
types such as the Windows FAT family, universal filesystems such as ISO 9660,
and many others. The following list includes the most common types of
filesystems for data storage:

* The Fourth Extended filesystem (ext4) is the current iteration of a line of
filesystems native to Linux. The Second Extended filesystem (ext2) was a
longtime default for Linux inspired by traditional Unix filesystems, such as
the Unix File System (UFS) and the Fast File System (FFS). The Third Extended
filesystem (ext3) added a journal feature (a small cache outside the normal
filesystem data structure) to enhance data integrity and hasten booting. The
ext4 filesystem is an incremental improvement and supports larger files than
ext2 or ext3 as well as a greater number of subdirectories.
* Btrfs or B-tree filesystem (btrfs) is a newer filesystem native to Linux
designed to scale beyond the capabilities of ext4.
* FAT filesystems (msdos, vfat, exfat) pertain to Microsoft systems. The simple
msdos type supports the very primitive monocase variety in MS-DOS systems. Most
removable flash media, such as SD cards and USB drives, contain vfat (up to
4GB) or exfat (4GB and up) partitions by default. Windows systems can use
either a FAT-based filesystem or the more advanced NT File System (ntfs).
* XFS is a high-performance filesystem used by default by some distributions,
such as RHEL 7.0 and beyond.
* HFS+ (hfsplus) is an Apple standard used on most Macintosh systems.
* ISO 9660 (iso9660) is a CD-ROM standard. Most CD-ROMs use some variety of the
ISO 9660 standard.

After partitioning, a filesystem needs to be created. As with partitioning,
this is performed in user space because a user-space process can directly
access and manipulate a block device. Filesystem creation is a task that should
be performed only after adding a new disk or repartitioning an old one. A
filesystem should be created just once for each new partition that has no
pre-existing data (or that has data you want to remove). Creating a new
filesystem on top of an existing filesystem will effectively destroy the old
data.

The `mkfs` utility can create many kinds of filesystems. To create an ext4
partition on `/dev/sdf2`:

    mkfs -t ext4 /dev/sdf2

`mkfs` is only a frontend for a series of filesystem creation programs,
"mkfs.fs", where fs is a filesystem file. The above command actually runs
`mkfs.ext4`. Furthermore, `mkfs.ext4` is just a symbolic link to `mke2fs`. This
is important to know in case a system does not have a `mkfs` command or you
need to look up the documentation for a particular filesystem.

`mkfs` automatically determines the number of blocks in a device and sets some
reasonable defaults. When creating a filesystem, `mkfs` prints diagnostic
output as it works, including output pertaining to the superblock. The
superblock is a key component at the top level of the filesystem database, and
since it's important `mkfs` creates a number of backups in case the original is
destroyed. Consider recording a few of the superblock backup numbers when mkfs
runs, in case you need to recover the superblock in the event of a disk
failure.

#### Mounting a Filesystem

The process of attaching a filesystem to a running system is called _mounting_.
When the system boots, the kernel reads some configuration data and mounts root
(`/`) based on the configuration data. In order to mount a filesystem, you must
know the following:

* The filesystem's device, location, or identifier (such as disk partition,
where the actual filesystem data resides). Some special-purpose filesystems,
such as proc and sysfs don't have locations.
* The filesystem type.
* The _mount point_ - the place in the current system's directory hierarchy
where the filesystem will be attached. The mount point is always a normal
directory. For instance, you could use `/music` as a mount point for a
filesystem containing music. The mount point need not be directly below `/` and
can be anywhere on the system.

The common terminology for mounting a filesystem is "mount a device on a mount
point". To check the current filesystem status of your system, you use `mount`.
The output (which can be long) should look like:

```bash
mount
# /dev/sda1 on / type ext4 (rw,errors=remount-ro)
# proc on /proc type proc (rw,noexec,nosuid,nodev)
# sysfs on /sys type sysfs (rw,noexec,nosuid,nodev)
# fusectl on /sys/fs/fuse/connections type fusectl (rw)
# debugfs on /sys/kernel/debug type debugfs (rw)
# securityfs on /sys/kernel/security type securityfs (rw)
# udev on /dev type devtmpfs (rw,mode=0755)
# devpts on /dev/pts type devpts (rw,noexec,nosuid,gid=5,mode=0620)
# tmpfs on /run type tmpfs (rw,noexec,nosuid,size=10%,mode=0755)
# --snip--
```

Each line corresponds to one currently mounted filesystem, with items in this order:

1. The device, such as `/dev/sda3`. Notice that some of these are not real
devices (e.g. `proc`) but are stand-ins for real device names because these
special-purpose filesystems do not need devices.
2. The word `on`.
3. The mount point.
4. The word `type`.
5. The filesystem type, usually in the form of a short identifier.
6. Mount options (in parentheses).

Linux systems typically include a temporary mount point `/mnt`, which is used
for testing. For filesystems that are intended for extended use, mount it to
another location.

To mount a filesystem manually, use the `mount` command with the filesystem
type, device, and desired mount point.

    mount -t type device mountpoint

For example, to mount the Fourth Extended filesystem found on the device
`/dev/sdfs2` on `/home/extra`:

    mount -t ext4 /dev/sdf2 /home/extra

Normally you do not need to supply the `-t type` option because `mount` figures
it out. However, sometimes it is necessary to distinguish between two similar
types, such as the various FAT-style filesystems.

Mount options fall into two rough categories: general and filesystem-specific.
General options typically work for all filesystem types and include `-t` for
specifying the filesystem type. In contrast, a filesystem-specific option
pertains only to certain filesystem types. To activate a filesystem option, use
the `-o` switch followed by the option. For example, `-o remount,rw` remounts a
filesystem already mounted as read-only in read-write mode.

General options have a short syntax and the most important are:

* `-r` - this option mounts the filesystem in read-only mode.
* `-n` - this option ensures that `mount` does not try to update the system
runtime mount database, `/etc/mtab`. By default, `mount` fails when it cannot
write to this file, so this option is important at boot time because the root
partition (including the system mount database) is read-only at first. You will
also find this option handy when trying to fix a system problem in single-user
mode because the system mount database may not be available at the time.
* `-t` - this option specifies the filesystem type.

All filesystem-specific options use a longer, more flexible option format. To
use long options with `mount` on the command line, start with `-o` followed by
the appropriate keywords separated by commas. For example:

    mount -t vfat /dev/sde1 /dos -o ro,uid=1000

The two long options hare are `ro` and `uid=1000`. The `ro` option specifies
read-only mode and is the same as the `-r` short option. The `uid=1000` option
tells the kernal to treat all files on the filesystem as if user ID 1000 is the
owner. The most useful long options are:

* `exec,noexec` - enables or disables execution of programs on the filesystem.
* `suid, nosuid` - enables or disables `setuid` programs.
* `ro` - mounts the filesystem in read-only mode.
* `rw` - mounts the filesystem in read-write mode.

To unmount (detach) a filesystem, use the `umount` command.

    umount mountpoint

You can also unmount a filesystem with its device instead of its mount point.

Linux buffers writes to the disk, which means the kernel usually doesn't
immediately write changes to filesystems when processes request changes.
Instead, it stores those changes in RAM until the kernel determines a good time
to actually write them to disk. This buffering system is transparent to the
user and provides a very significant performance gain.

When a filesystem is unmounted, the kernel automatically synchronises with the
disk, writing the changes in its buffer to the disk. You can force the kernel
to do this at any time by running `sync`, which by default synchronises all the
disks on the system. If you can't unmount a filesystem before you turn off the
system, use `sync` first. In addition, the kernel uses RAM to cache blocks as
they're read from a disk. Therefore, if one or more processes repeatedly access
a file, the kernel does not have to go to the disk again and it can simply read
from the cache.

However, since device names can change, you should identify and mount
filesystems by their _universally unique identifier_ (UUID), which is an
industry standard for unique "serial numbers" to identify objects in a computer
system. Filesystem creation programs like `mke2fs` generate a UUID when
initialising the filesystem data structure.

To view a list of devices and the corresponding filesystems and UUIDs on your
system, use the `blkid` (block ID) program.

```bash
blkid
# /dev/sdf2: UUID="b600fe63-d2e9-461c-a5cd-d3b373a5e1d2" TYPE="ext4"
# /dev/sda1: UUID="17f12d53-c3d7-4ab3-943e-a0a72366c9fa" TYPE="ext4" PARTUUID="c9a5ebb0-01"
# /dev/sda5: UUID="b600fe63-d2e9-461c-a5cd-d3b373a5e1d2" TYPE="swap" PARTUUID="c9a5ebb0-05"
# /dev/sde1: UUID="4859-EFEA" TYPE="vfat"
```

The example above shows four partitions with data: two with ext4 filesystems,
one with a swap space signautre, and one with a FAT-based filesystem. The Linux
native partitions all have standard UUIDs, but the FAT partition does not. You
can reference the FAT partition with its FAT volume serial number
(`4859-EFEA`).

To mount a filesystem by its UUID, use the `UUID=` mount option. For example,
to mount the first filesystem in the example above on `/home/extra`:

    mount UUID=b600fe63-d2e9-461c-a5cd-d3b373a5e1d2 /home/extra

Typically you won't manually mount filesystems by UUID because you normally
know the device and it is much easier to mount a device by its name than its
UUID. However, it is important to understand UUIDs because they are the
preferred way to mount non-LVM filesystems in `/etc/fstab` automatically at
boot time. In addition, many distributions use the UUID as a mount point when
you insert removable media.

There will be times when you need to change the `mount` options for a currently
mounted filesystem; the most common situation is when you need to make a
read-only filesystem writable during crash recovery. In that case, you need to
reattach the filesystem at the same mount point. The following command remounts
the root directory in read-write mode; you need the `-n` option because the
`mount` command can't write to the system mount database when the root is
read-only:

    mount -n -o remount /

This command assumes that the correct device listing for `/` is in
`/etc/fstab`. If it isn't, you need to specify the device as an additional
option.
