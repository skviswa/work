/*
 * malloc.h
 *
 *  Created on: Feb 7, 2017
 *      Author: preethi
 */

#ifndef MALLOC_H_
#define MALLOC_H_
#include <unistd.h>
#include <string.h>
#include <stdio.h>
#include <stddef.h>
#include <sys/mman.h>
#include <stdint.h>
#include "myalloc.h"
#include "linkedlist.h"

void *malloc(size_t size);
void *calloc(size_t n, size_t size);
void *realloc(void *ptr, size_t size);
void free(void *ptr);
void malloc_stats();

#endif /* MALLOC_H_ */
