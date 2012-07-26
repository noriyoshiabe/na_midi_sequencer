OUT_DIR = bin
TARGET = ${OUT_DIR}/midi
SRC    = midi/main.m

CC   = gcc
LIBS = -framework CoreAudio -framework CoreMidi -framework Foundation

${DIR}: ${OUT_DIR}
	mkdir ${OUT_DIR}

${TARGET}: $(SRC) ${DIR}
	$(CC) $(LIBS) -o $@ $<

clean:
	rm ${TARGET}

