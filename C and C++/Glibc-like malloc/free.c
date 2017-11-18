#include "malloc.h"
#include <stdint.h>
#include<stdio.h>
#include "myalloc.h"
#include "linkedlist.h"
#include<sys/types.h>
extern pthread_mutex_t allocationmutex;

int is_pointer_invalid(void * ptr)
{
	struct block_header * blockheader = NULL;
	blockheader = (struct block_header*)(ptr - sizeof(struct block_header));
	if((uintptr_t)blockheader != 0x88888888)
		return 1;
	else
		return 0;
}


void free(void *ptr)
{

	pthread_mutex_lock(&allocationmutex);
	if(ptr == NULL)
	{
	    pthread_mutex_unlock(&allocationmutex);
		return;
	}
	if(is_pointer_invalid(ptr))
	{   pthread_mutex_unlock(&allocationmutex);
		return;
	}
	struct block_header * blockheader = NULL;
	blockheader = (struct block_header*)(ptr - sizeof(struct block_header));
	add_to_free_list(blockheader->chunk_size,ptr);
    pthread_mutex_unlock(&allocationmutex);
}

