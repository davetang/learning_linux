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
