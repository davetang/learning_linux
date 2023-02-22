## Networking

Notes from Chapter 9 of [How Linux Works, 3rd
Edition](https://nostarch.com/howlinuxworks3).

Networking is connecting computers and sending data between them. But how does
the computer sending the data know _where_ to send the data and how does the
computer that received the data know _what_ it received? Computers use
different components that are responsible for sending, receiving, and
identifying data. These components are arranged in groups that form _network
layers_, which stack on top of each other to form a complete system. Each layer
is typically independent and it's possible to build networks with many
different combinations of components.

### Basics

A simple network might have three hosts (A, B, and C) and a router connected
together in a Local Area Network (LAN). The router, also known as a _gateway_,
is also connected to the Internet via an _uplink_ connection, which is also
known as the Wide Area Network (WAN) connection, since it links the smaller LAN
to a larger network. The computers on the LAN can access the Internet via the
router.

Data is transmitted over a network in small chunks called _packets_, which
consists of a _header_ and a _payload_. The header contains identifying
information such as the source and destination host machines and the basic
protocol. The payload contains the actual application data that is sent, such
as HTML. A host can send, receive, and process packets in any order, which
makes it possible for several hosts to communicate simultaneously. You
typically do not have to worry about translating packets because the operating
system takes care of that.

### Network layers

A fully functioning network includes a set of network layers called a _network
stack_. The typical Internet stack, from the top to bottom layer, looks like
this:

* **Application layer** - contains the language that applications and servers
  use for communication, which is usually a high-level protocol. Common
  application layer protocols include HTTP (web protocol), TLS (encryption
  protocol), FTP (file protocol). Application layer protocols can often be
  combined such as TLS used in conjunction with HTTP forms HTTPS.
* **Transport layer** - defines the data transmission characteristics of the
  application layer. This layer includes data integrity checking, source and
  destination ports, and specifications for breaking application data into
  packets at the host side (if this hasn't already been done by the application
  layer), and reassembling them at the destination. Transmission Control Protocol
  (TCP) and User Datagram Protocol (UDP) are the most common transport layer
  protocols. The transport layer is sometimes called the _protocol layer_.
* **Network or internet layer** - defines how to move packets from a source to
  a destination. The particular packet transit rule set for the internet is known
  as the _Internet Protocol_ (IP).
* **Physical layer** - defines how to send raw data across a physical medium,
  such as Ethernet or a modem. This is sometimes called the _link layer_ or
  _host-to-network layer_.

It is important to understand the structure of a network stack because your
data must travel through these layers at least twice before it reaches a
program at its destination. For example, when sending data from Host A to Host
B, the bytes leave the application layer on Host A and travel through the
transport and network layers on Host A; then they go down to the physical
medium, across the medium, and up again through the various lower levels to the
application layer on Host B.

#### The Internet layer

The Internet is currently based on version 4 (IPv4) and 6 (IPv6) of the
Internet Protocol. One of the most important aspects of the internet layer is
that it is meant to be a software network that places no particular
requirements on hardware or operating systems. The idea is that you can send
and receive Internet packets over any kind of hardware, using any operating
system.

The Internet's topology is decentralised; it is made up of smaller networks
called _subnets_ that are all interconnected in some way. A host can be
attached to more than one subnet; for example, a router can transmit data from
one subnet (the LAN) to another.

Each Internet host has at least one numeric IP address. For IPv4, it is in the
form of a.b.c.d, such as 8.8.8.8, and consists of 4 bytes (or 32 bits). Bytes a
and d are numbers from 1 to 254, and b and c are numbers from 0 to 255. An
address in this notation is called a _dotted-quad_ sequence but a computer
processes IP addresses as raw bytes. If a host is connected to multiple
subnets, it has at least one IP address per subset. Each host's IP address
should be unique across the entire internet. To communicate with another host,
your machine needs to know the other host's IP address.

One machine can have many IP addresses to accommodate multiple physical
interfaces, virtual internal networks, and more. Use `ip address show` to
output active addresses; the output will be grouped by physical interface. The
`ip` command's output includes many details from the internet layer(s) and the
physical layer.

A subset is a connected group of hosts with IP addresses in a particular range.
For example, the hosts in the range 10.23.2.1 to 10.23.2.254 could comprise a
subnet. Usually the subnet hosts are on the same physical network. A subnet
is defined with two pieces of information:

1. _Network prefix_ (also called a _routing prefix_)
2. _Subnet mask_ (also called the _network mask_ or _routing mask_).

For example, a subnet containing the IP addresses between 10.23.2.1 and
10.23.2.254 has a network prefix of 10.23.2.0 (the part that is common to all
addresses in the subnet) and a subnet mask of 255.255.255.0 (the mask marks the
bit locations in an IP address that are common to the subnet). This makes more
sense in binary and below are the binary forms of 10.23.2.0 and 255.255.255.0:

```
00001010 00010111 00000010 00000000
11111111 11111111 11111111 00000000
```

A bitwise AND will return:

```
00001010 00010111 00000010 00000000
```

which lists the bit configuration of any address in the subnet. This is denoted
as 10.23.2.0/255.255.255.0.

In most Internet tools, the Classless Inter-Domain Routing (CIDR) notation is
used, which denotes 10.23.2.0/255.255.255.0 as 10.23.2.0/24. The CIDR notation
simply identifies the subnet mask by the number of _leading_ 1s (when in binary
form) in the subnet mask. For example:

|  Long form  |            Binary form              | CIDR form |
| ----------- | ----------------------------------- | --------- |
| 255.0.0.0   | 11111111 00000000 00000000 00000000 |     /8    |
| 255.240.0.0 | 11111111 11110000 00000000 00000000 |     /12   |
| 255.255.0.0 | 11111111 11111111 00000000 00000000 |     /16   |

#### Routes and the Kernel Routing Table

Connecting Internet subnets is mostly a process of sending data through hosts
connected to more than one subnet. The Linux kernel distinguishes between
different kinds of destinations (LAN vs. WAN) by using a _routing table_ to
determine its routing behaviour. Use `ip route show` to show the routing table;
the output will display each line as a routing rule.

```bash
ip route show
# default via 10.23.2.1 dev enp0s31f6 proto static metric 100
# 10.23.2.0/24 dev enp0s31f6 proto kernel scope link src 10.23.2.4 metric 100
```

The output of the first line has the destination network `default`. This rule,
which matches any host, is also called the _default route_. The mechanism is
via `10.23.2.1`, which indicates that traffic using the default route is to be
sent to `10.23.2.1`; `dev enp0s31f6` indicates that the physical transmission
will happen on that network interface.

The `default` entry in the routing table has special significance because it
matches any address on the Internet; in CIDR notation, it's `0.0.0.0/0` for
IPv4. This is the default route, and the address configured as the intermediary
in the default route is the _default gateway_. When no other rules match, the
default route always does, and the default gateway is where you send messages
when there is no other choice. On most networks with a netmask of `/24`
(255.255.255.0), the router is usually at address 1 of the subnet but this is
simply a convention and not a hard rule.

The output on the second line shows the destination network `10.23.2.0/24`,
which is the host's local subnet. This rule says that the host can reach the
local subnet directly through its network interface, indicated by the `dev
enp0s31f6` mechanism label.

When a host wants to send something to `10.23.2.132`, which matches both rules
in the routing table, the order in the routing table does not matter. The
kernel will choose the longest destination prefix that matches. `10.23.2.0/24`
matches but its prefix is 24 bits long whereas `0.0.0.0/0` matches, but its
prefix is 0 bits long because it has no prefix. Therefore the rule for
`10.23.2.0/24` takes priority.

#### Ipv6 addresses and networks

IPv4 addresses consist of 32 bits (4 bytes) yielding roughly 4.3 billion
addresses, which is insufficient for the number of devices currently connected
to the Internet. An IPv6 address has 128 bits, 16 bytes arranged in eight sets
of 2 bytes. In long form an address is written as:

```
2001:0db8:0a0b:12f0:0000:0000:0000:8b6e
```

The representation is in hexadecimal and there are different methods of
abbreviating the representation. Leading zeros can be omitted and one-and only
one- set of contiguous zero groups can be concatenated. The previous address
can be rewritten as:

```
2001:db8:a0b:12f0::8b6e
```

Subnets are still denoted in CIDR notation and they often cover half of the
available bits in the address space (`/64`). The portion of the address space
that's unique for each host is called the _interface ID_. Hosts normally have
at least two IPv6 addresses; the first, which is valid across the Internet, is
called the _global unicast address_ and the second, for the local network, is
called the _link-local address_. Link-local addresses always have an
`fe80::/10` prefix, followed by an all-zero 54 bit network ID, and end with a
64-bit interface ID. Global unicast addresses have the prefix `2000::/3`.

To view IP addresses in IPv6 use the `-6` argument

```bash
ip -6 address show
```

### Basic ICMP and DNS Tools

The Internet Control Message Protocol (ICMP) can help you find problems with
connectivity and routing. ICMP is a transport layer protocol used to configure
and diagnose Internet networks; it differs from other transport layer protocols
in that it does not carry any true user data and thus there is no application
layer above it. The Domain Name Service (DNS) system maps names to IP addresses
and is an application layer protocol used to map human-readable names to
Internet addresses.

#### `ping`

`ping` is one of the most basic network debugging tools. It sends ICMP echo
request packets to a host that asks a recipient host to return the packet to
the sender. If the recipient host receives the packet and is configured to
reply, it sends an ICMP echo response packet in return.

The most important part of the output are the sequence number (`icmp_seq`) and
the round-trip time (`time`). A gap in the sequence numbers usually means
there's some kind of connectivity problem.

#### DNS and host

To find the IP address behind a domain name, use `host`.

```bash
host www.example.com
```

### The Physical Layer and Ethernet

The Internet is a software network and because of this, it works on almost any
kind of computer, operating system, and physical network. However, in order to
communicate with another computer, a network layer on top of some kind of
hardware is necessary. This interface is the physical layer.

The most common kind of physical layer is an Ethernet network. The IEEE 802
family of standards documentation defines many different kinds of Ethernet
networks, from wired to wireless, but they all have a few things in common:

* All devices on an Ethernet network have a Media Access Control (MAC) address,
  sometimes called a hardware address. This address is independent of a host's
  IP address, and it is unique to the host's Ethernet network (but not
  necessarily a larger software network such as the Internet).
