armbot
======

armbot is an irc bot written in armv6-linux-gnueabi assembler.

# features
- connect to a non-ssl irc server
- ping/pong
- join a channel
- respond to "armbot: source"

# motivation
lol

# requirements to run on x86_64
- `qemu-arm`
- `as`/`ld` with armv6 target
- (optional) `gdb` with armv6 target for debugging

It may be necessary to change the XPREFIX variable in the Makefile to match
the local cross-compilation binaries.

# running
    # you can conveniently change the server, port, name, nick, channel info
    # in the connect.s and handle_ident.s configuration files.
    make run
    # to run with arguments, copy the output and append desired arguments

# debugging
    make debug
    gdb armbot # in another terminal, you have to use a gdb with arm targeting
    (gdb) target remote localhost:9000
    (gdb) disas

# todo
- command line options
- modules in C
- ssl connectivity

# bugs
- there's a heisenbug in handle_ident.s, and that branch is skipped and
  replaced by a hack.

# resources
ARM Reference:
http://ozark.hendrix.edu/~burch/cs/230/arm-ref.pdf

ARM EABI: new syscall entry convention:
http://www.arm.linux.org.uk/developer/patches/viewpatch.php?id=3105/4

syscall numbers (for me) found in:
/usr/armv6j-hardfloat-linux-gnueabi/usr/include/asm/unistd.h

