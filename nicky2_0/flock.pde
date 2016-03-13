import java.util.List;
import java.util.Random;
import java.util.Arrays;
import java.util.Comparator;
import java.awt.Polygon;
import java.awt.geom.Area;
import java.util.Collections;
import java.util.concurrent.ThreadLocalRandom;

import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;

class Flock { 

  private float[] xs, ys, dxs, dys, rotations, drotations, speedModifiers;
  private float[] drawxs, drawys, ddrawxs, ddrawys;
  private boolean[] isOnes;
  private int[] homeForceIndices;
  
  private float[][] distances;
  private int[][] nextUpdateIn;
  private color[] tints; 
  
  private float[] sepKeepsx, sepKeepsy;
  private float[] aliKeepsx, aliKeepsy;
  private float[] cohKeepsx, cohKeepsy;
  
  private MiniFlocks miniFlocks = new MiniFlocks();
  
  private static final float highDist = 999999;
  private static final float maxRotationSpeed = 0.06;
  public static final float desiredSeparation = 50.0f;
  public static final float minDistanceForForces = 2 * desiredSeparation;
  public static final float minDistanceForDontUpdateForNIterations = 2 * minDistanceForForces;
  public static final float minDistanceForForcesSquared = minDistanceForForces*minDistanceForForces;
  public static final float minDistanceForDontUpdateForNIterationsSquared = 2 * minDistanceForForcesSquared;
  public static final int   dontUpdateForNIterations = 10;
  public static final float imgScaleBy = 0.1; 
  private static final float maxforce = 0.2;    // Maximum steering force
  public static final color freeTint = 0; 
  public static final int centerChunkIndex = 27;
  
  Flock (int numParticles) {
    xs = new float[numParticles];
    ys = new float[numParticles];
    drawxs = new float[numParticles];
    drawys = new float[numParticles];
    ddrawxs = new float[numParticles];
    ddrawys = new float[numParticles];
    dxs = new float[numParticles]; //<>//
    dys = new float[numParticles];
    rotations = new float[numParticles];
    drotations = new float[numParticles];
    speedModifiers = new float[numParticles];
    
    isOnes = new boolean[numParticles];
    homeForceIndices = new int[numParticles];   
    
    sepKeepsx = new float[numParticles];
    aliKeepsx = new float[numParticles];
    cohKeepsx = new float[numParticles];
    sepKeepsy = new float[numParticles];
    aliKeepsy = new float[numParticles];
    cohKeepsy = new float[numParticles];
    
    tints = new color[numParticles];
    
    if (!useMiniFlocks) {
      distances = new float[numParticles][numParticles];
      nextUpdateIn = new int[numParticles][numParticles];
    }
    for (int n = 0; n < numParticles; n++) {
      isOnes[n] = random(1000 ) < 500;
      rotations[n] = random(0 , 1000);
      drotations[n] = random(-Flock.maxRotationSpeed , Flock.maxRotationSpeed);
      speedModifiers[n] = 1.0;
    }    
  }
   
  public void setupRandomDistributionCenteredOn(int x, int y, int radius) {
    for (int n = 0; n < xs.length; n++) {
      //xs[n] = x + random(-radius,radius);
      //ys[n] = y + random(-radius,radius);
      xs[n] = x - radius + (noise(n * 0.005) * radius * 2);
      ys[n] = y - radius + (noise(xs.length - n * 0.005) * radius * 2);
      drawxs[n] = xs[n];
      drawys[n] = ys[n];
      rotations[n] = random(2 * PI);
      drotations[n] = random(-Flock.maxRotationSpeed , Flock.maxRotationSpeed);
    }
  }
    
  public void allDraw (int videoOversample, int thisOversample) {
    for (int n = 0; n < xs.length; n++) {
      if (!fullDraw) {
        dotDraw(drawxs[n],drawys[n]);
      } else {
        imgDraw(drawxs[n],drawys[n],ddrawxs[n],ddrawys[n],rotations[n],drotations[n],isOnes[n],tints[n],videoOversample,thisOversample);
      } 
    }
  }
  
  public void allRunFlocking () {
    calcAllDistances();
    for (int n = 0; n < xs.length; n++ ) {      
      runFlocking(n);
    }
  }
  
