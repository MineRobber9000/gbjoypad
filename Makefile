SOURCES:=$(wildcard *.asm)

OBJECTS:=$(patsubst %.asm,%.o,$(SOURCES))

all: joypad.gb

%.o: %.asm
	rgbasm -o $@ $<

joypad.gb: $(OBJECTS)
	rgblink -d -n joypad.sym -o $@ $^
	rgbfix -jv -k 01 -l 0x33 -m 0x01 -p 0 -r 0 -t JOYPAD_ROM $@

clean:
	rm -f $(OBJECTS) joypad.gb joypad.sym
