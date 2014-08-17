class Flock { 

  private ArrayList<Particle> particles;
  private ArrayList<float[]> distances;
  private ArrayList<int[]> nextUpdateIn;
  public  int nActive;
  
  private static final float highDist = 999999;
  
  //private SquareRoot squareRoot = new SquareRoot();
  
  Flock (int numParticles, int aNActive, CDF cdf) {
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
    nActive = aNActive;
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
      
      for (int j = i + 1; j < nActive; j++ ) {               
        if (nextUpdateIn.get(i)[j] > 0) {
          nextUpdateIn.get(i)[j]--;
          continue;          
        } 
          
        Particle other = particles.get(j);
        
        float dx = abs(part.pos.x - other.pos.x);
        if (dx > Particle.minDistanceForDontUpdateForNIterations) {
          set2Dist(i,j,highDist);
          nextUpdateIn.get(i)[j] = Particle.dontUpdateForNIterations;
          continue;  
        } else if (dx > Particle.minDistanceForForces) {
          set2Dist(i,j,highDist);
          continue;
        }
        
        float dy = abs(part.pos.y - other.pos.y);
        if (dy > Particle.minDistanceForDontUpdateForNIterations) {
          set2Dist(i,j,highDist);
          nextUpdateIn.get(i)[j] = Particle.dontUpdateForNIterations;
          continue;  
        } else if (dy > Particle.minDistanceForForces) {
          set2Dist(i,j,highDist);
          continue;
        }
          
         
        float dz = abs(part.pos.z - other.pos.z);
        if (dz > Particle.minDistanceForDontUpdateForNIterations) {
          set2Dist(i,j,highDist);
          nextUpdateIn.get(i)[j] = Particle.dontUpdateForNIterations;
          continue;  
        } else if (dz > Particle.minDistanceForForces) {
          set2Dist(i,j,highDist);
          continue;
        }
            
        float distSquared = (dx*dx + dy*dy + dz*dz);
        if (distSquared > Particle.minDistanceForDontUpdateForNIterationsSquared) {
          set2Dist(i,j,highDist);
          nextUpdateIn.get(i)[j] = Particle.dontUpdateForNIterations;
          continue;
        } else if (distSquared > Particle.minDistanceForForcesSquared) {
          set2Dist(i,j,highDist);
          continue;
        }
                
        set2Dist(i,j,sqrt(distSquared));
      }//j
    } //i
  }
  
  private void set2Dist (int i , int j, float d) {
    distances.get(i)[j] = d;
    distances.get(j)[i] = d;
  }
  
  public int maxParticles() {
    return particles.size();
  }
}
