## Learning linux

I recently purchased the [Linux Humble
Bundle](https://www.humblebundle.com/books/linux-no-starch-press-books) for
around 40 USD. I'll slowly go through the books and will consolidate all my
notes here.

## Useful commands

List SCSI devices (typically hard disks); useful for listing block devices.

    sudo lsscsi

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
