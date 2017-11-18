#include <assert.h>
#include "malloc.h"
#include <stdio.h>

int main(int argc, char **argv)
{
  size_t size = 603;
  void *mem = malloc(size);
  printf("Successfully malloc'd %zu bytes at addr %p\n", size, mem);
 fflush(stdout);
  assert(mem != NULL);
  size = 904 ;
  mem = realloc(mem, size);
    printf("Successfully realloc'd %zu bytes at addr %p\n", size, mem);
     assert(mem != NULL);
    fflush(stdout);
  free(mem);
   printf("Successfully free'd %zu bytes from addr %p\n", size, mem);
   fflush(stdout);
   size = 1003;
   mem = malloc(size);

  printf("Successfully malloc'd %zu bytes at addr %p\n", size, mem);
  assert(mem != NULL);
  fflush(stdout);
  size = 2013;

  mem = realloc(mem, size);
  printf("Successfully realloc'd %zu bytes at addr %p\n", size, mem);
    assert(mem != NULL);
    fflush(stdout);


  mem = realloc(mem, 0);
  printf("Successfully realloc'd %zu bytes at addr \n", size);

  printf("Successfully free'd %zu bytes from addr %p\n", size, mem);
  fflush(stdout);
  size = 3003;
  mem = calloc(size,4);

    printf("Successfully calloc'd %zu bytes at addr %p\n", size * 4, mem);
    assert(mem != NULL);
    fflush(stdout);
    free(mem);
    printf("Successfully free'd %zu bytes from addr %p\n", size * 4, mem);
    fflush(stdout);
    size = 12;
    mem = NULL;
    mem = realloc(mem, size);
    printf("Successfully realloc'd %zu bytes at addr %p\n", size, mem);
    malloc_stats();
  return 0;
}
