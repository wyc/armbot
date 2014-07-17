TARGET   = armbot
#XPREFIX  = armv6j-hardfloat-linux-gnueabi-
XPREFIX  = arm-unknown-linux-gnueabi-
AS       = $(XPREFIX)as
LD       = $(XPREFIX)ld
ASFLAGS  =
LDLAGS   = 

SOURCES  := main.s argv.s connect.s line.s util.s \
	handler.s handle_ident.s handle_ping.s handle_msg.s
HEADERS  := 
OBJECTS  := $(SOURCES:%.s=%.o)

EMU		 = qemu-arm
EMUFLAGS = -L /usr/arm-linux-gnueabihf/ -cpu arm1136
EMUDB    = -g 9000

all: $(TARGET)

$(TARGET): $(OBJECTS)
	$(LD) -o $@ $(LDLAGS) $(OBJECTS)

$(OBJECTS): %.o : %.s $(HEADERS)
	$(AS) $(ASFLAGS) -c $< -o $@

.PHONY: clean
clean:
	$(RM) $(OBJECTS) $(TARGET)

.PHONY: run
run: $(TARGET)
	$(EMU) $(EMUFLAGS) $(TARGET)

.PHONY: debug
debug: $(TARGET)
	$(EMU) $(EMUFLAGS) $(EMUDB) $(TARGET)
