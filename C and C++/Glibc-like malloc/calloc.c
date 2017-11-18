#include<stddef.h>
#include<malloc.h>
#include <string.h>
extern pthread_mutex_t allocationmutex;
void *calloc(size_t n, size_t size)
{
	void * retaddress;
	size_t total = n * size;
	void *p = malloc(total);
	pthread_mutex_lock(&allocationmutex);
	if ( p == NULL) {
		 pthread_mutex_unlock(&allocationmutex);
		 return NULL;
	}
	retaddress = memset(p, 0, total);
	pthread_mutex_unlock(&allocationmutex);
	return retaddress;
}
