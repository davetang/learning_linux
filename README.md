## Learning linux

I recently purchased the [Linux Humble
Bundle](https://www.humblebundle.com/books/linux-no-starch-press-books) for
around 40 USD. I'll slowly go through the books and will consolidate all my
notes here.

## Useful commands

List SCSI devices (typically hard disks); useful for listing block devices.
Note that this is not limited to SCSI devices and block devices connected via
USB will also be listed.

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

### Use cases

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
