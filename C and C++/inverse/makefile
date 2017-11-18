# the compiler : g++ for C++
CC = gcc

# compiler flags:
CFLAGS = -g -Wall -fopenmp

#build executable
TARGET = matinv

all: build

build: $(TARGET)

$(TARGET): $(TARGET).c
	$(CC) $(CFLAGS) -o $(TARGET) $(TARGET).c -lrt -lm

run: $(TARGET)
	 ./$(TARGET) 

clean:
	$(RM) $(TARGET)	