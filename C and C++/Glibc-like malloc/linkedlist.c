#include<stddef.h>
#include<myalloc.h>
#include "linkedlist.h"
#include <unistd.h>
#include<string.h>
#include<stdint.h>
#include <stdio.h>

int totalnumberbins = 4;

struct free_list * bin_16 = NULL;
struct free_list * bin_64 = NULL;
struct free_list * bin_512 = NULL;
struct free_list * largebins = NULL;
int blockscount[4];
int usedblocks[4];
int freeblocks[4];
int totalfreerequests[4];
extern struct available_chunk freelistinventory ;

void print_list_details(int bin)
{
	printf("Total number of blocks %d\n",blockscount[bin]);
	printf("Used blocks %d\n",usedblocks[bin] - freeblocks[bin]);
	printf("Free blocks %d\n",freeblocks[bin]);
	printf("Total allocation requests %d\n",blockscount[bin]);
	printf("Total free requests %d\n", totalfreerequests[bin]);
	fflush(stdout);
}
void malloc_stats()
{
	printf("\n\n ***********Malloc stats************** \n\n");
	printf("Total number of bins 4\n");
	printf("\n\n64 size bin\n\n");
	print_list_details(SIXTYFOUR);
	printf("\n\n512 size bin\n\n");
	print_list_details(FIVETWELVE);
	printf("\n\nLarge size bin\n\n");
	print_list_details(LARGE);
}
int getbinsize(struct free_list * freelist)
{
	int bin;
		if (freelist == bin_16)
			bin = SIXTEEN;
		if (freelist == bin_64)
				bin = SIXTYFOUR;
		if (freelist == bin_512)
				bin = FIVETWELVE;
		if (freelist == largebins)
				bin = LARGE;
		return bin;
}

void add_to_free_list(size_t size,void * chunk)
{
	int binsize;
	struct block_header * chunk_header;
	if(((uintptr_t)chunk) % 8 != 0)
	{
		uintptr_t offset = ((uintptr_t)chunk) % 8;
		chunk += (8-offset);
		size -= (8-offset);
	}
	if((size - sizeof(struct block_header)) < 1)
		return;
	chunk_header = chunk - sizeof(struct block_header);
	struct  free_list  *curr_free_blk_ptr,*temp;
	struct  free_list ** freelist;

	freelist =  get_free_list(size);

	if((*freelist) == NULL)
	{
			(*freelist)= getfreelistinventory();
			(*freelist)->blockaddress = chunk_header;
			(*freelist)->next_chunk = NULL;
			(*freelist)->prev_chunk = NULL;
			binsize = getbinsize((*freelist));
			totalfreerequests[binsize] +=1;
			freeblocks[binsize] +=1;
			return;
	}
	binsize = getbinsize((*freelist));
	totalfreerequests[binsize] +=1;
	freeblocks[binsize] +=1;
	curr_free_blk_ptr = (*freelist);

	while((curr_free_blk_ptr->next_chunk)!=NULL)
			curr_free_blk_ptr= curr_free_blk_ptr->next_chunk;
	temp = getfreelistinventory();
	temp->prev_chunk = curr_free_blk_ptr;
	temp->blockaddress = chunk_header;
	temp->next_chunk = NULL;
	curr_free_blk_ptr->next_chunk = temp;

}

int get_chunk_remaining_size(void * chunk)
{
	int remainingsize;
	size_t occupiedsize;
	occupiedsize = get_chunk_size(chunk)+sizeof(struct block_header);
		if(occupiedsize<=16)
		{
			remainingsize = 16 - occupiedsize;
		}else if(occupiedsize <= 64){
			remainingsize = 64 - occupiedsize;
		}else if(occupiedsize <= 512){
			remainingsize = 512 - occupiedsize;
		}else
			remainingsize = -1;
	return remainingsize;
}

size_t get_chunk_size(void * chunk)
{
	size_t occupiedsize;
	struct block_header * chunk_header;
	chunk_header = chunk - sizeof(struct block_header);
	occupiedsize = chunk_header->chunk_size;
	return occupiedsize;
}
void remove_from_free_list(struct free_list * freelist,void * chunk)
{
	struct block_header * chunk_header = chunk - sizeof(struct block_header *);
	struct  free_list  * curr_free_blk_ptr,*temp;
	if(freelist->blockaddress == chunk_header)
	{
			freelist = NULL;
			return;
	}
	curr_free_blk_ptr = freelist;
	while(curr_free_blk_ptr!=NULL)
	{
		if( curr_free_blk_ptr->blockaddress == chunk_header)
		{
			temp = curr_free_blk_ptr->next_chunk;
			curr_free_blk_ptr->prev_chunk->next_chunk = temp;
			temp->prev_chunk = curr_free_blk_ptr->prev_chunk;
			break;
		}
		else
			curr_free_blk_ptr= curr_free_blk_ptr->next_chunk;
	}

}
void * remove_and_return_first_element(int binsize)
{
	   struct block_address* returnaddress = NULL;
	   switch(binsize)
	   {
	   case SIXTEEN:
	   {
		   returnaddress = (struct block_address*)bin_16->blockaddress;
		   bin_16 = bin_16->next_chunk;
		   break;
	   }
	   case SIXTYFOUR:
	   {
		   returnaddress = (struct block_address*)bin_64->blockaddress;
		   bin_64 = bin_64->next_chunk;
		   		   break;
	   }
	   case FIVETWELVE:
	   {
		   returnaddress = (struct block_address*)bin_512->blockaddress;
		   bin_512 = bin_512->next_chunk;
		   		   		   break;
	   }
	   case LARGE:
	   {
		   returnaddress = (struct block_address*)largebins->blockaddress;
		   largebins = largebins->next_chunk;
		   break;
	   }
	   default:
		   break;
       usedblocks[binsize] += 1;
		    }
	   return returnaddress;
}
struct free_list ** get_free_list(size_t size){
	struct free_list ** freelist = NULL;
	if(size<=16)
	{
		freelist = &bin_16;
	}else if(size<=64){
		freelist = &bin_64;
	}else if(size<=512){
		freelist = &bin_512;
	}else
		freelist = &largebins;
	return freelist;
}

struct free_list * getfreelistinventory()
{
	struct free_list * returnfreelistptr;
	if(freelistinventory.chunk_size < sizeof(struct free_list)  )
	{
		freelistinventory.chunk_address= sbrk(sysconf(_SC_PAGESIZE));
		freelistinventory.chunk_size= sysconf(_SC_PAGESIZE);
	}
	returnfreelistptr = freelistinventory.chunk_address;
	freelistinventory.chunk_size-= sizeof(struct free_list);
	freelistinventory.chunk_address+=sizeof(struct free_list);
	return returnfreelistptr;

}

void update_chunk_size(void * chunk,size_t size)
{
	    struct block_header * chunk_header;
		chunk_header = chunk - sizeof(struct block_header);
		chunk_header->chunk_size = size;

}

