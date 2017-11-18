#include <stdio.h>
#include <string.h>
#include <stddef.h>
#include <stdlib.h>
#include <ucontext.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <signal.h>
#include <errno.h>


struct MemoryRegion
{
  void *startAddr;
  void *endAddr;
  int isReadable;
  int isWriteable;
  int isExecutabl;
  size_t size;
};


 
void checkpoint(int signal_id)
{
	FILE* inputfile;
	int ret;
	int fd_outputfile;
	char* lineptr;
	char *addressrange;
	char *permissions;
	void *currentstartAddr;
	void *tempptr = NULL ;
	size_t len=0,read=0;
	ssize_t bytes_written=0;
	size_t regionsize = 0;
	size_t startAddr=0;
	size_t endAddr=0;
	int isckpt = 1;
	ucontext_t currentcontext;
	struct MemoryRegion myregion;
	
	
	ret = getcontext(&currentcontext);
	if(ret!=0)
	{
		printf("get Context failed error code %d\n",errno);
		return;
	}

	if(isckpt)
	{                 
		isckpt = 0;
		inputfile=fopen("/proc/self/maps","r");
		if (inputfile == NULL)
		{
			printf("Cannot open /proc/self/maps. Exiting");
			exit(0);
		}
		fd_outputfile=open("myckpt",O_CREAT|O_WRONLY,S_IRUSR | S_IWUSR);
		if (fd_outputfile == -1)
		{
			printf("Cannot create and open a new file. Exiting");
			exit(0);
		}
		bytes_written = write(fd_outputfile,&currentcontext,sizeof(ucontext_t));
		if(bytes_written == -1)
		{
			printf("Cannot Write Current Context to checkpoint File. Exiting");
			exit(0);
		}
		while( (read=getline(&lineptr,&len,inputfile))!= -1)
		{
			if (strstr(lineptr, "vsyscall") != NULL)
				continue;
			if (strstr(lineptr, "vvar") != NULL)
				continue;  
			if (strstr(lineptr, "vdso") != NULL)
				continue;  
			addressrange = strtok(lineptr," ");
			permissions =strtok(NULL," ");
			startAddr = strtoul((char*)strtok(addressrange,"-"),NULL,16);
			endAddr= strtoul((char*)strtok(NULL,"-"),NULL,16) ;
			myregion.size= endAddr-startAddr;
			myregion.startAddr= (void*)startAddr;
			myregion.endAddr=(void*) endAddr;
			if (permissions[0] == 'r')
				 myregion.isReadable = 1;
			else 
				 myregion.isReadable = 0;
			if (permissions[1] == 'w')
				 myregion.isWriteable = 1;
			else 
				 myregion.isWriteable = 0;
			if (permissions[2] == 'x')
				 myregion.isExecutabl = 1;
			else 
				 myregion.isExecutabl = 0;			
			if(myregion.isReadable) 
			{ 									   
				bytes_written = write(fd_outputfile,&myregion,sizeof(struct MemoryRegion));
				if(bytes_written == -1)
				{
					printf("Cannot Write Memory Section header to checkpoint File. Exiting");
					exit(0);
				}
				bytes_written = write(fd_outputfile,myregion.startAddr,myregion.size);
				if(bytes_written == -1)
				{
					printf("Cannot Write Memory Section Contents to checkpoint File. Exiting");
					exit(0);
				}
				regionsize = myregion.size;
				currentstartAddr  = myregion.startAddr;
				while (bytes_written != regionsize)
				{
					tempptr = currentstartAddr + bytes_written;
					regionsize = (regionsize-bytes_written);
					bytes_written = write(fd_outputfile,tempptr,regionsize);
					if(bytes_written == -1)
					{
						printf("Cannot Write Memory Section Contents to checkpoint File. Exiting");
						exit(0);
					}
					currentstartAddr = tempptr;
				}
			}
		}	
		
		ret = fclose(inputfile);
		if(ret != 0)
			printf("/proc/self/maps is not closed properly.");
		ret = fsync(fd_outputfile);
		if(ret == -1)
			printf("fsyn for Checkpoint image failed.");
		ret = close(fd_outputfile);
		if(ret == -1)
			printf("Checkpoint image cannot be closed properly.");
	}
}

__attribute__ ((constructor))
void myconstructor() {
   signal(SIGUSR2, checkpoint);  
}
