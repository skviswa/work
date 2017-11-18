#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include <omp.h>
#include <math.h>
#define SIZE 1000
#define CHUNK 64           // The size of matrix/vector and the chunk size for computation

void serial_inv(double **m, double *id, double **ser);

void parallel_inv(double **m, double **inv, double **par);

void freeMatrix(double **matrix);

void printMatrix(double **m);

void decompose_ser(double **m);

void backward_solve_ser(double **m, double **id, double **inv);

void forward_solve_ser(double **m, double *id, double **inv);

void check(double **ser, double **par);

int main(int argc, char *argv[]) 
{
   
  int i,j;
  double **m = malloc(sizeof(double *)*SIZE);
  double *id = malloc(sizeof(double *)*SIZE);
 
 double **inv = malloc(sizeof(double *)*SIZE);
 double **m_ser = malloc(sizeof(double *)*SIZE);
 double **ser = malloc(sizeof(double *)*SIZE);
 double **par = malloc(sizeof(double *)*SIZE);

   for(i=0; i<SIZE; i++) {
	inv[i] = malloc(sizeof(*inv[i])*SIZE);   
    m[i] = malloc(sizeof(*m[i])*SIZE);
	m_ser[i] = malloc(sizeof(*m_ser[i])*SIZE);
	ser[i] = malloc(sizeof(*ser[i])*SIZE);
	par[i] = malloc(sizeof(*par[i])*SIZE);
   }
 
   i = 0; j = 0;  
	
#pragma omp parallel shared(m,id,ser) private(i,j)
  {

  #pragma omp for schedule (static, CHUNK) 
  for (i=0; i<SIZE; i++) {
    for (j=0; j<SIZE; j++) {
      m[i][j]= rand()%100;
      m_ser[i][j] = m[i][j];
	}	  
  } 
  
  #pragma omp for schedule (static, CHUNK)
  for (i=0; i<SIZE; i++) {
    for (j=0; j<SIZE; j++) {
      par[i][j]= 0;
      ser[i][j]= 0;
	  if(i==j)
		  inv[i][j] = 1;
	  else
		  inv[i][j] = 0;
	}  
  }

  #pragma omp for schedule (static, CHUNK)
  for (i=0; i<SIZE; i++) {
	  id[i] = 0;
  }
  
  }

 // printMatrix(m);
  double total_time1,total_time2;
   struct timespec start,finish;
   clock_gettime(CLOCK_MONOTONIC, &start);
  
  serial_inv(m_ser,id,ser);

	clock_gettime(CLOCK_MONOTONIC, &finish);

	total_time2 = (finish.tv_sec - start.tv_sec)*1000;
	total_time2 += (finish.tv_nsec - start.tv_nsec)*1e-6;
		printf("%f msec is the time taken for serial exec \n", total_time2);

  
 //  printMatrix(ser);  
	printf("\n Serial execution done!\n");
	
	   clock_gettime(CLOCK_MONOTONIC, &start);
  
  parallel_inv(m,inv,par);

	clock_gettime(CLOCK_MONOTONIC, &finish);

	total_time2 = (finish.tv_sec - start.tv_sec)*1000;
	total_time2 += (finish.tv_nsec - start.tv_nsec)*1e-6;
		printf("%f msec is the time taken for parallel exec \n", total_time2);

  
   // printMatrix(par);  
	printf("\n Parallel execution done!\n");
//    check(ser,par);
	
	free(m);
	free(id);
	free(m_ser);
	free(par);
	free(ser);
	return 0;
	
}

void parallel_inv(double **m, double **inv, double **par)
{
	int i, j=0, k=0;
	int maxPivot,x,y,z;
	double t,sum,sum1;

    double **temp = malloc(sizeof(double *)*SIZE);
    for(i=0; i<SIZE; i++) {
    temp[i] = malloc(sizeof(*temp[i])*SIZE);
    }
    i=0;
	//omp_set_nested(1);
  #pragma omp parallel shared(m) private(i,j,k,maxPivot,t)
  {	
  #pragma omp for schedule(static,CHUNK)  	
  for(i =0; i<SIZE-1; i++) {
	
  maxPivot = i;
  //#pargma omp task
  for (k = i + 1; k < SIZE; k++)
  if (fabs(m[k][i]) > fabs(m[i][i]))
  maxPivot = k;

    // check for singularity
  if (m[maxPivot][i] == 0) {
  printf("matrix is singular\n");
  exit(1);
  }

    // swap rows
  #pragma omp task	
  {
  if (maxPivot != i) {
  for (k = i; k < SIZE; k++) {
  t = m[i][k];
  m[i][k] = m[maxPivot][k];
  m[maxPivot][k] = t;
  }	
  }
  }
  
  #pragma omp taskwait
  
  #pragma omp task
 {
  for(k = i+1; k<SIZE; k++) {
  m[k][i] = m[k][i]/m[i][i];  // L matrix
  }
 // #pragma omp task
  for(k=i+1; k<SIZE; k++) {
  for(j=i+1; j<SIZE; j++)
  m[j][k] = m[j][k] - (m[j][i]*m[i][k]);
  }
  	   
  }
  }
  }


for(i=0;i<SIZE;i++)
{
	for(j=0; j<SIZE; j++)
		temp[i][j] = 0;
}
  #pragma omp parallel shared(m,inv,temp,par) private(x,y,z) 
  {
  #pragma omp for schedule(static, CHUNK)		
  for(z=0; z<SIZE; z++)
  {
  #pragma omp task
  {
  for (x=0; x<SIZE; x++) {
  temp[x][z] = inv[x][z];
  for (y=0; y<x; y++)
  temp[x][z] = temp[x][z] - (m[x][y]*temp[y][z]);
  }
  }
  
  #pragma omp taskwait

  #pragma omp task  
  {
  for (x=SIZE-1; x>=0; x--) {
  par[x][z] = temp[x][z];
  for (y=SIZE-1; y>x; y--)
  {	 
  par[x][z] = par[x][z] - (m[x][y]*par[y][z]); 
  }
  par[x][z] = par[x][z]/m[x][x]; 		  
  }
  
  }
  
  }
	
  }	
//	printMatrix(temp);    
	freeMatrix(temp);
}	


