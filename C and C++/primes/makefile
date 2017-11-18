# the compiler : g++ for C++
CC = gcc

# compiler flags:
CFLAGS = -std=gnu99 -g -Wall -lpthread -lm -lrt

#build executable
TARGET = primes

all: $(TARGET)

$(TARGET): $(TARGET).c
	$(CC) $(CFLAGS) -o $(TARGET) $(TARGET).c

clean:
	$(RM) $(TARGET)

