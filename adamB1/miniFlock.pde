class MiniFlock {
  public  List<Integer> particles;
  private ArrayList<float[]> distances;
  
  public MiniFlock () {
    particles = new ArrayList<Integer>();
    distances = new ArrayList<float[]>();
  }
  
  private void calcAllDistances () {
    int nPart = particles.size();
    
    distances = new ArrayList<float[]>(nPart);
    for (int i = 0; i < nPart; i++ ) {
      distances.add(new float[nPart]);
    }
    
    for (int i = 0; i < nPart; i++ ) {
      int n = particles.get(i);
      
      for (int j = i + 1; j < nPart; j++ ) {              
        int n2 = particles.get(j);
        
        float dx = abs(flock.xs[n] - flock.xs[n2]);
        if (dx > Flock.minDistanceForForces) {
          continue;
        } 
        
        float dy = abs(flock.ys[n] - flock.ys[n2]);
        if (dy > Flock.minDistanceForForces) {
          continue;
        }
              
        float distSquared = (dx*dx + dy*dy);
        if (distSquared > Flock.minDistanceForForcesSquared) {
          continue;
        } 
        
        float d = sqrt(distSquared);
        distances.get(i)[j] = d;
        distances.get(j)[i] = d;
      } // j
    } // i
  }  
  
  public void calcForces() {
    int nPart = this.particles.size();
    if (nPart > 0) {
      for (int i = 0; i < nPart; i++ ) {
        int n = particles.get(i);  
        flock.addFlockingForces(n, this.particles, this.distances.get(i), nPart);
      }
    }
  }
}
