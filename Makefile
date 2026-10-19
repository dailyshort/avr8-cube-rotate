MCU      := attiny85
SRC		 := main.S vectors.S i2c_display.S pipeline.S math.S
BUILD_DIR:= build
TARGET   := $(BUILD_DIR)/rotate

CC       := avr-gcc
OBJCOPY  := avr-objcopy
OBJDUMP  := avr-objdump
SIZE     := avr-size

ASFLAGS  :=
LDFLAGS  := -nostartfiles -nostdlib
DEBUGFLAGS :=
MAPFLAGS  := -Wl,-Map,$(TARGET).map -Wl,--cref

all: $(TARGET).hex

$(BUILD_DIR):
	mkdir -p $@

$(TARGET).elf: $(SRC) include/asm_defs.inc | $(BUILD_DIR)
	$(CC) -mmcu=$(MCU) $(ASFLAGS) $(LDFLAGS) $(DEBUGFLAGS) $(MAPFLAGS) -o $@ $(SRC)

$(TARGET).hex: $(TARGET).elf
	$(OBJCOPY) -O ihex -R .eeprom $< $@
	$(SIZE) $<
	$(OBJDUMP) -d -S -C $< > $(TARGET).lst

flash: $(TARGET).hex
	avrdude -c dragon_isp -p t85 -P usb -U flash:w:$<

clean:
	rm -rf $(BUILD_DIR)

.PHONY: all clean
