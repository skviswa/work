#Sample Makefile for Malloc
CC=gcc
CFLAGS=-g -O0 -fPIC   
LFLAGS=-L`pwd`
all:	check

clean:
	rm -rf libmalloc.so malloc.o linkedlist.o free.o test1 test1.o  test2 test2.o ttest1 t-test1.o  calloc.o realloc.o core helper.o 

libmalloc.so: linkedlist.o malloc.o free.o calloc.o realloc.o helper.o
	$(CC) $(CFLAGS) -shared -Wl,--unresolved-symbols=ignore-all linkedlist.o helper.o malloc.o free.o calloc.o realloc.o -o $@

test1: test1.o
	 $(CC) $(CFLAGS) $(LFLAGS) -Wall  -I. $< -o $@ -lmalloc

ttest1: t-test1.o
	 $(CC) $(CFLAGS) $(LFLAGS) -Wall  -I. $< -o $@ -lmalloc -lpthread
ttest2: t-test1.o
	 $(CC) $(CFLAGS) $(LFLAGS) -Wall  -I. $< -o $@ -lpthread
%.o: %.c
	$(CC) $(CFLAGS) $< -c -I. -o $@ 

check:	clean libmalloc.so test1
	LD_LIBRARY_PATH=`pwd` LD_PRELOAD=`pwd`/libmalloc.so ./test1 
	
check-ttest1:	clean libmalloc.so ttest1
	LD_LIBRARY_PATH=`pwd` LD_PRELOAD=`pwd`/libmalloc.so ./ttest1 
	
check-ttest1-malloc:clean ttest2
	./ttest2
	
dist:
	dir=`basename $$PWD`; cd ..; tar cvf $$dir.tar ./$$dir; gzip $$dir.tar