void serial_inv(double **m, double *id, double **ser)
{
    int i,j;
    double **temp = malloc(sizeof(double *)*SIZE);
    for(i=0; i<SIZE; i++) {
    temp[i] = malloc(sizeof(*temp[i])*SIZE);
    }

	decompose_ser(m);
	
    // Now we have M = LU
    // We need to solve for (LU)(INV) = I	
	// We will take each column of INV, and do the operation (LU)C = CI
	// Where C is the ith column of INV, and CI is the ith column of I
    // This method of forward and backward substitution should give us 
    // INV when it is done SIZE times 	

	forward_solve_ser(m,id,temp);
//	printMatrix(temp);
	backward_solve_ser(m,temp,ser);
	freeMatrix(temp);
}	

void decompose_ser(double **m) {
		int i=0, j=0, k=0;
		int maxPivot;
		double t;
	for(i =0; i<SIZE-1; i++) {
	
	maxPivot = i;
    for (k = i + 1; k < SIZE; k++)
      if (fabs(m[k][i]) > fabs(m[i][i]))
        maxPivot = k;

    // check for singularity
    if (m[maxPivot][i] == 0) {
      printf("matrix is singular\n");
      exit(1);
    }

    // swap rows
    if (maxPivot != i) {
      for (k = i; k < SIZE; k++) {
        t = m[i][k];
	    m[i][k] = m[maxPivot][k];
		m[maxPivot][k] = t;
	  }	
    }

      for(k = i+1; k<SIZE; k++) {
           m[k][i] = m[k][i]/m[i][i];  // L matrix
    	}	
       for(k=i+1; k<SIZE; k++) {
		  for(j=i+1; j<SIZE; j++)
			  m[j][k] = m[j][k] - (m[j][i]*m[i][k]);
	    }
	   
    }
	
//	printMatrix(m);
}
	
void backward_solve_ser(double **m, double **id, double **inv) {
	int i,j,k;
	for(k=0; k<SIZE; k++)
	{
		for (i=SIZE-1; i>=0; i--) {
         inv[i][k] = id[i][k];
		 for (j=SIZE-1; j>i; j--)
		 {	 inv[i][k] = inv[i][k] - (m[i][j]*inv[j][k]); }
         inv[i][k] = inv[i][k]/m[i][i]; 		  
		}
    }
}	

void forward_solve_ser(double **m, double *id, double **inv) {
	int i,j,k;
	for(k=0; k<SIZE; k++)
	{
       if(k==0)
         id[k] = 1;
       else {
       id[k-1] = 0; 
       id[k] = 1;
       }
	   
    	for (i=0; i<SIZE; i++) {
         inv[i][k] = id[i];
		 for (j=0; j<i; j++)
			 inv[i][k] = inv[i][k] - (m[i][j]*inv[j][k]);
		// inv[i][k] = inv[i][k]/m[i][i];
		 
	   }
    }
	id[SIZE-1] = 0;
}	

void check(double **ser, double **par)
{
	int i,j;
	int flag = 0;
	for(i=0;i<SIZE;i++)
	{
		for(j=0;j<SIZE;j++)
			if(!(ser[i][j] == par[i][j]))
				flag = 1;
	}	
	
	if(flag == 1)
		printf("Result is not same, there is some race condition\n");
}
	
void freeMatrix(double **matrix)
{
	int i =0;
    for(i = 0; i < SIZE; i++)
        free(matrix[i]);
    free(matrix);
}

void printMatrix(double **m) {
    printf("\n \n");

	int i =0, j=0;
    for (i=0;i<SIZE;i++) {
        for(j=0;j<SIZE;j++) {
            printf("|  %f  | ",m[i][j]);
        }
        printf("\n");
    }
}