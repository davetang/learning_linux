## Table of Contents

  - [Learning linux](#learning-linux)
  - [Quick notes](#quick-notes)
  - [Useful commands](#useful-commands)
  - [Mount portable USB](#mount-portable-usb)
  - [Mount new hard disk](#mount-new-hard-disk)
  - [Don't panic](#dont-panic)
    - [Check Filesystem Consistency](#check-filesystem-consistency)
    - [Detect Bad Sectors](#detect-bad-sectors)

## Learning linux

I recently purchased the [Linux Humble
Bundle](https://www.humblebundle.com/books/linux-no-starch-press-books) for
around 40 USD. I'll slowly go through the books and will consolidate all my
notes here.

## Quick notes

* Use `/etc/hosts` to map hostnames to IP addresses. The format is:

```
# this is a comment
# fields can be spaces or tabs
IP_address  hostname  [alias1]  [alias2]  ...
```

As with most things Linux, the order matters: first matching entry will be used.

On Debian, an IP address of 127.0.1.1 is sometimes seen. This is [because](https://www.debian.org/doc/manuals/debian-reference/ch05.en.html#_the_hostname_resolution):

> The IP address 127.0.1.1 is created by the Debian Installer for a system without a permanent IP address as a workaround for some software (e.g., GNOME).

## Useful commands

List SCSI devices (typically hard disks); useful for listing block devices.
Note that this is not limited to SCSI devices and block devices connected via
USB will also be listed. Output from the examples below are from two separate
computers.

You may need to install it first.

```console
# Debian/Ubuntu
sudo apt install -y lsscsi

# CentOS/RHEL
yum install lsscsi
```

List SCSI devices (or hosts) and list NVMe devices (version 0.30 and higher).

```console
sudo lsscsi
```
```
[0:0:0:0]    disk    ATA      SUNEAST SE800 SS AA20  /dev/sda
```

Lists NVMe controllers and SCSI hosts.

```console
sudo lsscsi --controllers
```
```
[0]    ahci
[1]    ahci
[2]    ahci
[3]    ahci
```

On a computer that has a NVMe controller.

```console
sudo lsscsi --long
```
```
[2:0:0:0]    disk    ATA      TOSHIBA DT01ACA2 AC60  /dev/sda
  state=running queue_depth=32 scsi_level=6 type=0 device_blocked=0 timeout=30
[3:0:0:0]    disk    ATA      WDC  WDS100T2B0A 40WD  /dev/sdb
  state=running queue_depth=32 scsi_level=6 type=0 device_blocked=0 timeout=30
[N:0:4:1]    disk    SAMSUNG MZVLB512HAJQ-000H1__1              /dev/nvme0n1
  capability=0  ext_range=256  hidden=0  nsid=1  range=0  removable=0
```

`smartctl` - Control and Monitor Utility for SMART Disks

Install if necessary.

```console
sudo apt install -y smartmontools
```

Scan for devices.

```console
sudo smartctl --scan
```
```
/dev/sda -d scsi # /dev/sda, SCSI device
/dev/sdb -d scsi # /dev/sdb, SCSI device
/dev/nvme0 -d nvme # /dev/nvme0, NVMe device
```

Info on `/dev/sda`.

```console
sudo smartctl --info /dev/sda
```
```
smartctl 7.3 2022-02-28 r5338 [x86_64-linux-6.1.0-18-amd64] (local build)
Copyright (C) 2002-22, Bruce Allen, Christian Franke, www.smartmontools.org

=== START OF INFORMATION SECTION ===
Device Model:     SUNEAST SE800 SSD 1T
Serial Number:    30091897265
LU WWN Device Id: 5 000000 000002f9f
Firmware Version: 030fAA20
User Capacity:    1,024,209,543,168 bytes [1.02 TB]
Sector Size:      512 bytes logical/physical
Rotation Rate:    Solid State Device
Form Factor:      2.5 inches
TRIM Command:     Available, deterministic, zeroed
Device is:        Not in smartctl database 7.3/5319
ATA Version is:   ACS-4 (minor revision not indicated)
SATA Version is:  SATA 3.2, 6.0 Gb/s (current: 6.0 Gb/s)
Local Time is:    Tue Mar 26 23:31:18 2024 JST
SMART support is: Available - device has SMART capability.
SMART support is: Enabled
```

View system's partition table; useful for finding out the File system, device
name, start/end sectors.

    sudo parted -l

Locate and print block device attributes; useful for for getting information on
a device's file system and UUID.

    sudo blkid

Use `udevadm` to show the path and attributes of a device.

    sudo udevadm info --query=all --name=/dev/sdb

Run `cat /proc/devices` to see the block and character devices for which your
system currently has drivers.

    cat /proc/devices

To view IP addresses in IPv6 include the `-6` argument with `ip`.

    ip -6 address show

View current IP filtering rules.

    sudo iptables -L

`dmidecode` is a tool for dumping a computer's DMI (some say SMBIOS) table
contents in a human-readable format. This table contains a description of the
system's hardware components, as well as other useful pieces of information
such as serial numbers and BIOS revision. Thanks to this table, you can
retrieve this information without having to probe for the actual hardware.
While this is a good point in terms of report speed and safeness, this also
makes the presented information possibly unreliable.

    sudo dmidecode --type connector | less

Find motherboard/system model.

```console
sudo dmidecode --string system-product-name
```

## Mount portable USB

Mount a portable USB hard disk plugged into a server.

1. Use `sudo lsscsi` to find the device and associated device file.

For example, `/dev/sdc`.

2. Use `sudo parted -l` to find out the parition table type, partitions, File
system and the disk size.

For example, the partition table is gpt, with two partitions, using the `ntfs`
File system.

3. (Optional) Find UUID using `sudo blkid` and looking for the device file.
4. Mount using `mount`.

For example:

    sudo mkdir -p /mnt/media/my_hd
    sudo mount -t ntfs /dev/sdc2 /mnt/media/my_hd

If you get the following error:

    mount: unknown filesystem type 'ntfs'

Install ntfs-3g:

```bash
# RHEL/CentOS/Fedora
sudo yum install ntfs-3g

# Ubuntu/Debian
sudo apt install ntfs-3g
```

5. Once you are done unmount using `umount` and make sure you're not in the
mount point directory.

    sudo umount /mnt/media/my_hd

## Mount new hard disk

1. Find 2.5" SSD plugged in with the SATA data and power cable.

```console
sudo fdisk -l
```
```
Disk /dev/sda: 931.51 GiB, 1000204886016 bytes, 1953525168 sectors
Disk model: CT1000MX500SSD1
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 4096 bytes
I/O size (minimum/optimal): 4096 bytes / 4096 bytes
```

2. Create new primary partition accepting all defaults.

```console
sudo fdisk /dev/sda
```
```
Welcome to fdisk (util-linux 2.38.1).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.

Device does not contain a recognized partition table.
Created a new DOS (MBR) disklabel with disk identifier 0x7dd18d01.

Command (m for help): n
Partition type
   p   primary (0 primary, 0 extended, 4 free)
   e   extended (container for logical partitions)
Select (default p):

Using default response p.
Partition number (1-4, default 1):
First sector (2048-1953525167, default 2048):
Last sector, +/-sectors or +/-size{K,M,G,T,P} (2048-1953525167, default 1953525167):

Created a new partition 1 of type 'Linux' and of size 931.5 GiB.

Command (m for help):
```

3. Enter `w` to write the changes after the `Command (m for help):` prompt.

```
Command (m for help): w
The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.
```

4. Add a file system (`ext4`).

```console
sudo mkfs -t ext4 /dev/sda1
```
```
mke2fs 1.47.0 (5-Feb-2023)
Discarding device blocks: done
Creating filesystem with 244190390 4k blocks and 61054976 inodes
Filesystem UUID: ee812feb-e1c0-4143-9000-f8236518eef3
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208,
        4096000, 7962624, 11239424, 20480000, 23887872, 71663616, 78675968,
        102400000, 214990848

Allocating group tables: done
Writing inode tables: done
Creating journal (262144 blocks): done
Writing superblocks and filesystem accounting information: done
```

5. Find the UUID.

```console
sudo blkid
```

6. Add entry to `/etc/fstab`.

```console
sudo vi /etc/fstab
```
```
UUID=ID /data ext4 defaults 0 0
```

7. Restart.

```console
sudo shutdown -r now
```

8. Change permission

```console
sudo chown $USER:$USER /data
cd /data
echo hello > test.txt
cat test.txt
```
```
hello
```

## Don't panic

Filesystem inconsistencies.

```
Unexpected inconsistency: run fsck manually without -a or -p
```

In recovery mode, replacing `/dev/sda1` with the actual partition. Do not run `fsck` on a mounted filesystem.

```console
fsck -f /dev/sda1
```

Answer 'y' (default) to prompts about fixing issues. Afterwards reboot and hopefully the issues have been resolved.

### Check Filesystem Consistency

Manual scan; the `-n` option tells `fsck` not to mount the filesystem after the check.

```console
sudo fsck -n /dev/nvme0n1p2
```
```
sck from util-linux 2.38.1
e2fsck 1.47.0 (5-Feb-2023)
Warning!  /dev/nvme0n1p2 is mounted.
Warning: skipping journal recovery because doing a read-only filesystem check.
/dev/nvme0n1p2: clean, 1815101/31162368 files, 93123289/124645632 blocks
```

### Detect Bad Sectors

Manual scan using `badblocks`. (Took 45 minutes on a 512GB NVMe SSD.)

```console
sudo /sbin/badblocks --v /dev/nvme0n1p2
```
```
sudo /sbin/badblocks -v /dev/nvme0n1p2
Checking blocks 0 to 498582527
Checking for bad blocks (read-only test): 120589728
120589729
120589730
120589731
280183072
280183073
280183074
280183075
280183076
280183077
280183078
280183079
280486588
280486589
280486590
280486591
481071784
481071785
481071786
481071787
done
Pass completed, 20 bad blocks found. (20/0/0 errors)
```

It is essential to note that:

* Not all "bad" blocks are necessarily problematic.
* Even if the disk reports multiple bad blocks, it may still be functional.

To prevent such issues in the future, consider the following best practices:

* Regularly check your disks for errors using tools like `badblocks` and `fsck`.
* Keep your system's file system up to date with the latest patches.
* Use a reliable disk format (e.g., XFS or ext4); use `sudo parted -l` to find out.