  private void runFlocking(int n) {
    PVector sep = separateAll(n);   // Separation
    PVector ali = alignAll(n);      // Alignment
    PVector coh = cohesionAll(n);   // Cohesion
    
    // weight these forces
    sep.mult(separationForce);
    ali.mult(alignmentForce);
    coh.mult(cohesionForce);
             
    // Update velocity
    dxs[n] += (sep.x + ali.x + coh.x);
    dys[n] += (sep.y + ali.y + coh.y);
    this.limitSpeed(n);
    xs[n] += dxs[n];
    ys[n] += dys[n];
    
    updateSmoothedPositions(n,motionSmoothing);
    //if (n == 0) {
    //  println(xs[n],drawxs[n]);
    //}
  }

  public void allRotate () {
    for (int n = 0; n < xs.length; n++) {
      rotations[n] += drotations[n] * freeSpeedModifier;
    }
  }  
   
  private void calcAllDistances () {
    for (int i = 0; i < xs.length; i++ ) {
      distances[i][i] = 0; //self
            
      for (int j = i + 1; j < xs.length; j++ ) {                              
        if (nextUpdateIn[i][j] > 0) {
          nextUpdateIn[i][j]--;
          continue;          
        } 
          
        float dx = abs(xs[i] - xs[j]);
        if (dx > Flock.minDistanceForDontUpdateForNIterations) {
          set2dist(i,j,Flock.highDist);
          nextUpdateIn[i][j] = Flock.dontUpdateForNIterations;
          continue;
        } else if (dx > Flock.minDistanceForForces) {
          set2dist(i,j,highDist);
          continue;
        }
        
        float dy = abs(ys[i] - ys[j]);
        if (dy > Flock.minDistanceForDontUpdateForNIterations) {
          set2dist(i,j,Flock.highDist);
          nextUpdateIn[i][j] = Flock.dontUpdateForNIterations;
          continue;
        } else if (dy > Flock.minDistanceForForces) {
          set2dist(i,j,Flock.highDist);
          continue;
        }
              
        float distSquared = (dx*dx + dy*dy);
        if (distSquared > Flock.minDistanceForDontUpdateForNIterationsSquared) {
          set2dist(i,j,Flock.highDist);
          nextUpdateIn[i][j] = Flock.dontUpdateForNIterations;
          continue;
        } else if (distSquared > Flock.minDistanceForForcesSquared) {
          set2dist(i,j,Flock.highDist);
          continue;
        } 
        
        set2dist(i,j,sqrt(distSquared));
      } // j
    } // i
  }
  
  private void set2dist (int i, int j, float d) {
    distances[i][j] = d;
    distances[j][i] = d;
  }
  
  public void assignMiniFlocks() { //<>//
    miniFlocks.assignToMiniFlocks(xs.length);
  } 
  
  public void calcMiniFlocksForcesAndMotion() {
    sepKeepsx = new float[xs.length];
    sepKeepsy = new float[xs.length];
    aliKeepsx = new float[xs.length];
    aliKeepsy = new float[xs.length];
    cohKeepsx = new float[xs.length];
    cohKeepsy = new float[xs.length];
    
    miniFlocks.calcMiniFlocksForces();

    for (int n = 0; n < xs.length; n++) {
      PVector homeF = homeForceForParticle(n);
      runFlockingWithKeptForces(n,homeF,false);
    }
  }
  
  public void runFlockingWithKeptForces(int n, PVector homeF, boolean printing) {
    dxs[n] += (sepKeepsx[n] * separationForce + aliKeepsx[n] * alignmentForce + cohKeepsx[n] * cohesionForce);
    dys[n] += (sepKeepsy[n] * separationForce + aliKeepsy[n] * alignmentForce + cohKeepsy[n] * cohesionForce);
    HomeForce homeForce = homeForces.get(homeForceIndices[n]);
    if (homeForce.force != 0) {
      dxs[n] += homeF.x * homeForce.force;
      dys[n] += homeF.y * homeForce.force;
    }
    this.limitSpeed(n);
    xs[n] += dxs[n] * speedModifiers[n];
    ys[n] += dys[n] * speedModifiers[n];
    
    updateSmoothedPositions(n,motionSmoothing);
  }
  
  public void updateSmoothedPositions(int n, float motionSmoothing) {
    ddrawxs[n] = (xs[n] - drawxs[n]) * motionSmoothing;
    drawxs[n] += ddrawxs[n];
    ddrawys[n] = (ys[n] - drawys[n]) * motionSmoothing;
    drawys[n] += ddrawys[n];    
  }
  
