#include<stddef.h>
#include <string.h>
#include "malloc.h"
#include "linkedlist.h"
extern pthread_mutex_t allocationmutex;

void *realloc(void *ptr, size_t size){

	int available_space = 0;
	size_t chunk_size = 0;

	if(ptr == NULL)
		return malloc(size);
	if(size == 0)
		free(ptr);
	pthread_mutex_lock(&allocationmutex);

	chunk_size = get_chunk_size(ptr);
	available_space = get_chunk_remaining_size(ptr);
	if (size <= chunk_size)
		{
		update_chunk_size(ptr,size);
		pthread_mutex_unlock(&allocationmutex);
		return ptr;
		}
	else if(available_space >= (size-chunk_size))
		{
		update_chunk_size(ptr,size);
		pthread_mutex_unlock(&allocationmutex);
		return ptr;
		}
	else
	{
		pthread_mutex_unlock(&allocationmutex);
		void *p = malloc(size);
		pthread_mutex_lock(&allocationmutex);
		if (p == NULL)
			return NULL;
		memcpy(p,ptr,chunk_size);
		pthread_mutex_unlock(&allocationmutex);
		free(ptr);
		return p;
	}


}