* Devices on an Ethernet network send messages in _frames_, which are wrappers
  around the data sent. A frame contains the origin and destination MAC
  addresses.

When configuring a network interface, you link the IP address settings from the
Internet side with the hardware identification on the physical device side.
Network interfaces usually have names that indicate the kind of hardware
underneath, such as _enp0s31f6_ (an interface in a PCI slot). A name like this
is called a _predictable network interface device name_, because it remains the
same after a reboot. At boot time, interfaces have traditional names such as
_eth0_ (the first Ethernet card in the computer) and _wlan0_ (a wireless
interface), but on most machines running `systemd`, they are quickly renamed.

`ip addr show` shows the network interface settings and the output is organised
by interface.

Each network interface gets a number and interface 1 is almost always the
loopback. A flag **UP** indicates that the interface is working. Although `ip`
shows some hardware information, it is designed primarily for viewing and
configuring the software layers attached to the interfaces. To dig deeper into
the hardware and physical layer behind a network interface, use something like
`ethtool` to display or change the settings on Ethernet cards.

### Introduction to Network Interface Configuration

The basic elements that go into the lower levels of a network stack include:

* The physical layer
* The network (internet) layer
* The Linux kernel's network interfaces

In order to combine these pieces to connect a Linux machine to the internet,
the following needs to be performed:

1. Connect the network hardware and ensure that the kernel has a driver for it.
   If the driver is present, `ip addr show` includes an entry for the device,
   even if it has not been configured.
2. Perform any additional physical layer setup, such as choosing a network name
   or password.
3. Assign IP address(es) and subnets to the kernel network interface so that
   the kernel's device drivers (physical layer) and internet subsystems
   (internet layer) can communicate with each other.
4. Add any additional necessary routes, including the default gateway.

#### Manually Configuring Interfaces

This is typically something you'd only do when experimenting with your system. You can bind an interface to the internet layer with the `ip` command. To add an IP address and subnet for a kernel network interface:

```bash
ip addr add address/subnet dev interface
```

`interface` is the name of the interface, such as _enp0s31f6_ or _eth0_.

Add routes, which is typically setting up the default gateway.

```bash
ip route add default via gw-address dev interface
```

`gw-address` is the IP address of your default gateway; it _must_ be an address
in a locally connected subnet assigned to one of your network interfaces.

To remove the default gateway.

```bash
ip route del default
```

### Network Configuration Managers

The most widely used option on desktops and notebooks for automatically
configuring networks is NetworkManager. There is an add-on to `systemd`, called
`systemd-networkd`, that can do basic network configuration and is useful for
machines that do not need much flexibility (such as servers) but it does not
have the dynamic capabilities of NetworkManager. Other network configuration
management systems are mainly targeted for smaller embedded systems, such as
OpenWRT's `netifd`, Android's ConnectivityManager service, ConnMan, and Wicd.

NetworkManager is a daemon that the system starts upon boot. Like most daemons,
it does not depend on a running desktop component. Its job is to listen to
events from the system and users and to change the network configuration based
on a set of rules.

NetworkManager maintains two basic levels of configuration. The first is a
collection of information about available hardware devices, which it normally
collects from the kernel and maintains by monitoring udev over the Desktop Bus
(D-Bus). The second configuration level is a more specific list of
_connections_: hardware devices and additional physical and network layer
configuration parameters. For example, a wireless network can be represented as
a connection.

