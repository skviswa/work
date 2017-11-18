#include<stdio.h>
#include<stdlib.h>
#include<pthread.h>
#include<semaphore.h>
#include<time.h>

typedef struct {    // this struct is to pass arguements to worker threads
int pos;           // represents position of philosopher in round table, starting from 0
int cnt;          // total no of philosophers
int no;          // max time spent by a thread on a philosopher 
sem_t *forks;   // the forks for each philosopher
sem_t *lock;   // lock for the critical eat section
} phil_par;


void initialize_semaphores(sem_t *lock, sem_t *forks, int num_forks);  // to initialize fork semaphores
void run_all_threads(pthread_t *threads, sem_t *forks, sem_t *lock, int num_phil, int N); // runs the round table simulation

void *philosopher(void *params);  // what each philosopher does when its their turn
void think(int position);           
void eat(int position);

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
  sem_t lock;
  sem_t *forks = (sem_t *)malloc(num_phil*sizeof(sem_t));
  pthread_t *philosophers = (pthread_t *)malloc(num_phil*sizeof(pthread_t));
  initialize_semaphores(&lock,forks,num_phil);

  run_all_threads(philosophers,forks,&lock,num_phil,N);

  pthread_exit(NULL);
}

void initialize_semaphores(sem_t *lock, sem_t *forks, int num_forks)
{
  int i;
  for(i=0; i<num_forks;i++)
   sem_init(&forks[i],0,1);
  sem_init(lock,0,num_forks-1);  // allowing only N-1 philosophers a chance to pick up their forks to have at least one philosopher get both
}

void run_all_threads(pthread_t *threads, sem_t *forks, sem_t *lock, int num_phil, int N)
{
  int i;
  for(i=0;i<num_phil;i++)
  {
    phil_par *arg = malloc(sizeof(phil_par));
    arg->pos = i;
    arg->cnt = num_phil;
    arg->lock = lock;
    arg->forks = forks;
    arg->no = N;
    pthread_create(&threads[i],NULL,philosopher,(void *)arg);
  }
}

void *philosopher(void *params)
{
  int i,count;
  phil_par self = *(phil_par *)params;
  count = rand()%self.no;               // select a random number between the given no and max to repeat the experiment

  if(count == 0)
  count = self.no;

 // while(1)
  for(i = 0; i < count; i++)
  {                                                     // when its a philosophers turn, they are thinking, then ready to eat       
    think(self.pos);                          
    sem_wait(self.lock);
    sem_wait(&self.forks[self.pos]);
    sem_wait(&self.forks[(self.pos + 1)%self.cnt]);
    eat(self.pos);   
    sem_post(&self.forks[self.pos]);
    sem_post(&self.forks[(self.pos + 1)%self.cnt]);
    sem_post(self.lock);
  }
   
  think(self.pos);
  pthread_exit(NULL);
}

void think(int position)
{
  printf("Philisopher %d thinking...\n", position);
  sleep(2);                                         // can be increased or decreased

}

void eat(int position)
{ 
  printf("Philosopher %d eating...\n", position);
  sleep(2);                   // can be increased or decreased

}
 
