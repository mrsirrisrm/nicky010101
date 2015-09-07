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

public static final int kGrid = 0;
public static final int kTransition = 1;
public static final int kChunk = 2;
public static final int kFree = 3;
public static final int kDisordering = 4;

class Flock { 

  private float[] xs, ys, dxs, dys, rotations, drotations;
  private float[] drawxs, drawys, ddrawxs, ddrawys;
  private int[] states;
  private float[] stateMixes;
  private int[] stateChangeCountdown;
  private boolean[] isOnes;
  private int[] chunkIndices;
  
  private List<Integer> permanentGridInds;
  public List<Float> erosionAngles;
  
  private float[][] distances;
  private int[][] nextUpdateIn;
  private color[] tints; 
  
  private float[] sepKeepsx, sepKeepsy;
  private float[] aliKeepsx, aliKeepsy;
  private float[] cohKeepsx, cohKeepsy;
  private float[] grdKeepsx, grdKeepsy;
  private float[] gr2Keepsx, gr2Keepsy;
  
  private ArrayList<Chunk> chunks; 
  private MiniFlocks miniFlocks = new MiniFlocks();
  private float maxPermanentGridDistFromCenter = 0;
  
  //private float velocityTrendX = 0;
  //private float velocityTrendY = 0;
  private float velocityTrendDistribution = 0;
  
  InputStream fis = null;
  DataInputStream dis = null;
  FileOutputStream fos = null;
  DataOutputStream dos = null;
  
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
  
  Flock (int numParticles, int inputPositionsMode, int inputPositionsStartFromFrame) {
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
    
    states = new int[numParticles];
    stateMixes = new float[numParticles];
    stateChangeCountdown = new int[numParticles];   
    isOnes = new boolean[numParticles];
    chunkIndices = new int[numParticles];   
    permanentGridInds = new ArrayList<Integer>();
    erosionAngles = new ArrayList<Float>();
    
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
      chunkIndices[n] = -1;
      rotations[n] = random(0 , 1000);
      drotations[n] = random(-Flock.maxRotationSpeed , Flock.maxRotationSpeed);
    } 
    
    chunks = new ArrayList<Chunk>();
    
    try {
      if (inputPositionsMode == 2) {
          fis = new FileInputStream( positionsFile ); 
          dis = new DataInputStream(fis);
          int fileParticles = dis.readInt(); 
          if (fileParticles != numParticles) {
            println("Warning, recorded positions had",fileParticles,"particles, this run has",numParticles,"particles");
          }
          dis.skipBytes( inputPositionsStartFromFrame * 6 * 4 * numParticles );
      } else if (inputPositionsMode == 1) {
          fos = new FileOutputStream( positionsFile ); 
          dos = new DataOutputStream(fos);
          dos.writeInt( numParticles );
      }
    } catch (Exception e) {
      inputPositionsMode = 0;
    };
    
