class MiniFlocks {
 
  private int nMFx;
  private int nMFy;
  private float sizeDithering = 1.3;
  private MiniFlock[][] miniFlocks;
  
  public MiniFlocks () {
    nMFx = max(1,floor(width  / Flock.minDistanceForForces * sizeDithering * 1.1)); //larger than we will need
    nMFy = max(1,floor(height / Flock.minDistanceForForces * sizeDithering * 1.1));
    //println("miniflocks",nMFx,nMFy);
    miniFlocks = new MiniFlock[nMFx][nMFy];
    for (int i = 0; i < nMFx; i++) {
      for (int j = 0; j < nMFy; j++) {
        miniFlocks[i][j] = new MiniFlock();
      }
    }
  }
  
  public void assignToMiniFlocks(int count) {
    for (int i = 0; i < nMFx; i++) {
      for (int j = 0; j < nMFy; j++) {
        miniFlocks[i][j].particles.clear();
      }
    }
    
    //dither the size of the flocks to move the flock boundaries
    nMFx = max(1,floor(width  / Flock.minDistanceForForces * random(1.0,sizeDithering)));
    nMFy = max(1,floor(height / Flock.minDistanceForForces * random(1.0,sizeDithering)));
    float xx = width  / nMFx;
    float yy = height / nMFy;
    
    for (int n = 0; n < count; n++) {
      int ic = min(nMFx - 1, max(0,round(nMFx * (flock.xs[n] + random(-xx,+xx)) / width )));
      int jc = min(nMFy - 1, max(0,round(nMFy * (flock.ys[n] + random(-yy,+yy)) / height)));
      miniFlocks[ic][jc].particles.add(n);
    }    
  }
  
  public void calcMiniFlocksForces() {
    //println("q");
    for (int i = 0; i < nMFx; i++) {
      //println("q",i);
      for (int j = 0; j < nMFy; j++) {
        //println("q",j);
        miniFlocks[i][j].calcAllDistances();
        miniFlocks[i][j].calcForces();
      }
    }    
  }  
} 