#include "myalloc.h"
#include "linkedlist.h"
#include<sys/types.h>
#include <unistd.h>
#include <string.h>
#include <stdio.h>
#include <stddef.h>
#include <sys/mman.h>
#include <stdint.h>
extern struct available_chunk memoryinventory;

void fill_in_block_header(void * kernel_return_address,size_t size){
	struct block_header current_block;
	current_block.chunk_size = size;
	current_block.next_block = NULL;
	current_block.magicnumber = 0x88888888;
	memcpy(kernel_return_address,&current_block,sizeof(struct block_header));
}

void *memory_from_inventory(size_t ssize)
{
	void * returnaddress = NULL;
	if(memoryinventory.chunk_size > ssize){
		if((((uintptr_t)memoryinventory.chunk_address) % 8) != 0){
				uintptr_t offset = (((uintptr_t)memoryinventory.chunk_address ))% 8;
				memoryinventory.chunk_address+= (8-offset);
				memoryinventory.chunk_size -= (8-offset);
			}
		}
	if(memoryinventory.chunk_size < ssize){
		if(memoryinventory.chunk_size!=0 && (memoryinventory.chunk_size>sizeof(struct block_header)) )
			{
			fill_in_block_header(memoryinventory.chunk_address,memoryinventory.chunk_size);
			add_to_free_list(memoryinventory.chunk_size,memoryinventory.chunk_address+sizeof(struct block_header));
			}
		memoryinventory.chunk_address = sbrk(sysconf(_SC_PAGESIZE));
		memoryinventory.chunk_size = sysconf(_SC_PAGESIZE);
		if((((uintptr_t)memoryinventory.chunk_address) % 8) != 0){
			uintptr_t offset = ((uintptr_t)memoryinventory.chunk_address) % 8;
			memoryinventory.chunk_address+= (8-offset);
			memoryinventory.chunk_size -= (8-offset);
		}
	}
	returnaddress = memoryinventory.chunk_address;
	memoryinventory.chunk_size -= ssize;
	memoryinventory.chunk_address += ssize;
	return returnaddress;
}

void *balloc(size_t ssize)
{
	void * returnaddress = NULL;;
	struct block_header current_block;
	current_block.chunk_size = ssize;
	current_block.next_block = NULL;
	current_block.magicnumber = 0x88888888;
	returnaddress =memory_from_inventory(ssize);
	memcpy(returnaddress,&current_block,sizeof(struct block_header));
	return returnaddress+sizeof(struct block_header);
}

void * find_free_block(size_t ssize)
{
	void * blockaddress = NULL;
	struct block_header current_block;
	fflush(stdout);
	if(ssize <= 16)
		blockaddress=remove_and_return_first_element((int)SIXTEEN);
	else if(ssize <= 64)
		blockaddress=remove_and_return_first_element((int)SIXTYFOUR);
	else if(ssize <= 512)
		blockaddress=remove_and_return_first_element((int)FIVETWELVE);
	else
		blockaddress=remove_and_return_first_element((int)LARGE);
	memcpy(&current_block,blockaddress,sizeof(struct block_header));
	current_block.chunk_size = ssize;
	memcpy(blockaddress,&current_block,sizeof(struct block_header));
	return blockaddress+sizeof(struct block_header);

}