    int N = 10;
    for (int i = 0; i < N; i++) { 
      erosionAngles.add( i * 2 * PI / N + random(-PI/N, PI/N) );
    }
  }
 
  public float setupPolarGrid (int highGridIndex, int highTransitionIndex) {
    float randomAngleThisDist = random(0,2*PI);
    
    //float[] permanentG = new float[100];
    //int endCutoff = 5;
    //for (int i = 0; i < permanentG.length; i++) {
    //  permanentG[i] = 30 + noise(0.05*i) * 70;
    //  if (i > permanentG.length - endCutoff) {
    //    permanentG[i] += (permanentG[0] - permanentG[i]) * (1.0 - ((float)(permanentG.length - i) / (float)endCutoff)); 
    //  }
    //} 
    
    float angleSpacingScaling = 1.2;
    float distScaling = 1.1;
    float ang = 0.;
    float d = 0.;
    //float dTransition = 5000.;
    for (int n = 0; n < xs.length; n++) { 
      if (n == 0) {
        d = imgHeight(isOnes[n]);
      }
      if (n < highGridIndex) {
        xs[n] = width/2 + d * sin(ang + randomAngleThisDist);
        ys[n] = height/2 + d * cos(ang + randomAngleThisDist);
        rotations[n] = -(ang + randomAngleThisDist);
        drotations[n] = 0.0;
        states[n] = kGrid;
        
        //move to next position
        ang += atan2( imgWidth(isOnes[n]) , d ) * angleSpacingScaling; 
        
        //check for move out by 1 row
        if (ang > 2.0*PI) {
          d += imgHeight(isOnes[n]) * 1.0 * distScaling;
          ang -= 2.*PI;   
          randomAngleThisDist = random(0,2*PI);
        } 
      } else if (n < highTransitionIndex) {
        xs[n] = width/2 + d * sin(ang + randomAngleThisDist);
        ys[n] = height/2 + d * cos(ang + randomAngleThisDist);
        rotations[n] = -(ang + randomAngleThisDist);
        states[n] = kTransition;

        //move to next position
        ang += atan2( imgWidth(isOnes[n]) , d ) * angleSpacingScaling;
        
        //check for move out by 1 row
        if (ang > 2.*PI) {
          d += imgHeight(isOnes[n]) * 1.1 * distScaling;
          ang -= 2.*PI;
          randomAngleThisDist = random(0,2*PI);   
        }  
      } else {
        xs[n] = width/2 + random(0.995,1.005) * d * sin(ang + randomAngleThisDist);
        ys[n] = height/2 + random(0.995,1.005) * d * cos(ang + randomAngleThisDist);
        rotations[n] = random(0,2*PI);
        states[n] = kFree;
        
        //move to next position
        ang += atan2( imgWidth(isOnes[n]) , d ) * angleSpacingScaling;
        
        //check for move out by 1 row
        if (ang > 2.0*PI) {
          d += imgHeight(isOnes[n]) * 1.15 * distScaling;
          ang -= 2.*PI; 
          randomAngleThisDist = random(0,2*PI);  
        }  
      }
    }
    
    for (int n = 0; n < xs.length; n++) {
      drawxs[n] = xs[n];
      drawys[n] = ys[n];
    }
    
    return d;
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
    
  private float particleDistanceToAppletCenter(int n) {
    return distanceToAppletCenter(xs[n],ys[n]); 
  }
  
  public void freeParticle(Integer n) {
    states[n] = kFree;
    if (chunkIndices[n] >= 0) {
      Chunk chunk = chunks.get(chunkIndices[n]);
      dxs[n] += chunk.velocity.x;
      dys[n] += chunk.velocity.y;
      
      if (chunkIndices[n] == Flock.centerChunkIndex) {
        Integer nn = n;
        permanentGridInds.remove( nn );
      }
    }
    chunkIndices[n] = -1;
    tints[n] = Flock.freeTint;
  }
  
  private boolean isCenterChunk (Chunk chunk) {
    return chunks.indexOf(chunk ) == Flock.centerChunkIndex;
  }
  
  public void erodeFromChunks() {
    for (Chunk chunk : chunks) {
      if (chunk.canMove || isCenterChunk(chunk)) {
        chunk.erodeParticles();
        if (this.isCenterChunk(chunk) && chunk.erosionRate > 0) {
          this.updateMaxPermanentGridDistFromCenter();
        }
      }
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
    calcAllDistances ();
    for (int n = 0; n < xs.length; n++ ) {  
      runFlocking(n);
    }
    //permanentGridRepelFreeParticles();
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
  }

  public void allRotate () {
    for (int n = 0; n < xs.length; n++) {
      if (states[n] == kTransition) {
        rotations[n] += drotations[n] * (stateMixes[n] * speedModifier(kTransition) + (1.0 - stateMixes[n]) * speedModifier(kGrid));
      } else {
        rotations[n] += drotations[n] * speedModifier(states[n]);
      }
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
  
  private float velocityCurve(float d) {
    if (d < 0) {
      return d - d*d*0.0002;
    } else {
      return d + d*d*0.0002;      
    } 
  }
  
  public void assignChunkVelocities (float globalVelocity) {
    for (Chunk chunk : chunks) {
      chunk.velocity.x = velocityCurve(chunk.centerX() - width  / 2);
      chunk.velocity.y = velocityCurve(chunk.centerY() - height / 2);
      //chunk.velocity.normalize();
      chunk.velocity.mult(globalVelocity);
      //chunk.rotationVelocity = 0;//random(-chunk.velocity.mag() * 0.01,chunk.velocity.mag() * 0.01);
      //println(chunk.particles.size(), chunk.velocity); 
    }
  }
  
  public void moveChunks() {
    //println("chunk count",chunks.size());
    for (Chunk chunk : chunks) {
      if (chunk.canMove) {
        chunk.moveParticles();
      }
    }  
  }
  
  public void colourChunks() {
    for (Chunk chunk : chunks) {
      for (int n : chunk.particles) {
        tints[n] = chunk.tint;
      }
    }
  }
             
  private float dist2Particles(int n, int n2) {
    return sqrt( (xs[n] - xs[n2])*(xs[n] - xs[n2]) + (ys[n] - ys[n2])*(ys[n] - ys[n2]) );
  }  
      
  private int nearestParticle (int n) {
    int index = -1;
    float minDist = 99999;
    for (int n2 = 0; n2 < xs.length; n2++) {
      if (n != n2) {
        float aDist = dist2Particles(n,n2);
        if (aDist < minDist) {
          index = n2;
          minDist = aDist; 
        }
      }
    }
    return index;
  }
  
  
  public void assignChunksFromFile2(String filename, float maxDistFromCenter) {
    int DIM = 1530;
    float maxD = 0.0;
    int minChunkN = 999;
    int maxChunkN = -1;
    int[][] ins = new int[DIM][DIM]; //!!! change if file size changed

    try {
      FileInputStream afis = new FileInputStream( filename ); 
      DataInputStream adis = new DataInputStream(afis);
      if (adis.available() > 0) {
        for (int i = 0; i < DIM; i++) {
          for (int j = 0; j < DIM; j++) {
            ins[i][j] = adis.readInt();
            //NB the chunk indices in the file are 1-indexed
            if (ins[i][j] >= 0) {
              if (ins[i][j] > maxChunkN) {
                maxChunkN = ins[i][j];
              }
              if (ins[i][j] < minChunkN) {
                minChunkN = ins[i][j];
              }
              
              float dx = i + 1 - DIM / 2;
              float dy = j + 1 - DIM / 2;
              float d = sqrt(dx*dx + dy*dy);
              if (d > maxD) {
                maxD = d;
              }
            }
          }
        }
        //println(maxD);
        println("minChunk",minChunkN);
        println("maxChunk",maxChunkN);
        for (int i = minChunkN; i <= maxChunkN; i++) {
          Chunk chunk = new Chunk();
          chunk.tint = color(round(random(255)), round(random(255)), round(random(255)));
          chunks.add(chunk);
        }  //<>//
      } else {
        println("Error: end of chunks file");
      }
      adis.close();
      afis.close();
    } catch (Exception e) {
      println("Error reading chunks from file");
    };
    
    for (int n = 0; n < xs.length; n++) {
      int aI = round( (xs[n] - width /2) / maxDistFromCenter * maxD + DIM / 2);
      int aJ = round( (ys[n] - height/2) / maxDistFromCenter * maxD + DIM / 2);
      if (ins[aI][aJ] >= 0) {
        chunks.get(ins[aI][aJ] - minChunkN).addIndex(n,ins[aI][aJ] - minChunkN);
        if (ins[aI][aJ] - minChunkN == Flock.centerChunkIndex) {
          Integer nn = n;
          this.permanentGridInds.add( nn );
          //if (particleDistanceToAppletCenter(n) > maxPermanentGridDistFromCenter) {
          //  maxPermanentGridDistFromCenter = particleDistanceToAppletCenter(n);
          //}
        }
      }
    }
    
    updateMaxPermanentGridDistFromCenter();    
  }
  
  private void updateMaxPermanentGridDistFromCenter() {
    maxPermanentGridDistFromCenter = 0;
    for (Integer nn : this.permanentGridInds) {
      int n = nn;
      if (particleDistanceToAppletCenter(n) > maxPermanentGridDistFromCenter) {
        maxPermanentGridDistFromCenter = particleDistanceToAppletCenter(n);
      }
    }
    //println("maxPermanentGridDistFromCenter",maxPermanentGridDistFromCenter);
  }
     
  public int nFree() {
    int count = 0;
    for (int n = 0; n < xs.length; n++) {
      if (states[n] == kFree) {
        count++;
      }
    } 
    return count;
  } 
  
  public void assignMiniFlocks() {
    miniFlocks.assignToMiniFlocks(xs.length);
  } 
  
  public void calcMiniFlocksForcesAndMotion() {
    sepKeepsx = new float[xs.length];
    sepKeepsy = new float[xs.length];
    aliKeepsx = new float[xs.length];
    aliKeepsy = new float[xs.length];
    cohKeepsx = new float[xs.length];
    cohKeepsy = new float[xs.length];
    grdKeepsx = new float[xs.length];
    grdKeepsy = new float[xs.length];
    gr2Keepsx = new float[xs.length];
    gr2Keepsy = new float[xs.length];
    
    miniFlocks.calcMiniFlocksForces();

    for (int n = 0; n < xs.length; n++) {
      PVector homeF = homeForceForParticle(n);
      
      runFlockingWithKeptForces(n,homeF,false);
    }
    //permanentGridRepelFreeParticles();
  }
  
  public void runFlockingWithKeptForces(int n, PVector homeF, boolean printing) {
    dxs[n] += (sepKeepsx[n] * separationForce + aliKeepsx[n] * alignmentForce + cohKeepsx[n] * cohesionForce);
    dys[n] += (sepKeepsy[n] * separationForce + aliKeepsy[n] * alignmentForce + cohKeepsy[n] * cohesionForce);
    dxs[n] += grdKeepsx[n] * antiGridForce + gr2Keepsx[n] * antiGridForce2;
    dys[n] += grdKeepsy[n] * antiGridForce + gr2Keepsy[n] * antiGridForce2;
    if (homeForce != 0) {
      dxs[n] += homeF.x * homeForce;
      dys[n] += homeF.y * homeForce;
    }
    this.limitSpeed(n);
    //dxs[n] += velocityTrendX + random(-velocityTrendDistribution,velocityTrendDistribution);
    //dys[n] += velocityTrendY + random(-velocityTrendDistribution,velocityTrendDistribution); 
    xs[n] += dxs[n];
    ys[n] += dys[n];
    
    updateSmoothedPositions(n,motionSmoothing);
  }
  
  public void updateSmoothedPositions(int n, float motionSmoothing) {
    ddrawxs[n] = (xs[n] - drawxs[n]) * motionSmoothing;
    drawxs[n] += ddrawxs[n];
    ddrawys[n] = (ys[n] - drawys[n]) * motionSmoothing;
    drawys[n] += ddrawys[n];    
  }
  
  public PVector homeForceForParticle(int n) {
    if (homeForce == 0) {
      return new PVector(0,0);
    } else {
      //add a little bit of fudging to the homeforce target locations
      PVector steer = new PVector(homeForceX + random(- homeForceRadius, homeForceRadius)  - xs[n], homeForceY - random(- homeForceRadius, homeForceRadius) - ys[n]);
      steer.limit(maxforce);
      return steer;
    }
  }
  
  public void limitSpeed(int n) {
    float velocitySquared = dxs[n]*dxs[n] + dys[n]*dys[n];
    float mxV = maxSpeed(n);
    if (velocitySquared > mxV*mxV) {
      float scaling = mxV / sqrt (velocitySquared);
      dxs[n] *= scaling;
      dys[n] *= scaling;
    }     
  }
  
  public void releaseAChunk() {
    int ind = -1;
    float maxDist = 0;
    for (int i = 0; i < chunks.size(); i++) {
      Chunk chunk = chunks.get(i);
      if (!chunk.canMove) {
        float dx = chunk.centerX() - width  / 2;
        float dy = chunk.centerY() - height / 2;
        float dist = sqrt(dx*dx + dy*dy);
        if (dist > maxDist) {
          maxDist = dist;
          ind = i;
        }
      }
    }
    
    if (ind >= 0) {
      chunks.get(ind).canMove = true;
    }
  }
  
  public void releaseChunk(int chunkIndex) {
    if (chunkIndex < chunks.size()) {
      chunks.get(chunkIndex).canMove = true;
    }
  }
  
  public void explodeAChunk() {
    int ind = -1;
    float maxDist = 0;
    for (int i = 0; i < chunks.size(); i++) {
      Chunk chunk = chunks.get(i);
      if (chunk.canMove) {
        float dx = chunk.centerX() - width  / 2;
        float dy = chunk.centerY() - height / 2;
        float dist = sqrt(dx*dx + dy*dy);
        if (dist > maxDist) {
          maxDist = dist;
          ind = i;
        }
      }
    }
    
    if (ind >= 0) {
      chunks.get(ind).freeAllParticles();
    }    
  }
  
  public void explodeChunk(int chunkIndex) {
    if (chunkIndex < chunks.size()) {
      chunks.get(chunkIndex).freeAllParticles();
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
    
    PVector grd = this.antiGrid(n, particles, distances, nActive);   //anti-grid force
    grdKeepsx[n] += grd.x;
    grdKeepsy[n] += grd.y;
    
    PVector gr2 = this.antiGrid2(n, particles, distances, nActive);   //anti-grid force
    gr2Keepsx[n] += gr2.x;
    gr2Keepsy[n] += gr2.y;
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
      steer.mult(maxSpeed(n));
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
      sum.mult(maxSpeed(n));
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
  
  private PVector antiGrid (int n, List<Integer> particles, float[] distances, int nActive) {
    //Trying to deflect any particles that are heading for the centre grid
    PVector f = new PVector(0, 0);
    if (maxPermanentGridDistFromCenter == 0) {
      return f;
    }
    
    if (states[n] == kFree) {
      float d0 = particleDistanceToAppletCenter(n);
      if (d0 < maxPermanentGridDistFromCenter * 0.98) {
        float d1 = distanceToAppletCenter( xs[n] + dxs[n] , ys[n] + dys[n] );
        if (d1 < d0) {             
          float contactAngle = atan2( ys[n] + dys[n] - height / 2 , xs[n] + dxs[n] - width / 2 );          
          f.x = maxforce * cos(contactAngle);
          f.y = maxforce * sin(contactAngle);
          //tints[n] = color(255,0,0);
        }
      }
    }
    return f;    
  }
  
  private PVector antiGrid2 (int n, List<Integer> particles, float[] distances, int nActive) {
    //Trying to deflect any particles that are heading for the centre grid
    PVector f = new PVector(0, 0);
    if (maxPermanentGridDistFromCenter == 0) {
      return f;
    }
    
    if (states[n] == kFree) {
      float d0 = particleDistanceToAppletCenter(n);
      if (d0 < maxPermanentGridDistFromCenter * 1.3) {
        float d1 = distanceToAppletCenter( xs[n] + dxs[n] , ys[n] + dys[n] );
        if (d1 < d0) {             
          float contactAngle = atan2( ys[n] + dys[n] - height / 2 , xs[n] + dxs[n] - width / 2 );          
          f.x = maxforce * cos(contactAngle);
          f.y = maxforce * sin(contactAngle);
          //tints[n] = color(255,0,0);
        }
      }
    }
    return f;    
  }  
  
  private PVector seek(int n, PVector target) {
    PVector desired = new PVector(target.x - xs[n], target.y - ys[n]);  // A vector pointing from the location to the target
    // Scale to maximum speed
    desired.normalize();
    desired.mult(maxSpeed(n));//desired.mult(maxspeed);

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
          if (states[n] != kChunk || chunkIndices[n] != chunkIndices[n2]) {
            // Calculate vector pointing away from neighbor
            PVector diff = new PVector(xs[n] - xs[n2], ys[n] - ys[n2]);
            diff.normalize();
            diff.div(d);        // Weight by distance
            steer.add(diff);
            count++;            // Keep track of how many
          }
        }
      }
    }
    
    if (count > 0) {
      steer.div((float)count);
    }

    if (steer.mag() > 0) {
      // Implement Reynolds: Steering = Desired - Velocity
      steer.normalize();
      steer.mult(maxSpeed(n));
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
          if (states[n] != kChunk || chunkIndices[n] != chunkIndices[n2]) {
            sum.x += dxs[n2];
            sum.y += dys[n2];
            count++;
          }
        }
      }
    }
    if (count > 0) {
      sum.div((float)count);
      // Implement Reynolds: Steering = Desired - Velocity
      sum.normalize();
      sum.mult(maxSpeed(n));
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
          if (states[n] != kChunk || chunkIndices[n] != chunkIndices[n2]) {
            sum.x += xs[n2]; // Add location
            sum.y += ys[n2]; // Add location
            count++;
          }
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
  
  public void releaseGriddedParticlesExceptForRandomCenter() {
    for (int n = 0; n < xs.length; n++) {
      if (states[n] == kGrid) {
        this.freeParticle(n);
      }
    }
  }
  
  public void writePositionsToFile(boolean flush) {
    try {
      for (int n = 0; n < xs.length; n++) {
        //println("writing", frameCount);
        dos.writeFloat(xs[n]);
        dos.writeFloat(ys[n]);
        dos.writeFloat(dxs[n]);
        dos.writeFloat(dys[n]);
        dos.writeFloat(rotations[n]);
        dos.writeFloat(drotations[n]);      
      }
      if (flush) {
        dos.flush();
      }
    } catch (Exception e) {
      println("caught io exception on write positions to file", e); 
      inputPositionsMode = 0;
    }
  }
  
  public void closePositionsFile() {
    try {
      println("Closing positions file");
      if(fos != null) {
        fos.close();
      }
    } catch (Exception e) {};
    inputPositionsMode = 0;
  }
  
  public void readPositionsFromFile(boolean setSmoothedPositions) {
    try {
      if (dis.available() > 0) {
        //println("reading", frame);
        for (int n = 0; n < xs.length; n++) {
          xs[n] = dis.readFloat();
          ys[n] = dis.readFloat();
          dxs[n] = dis.readFloat();
          dys[n] = dis.readFloat();
          //drawxs[n] = xs[n];
          //drawys[n] = ys[n];
          rotations[n] = dis.readFloat();
          drotations[n] = dis.readFloat();
          
          if (setSmoothedPositions) {
            drawxs[n] = xs[n];
            drawys[n] = ys[n];
            ddrawxs[n] = dxs[n];
            ddrawys[n] = dys[n];
          }
          
          updateSmoothedPositions(n,motionSmoothing);
        }
      } else {
        println("End of input positions file");
        inputPositionsMode = 0;
      }
    } catch (Exception e) {
      println("Error reading input positions from file");
      inputPositionsMode = 0;
    };
  }
  
  public void freeParticlesGreaterThanRadius(float d) {
    //int count = 0;
    if (d > 0) {
      for (int n = 0; n < xs.length; n++) {
        if (particleDistanceToAppletCenter(n) > d) {
          if (states[n] == kGrid && !permanentGridInds.contains((Integer)n)) {
            states[n] = kDisordering;
            stateChangeCountdown[n] = 7; //start countdown timer
            drotations[n] = random(-0.1,+0.1);
            //count++;
          }
        }
      }
    }
    //println("moved",count,"from kGrid");
  }
    
  public void runStateChangeCountdown() {
    for (int n = 0; n < xs.length; n++) {
      if (stateChangeCountdown[n] > 1) {
        stateChangeCountdown[n]--;
      } else if (stateChangeCountdown[n] == 1) {
        states[n] = kChunk;  
        stateChangeCountdown[n]--;
      }
    }  
  }
  
  public void tempSetAllBackToGrid() {
    for (int n = 0; n < xs.length; n++) {
      states[n] = kGrid;
    }
  }
  
  public void erode(int i, float maxInitialDistFromCenter) {
    if (i < erosionAngles.size()) {
      float ang = erosionAngles.get(i);
      float x = width  / 2 + maxInitialDistFromCenter * sin(ang);
      float y = height / 2 + maxInitialDistFromCenter * cos(ang);
      
      //find closest particle to that point
      DistTuple[] dists = new DistTuple[xs.length];
      for (int n = 0; n < xs.length; n++) {
        if (states[n] == kTransition || states[n] == kGrid) {        
          float dx = xs[n] - x;
          float dy = ys[n] - y;
          dists[n] = new DistTuple(n,  dx * dx + dy * dy );
        } else {
          dists[n] = new DistTuple(n,  9999999);
        } 
      }   
      Arrays.sort(dists, new DistTupleComparator());
      
      states[dists[0].ind] = kFree;
    }
  }
  
  public void permanentGridRepelFreeParticles() {
//    for (Integer nn : permanentGridInds) {
//      for (int i = 0; i < miniFlocks.nMFx; i++) {
//        for (int j = 0; j < miniFlocks.nMFy; j++) {
//          MiniFlock mf = miniFlocks.miniFlocks[i][j];
//          for (Integer mm : mf.particles) {
//            if (states[mm] == kFree && mf.distances.get(nn)[mm] < 20) {
//              float angToCentre = atan2( height / 2 - ys[mm] , width / 2 - xs[mm]);
//              float velAngle = atan2( dys[mm], dxs[mm] );
//              if (abs(angToCentre - velAngle) < PI/3) {
//                dxs[mm] = -2 * dxs[mm];
//                dys[mm] = -2 * dys[mm];
//              }
//            }
//          }
//        }
//      }
//    }   

    for (int n = 0; n < xs.length; n++) {
      if (states[n] == kFree) {
        float d0 = particleDistanceToAppletCenter(n);
        if (d0 < maxPermanentGridDistFromCenter * 1.00) {
          float d1 = distanceToAppletCenter( xs[n] + dxs[n] , ys[n] + dys[n] );
          if (d1 < d0) { 
            //dxs[n] = -dxs[n];
            //dys[n] = -dys[n];
            //xs[n] += 2 * dxs[n];
            //ys[n] += 2 * dys[n];          
            
            //tints[n] = color(255,0,0);
            
            //Trying to deflect any particles that are heading for the centre grid
            xs[n] -= dxs[n];
            ys[n] -= dys[n];
            float velAngle = atan2( dys[n] , dxs[n] );
            if (velAngle < 0) {
              velAngle += 2 * PI;
            }
            float contactAngle = atan2( ys[n] + dys[n] , xs[n] + dxs[n] );
            if (contactAngle < 0) {
              contactAngle += 2 * PI;
            }
            float outAngle;
            if (velAngle > contactAngle) {
              outAngle = contactAngle - PI / 2;
            } else {
              outAngle = contactAngle + PI / 2;
            }
            float speed = sqrt(dxs[n] * dxs[n] + dys[n] * dys[n]);
            dxs[n] = speed * cos(outAngle);
            dys[n] = speed * sin(outAngle);
          }
        }
      }
    }
  }
  
  public void freeAllParticles() {
    for (int n = 0; n < xs.length; n++) {
      states[n] = kFree;
      chunkIndices[n] = -1;
    }
  }
}
