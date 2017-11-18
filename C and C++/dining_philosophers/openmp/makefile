# the compiler : g++ for C++
CC = gcc

# compiler flags:
CFLAGS = -g -Wall -fopenmp

#build executable
TARGET = diningomp

all: $(TARGET)

$(TARGET): $(TARGET).c
	$(CC) $(CFLAGS) -o $(TARGET) $(TARGET).c

clean:
	$(RM) $(TARGET)