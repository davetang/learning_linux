## Linux desktop system

From the beginning until recently, Linux desktops used X (X Window System, also
known as Xorg, after its maintaining organisation). However many distributions
have transitioned to a software set based on the Wayland protocol to build a
windowing system.

X is based on a [client-server
  model](https://www.cs.mcgill.ca/~rwest/wikispeedia/wpcd/wp/x/X_Window_System_protocols_and_architecture.htm)
but the server runs on the user's computer, while the clients run on the remote
machine; this is the reverse of common client-server systems.

> The communication protocol between server and client runs
  network-transparently: the client and server may run on the same machine or
  on different ones, possibly with different architectures and operating
  systems. A client and server can communicate securely over the Internet by
  tunneling the connection over an encrypted connection.

### Framebuffers

At the bottom of any graphical display mechanism is the _framebuffer_, which is
a chunk of memory that the graphics hardware reads and transmits to the screen
for display. A few individual bytes in the framebuffer represent each pixel of
the display, so if you want to change the way something looks, you write new
values to the framebuffer memory.

One problem that a windowing system must solve is how to manage writing to the
framebuffer. On any contemporary system, windows (or sets of windows) belong to
individual processes, doing all of their graphics updates independently. So if
the user is allowed to move windows around and overlap some on top of others,
how does an application know where to draw its graphics and how do you make
sure that one application isn't allowed to overwrite the graphics of other
windows?

#### The X Window System

The approach that the X Window System takes is to have a server (called the X
server) that acts as a sort of "kernel" of the desktop to manage everything
from rendering windows to configuring displays to handling input from devices,
such as keyboards and mice.

The X server does not dictate the way anything should act or appear. Instead, X
client programs handle the user interface. Basic X client applications, such as
terminal windows and web browsers, make connections to the X server and ask to
draw windows. In response, the X server figures out where to place the windows
and where to render client graphics, and it takes a certain amount of
responsibility for rendering graphics to the framebuffer. The X server also
channels input to a client when appropriate. The X server can be a significant
bottleneck because it acts as an intermediary for everything. In addition, it
includes a lot of functionality that is no longer used.

#### Wayland

Wayland is significantly decentralised by design unlike X. There is no large
display server managing the framebuffer for a number of graphical clients and
there's no centralised authority for rendering graphics. Instead, each client
gets its own memory buffer (like a sub-framebuffer) for its own window, and a
piece of software called a _compositor_ combines all of the client's buffers
into the necessary form for copying to the screen's framebuffer. There is
normally hardware support for this task making the compositor quite efficient.

If the `$WAYLAND_DISPLAY` environment variable is something like `wayland-0`,
then you are running Wayland. If it is not set, you are probably running X.

```console
echo $WAYLAND_DISPLAY
```

#### Window Managers

A major different between X and Wayland systems is in the _window manager_, the
piece of software that determines how to arrange windows on the screen and is
central to the user experience. In X, the window manager is a client that acts
as a helper to the server; it draws the window's decorations (such as title
bars and close buttons), handles input events to those decorations, and tells
the server where to move windows.

In Wayland the window manager is more or less the server. It is responsible for
compositing all of the client window buffers into the display framebuffer and
it handles the channeling of input device events. As a result, it is required
to do more work than a window manager in X, but much of that code can be common
between window manager implementations.

### Toolkits

Desktop applications include certain common elements, such as buttons and
menus, called _widgets_. To speed up development and provide a common look,
programmers use graphical toolkits to provide those elements. On operating
systems like Windows or macOS, the vendor provides a common toolkit, which most
programmers use. On Linux, the GTK+ toolkit is one of the most common, but you
will also frequently see widgets built on the Qt framework and others.

### Desktop Environments

Toolkits and other libraries are bundled into larger packages called _desktop
environments_. The environment ensures that different applications can work
together. GNOME, KDE, and Xfce are some common Linux desktop environments.

### Applications

At the top of the desktop are applications, such as web browsers and the
terminal. X applications can range from crude (`xclock` or `xeyes`) to complex
(the Firefox browser). These applications normally stand alone, but they often
use interprocess communication to become aware of pertinent events. For
example, an application can express interest when you attach a new storage
device or when you receive new email. This communication usually occurs over
D-Bus.

### A Closer Look at the X Window System

The [X Window System](https://x.org/wiki/) comes with the X server, client
support libraries, and clients. Due to the emergence of desktop environments
such as GNOME and KDE, the role of X has changed over time, with the focus now
more on the core server that managers rendering and input devices, as well as a
simplified client library.

The X server is called `X` or `Xorg` and you should be able to find it in a
process listing.

    Xorg -core :0 -seat seat0 -auth /var/run/lightdm/root/:0 -nolisten tcp vt7 -novtswitch

The `:0` is called the X display, an identifier representing one or more
monitors that you access with a common keyboard and/or mouse. For processes
running under an X session, the `DISPLAY` environment variable is set to the
display identifier.

An X server runs on a virtual terminal and in the example above, the `vt7`
argument shows that it has been told to run on `/dev/tty7` (normally the server
starts on the first virtual terminal available). You can run more than one X
server at a time on Linux by running them on separate virtual terminals, with
each server having a unique display identifier. You can switch between the
servers with the `chvt` command.

#### Display Managers

The most common way to start an X server is with a _display manager_, a program
that starts the server and puts a login box on the screen. When you log in, the
display manager starts a set of clients, such as a window manager and file
manager, so that you can start to use the machine.

Many different display managers are available, such as `gdm` (GNOME) and `kdm`
(KDE). The `lightdm` in the argument list for the previous X server example is
a cross-platform display manager meant to be able to start GNOME or KDE
sessions.

Run `startx` or `xinit` to start an X session from a virtual console instead of
using a display manager. The session you get will likely be very simple because
the mechanics and startup files are different than a display manager.

To get a list of all window IDs and clients, use `xlsclients -l`.

### D-Bus

The _Desktop Bus_ (D-Bus) is a message-passing system and is important because
it serves as an interprocess communication mechanism that allows desktop
applications to talk to each other. Most Linux systems use it to notify
processes of system events, such as when a USB drive has been inserted. D-Bus
itself consists of a library that standardises interprocess communication with
a protocol and supporting functions for any two processes to talk to each
other.
