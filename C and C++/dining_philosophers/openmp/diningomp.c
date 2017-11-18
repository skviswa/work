# include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include <omp.h>
 
omp_lock_t *forks;          // This initializes the locks (forks)

void think(int position)
{
	printf("philosopher %d is thinking...\n", position);
	sleep(3);
}

void eat(int position)
{
    printf("philosopher %d is eating...\n", position);
    sleep(3);
}

void philosopher(int position, int num_phil, int N)
{
	int j;
	//while (1)
	 for(j = 0; j<N; j++)                      
	{                                          
		think(position);
      if (position == num_phil - 1)          // Change the order of picking forks
	  {
		omp_set_lock(&forks[position]);     // The last philosopher picks up the fork in the order right and left
		 omp_set_lock(&forks[0]);
			eat(position);
		 omp_unset_lock(&forks[0]);
		omp_unset_lock(&forks[position]);
	  }
	  else 
	  {
		omp_set_lock(&forks[position]);      // The generic philosopher picks up the fork in the order left and right
		 omp_set_lock(&forks[position + 1]);
			eat(position);
		 omp_unset_lock(&forks[position + 1]);
		omp_unset_lock(&forks[position]);
	  }
	}
}

int main(int argc, char *argv[]) 
{

  int num_phil, N;  // the no of philosophers and max time spent for simulation are inputs
  if(argc < 2) {
   num_phil = 5;   // default values are 5 philosophers and 5 cycles
   N = 5;
  }
  else {
   if(argc == 2) {
	num_phil = atoi(argv[1]);
    N = 5;
   }	
   else {  	
   num_phil = atoi(argv[1]);
   N = atoi(argv[2]);
   }
  }
  
  printf("Welcome! We will observe %d philosophers today! \n", num_phil);

    omp_set_num_threads(num_phil);
	forks = (omp_lock_t *)malloc(num_phil*sizeof(omp_lock_t));
	int i;
	

	for (i = 0; i < num_phil; i++)
	{
		omp_init_lock(&forks[i]);          // Initialize the locks
	}	

    struct timespec start,finish;
	clock_gettime(CLOCK_MONOTONIC, &start);

	
	#pragma omp parallel for private(i) shared(num_phil,N)
	for (i = 0; i < num_phil; i++)
	{
		philosopher(i,num_phil,N);                // Do what the philosophers do! 
	}

	clock_gettime(CLOCK_MONOTONIC, &finish);

	double total_time;
	total_time = (finish.tv_sec - start.tv_sec)*1000;
	total_time += (finish.tv_nsec - start.tv_nsec)*1e-6;
	
	printf("%f msec is the time taken \n", total_time);

	return 0;
}