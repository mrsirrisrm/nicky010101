#define HIGHDIST 999999
#define DISTDONTUPDATENITER 200.0
#define DISTFORCES 100.0
#define DISTDONTUPDATENITER2 20000.0
#define DISTFORCES2 10000.0
#define SETHIGHDIST distances[i * n + j] = highDist; distances[j * n + i] = highDist;

typedef struct Particles
{
	int x,y,z;
} Particle;

__kernel void calcAllDistances(int n, __global int *nextUpdateIn, __global float * distances, __global const Particle *particles)

  int i = get_global_id(0);
  Particle part = particles.get(i); //replace
    
  //distances[i * n + i] = 0; //self
  
  for (int j = i + 1; j < n; j++) {               
	if (nextUpdateIn[i * n + j] > 0) {
	  nextUpdateIn[i * n + j] -= 1;
	  continue;          
	} 
	  	
	float dx = abs(particles[i].x - particles[j].x);
	if (dx > DISTDONTUPDATENITER) {
	  distances[i * n + j] = HIGHDIST;
      distances[j * n + i] = HIGHDIST;
	  nextUpdateIn[i * n + j] = 5; 
	  continue;  
	} else if (dx > DISTFORCES) {
	  distances[i * n + j] = HIGHDIST;
      distances[j * n + i] = HIGHDIST;
	  continue;
	}
	
	float dy = abs(particles[i].y - particles[j].x);
	if (dy > DISTDONTUPDATENITER) {
	  distances[i * n + j] = HIGHDIST;
      distances[j * n + i] = HIGHDIST;
	  nextUpdateIn[i * n + j] = 5;
	  continue;  
	} else if (dy > DISTFORCES) {
	  distances[i * n + j] = HIGHDIST;
      distances[j * n + i] = HIGHDIST;
	  continue;
	}
	  
	 
	float dz = abs(particles[i].z - particles[j].z);
	if (dz > DISTDONTUPDATENITER) {
	  distances[i * n + j] = HIGHDIST;
      distances[j * n + i] = HIGHDIST;
	  nextUpdateIn[i * n + j] = 5;
	  continue;  
	} else if (dz > DISTFORCES) {
	  distances[i * n + j] = HIGHDIST;
      distances[j * n + i] = HIGHDIST;
	  continue;
	}
		
	float distSquared = (dx*dx + dy*dy + dz*dz);
	if (distSquared > DISTDONTUPDATENITER2) {
	  distances[i * n + j] = HIGHDIST;
      distances[j * n + i] = HIGHDIST;
	  nextUpdateIn[i * n + j] = 5;
	  continue;
	} else if (distSquared > DISTFORCES2) {
	  distances[i * n + j] = HIGHDIST;
      distances[j * n + i] = HIGHDIST;
	  continue;
	}
	
	float d = sqrt(distSquared); 	
	distances[i * n + j] = d;
    distances[j * n + i] = d;		
  }//j
}