To activate a connection, NetworkManager often delegates the tasks to other
specialised network tools and daemons, such as `dhclient`, to get internet
layer configuration from a locally attached physical network. NetworkManager
uses plug-ins to interface with network configuration tools and schemes since
they vary amount distributions.

Upon startup, NetworkManager gathers all available network device information,
searches its list of connections, and then decides to try to activate one.
Here's how it makes that decision for Ethernet interfaces:

1. If a wired connection is available, try to connect using it, otherwise try
   the wireless connections.
2. Scan the list of available wireless networks. If a network is available that
   you have previously connected to, NetworkManager will try it again.
3. If more than one previously connected wireless network is available, select
   the most recently connected.

After establishing a connection, NetworkManager maintains it until the
connection is lost, a better network becomes available, or the user forces a
change.

For a quick summary of your current connection status, use `nmcli` with no
arguments. A list of interfaces and configuration parameters will be shown. The
`nmcli` command allows you to control NetworkManager from the command line.
Check out `man nmcli-examples` to get usage examples of `nmcli`. The utility
`nm-online` will tell you whether the network is up or down; if the network is
up, the command returns 0 as its exit code and non-zero otherwise.

```bash
nm-online
# Connecting...............   30s [online]

echo $?
# 0
```

NetworkManager's general configuration directory is usually in
`/etc/NetworkManager` and there are several different kinds of configuration.
The general configuration file is `NetworkManager.conf` and the format is
similar to the XDG-style `.desktop` and Microsoft `.ini` files, with key-value
parameters falling into different sections. You will find that nearly every
config file has a `[main]` section that defines the plug-ins to use. For the
most part, you will not need to change `NetworkManager.conf` because the more
specific config options are found in other files.

TBC.

### Routers

Routers are specialised hardware consisting of an efficient processor, flash
memory, and several network ports. It has enough power to manage a typical
simple network, run important software such as a DHCP server and use NAT. Many
routers are powered by Linux and one manufacturer, Linksys, was required to
release the source code for its software under the terms of the license of one
of its components and soon specialised Linux distributions such as OpenWRT (WRT
came from the Linksys model number). As with many embedded systems, open
firmware typically use BusyBox to provide shell features. BusyBox is a single
executable program that offers limited functionality for many Unix commands
such as the shell, `ls`, `grep`, `cat`, and more.

### Firewalls

A _firewall_ is a software and/or hardware configuration that usually sits on a
router between the Internet and a smaller network that keeps undesirable
traffic out of the smaller network. You can also set up firewall features to
screen all incoming and outgoing data at the packet level. Firewalling on
individual machines is sometimes called _IP filtering_.

Firewalls put checkpoints for packets at the points of data transfer just
identified and drops, rejects, or accepts packets based on these criteria:

* The source or destination IP address or subnet.
* The source or destination port (in the transport layer information).
* The firewall's network interface.

A series of firewall rules known as a _chain_ are created and together form a
_table_. As a packet moves through the network, the kernel applies the rules
in certain chains to the packets. For example, a new packet arriving from the
physical layer is classified by the kernel as `input`, so it activates rules
in chains corresponding to `input`.

All of these data structures are maintained by the kernel. The whole system is
called `iptables`, with an iptables user-space command to create and manipulate
the rules.

A newer system called `nftables` is meant to replace `iptables` but `iptables`
is still the most widely used system. The command to administer nftables is
`nft` and there is an "iptables-to-nftables" translator called
`iptables-translate`.

Packet flow can become quite complicated since there can be many tables, each
with its own set of chains, which can contain many rules. However, you'll
normally work primarily with a single table named _filter_ that controls basic
packet flow. There are three basic chains in the filter table:

1. `INPUT` for incoming packets.
2. `OUTPUT` for outgoing packets.
3. `FORWARD` for routed packets.

View the current configuration.

```bash
iptables -L
# Chain INPUT (policy ACCEPT)
# target     prot opt source               destination
# …
```

Each firewall chain has a default _policy_ that specifies what to do with a
packet that matches no rules. The policy for the `INPUT` chain is to ACCEPT,
which means that the kernel will allow the packet to pass through the
packet-filtering system.

The DROP policy tells the kernel to discard the packet. To set the policy on a
chain, use `iptables -P`.

```bash
iptables -P FORWARD DROP
```

To prevent an IP from interacting with the server.

```bash
iptables -A INPUT -s 192.168.0.66 -j DROP
```

The `-A INPUT` parameter appends a rule to the INPUT chain. The `-s
192.168.0.66` specifies the source IP address in the rule and `-j DROP` tells
the kernel to discard any packets matching the rule.
