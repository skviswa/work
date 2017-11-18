/*
 * myalloc.h
 *
 *  Created on: Feb 7, 2017
 *      Author: preethi
 */

#ifndef MYALLOC_H_
#define MYALLOC_H_
#include <pthread.h>
struct free_list
{
	struct block_header * blockaddress;
	size_t chunk_size;
	struct free_list * next_chunk;
	struct free_list * prev_chunk;
};

struct block_header
{
	size_t chunk_size;
	struct block_header * next_block;
	size_t magicnumber;
};
struct available_chunk
{
	size_t chunk_size;
	void * chunk_address;
};

enum BINS
{
	SIXTEEN,SIXTYFOUR,FIVETWELVE,LARGE
}mybins;


#endif /* MYALLOC_H_ */