  public PVector homeForceForParticle(int n) {
    HomeForce homeForce = homeForces.get(homeForceIndices[n]);
    if (homeForce.force == 0) {
      return new PVector(0,0);
    } else {
      //add a little bit of fudging to the homeforce target locations
      PVector steer = new PVector(homeForce.x + random(- homeForce.radius, homeForce.radius) - xs[n], 
                                  homeForce.y - random(- homeForce.radius, homeForce.radius) - ys[n]);
      steer.limit(maxforce);
      return steer;
    }
  }
  
  public void limitSpeed(int n) {
    float velocitySquared = dxs[n]*dxs[n] + dys[n]*dys[n];
    float mxV = maxSpeed();
    if (velocitySquared > mxV*mxV) {
      float scaling = mxV / sqrt (velocitySquared);
      dxs[n] *= scaling;
      dys[n] *= scaling;
    }     
  }
    
  public void addFlockingForces(int n, List<Integer> particles, float[] distances, int nActive) {
    PVector sep = this.separate(n, particles, distances, nActive);   // Separation
    sepKeepsx[n] += sep.x;
    sepKeepsy[n] += sep.y;
    
    PVector ali = this.align(n, particles, distances, nActive);      // Alignment
    aliKeepsx[n] += ali.x;
    aliKeepsy[n] += ali.y;
    
    PVector coh = this.cohesion(n, particles, distances, nActive);   // Cohesion
    cohKeepsx[n] += coh.x;
    cohKeepsy[n] += coh.y;    
  }
  
  private PVector separate (int n, List<Integer> particles, float[] distances, int nActive) {
    PVector steer = new PVector(0, 0);
    int count = 0;
    for (int i = 0; i < nActive; i++) {
      float d = distances[i];  
      if ((d > 0) && (d < desiredSeparation)) {
        int n2 = particles.get(i);
        if (n != n2) {// && (states[n] != kChunk || chunkIndices[n] != chunkIndices[n2])) {
          // Calculate vector pointing away from neighbor
          PVector diff = new PVector(xs[n] - xs[n2], ys[n] - ys[n2]);
          diff.normalize();
          diff.div(d);        // Weight by distance
          steer.add(diff);
          count++;            // Keep track of how many
        }
      }
    }
    
    if (count > 0) {
      steer.div((float)count);
    }

    if (steer.mag() > 0) {
      // Implement Reynolds: Steering = Desired - Velocity
      steer.normalize();
      steer.mult(maxSpeed());
      steer.x -= dxs[n];
      steer.y -= dys[n];
      steer.limit(maxforce);
    }
    return steer;
  }
  
  private PVector align (int n, List<Integer> particles, float[] distances, int nActive) {
    PVector sum = new PVector(0, 0);
    int count = 0;
    for (int i = 0; i < nActive; i++) {
      float d = distances[i];
      if ((d > 0) && (d < minDistanceForForces)) {
        int n2 = particles.get(i);
        if (n != n2) {// && (states[n] != kChunk || chunkIndices[n] != chunkIndices[n2])) {
          sum.x += dxs[n2];
          sum.y += dys[n2];
          count++;
        }
      }
    }
    if (count > 0) {
      sum.div((float)count);
      // Implement Reynolds: Steering = Desired - Velocity
      sum.normalize();
      sum.mult(maxSpeed());
      PVector steer = new PVector(sum.x - dxs[n], sum.y - dys[n]);
      steer.limit(maxforce);
      return steer;
    } 
    else {
      return new PVector(0, 0);
    }
  }
  
  private PVector cohesion (int n, List<Integer> particles, float[] distances, int nActive) {
    PVector sum = new PVector(0, 0);   // Start with empty vector to accumulate all locations
    int count = 0;
    for (int i = 0; i < nActive; i++) {
      float d = distances[i];
      if ((d > 0) && (d < minDistanceForForces)) {
        int n2 = particles.get(i);
        if (n != n2) {// && (states[n] != kChunk || chunkIndices[n] != chunkIndices[n2])) {
          sum.x += xs[n2]; // Add location
          sum.y += ys[n2]; // Add location
          count++;
        }
      }
    }
    if (count > 0) {
      sum.div(count);
      return seek(n, sum);  // Steer towards the location
    } 
    else {
      return new PVector(0, 0);
    }
  }
    
