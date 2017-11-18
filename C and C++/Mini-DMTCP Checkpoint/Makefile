#Sample Makefile

all:	check

default: check
	
clean-ckpt:
	rm -rf myckpt

clean: clean-ckpt
	rm -rf myrestart hello.o hello ckpt ckpt.o libckpt.so

ckpt.o: ckpt.c
	gcc -c -Wall -Werror -fno-stack-protector -fpic -o ckpt.o ckpt.c

libckpt.so: ckpt.o
	gcc -shared -o libckpt.so ckpt.o

hello.o: hello.c
	gcc -c -Wall -Werror -fno-stack-protector -fpic -o hello.o hello.c

hello:	hello.o
	gcc -g -o hello hello.o

restart: myrestart.c
	 gcc -g -static -fno-stack-protector -Wl,-Ttext-segment=5000000 -Wl,-Tdata=5100000 -Wl,-Tbss=5200000 -o myrestart myrestart.c;\
        ./myrestart myckpt

gdb:
	gdb --args ./restart myckpt

build: 

check:	clean libckpt.so hello
	(sleep 3 && kill -12 `pgrep -n hello` && sleep 2 && pkill -9 -n hello && make restart) &
	LD_PRELOAD=`pwd`/libckpt.so ./hello

dist:
	dir=`basename $$PWD`; cd ..; tar cvf $$dir.tar ./$$dir; gzip $$dir.tar
