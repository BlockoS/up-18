AS = ~/Dev/bin/pceas
SRCDIR = ./src
INCLUDE = -I . -I ./src/ -I ./include/
EMU = mednafen

all: main.pce

main.pce:
	$(AS) -S -l 3 $(INCLUDE) -raw ./src/main.asm 

run:
	$(EMU) $(SRCDIR)/main.pce

clean:
	rm $(SRCDIR)/*.sym
