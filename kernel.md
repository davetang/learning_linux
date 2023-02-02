## The Kernel

The kernel is the core of the operating system. It is software residing in
memory that acts as a mediator between the hardware (especially main memory)
and any running program. The kernel runs in kernel mode and has unrestricted
access to the processor and main memory. The memory area that only the kernel
can access is called the _kernel space_.

The kernel is in charge of managing tasks in four general system areas:

1. Processes - the kernel determines which processes are allowed to use the CPU.

Only one process can actually use the CPU at any given time. In practice, each
process uses the CPU for a small fraction of time, then pauses; then another
process uses the CPU, and so on. _Context switching_ is when one process gives
up control of the CPU to another process. Each piece of time is called a _time
slice_ and provides a process computational time. The kernel is responsible for
context switching.

2. Memory - the kernel keeps track of all memory; what is currently allocated,
   what is shared, and what is free.

The kernel must manage memory during a context switch and in order to carry out
this complex job the following conditions must hold:

* The kernel must have its own private area in memory that user processes can't
  access.
* Each user process needs its own section of memory.
* One user process may not access the private memory of another process.
* User processes can share memory.
* Some memory in user processes can be read-only.
* The system can use memory than is physically present by using disk space.

3. Device drivers - the kernel acts as an interface between hardware and
   processes. It is usually the kernel's job to operate the hardware.

A device is typically accessible only in kernel mode but a notable difficulty
is that different devices rarely have the same programming interface.

4. System calls and support - processes normally use system calls to
   communicate with the kernel.

_System calls_ perform specific tasks that a user process alone cannot do well
or at all. For example opening, reading, and writing files all involve system
calls. Two examples of system calls include:

* `fork()` - when a process calls `fork()`, the kernel creates a nearly
  identical copy of the process
* `exec()` - when a process calls `exec(program)`, the kernel loads and starts
  `program`, replacing the current process.

The kernel also supports user processes with features other than traditional
system calls, the most common of which are _pseudodevices_, which look like
devices to user processes but are implemented purely in software. An example is
the kernel random number generator device (`/dev/random`).
