#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>

//#define _POSIX_C_SOURCE 199309L

#include <time.h>

#define MAX_N 10000000
#define MAX_THREADS 100

void run_all_threads(pthread_t *threads, int N, int lim, int q, int kprime[]); // Creates worker threads
void crossout(int *arr, int lim, int prek);  // Crosses out all multiples of 2
void *sieve(void *arg);        // implements the sieve for each thread

int *count = &(int){1};   // Global variable, initialized to one as we are already taking 2 to be a trivial prime.

typedef struct {             // Struct to pass the arguements to thread workers
int tn;                     // Thread no
int N;                     // Max range
int lim;                  // No of threads 
int len;                 // Length of array of pre-computed primes
int *kset;              //  Array of primes from 3-sqrt(N) 
} work;

pthread_mutex_t nextbaselock = PTHREAD_MUTEX_INITIALIZER;   // For updating count

int main(int argc, char *argv[])
{
	int numth, N;
	if(argc < 2)
	{
	  N = 100;
	  numth = 2;
    }	  
	else
	{
      if(argc == 2) {
		  N = atoi(argv[1]);
		  numth = 2;
	  }
      else {	  
      N = atoi(argv[1]);
	  numth = atoi(argv[2]);
	  }
	}
	
	if(N < 2)
	{
	 printf("the max no should be greater than 2. Please run again!\n");
	 return 0;
	} 
    
//	if(N > MAX_N) N = MAX_N; 

    if(numth < 1)
	 printf("Need at least one thread, switching to a default value of 2!\n");
 
// 	if(numth > MAX_THREADS) numth = MAX_THREADS;
 
    int temp = (N-1)/numth;
	if((1+temp) < (int)sqrt((double)N))
	{
      printf("Too many threads requested! \n");
	  printf("first thread must have a block size of >= %f (sqrt N)\n",sqrt((double)N));
	  return 0;
	}
    
	int lim = ceil(sqrt((double)N));
	int *intmark;
	intmark = malloc((lim+1)*sizeof(int));   // This array is used to precompute the primes in the range 3-sqrt(N)
	intmark[0] = 1;
    intmark[1] = 1;
	for(int i=2; i<=lim ;i++)
	    intmark[i] = 0;
    int prek = 2;

	crossout(intmark,(lim+1),prek);
  		 
    int *kset; 
	kset = malloc(lim*sizeof(int));	
	int j = 0;
	for(int i=3 ; i <= lim; i++)
    {
      if(intmark[i] == 0)
      { kset[j] = i;                   // This array aggregates the generated primes
       j++; 
	  }
    }
	free(intmark);
    if(!kset)
    {
      printf("There is one prime less than or equal to 2\n");
      exit(0);
    }
  
    int q;
    for(q = 0; q < lim; q++)
    {
        if(kset[q] == 0)
        break;
    }

    int *kset_new; 
	kset_new = malloc(q*sizeof(int));
	for(j=0; j<q ; j++)
	 kset_new[j] = kset[j];	                          
   // memcpy(kset_new,kset,sizeof(kset_new));
   
	pthread_t *worker; 
	worker = malloc(numth*sizeof(pthread_t));

	free(kset);
    struct timespec start,finish;
	//start = clock();
	clock_gettime(CLOCK_MONOTONIC, &start);
	run_all_threads(worker,N,numth, q, kset_new);


	for(int i = 0; i < numth; i++)
		pthread_join(worker[i], (void **) &count);

   free(kset_new);
	
	//finish = clock();
	clock_gettime(CLOCK_MONOTONIC, &finish);

	double total_time;
	total_time = (finish.tv_sec - start.tv_sec)*1000;
	total_time += (finish.tv_nsec - start.tv_nsec)*1e-6;
	//double total_time = (double) (finish - start) / CLOCKS_PER_SEC;
	
//	free(worker);
	
	printf("%d is the overall no of primes between 1 and %d\n", *count,N); 
	printf("%f msec is the time taken \n", total_time);
//	pthread_exit(NULL);
}

void run_all_threads(pthread_t *threads,int N, int lim, int q, int kprime[])
{
  int i;
  for(i = 0; i < lim; i++) {
	work *arg = malloc(sizeof(work) + q*(sizeof(int)));
   	arg->len = q;
	arg->tn = i;
    arg->N = N;
    arg->lim = lim;
    arg->kset = (int *) malloc(q*sizeof(int));
    memcpy(arg->kset,kprime,(q*sizeof(int)));
    pthread_create(&threads[i], NULL, sieve, (void *)arg);
  }
  
}

void *sieve(void *arg)
{
	work cur = *(work *)arg;
	int kindex = 0;
	int k, lv, hv, bs;
	k = cur.kset[kindex];
	lv = 2 + (int)(cur.tn*(cur.N-1))/cur.lim;            // calculate the start index of the block for thread tn
	hv = 2 + ((int)((cur.tn+1)*(cur.N-1))/cur.lim) - 1; // calculate the end index of the block for thread tn
    bs = hv - lv + 1;  // block size
	
	if(lv % 2 == 0) {                       // since 2 is a trivial prime, we can overlook any of its multiples
		if(hv % 2 ==0) {                   // since 2 is a trivial prime, we can overlook any of its multiples
			bs = (int)(floor((double)bs / 2.0));
			hv--;
		}
        else {
            bs = bs/2;
        }
        lv++;
	}
    else {
         if(hv % 2 == 0) {
            bs = bs/2;
            hv--;
         }
         else {
             bs = (int)ceil((double) bs / 2.0);
         }
    }
	
	char *marked = (char *)malloc(bs);
	
	if (marked  == 0) {
		printf("Thread %d cannot allcoate enough memory\n",cur.tn);
		exit(1);
	}
    
	for(int i=0; i < bs; ++i)
       marked[i] = 0;

    int findex = 0;
    do {
        if(k >= lv) {
			findex = ((k - lv)/2) + k;
			//findex = (k - lv) + k;
		}	
		else if(k*k >= lv) {
			findex = (k*k - lv)/2;
		    //findex = (k*k - lv);
		}	
		else {
			if (lv % k == 0)
				findex = 0;
			else {
				findex = 1;
				while ((lv + (2*findex)) % k != 0)
                   ++findex;
			
          //  findex = k - (lv % k);
			}
        }
	    
        for(int i = findex; i<bs ;	i+=k)
            marked[i] = 1;
	
        k = cur.kset[++kindex];
    }while (k>0 && (k*k <= cur.N) && (kindex < cur.len));     		
				
    int lcnt = 0;
	for (int i=0; i<bs; ++i) {
		if(marked[i] == 0) {
			lcnt++;                         // Find the count of primes
//			printf("%d, ", lv + 2*i);
		}	
	}
//	printf("\n%d thread has found %d primes between %d and %d\n", tn, lcnt, lv, hv);

	free(marked);
	//marked = 0;
    free(cur.kset);
	
    pthread_mutex_lock(&nextbaselock);
    *count += lcnt;                                // update the global variable
    pthread_mutex_unlock(&nextbaselock);
	
    //free(&cur);
    return (void *) count;
}    

void crossout(int *arr, int lim, int prek)
{
	int k;
	k = prek;
    do {
         int base = k*k;
         for(int i = base; i <= lim; i += k)
             arr[i] = 1;
		 while(arr[++k])
			 ;
    }while(k*k <= lim);
}	
