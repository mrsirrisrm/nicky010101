import java.util.Collections;

void doFlockAllCalcThread() {
  flock.calcAllDistances();
}

void doFlockSomeCalcThread() {
  flock.calcSomeDistances();
}

class Flock { 

  private ArrayList<Particle> particles;
  private ArrayList<float[]> distances;
  //private ArrayList<int[]> nextUpdateIn;
  private int nActive;
  private int nextPartOfDistancesToCalc = 0;
  private static final int divideDistancesCalcIntoNParts = 2;
  private boolean[] isCalculating = new boolean[divideDistancesCalcIntoNParts]; 
  
  private int posListsDim;
  private ArrayList<ArrayList<Particle>> posLists;
  
  private static final float highDist = 999999;
  
  //private SquareRoot squareRoot = new SquareRoot();
  
  Flock (int numParticles, int aNActive, CDF cdf) {
    particles = new ArrayList<Particle>(numParticles);
    distances = new ArrayList<float[]>(numParticles);
    //nextUpdateIn = new ArrayList<int[]>(numParticles);
    posListsDim = ceil( min(width,height) / Particle.minDistanceForForces);
    //println(posListsDim);
    posLists = new ArrayList<ArrayList<Particle>>(posListsDim*posListsDim*posListsDim);
    for (int i = 0; i < posListsDim*posListsDim*posListsDim; i++) {
      posLists.add(new ArrayList<Particle>());
    }
    for (int i = 0; i < numParticles; i++) {
      particles.add( new Particle(new PVector(0.0 , 0.0 , 0.0)) );
      distances.add( new float[numParticles] );
      //nextUpdateIn.add( new int[numParticles] ); //default 0
    } 
    particles.get(0).isOne = false;
    particles.get(1).isOne = true;
    nActive = aNActive;
    moveAllItemsFromImageCDF(cdf);
    vectorAllItemsFromImageCDF(cdf);
    
    for (int i = 0; i < divideDistancesCalcIntoNParts; i++) {
      isCalculating[i] = false;
    }
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
          this.vectorParticleFromCDF( part, cdf );
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
    //int nToPlot = 5000;
    //for (Particle part : particles.subList(0,nToPlot)) {
    for (Particle part : particles.subList(0,nActive)) {
      if (part.useImage) {
        part.imgDraw();
      } else {
        part.textDraw();
      }
    }
  }
  
  public void allRunFlocking (InputData inputData) { 
    thread("doFlockAllCalcThread");
    //thread("doFlockSomeCalcThread");
    //thread("doFlockSomeCalcThread");
    //this.calcAllDistances();
    for (int i = 0; i < nActive; i++ ) {
      Particle part = particles.get(i);  
      part.runFlocking(particles,distances.get(i),nActive,inputData);
    }
  }

