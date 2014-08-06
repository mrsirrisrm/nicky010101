class Flock { 

  private ArrayList<Particle> particles; //somehow this is being called from outside class?
  //private PVector[] vectorsToAdd = new PVector[10];
  private ArrayList<float[]> distances;
  private ArrayList<int[]> nextUpdateIn;
  
  Flock (int numParticles) {
    particles = new ArrayList<Particle>(numParticles);
    distances = new ArrayList<float[]>(numParticles);
    nextUpdateIn = new ArrayList<int[]>(numParticles);
    for (int i = 0; i < numParticles; i++) {
      particles.add( new Particle(new PVector(0.0 , 0.0 , 0.0)) );
      distances.add( new float[numParticles] );
      nextUpdateIn.add( new int[numParticles] ); //default 0
    }  
  }
  
  public void changeNCDF (int N, CDF cdf) {
    int n = 0;
    for (Particle part : particles) {
      if (n < N) {
        if (part.CDFParent != cdf) {
          flock.vectorParticleFromCDF( part, cdf );
          //println(n,"   ",part);
          n++;        
        }
      }  
    }
  }
  
  public int numberInCDF (CDF cdf) {
    int n = 0;
    for (Particle part : particles) {
      if (part.CDFParent == cdf) {
        n++;        
      }
    }  
    return n;    
  }
  
  public void makeNInCDF (int N, CDF cdf) {
    int currentN = numberInCDF(cdf);
    if (N > currentN) {
      changeNCDF(N - currentN,cdf);
    } else {
      //do nothing as we don't know which cdf to move them to
    }
  } 
  
  public void allTextDraw () {
    for (Particle part : particles) {
      if (part.useImage) {
        part.imgDraw();
      } else {
        part.textDraw();
      }
    }
  }
  
  public void allRunFlocking () {
    calcAllDistances ();
    //for (Particle part : particles) {
    for (int i = 0; i < particles.size(); i++ ) {
      Particle part = particles.get(i);  
      part.runFlocking(particles,distances.get(i));
    }
  }

  public void allIterate () {
    for (Particle part : particles) {
      part.iterate();
    }
  }  
  
  public void addVectorToAll (PVector vector) {
    for (Particle part : particles) {
      part.home.add(vector); 
    } 
  }
  
  public void moveAllItemsFromImageCDF (CDF cdf) {
    for (Particle part : particles) {
      moveParticleFromImageCDF(part, cdf);   
    }   
  }  
  
  private void moveParticleFromImageCDF (Particle part, CDF cdf) {
    int x = cdf.weightedRandomInt2DX () ;
    part.moveTo(new PVector(float(x) , float(cdf.weightedRandomInt2DY( x )) , part.pos.z) , cdf);    
  }
  
  public void vectorAllItemsFromImageCDF (CDF cdf) {
    for (Particle part : flock.particles) {
      if (part.CDFParent == cdf) {
        vectorParticleFromCDF( part, cdf );  
      } 
    }   
  }  
  
  public void vectorParticleFromCDF (Particle part, CDF cdf) {
    int x = cdf.weightedRandomInt2DX () ;
    part.vectorTo(new PVector(x , cdf.weightedRandomInt2DY( x ), cdf.randomZ()) , cdf);  
  }  
  
  private void calcAllDistances () {
    for (int i = 0; i < particles.size(); i++ ) {
      Particle part = particles.get(i);
      distances.get(i)[i] = 0; //self
      
      //loop for each other particle
      otherParticleLoop:
      for (int j = i + 1; j < particles.size(); j++ ) {
        if (nextUpdateIn.get(i)[j] > 0) {
          nextUpdateIn.get(i)[j]--;          
        } else {
          //du update
          Particle other = particles.get(j);
          float dx = abs(part.pos.x - other.pos.x);
          if (dx > Particle.minDistanceForDontUpdateForNIterations) {
            distances.get(i)[j] = 999999;
            distances.get(j)[i] = 999999;
            nextUpdateIn.get(i)[j] = Particle.dontUpdateForNIterations;
            break otherParticleLoop;          
          } else if (dx > Particle.minDistanceForForces) {
            distances.get(i)[j] = 999999;
            distances.get(j)[i] = 999999;
            break otherParticleLoop;
          }
          
          float dy = abs(part.pos.x - other.pos.x);
          if (dy > Particle.minDistanceForDontUpdateForNIterations) {
            distances.get(i)[j] = 999999;
            distances.get(j)[i] = 999999;
            nextUpdateIn.get(i)[j] = Particle.dontUpdateForNIterations;
            break otherParticleLoop;          
          } else if (dy > Particle.minDistanceForForces) {
            distances.get(i)[j] = 999999;
            distances.get(j)[i] = 999999;
            break otherParticleLoop;
          }
          
          float dz = abs(part.pos.x - other.pos.x);
          if (dz > Particle.minDistanceForDontUpdateForNIterations) {
            distances.get(i)[j] = 999999;
            distances.get(j)[i] = 999999;
            nextUpdateIn.get(i)[j] = Particle.dontUpdateForNIterations;
            break otherParticleLoop;          
          } else if (dz > Particle.minDistanceForForces) {
            distances.get(i)[j] = 999999;
            distances.get(j)[i] = 999999;
            break otherParticleLoop;
          }
          
          float distSquared = (dx*dx + dy*dy + dz*dz);
          if (distSquared > Particle.minDistanceForDontUpdateForNIterationsSquared) {
            distances.get(i)[j] = 999999;
            distances.get(j)[i] = 999999;
            nextUpdateIn.get(i)[j] = Particle.dontUpdateForNIterations;
            break otherParticleLoop;          
          } else if (distSquared > Particle.minDistanceForForcesSquared) {
            distances.get(i)[j] = 999999;
            distances.get(j)[i] = 999999;
            break otherParticleLoop;
          }
          //float dist = PVector.dist(part.pos, other.pos);
          float dist = sqrt(distSquared);
          distances.get(i)[j] = dist;
          distances.get(j)[i] = dist;
        }
      }
    }
  }
}
