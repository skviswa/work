/*
 * linkedlist.h
 *
 *  Created on: Feb 7, 2017
 *      Author: preethi
 */

#ifndef LINKEDLIST_H_
#define LINKEDLIST_H_
#include <stddef.h>


void add_to_free_list(size_t size,void * chunk);
struct free_list ** get_free_list(size_t size);
void * remove_and_return_first_element(int binsize);
void remove_from_free_list(struct free_list * freelist,void * chunk);
struct free_list * getfreelistinventory();
int get_chunk_remaining_size(void * chunk);
size_t get_chunk_size(void * chunk);
void update_chunk_size(void * chunk ,size_t size);
void fill_in_block_header(void * kernel_return_address,size_t size);
void *memory_from_inventory(size_t ssize);
void *balloc(size_t ssize);
void * find_free_block(size_t ssize);



#endif /* LINKEDLIST_H_ */