  public void allRotate (InputData inputData) {
    for (Particle part : particles.subList(0,nActive)) {
      part.rotateIt(inputData);
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

  private void calcSomeDistances() {
    if (this.divideDistancesCalcIntoNParts == 2) {
      if (nextPartOfDistancesToCalc == 0) {
        if (!isCalculating[0]) {
          nextPartOfDistancesToCalc = 1;
          isCalculating[0] = true;
          this.calcTheseDistances(0,floor(0.33*nActive));
          isCalculating[0] = false;
        }
      } else {
        nextPartOfDistancesToCalc = 0;
        isCalculating[1] = true;
        this.calcTheseDistances(ceil(0.33*nActive),nActive);
        isCalculating[1] = false;
      }
    }
  }
  
  private void calcAllDistances () {
    if (!this.isCalculating[0]) {
      this.isCalculating[0] = true;
      this.calcTheseDistances(0,nActive);
      this.isCalculating[0] = false;
    }
  }
  
  private void calcTheseDistances (int iStart, int iEnd) {
    int[] centralMapRefs = new int[nActive];
    for (int i = iStart + 1; i < nActive; i++ ) {
      centralMapRefs[i] = particles.get(i).centralMapRef();
    }
    
    for (int i = iStart; i < iEnd; i++ ) {
      Particle part = particles.get(i);
      //distances.get(i)[i] = 0; //self
      
      for (int j = i + 1; j < nActive; j++ ) { 
                  
        //Particle other = particles.get(j);
        
        if (!part.neighbouringParticle(centralMapRefs[j])) {
           continue;
        } 
        
        //if (nextUpdateIn.get(i)[j] > 0) {
        //  nextUpdateIn.get(i)[j]--;
        //  continue;          
        //} 

        Particle other = particles.get(j);
        
        float dx = abs(part.pos.x - other.pos.x);
        if (dx > Particle.minDistanceForDontUpdateForNIterations) {
          set2Dist(i,j,highDist);
          //nextUpdateIn.get(i)[j] = Particle.dontUpdateForNIterations;
          continue;  
        } else if (dx > Particle.minDistanceForForces) {
          set2Dist(i,j,highDist);
          continue;
        }
        
        float dy = abs(part.pos.y - other.pos.y);
        if (dy > Particle.minDistanceForDontUpdateForNIterations) {
          set2Dist(i,j,highDist);
          //nextUpdateIn.get(i)[j] = Particle.dontUpdateForNIterations;
          continue;  
        } else if (dy > Particle.minDistanceForForces) {
          set2Dist(i,j,highDist);
          continue;
        }
          
         
        float dz = abs(part.pos.z - other.pos.z);
        if (dz > Particle.minDistanceForDontUpdateForNIterations) {
          set2Dist(i,j,highDist);
          //nextUpdateIn.get(i)[j] = Particle.dontUpdateForNIterations;
          continue;  
        } else if (dz > Particle.minDistanceForForces) {
          set2Dist(i,j,highDist);
          continue;
        }
            
        float distSquared = (dx*dx + dy*dy + dz*dz);
        if (distSquared > Particle.minDistanceForDontUpdateForNIterationsSquared) {
          set2Dist(i,j,highDist);
          //nextUpdateIn.get(i)[j] = Particle.dontUpdateForNIterations;
          continue;
        } else if (distSquared > Particle.minDistanceForForcesSquared) {
          set2Dist(i,j,highDist);
          continue;
        }
                
        set2Dist(i,j,sqrt(distSquared));
      }//j
    } //i
    //println(100*notNeighbourCnt/(neighbourCnt + notNeighbourCnt), 100*neighbourCnt/(neighbourCnt + notNeighbourCnt));
  }
  
  private void set2Dist (int i , int j, float d) {
    distances.get(i)[j] = d;
    distances.get(j)[i] = d;
  }
  
  public int maxParticles() {
    return particles.size();
  }
  
  public void getNewTargetForParticles(int n) {
    for (int i = 0; i < n; i++) {
      Particle p = particles.get(int(random(nActive)));
      this.vectorParticleFromCDF(p,p.CDFParent);
    }  
  }
  
  public void sortParticles() {
    Collections.sort(this.particles, new ParticleComparator());  
  }
  
  public int posListsInd(int i, int j, int k) {
    return i + j*posListsDim + k*posListsDim*posListsDim;
  }
  
  public int posListsCalculateDimInd(float d, int totalDimLength) {
    if (d <= 0) {
      return 0;
    } else if (d >= totalDimLength) {
      return posListsDim - 1;
    } else {
      return round(d/totalDimLength*(posListsDim - 1));
    }
  }
  
  private void updatePosLists() {
    //for (ArrayList<Particle> list : posLists) {
    //  list.clear();
    //}
    
    for (Particle p : particles) {
      p.updateMapRefs();
      //posLists.get(ind).add(p);
    }
  }
  
  public int runInputStep(InputData input) {
    int numToMove = 0;
    if (input.prevHighLev > input.audioThreshold || input.prevLowLev > input.audioThreshold ) {
      numToMove = round(input.mix * moveParticlesBetweenCDFSensitivity);
      if (input.mix > 0 ) {
        //higher freqs dominate 
        this.changeNCDF( numToMove , cdf2 );
      } else {
        //lower freqs dominate
        this.changeNCDF( -numToMove , cdf1 );
      }
    }
    
    this.allTextDraw();
    //this.sortParticles();
    //long startTime = System.nanoTime();
    this.updatePosLists();    
    this.allRunFlocking(input);
    //println((System.nanoTime() - startTime) / 1000);
    this.allRotate(input);
    this.getNewTargetForParticles(2);
   
    return numToMove; 
  }
}
