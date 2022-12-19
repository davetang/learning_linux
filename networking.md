## Networking

Notes from Chapter 9 of [How Linux Works, 3rd Edition](https://nostarch.com/howlinuxworks3).

Networking is connecting computers and sending data between them. But how does the computer sending the data know _where_ to send the data and how does the computer that received the data know _what_ it received? Computers use different components that are responsible for sending, receiving, and identifying data. These components are arranged in groups that form _network layers_, which stack on top of each other to form a complete system. Each layer is typically independent and it's possible to build networks with many different combinations of components.

### Basics

A simple network might have three hosts (A, B, and C) and a router connected together in a Local Area Network (LAN). The router, also known as a _gateway_, is also connected to the Internet via an _uplink_ connection, which is also known as the Wide Area Network (WAN) connection, since it links the smaller LAN to a larger network. The computers on the LAN can access the Internet via the router.

Data is transmitted over a network in small chunks called _packets_, which consists of a _header_ and a _payload_. The header contains identifying information such as the source and destination host machines and the basic protocol. The payload contains the actual application data that is sent, such as HTML. A host can send, receive, and process packets in any order, which makes it possible for several hosts to communicate simultaneously. You typically do not have to worry about translating packets because the operating system takes care of that.

### Network layers

A fully functioning network includes a set of network layers called a _network stack_. The typical Internet stack, from the top to bottom layer, looks like this:

* **Application layer** - contains the language that applications and servers use for communication, which is usually a high-level protocol. Common application layer protocols include HTTP (web protocol), TLS (encryption protocol), FTP (file protocol). Application layer protocols can often be combined such as TLS used in conjunction with HTTP forms HTTPS.
* **Transport layer** - defines the data transmission characteristics of the application layer. This layer includes data integrity checking, source and destination ports, and specifications for breaking application data into packets at the host side (if this hasn't already been done by the application layer), and reassembling them at the destination. Transmission Control Protocol (TCP) and User Datagram Protocol (UDP) are the most common transport layer protocols. The transport layer is sometimes called the _protocol layer_.
* **Network or internet layer** - defines how to move packets from a source to a destination. The particular packet transit rule set for the internet is known as the _Internet Protocol_ (IP).
* **Physical layer** - defines how to send raw data across a physical medium, such as Ethernet or a modem. This is sometimes called the _link layer_ or _host-to-network layer_.

It is important to understand the structure of a network stack because your data must travel through these layers at least twice before it reaches a program at its destination. For example, when sending data from Host A to Host B, the bytes leave the application layer on Host A and travel through the transport and network layers on Host A; then they go down to the physical medium, across the medium, and up again through the various lower levels to the application layer on Host B.

#### The Internet layer

The Internet is currently based on version 4 (IPv4) and 6 (IPv6) of the Internet Protocol. One of the most important aspects of the internet layer is that it is meant to be a software network that places no particular requirements on hardware or operating systems. The idea is that you can send and receive Internet packets over any kind of hardware, using any operating system.

The Internet's topology is decentralised; it is made up of smaller networks called _subnets_ that are all interconnected in some way. A host can be attached to more than one subnet; for example, a router can transmit data from one subnet (the LAN) to another.

Each Internet host has at least one numeric IP address. For IPv4, it is in the form of a.b.c.d, such as 8.8.8.8, and consists of 4 bytes (or 32 bits). Bytes a and d are numbers from 1 to 254, and b and c are numbers from 0 to 255. An address in this notation is called a _dotted-quad_ sequence but a computer processes IP addresses as raw bytes. If a host is connected to multiple subnets, it has at least one IP address per subset. Each host's IP address should be unique across the entire internet. To communicate with another host, your machine needs to know the other host's IP address.

One machine can have many IP addresses to accommodate multiple physical interfaces, virtual internal networks, and more. Use `ip address show` to output active addresses; the output will be grouped by physical interface. The `ip` command's output includes many details from the internet layer(s) and the physical layer.

A subset is a connected group of hosts with IP addresses in a particular range. For example, the hosts in the range 10.23.2.1 to 10.23.2.254 could comprise a subnet. Usually the subnet hosts are on the same physical network. A subnet is defined with two pieces of information:

1. _Network prefix_ (also called a _routing prefix_)
2. _Subnet mask_ (also called the _network mask_ or _routing mask_).

For example, a subnet containing the IP addresses between 10.23.2.1 and 10.23.2.254 has a network prefix of 10.23.2.0 (the part that is common to all addresses in the subnet) and a subnet mask of 255.255.255.0 (the mask marks the bit locations in an IP address that are common to the subnet). This makes more sense in binary and below are the binary forms of 10.23.2.0 and 255.255.255.0:

```
00001010 00010111 00000010 00000000
11111111 11111111 11111111 00000000
```

A bitwise AND will return:

```
00001010 00010111 00000010 00000000
```

which lists the bit configuration of any address in the subnet. This is denoted as 10.23.2.0/255.255.255.0.

In most Internet tools, the Classless Inter-Domain Routing (CIDR) notation is used, which denotes 10.23.2.0/255.255.255.0 as 10.23.2.0/24. The CIDR notation simply identifies the subnet mask by the number of _leading_ 1s (when in binary form) in the subnet mask. For example:

|  Long form  |            Binary form              | CIDR form |
| ----------- | ----------------------------------- | --------- |
| 255.0.0.0   | 11111111 00000000 00000000 00000000 |     /8    |
| 255.240.0.0 | 11111111 11110000 00000000 00000000 |     /12   |
| 255.255.0.0 | 11111111 11111111 00000000 00000000 |     /16   |

#### Routes and the Kernel Routing Table

Connecting Internet subnets is mostly a process of sending data through hosts connected to more than one subnet. The Linux kernel distinguishes between different kinds of destinations (LAN vs. WAN) by using a _routing table_ to determine its routing behaviour. Use `ip route show` to show the routing table; the output will display each line as a routing rule.

```bash
ip route show
# default via 10.23.2.1 dev enp0s31f6 proto static metric 100
# 10.23.2.0/24 dev enp0s31f6 proto kernel scope link src 10.23.2.4 metric 100
```

The output of the first line has the destination network `default`. This rule, which matches any host, is also called the _default route_. The mechanism is via `10.23.2.1`, which indicates that traffic using the default route is to be sent to `10.23.2.1`; `dev enp0s31f6` indicates that the physical transmission will happen on that network interface.

The `default` entry in the routing table has special significance because it matches any address on the Internet; in CIDR notation, it's `0.0.0.0/0` for IPv4. This is the default route, and the address configured as the intermediary in the default route is the _default gateway_. When no other rules match, the default route always does, and the default gateway is where you send messages when there is no other choice. On most networks with a netmask of `/24` (255.255.255.0), the router is usually at address 1 of the subnet but this is simply a convention and not a hard rule.

The output on the second line shows the destination network `10.23.2.0/24`, which is the host's local subnet. This rule says that the host can reach the local subnet directly through its network interface, indicated by the `dev enp0s31f6` mechanism label.

When a host wants to send something to `10.23.2.132`, which matches both rules in the routing table, the order in the routing table does not matter. The kernel will choose the longest destination prefix that matches. `10.23.2.0/24` matches but its prefix is 24 bits long whereas `0.0.0.0/0` matches, but its prefix is 0 bits long because it has no prefix. Therefore the rule for `10.23.2.0/24` takes priority.

#### Ipv6 addresses and networks

IPv4 addresses consist of 32 bits (4 bytes) yielding roughly 4.3 billion addresses, which is insufficient for the number of devices currently connected to the Internet. An IPv6 address has 128 bits, 16 bytes arranged in eight sets of 2 bytes. In long form an address is written as:

```
2001:0db8:0a0b:12f0:0000:0000:0000:8b6e
```

The representation is in hexadecimal and there are different methods of abbreviating the representation. Leading zeros can be omitted and one-and only one- set of contiguous zero groups can be concatenated. The previous address can be rewritten as:

```
2001:db8:a0b:12f0::8b6e
```

Subnets are still denoted in CIDR notation and they often cover half of the available bits in the address space (`/64`). The portion of the address space that's unique for each host is called the _interface ID_. Hosts normally have at least two IPv6 addresses; the first, which is valid across the Internet, is called the _global unicast address_ and the second, for the local network, is called the _link-local address_. Link-local addresses always have an `fe80::/10` prefix, followed by an all-zero 54 bit network ID, and end with a 64-bit interface ID. Global unicast addresses have the prefix `2000::/3`.

To view IP addresses in IPv6 use the `-6` argument

```bash
ip -6 address show
```

