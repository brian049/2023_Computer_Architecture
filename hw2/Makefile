.PHONY: clean

include ../../mk/toolchain.mk

CFLAGS = -march=rv32g -Os

OBJS = \
    getcycles.o \
    getinstret.o \
    bfmul.o \
    main.o
BIN = bfmul.elf

%.o: %.S
	$(CROSS_COMPILE)gcc $(CFLAGS) -c -o $@ $<

%.o: %.c
	$(CROSS_COMPILE)gcc $(CFLAGS) -c -o $@ $<
	
all: $(BIN)

$(BIN): $(OBJS)
	 $(CROSS_COMPILE)gcc -o $@ $^

clean:
	$(RM) $(BIN) $(OBJS)