  private PVector seek(int n, PVector target) {
    PVector desired = new PVector(target.x - xs[n], target.y - ys[n]);  // A vector pointing from the location to the target
    // Scale to maximum speed
    desired.normalize();
    desired.mult(maxSpeed());

    // Above two lines of code below could be condensed with new PVector setMag() method
    // Not using this method until Processing.js catches up
    // desired.setMag(maxspeed);

    // Steering = Desired minus Velocity
    PVector steer = new PVector(desired.x - dxs[n], desired.y - dys[n]);
    steer.limit(maxforce);  // Limit to maximum steering force
    return steer;
  }
  
  public PVector getForceSumForParticle(int n, List<Integer> particles, float[] distances, int nActive) {
    PVector sep = separate(n,particles,distances,nActive);   // Separation
    PVector ali = align(n,particles,distances,nActive);      // Alignment
    PVector coh = cohesion(n,particles,distances,nActive);   // Cohesion
    // weight these forces
    sep.mult(separationForce);
    ali.mult(alignmentForce);
    coh.mult(cohesionForce);
    
    PVector force = new PVector(0,0);
    force.add(sep);
    force.add(ali);
    force.add(coh);
    return force;
  } 
  
  private PVector separateAll (int n) {
    PVector steer = new PVector(0, 0);
    int count = 0;
    for (int n2 = 0; n2 < xs.length; n2++) {
      if (n != n2) {
        float d = distances[n][n2];  
        if ((d > 0) && (d < desiredSeparation)) {          
          // Calculate vector pointing away from neighbor
          PVector diff = new PVector(xs[n] - xs[n2], ys[n] - ys[n2]);
          diff.normalize();
          diff.div(d);        // Weight by distance
          steer.add(diff);
          count++;            // Keep track of how many
        }
      }
    }
    
    if (count > 0) {
      steer.div((float)count);
    }

    if (steer.mag() > 0) {
      // Implement Reynolds: Steering = Desired - Velocity
      steer.normalize();
      steer.mult(maxSpeed());
      steer.x -= dxs[n];
      steer.y -= dys[n];
      steer.limit(maxforce);
    }
    return steer;
  }
  
  private PVector alignAll (int n) {
    PVector sum = new PVector(0, 0);
    int count = 0;
    for (int n2 = 0; n2 < xs.length; n2++) {
      if (n != n2) {
        float d = distances[n][n2];
        if ((d > 0) && (d < minDistanceForForces)) {          
          sum.x += dxs[n2];
          sum.y += dys[n2];
          count++;          
        }
      }
    }
    if (count > 0) {
      sum.div((float)count);
      // Implement Reynolds: Steering = Desired - Velocity
      sum.normalize();
      sum.mult(maxSpeed());
      PVector steer = new PVector(sum.x - dxs[n], sum.y - dys[n]);
      steer.limit(maxforce);
      return steer;
    } 
    else {
      return new PVector(0, 0);
    }
  }
  
  private PVector cohesionAll (int n) {
    PVector sum = new PVector(0, 0);   // Start with empty vector to accumulate all locations
    int count = 0;
    for (int n2 = 0; n2 < xs.length; n2++) {
      if (n != n2) {
        float d = distances[n][n2];
        if ((d > 0) && (d < minDistanceForForces)) {
          sum.x += xs[n2]; // Add location
          sum.y += ys[n2]; // Add location
          count++;
        }
      }
    }
    if (count > 0) {
      sum.div(count);
      return seek(n, sum);  // Steer towards the location
    } 
    else {
      return new PVector(0, 0);
    }
  }
        
  public void assignHomeForceIndexWithProbability(float p1, float p2) {
    for (int n = 0; n < homeForceIndices.length; n++) {
      if (random(0,1) < p1 ) {
        homeForceIndices[n] = 0;
      } else if (random(0,1) < p2) {
        homeForceIndices[n] = 1;
      } else {
        homeForceIndices[n] = 2;
      }
    }
  }
  
  public void assignHomeForceIndexWithLocation(int radius, int x, int y) {
    float radiusSquared = radius * radius;
    for (int n = 0; n < homeForceIndices.length; n++) {
      float distSquared = (x - xs[n])*(x - xs[n]) + (y - ys[n])*(y - ys[n]);
      if (distSquared > radiusSquared) {
        homeForceIndices[n] = 0;
      } else {
        homeForceIndices[n] = 1;
      }
    }
  }
  
}