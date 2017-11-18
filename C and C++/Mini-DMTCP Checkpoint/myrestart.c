#include <stdio.h>
#include <string.h>
#include <stddef.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <unistd.h>
#include <errno.h>
#include <ucontext.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

char checkpointfile[1000];
ucontext_t restorecontext;
/* stack address and size of the current program to be unmapped
cannot be placed in stack. Hence global Scope*/
void* restartstackAddr;
size_t restartstacksize;

struct MemoryRegion
{
  void *startAddr;
  void *endAddr;
  int isReadable;
  int isWriteable;
  int isExecutabl;
  size_t size;
};
 
void restore_memory()
{

	/* Stack Unmpapping Declaration */	
	int ret=-1;

	/*Copying Context declaration*/
	int fd_inputfile;
	ssize_t bytes_read=0;

	/*  Copying Memory  declaration*/
	struct MemoryRegion restoreregion;
	void * regionStartAddr = NULL;
	int prot = 0;
	size_t regionsize=0;
	void* currentstartAddr;
	void * tempptr;

	/* Current Stack Unmpapping Definition */
	/*Unmap the stack used by the myrestart program. 
	The reason is that the stack might be located at an address range that conflicts 
	with what the target program was using prior to checkpointing. 
	Since the goal is to restore the memory as it existed at checkpoint time, 
	the conflicting addresses can lead to hard to debug problems.*/

	
	ret =  munmap((void *)restartstackAddr, restartstacksize);
	if(ret == -1)
	{
		printf("Restart Stack unmap failed with errno %d startaddress %p size %lx\n",errno,(void*)restartstackAddr,restartstacksize);
	}

	/* Copying Context Definition*/
	fd_inputfile=open(checkpointfile,O_RDONLY);		
	if (fd_inputfile == -1)
	{
		printf("Cannot create and open a new file. Exiting");
		exit(0);
	}
	/*Copy the registers from the file header of the checkpoint image file 
	into some pre-allocated memory in your data segment*/
	bytes_read = read(fd_inputfile , &restorecontext, sizeof(ucontext_t));
	if(bytes_read == -1)
	{
		printf("Cannot Read Current Context from checkpoint File. Exiting");
		exit(0);
	}
	/*  Copying Memory Map Definition*/
	bytes_read=read(fd_inputfile,&restoreregion,sizeof(struct MemoryRegion));
	if(bytes_read == -1)
	{
		printf("Cannot Read Memory region header from checkpoint File. Exiting");
		exit(0);
	}
	while( bytes_read != 0)
	{
		if(bytes_read == -1)
		 {
		   printf("Error Number %d\n",errno);
		   return;
		 }
		 if(restoreregion.isReadable)
			prot |=  PROT_READ;
		 if(restoreregion.isWriteable)
			prot |=  PROT_WRITE;
		 if(restoreregion.isExecutabl)
			prot |=  PROT_EXEC;
		 
		 /*Copy the data from the memory sections of the checkpoint image into the corresponding memory sections.*/
		 regionStartAddr = mmap(restoreregion.startAddr, restoreregion.size, PROT_READ|PROT_WRITE|PROT_EXEC,MAP_PRIVATE | MAP_ANON, -1, 0);
		 if (regionStartAddr == MAP_FAILED)
		 {
			printf("Map failed\n");
			return;
		 }
		bytes_read = read(fd_inputfile , regionStartAddr, restoreregion.size);
		if(bytes_read == -1)
		{
			printf("Cannot Read Memory Region Contents from checkpoint File. Exiting");
			exit(0);
		}
		regionsize = restoreregion.size;
		currentstartAddr  = restoreregion.startAddr;
		while (bytes_read != regionsize)
		{
			tempptr = currentstartAddr+ bytes_read;
			regionsize = (regionsize-bytes_read);
			bytes_read = read(fd_inputfile,tempptr,regionsize);
			if(bytes_read == -1)
			{
				printf("Cannot Read Memory Region Contents from checkpoint File. Exiting");
				exit(0);
			}
			currentstartAddr = tempptr;
		}
		bytes_read=read(fd_inputfile,&restoreregion,sizeof(struct MemoryRegion));
	}
	ret = close(fd_inputfile);
	if(ret == -1)
		printf("Checkpoint image cannot be closed properly.");
	/*Jump into the old program and restore the old registers*/
	ret = setcontext(&restorecontext);
	if(ret == -1)
	{
		printf("setContext failed error code %d\n",errno);
		return;
	}
}


int main(int argc,char** argv)
{
	void *stack_address;
	/* Get existing Stack Information Declaration */
	FILE* inputfile;
	char* lineptr;	
	size_t len=0;
	char* addressrange;
	size_t startAddr;
	size_t endAddr;	
	size_t readb=0;
	int ret=-1;

    inputfile=fopen("/proc/self/maps","r");
	if (inputfile == NULL)
	{
		printf("Cannot open /proc/self/maps. Exiting");
		exit(0);
	}
	while((readb=getline(&lineptr,&len,inputfile))!= -1)
	{
	   if (strstr(lineptr, "stack") != NULL)
	   {        
		   addressrange = strtok(lineptr," ");
		   startAddr = strtoul((char*)strtok(addressrange,"-"),NULL,16);
		   endAddr = strtoul((char*)strtok(NULL,"-"),NULL,16);
		   restartstackAddr = (void*)startAddr ;
		   restartstacksize= endAddr-startAddr;                			   
		   break;
	   }
	   else
		 continue;
	}
        
	// Map in some new memory for a new stack
	stack_address = mmap((void *) 0x5300000, 4096, PROT_READ|PROT_WRITE|PROT_EXEC,MAP_PRIVATE | MAP_ANON, -1, 0);
	if (stack_address == MAP_FAILED)
	{
		printf("Map failed\n");
		return -1;
	}
	strcpy(checkpointfile,argv[1]);
	stack_address = stack_address + 4096;

	// set the stack pointer
	asm volatile ("mov %0,%%rsp" : : "g" (stack_address) : "memory");
	restore_memory();
}
