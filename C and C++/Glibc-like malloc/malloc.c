
#include "malloc.h"
#include "linkedlist.h"
#include<sys/types.h>
struct available_chunk memoryinventory;
struct available_chunk freelistinventory;
extern struct free_list * bin_16;
extern struct free_list * bin_64;
extern struct free_list * bin_512;
extern struct free_list * largebins;
extern int blockscount[4];
extern int usedblocks[4];
pthread_mutex_t allocationmutex;

__attribute__ ((constructor))
void myconstructor() {
	pthread_mutex_init ( &allocationmutex, NULL);
	memoryinventory.chunk_address = NULL;
	memoryinventory.chunk_size=0;
	freelistinventory.chunk_address = NULL;
	freelistinventory.chunk_size=0;
}


void *malloc(size_t size)
{
	int ret = -1;
	int bin =0;
	void * kernel_return_address = NULL;
	void * malloc_return_address = NULL;
	size_t actualblock_size = 0;
	actualblock_size += size + sizeof(struct block_header);
    pthread_mutex_lock(&allocationmutex);
	if(actualblock_size > 512){
		if (largebins == NULL){
			kernel_return_address =  mmap(NULL, actualblock_size , PROT_READ | PROT_WRITE, MAP_ANONYMOUS | MAP_PRIVATE, -1, 0);
			if(kernel_return_address == MAP_FAILED){
				perror("Memory allocation in heap failed");
				return NULL;
			}else{
				fill_in_block_header(kernel_return_address,actualblock_size);
				kernel_return_address= kernel_return_address + sizeof(struct block_header) ;
			}
			blockscount[LARGE] +=1;
			usedblocks[LARGE] +=1;
		}
		else{
			kernel_return_address = find_free_block(actualblock_size);
		}
	}else{
		if(actualblock_size <= 16){
			if(bin_16 == NULL)
				kernel_return_address = balloc(actualblock_size);
			else
				kernel_return_address = find_free_block(actualblock_size);
			blockscount[SIXTEEN] +=1;
			usedblocks[SIXTEEN] +=1;
		}else if(actualblock_size <= 64){
			if(bin_64 == NULL)
				kernel_return_address = balloc(actualblock_size);
			else
				kernel_return_address = find_free_block(actualblock_size);
			blockscount[SIXTYFOUR] +=1;
			usedblocks[SIXTYFOUR] +=1;
		}else{
			if(bin_512 == NULL)
				kernel_return_address = balloc(actualblock_size);
			else
				kernel_return_address = find_free_block(actualblock_size);
			blockscount[FIVETWELVE] +=1;
			usedblocks[FIVETWELVE] +=1;
		}
	}
		pthread_mutex_unlock(&allocationmutex);
		return kernel_return_address;
}
