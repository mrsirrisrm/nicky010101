class Flock { 

  private ArrayList<Particle> particles;
  private ArrayList<float[]> distances;
  private ArrayList<int[]> nextUpdateIn;
  public  int nActive;
  
  //private SquareRoot squareRoot = new SquareRoot();
  
  Flock (int numParticles, CDF cdf) {
    particles = new ArrayList<Particle>(numParticles);
    distances = new ArrayList<float[]>(numParticles);
    nextUpdateIn = new ArrayList<int[]>(numParticles);
    for (int i = 0; i < numParticles; i++) {
      particles.add( new Particle(new PVector(0.0 , 0.0 , 0.0)) );
      distances.add( new float[numParticles] );
      nextUpdateIn.add( new int[numParticles] ); //default 0
    } 
    particles.get(0).isOne = false;
    particles.get(1).isOne = true;
    nActive = numParticles;
    moveAllItemsFromImageCDF(cdf);
    vectorAllItemsFromImageCDF(cdf);
  }
  
  public void setNumActiveParticles (int n) {
    if (n < 2) {
      nActive = 2;
    } else if (n > particles.size()) {
      nActive = particles.size();
    } else {
      nActive = n;
    }
    //println("setting n active particles: ", nActive);
  }
  
  public void changeNCDF (int N, CDF cdf) {
    int n = 0;
    for (Particle part : particles.subList(0,nActive)) {
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
    for (Particle part : particles.subList(0,nActive)) {
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
    for (Particle part : particles.subList(0,nActive)) {
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
    for (int i = 0; i < nActive; i++ ) {
      Particle part = particles.get(i);  
      part.runFlocking(particles, distances.get(i), nActive);
    }
  }

  public void allIterate () {
    for (Particle part : particles.subList(0,nActive)) {
      part.iterate();
    }
  }  
  
  public void addVectorToAll (PVector vector) {
    for (Particle part : particles.subList(0,nActive)) {
      part.home.add(vector); 
    } 
  }
  
  public void moveAllItemsFromImageCDF (CDF cdf) {
    for (Particle part : particles.subList(0,nActive)) {
      moveParticleFromImageCDF(part, cdf);   
    }   
  }  
  
  private void moveParticleFromImageCDF (Particle part, CDF cdf) {
    int x = cdf.weightedRandomInt2DX () ;
    part.moveTo(new PVector(float(x) , float(cdf.weightedRandomInt2DY( x )) , part.pos.z) , cdf);    
  }
  
  public void vectorAllItemsFromImageCDF (CDF cdf) {
    for (Particle part : particles.subList(0,nActive)) {
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
    for (int i = 0; i < nActive; i++ ) {
      Particle part = particles.get(i);
      distances.get(i)[i] = 0; //self
      
      //loop for each other particle
      otherParticleLoop:
      for (int j = i + 1; j < nActive; j++ ) {       
        
        if (j >= nActive) {
          println(i, 'i' );
          println(j, 'j' );
        }
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
          //int dist = squareRoot.fastSqrt( floor(distSquared ));
          distances.get(i)[j] = dist;
          distances.get(j)[i] = dist;
        }
      }
    }
  }
}
