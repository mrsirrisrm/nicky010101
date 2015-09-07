import java.util.List;

class Chunk {
 
  public List<Integer> particles;
  
  public PVector velocity;
  //public float rotationVelocity;
  
  public color tint;
  public boolean canMove = false;
  public int erosionRate = 1; 

  public Chunk () {
    particles = new ArrayList<Integer>();
    velocity = new PVector(0 , 0);
    //rotationVelocity = 0;
  } 
 
  public float centerX () {
    if (particles.size() == 0) {
      return width / 2;
    }
    float c = 0;
    for (int n : particles) {
      c += flock.xs[n];
    }
    return c / particles.size();
  }
 
  public float centerY () {
    if (particles.size() == 0) {
      return height / 2;
    }
    float c = 0;
    for (int n : particles) {
      c += flock.ys[n];
    }
    return c / particles.size();
  }  
  
  
  
  public PVector vectorToCenter (float x, float y) {
    return new PVector ( x - centerX(), y - centerY() );
  }
  
  public void addIndex(int n, int chunkIndex) {
    particles.add(n);
    flock.chunkIndices[n] = chunkIndex;
    flock.states[n] = kChunk;
  }
  
  public float rotationalInertia () {
    float inertia = 0;
    for (int n : particles) {
      inertia += pow(2,vectorToCenter(flock.xs[n],flock.ys[n]).mag());
    }
    return inertia;
  }
  
  public int removeParticle() {
    boolean remove;
    if (particles.size() == 0) {
      remove = false;
    } else if (particles.size() < 10) {
      remove = random(10) < 1.0;
    } else if (particles.size() < 50) {
      remove = random(10) < 4.0;
    } else if (particles.size() < 200) {
      remove = random(10) < 7.0;
    } else {
      remove = true;
    }
      
    if (remove) {  
      DistTuple[] dists = new DistTuple[particles.size()];
      for (int i = 0; i < particles.size(); i++) {
        int n = particles.get(i);
        dists[i] = new DistTuple(i, vectorToCenter(flock.xs[n],flock.ys[n]).mag() ); 
      }   
      Arrays.sort(dists, new DistTupleComparator());
      
      Integer n = particles.get(dists[dists.length - 1].ind);
      particles.remove(n);
      flock.chunkIndices[n] = -1;
      flock.freeParticle(n);            
      return n;
    } else {
      return -1;
    }
  }
  
  public void erodeParticles() {
    if (erosionRate > 0) {
      for (int i = 0; i < erosionRate; i++) {
        this.erodeParticleWithinAngle();
      }
    }
  }
  
  private void erodeParticle() {
    if (particles.size() > 0) {
      DistTuple[] dists = new DistTuple[particles.size()];
      for (int i = 0; i < particles.size(); i++) {
        int n = particles.get(i);
        dists[i] = new DistTuple(i, vectorToCenter(flock.xs[n],flock.ys[n]).mag() ); 
      }   
      Arrays.sort(dists, new DistTupleComparator());
      
      Integer n = particles.get(dists[dists.length - 1].ind);
      particles.remove(n);
      flock.freeParticle(n);
    }
  }
  
  private void erodeParticleWithinAngle() {
    if (particles.size() > 0) {
      int divideAnglesIntoSegments = 24;
      int theSegment = randForInts.nextInt(divideAnglesIntoSegments);
      float startAng = 2 * PI * theSegment / float(divideAnglesIntoSegments);
      float endAng = 2 * PI * (theSegment + 1) / float(divideAnglesIntoSegments);
      
      boolean canErodeSomething = false;
      DistTuple[] dists = new DistTuple[particles.size()];
      for (int i = 0; i < particles.size(); i++) {
        int n = particles.get(i);
        PVector v = vectorToCenter(flock.xs[n],flock.ys[n]);
        float heading = v.heading();
        if (heading < 0) {
          heading += 2 * PI;
        } else if (heading >= 2 * PI) {
          heading -= 2 * PI;
        }
        if (heading >= startAng && heading <= endAng) {
          dists[i] = new DistTuple(i, v.mag() );
          canErodeSomething = true;
        } else {
          dists[i] = new DistTuple(i, 0);
        }
      }       
      
      if ( canErodeSomething ) {
        Arrays.sort(dists, new DistTupleComparator());
        Integer n = particles.get(dists[dists.length - 1].ind);
        particles.remove(n);
        flock.freeParticle(n);
      }
    
    }
  }
  
  public void moveParticles() {
    for (int n : particles) {
      flock.xs[n] += this.velocity.x;
      flock.ys[n] += this.velocity.y;
      
      //PVector home = vectorToCenter(p.pos);
      //float ang = atan2(home.y,home.x);
      //float r = home.mag();
      //p.pos.x += this.velocity.x - r * sin(ang) * rotationVelocity;
      //p.pos.y += this.velocity.y + r * cos(ang) * rotationVelocity;
      //p.rotation += rotationVelocity;
    }  
  } 
  
  public void freeAllParticles() {
    if (particles.size() > 0) {
      for (int n : particles) {
        flock.freeParticle(n);
      }
      particles.clear(); 
    }
  }
}

class ChunkComparator implements Comparator {
  int compare(Object o1, Object o2) {
    int d1 = ((Chunk) o1).particles.size();
    int d2 = ((Chunk) o2).particles.size();
    if (d1 == d2) {
      return 0; 
    } else if (d1 > d2) {
      return 1;
    } else return -1;
  }
}
