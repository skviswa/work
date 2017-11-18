# the compiler : g++ for C++
CC = gcc

# compiler flags:
CFLAGS = -g -Wall -lpthread

#build executable
TARGET = diningphilosopher

all: $(TARGET)

$(TARGET): $(TARGET).c
	$(CC) $(CFLAGS) -o $(TARGET) $(TARGET).c

clean:
	$(RM) $(TARGET)

