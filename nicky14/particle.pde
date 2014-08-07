class Particle { 
  //position
  public  PVector pos; 
  private PVector velocity; 
  private PVector acceleration;
  
  //rotation
  private PVector rotation;
  private PVector rotationVelocity;
  
  //target position
  //private PVector target;
  //private boolean targetReached = true;
  //private float   targetRadius = 5.0;
  
  //home position
  private PVector home;
  
  public  boolean isOne;
  public  boolean useImage = true;
  //private static final float moveByDenominator = 8;
  private static final float maxRotationSpeed = 0.06;
  //static final float maxspeed = 30;    // Maximum speed
  public  static final float maxMaxSpeed = 50.0;
  private static final float maxforce = 0.2;    // Maximum steering force
  
  public static final float minDistanceForForces = 100.0;
  public static final float minDistanceForDontUpdateForNIterations = 2 * minDistanceForForces;
  public static final float minDistanceForForcesSquared = minDistanceForForces*minDistanceForForces;
  public static final float minDistanceForDontUpdateForNIterationsSquared = 2 * minDistanceForForcesSquared;
  public static final int   dontUpdateForNIterations = 5;
  public static final int   imgScaleBy = 5;
  
  
  //CDF parent: who set our target
  CDF CDFParent;
   
  //------------------------------------------------------------
  
  
  public Particle (PVector vector) {
    pos = vector;
    //velocity = new PVector(0 , 0 , 0);
    float vMax = 50;
    home = new PVector(0,0,0);
    velocity = new PVector(random(vMax) , random(vMax) , random(vMax));
    acceleration = new PVector(0 , 0 , 0);
    isOne = random(255) < 128.0;
    rotation = new PVector(random(0 , 1000) , random(0 , 1000) , random(0 , 1000));
    rotationVelocity = new PVector(random(-maxRotationSpeed , maxRotationSpeed) ,
                                   random(-maxRotationSpeed , maxRotationSpeed) ,
                                   random(-maxRotationSpeed , maxRotationSpeed));
  }
  
  public void moveTo (PVector vector, CDF sender) {
    pos = vector;
    CDFParent = sender;
  }
  
  public void vectorTo (PVector vector, CDF sender) {
    //target = vector;
    //targetReached = false;
    home = vector;
    CDFParent = sender;
  }
  
  private String getText () {
    return (isOne ? "I" : "0");
  }
  
  String getInfo () {
    String[] s = {"x ", str(pos.x) ,"   y ", str(pos.y) , "    " ,  str(pos.z) };
    return join(s,"");  
  }
  
  public void iterate () {
 
//    if (!targetReached) {    
//      //move position towards target
//      if (pos.x != target.x) {
//        //velocity.x = (target.x - pos.x) / moveByDenominator; 
//        pos.x += (target.x - pos.x) / moveByDenominator; 
//      }
//      if (pos.y != target.y) {
//        //velocity.y = (target.y - pos.y) / moveByDenominator;
//        pos.y += (target.y - pos.y) / moveByDenominator;  
//      }
//      if (pos.z != target.z) {
//        //velocity.z = (target.z - pos.z) / moveByDenominator;
//        pos.z += velocity.z = (target.z - pos.z) / moveByDenominator;  
//      }
//      
//      //once we get close enough to the target, stop trying to go to target
//      if (abs(pos.x - target.x) < targetRadius && 
//          abs(pos.y - target.y) < targetRadius && 
//          abs(pos.z - target.z) < targetRadius) {
//        targetReached = true;
//      }
//    }
    
    //rotation velocity
    rotation.add(rotationVelocity);
  }
  
  
  public void textDraw () {
    pushMatrix();
    translate( pos.x , pos.y , pos.z * zScale); 
    rotateX(rotation.x);
    rotateY(rotation.y);
    rotateZ(rotation.z);               
  
    text( this.getText() , 0 , 0 , 0 ); 
    
    popMatrix();
  }
  
  public void imgDraw () {
    pushMatrix();
    translate( pos.x , pos.y , pos.z * zScale); 
    rotateX(rotation.x);
    rotateY(rotation.y);
    rotateZ(rotation.z);               
  
    if (this.isOne) {
      image(img1, 0, 0, img1.width / imgScaleBy, img1.height / imgScaleBy);
    } else {
      image(img0, 0, 0, img0.width / imgScaleBy, img0.height / imgScaleBy);
    } 
    
    popMatrix();
  }  
      
  // Separation
  // Method checks for nearby particles and steers away
  private PVector separate (ArrayList<Particle> particles, float[] distances, int nActive) {
    float desiredseparation = 50.0f;
    PVector steer = new PVector(0, 0, 0);
    int count = 0;
    // For every boid in the system, check if it's too close
    for (int i = 0; i < nActive; i++) {
      float d = distances[i];
      // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
      if ((d > 0) && (d < desiredseparation)) {
        Particle other = particles.get(i);
        // Calculate vector pointing away from neighbor
        PVector diff = PVector.sub(pos, other.pos);
        diff.normalize();
        diff.div(d);        // Weight by distance
        steer.add(diff);
        count++;            // Keep track of how many
      }
    }
    // Average -- divide by how many
    if (count > 0) {
      steer.div((float)count);
    }

    // As long as the vector is greater than 0
    if (steer.mag() > 0) {
      // First two lines of code below could be condensed with new PVector setMag() method
      // Not using this method until Processing.js catches up
      // steer.setMag(maxspeed);

      // Implement Reynolds: Steering = Desired - Velocity
      steer.normalize();
      steer.mult(maxParticleSpeed);//steer.mult(maxspeed);
      steer.sub(velocity);
      steer.limit(maxforce);
    }
    return steer;
  }
  
    // Alignment
  // For every nearby boid in the system, calculate the average velocity
  private PVector align (ArrayList<Particle> particles, float[] distances, int nActive) {
    float neighbordist = 100;
    PVector sum = new PVector(0, 0);
    int count = 0;
    for (int i = 0; i < nActive; i++) {
      float d = distances[i];
      if ((d > 0) && (d < neighbordist)) {
        Particle other = particles.get(i);
        sum.add(other.velocity);
        count++;
      }
    }
    if (count > 0) {
      sum.div((float)count);
      // First two lines of code below could be condensed with new PVector setMag() method
      // Not using this method until Processing.js catches up
      // sum.setMag(maxspeed);

      // Implement Reynolds: Steering = Desired - Velocity
      sum.normalize();
      sum.mult(maxParticleSpeed);//sum.mult(maxspeed);
      PVector steer = PVector.sub(sum, velocity);
      steer.limit(maxforce);
      return steer;
    } 
    else {
      return new PVector(0, 0);
    }
  }
  
  // Cohesion
  // For the average location (i.e. center) of all nearby boids, calculate steering vector towards that location
  private PVector cohesion (ArrayList<Particle> particles, float[] distances, int nActive) {
    float neighbordist = 100;
    PVector sum = new PVector(0, 0);   // Start with empty vector to accumulate all locations
    int count = 0;
    for (int i = 0; i < nActive; i++) {
      float d = distances[i];
      if ((d > 0) && (d < neighbordist)) {
        Particle other = particles.get(i);
        sum.add(other.pos); // Add location
        count++;
      }
    }
    if (count > 0) {
      sum.div(count);
      return seek(sum);  // Steer towards the location
    } 
    else {
      return new PVector(0, 0);
    }
  }
  
  //BackHome
  private PVector backHome () {    
    return seek(home);
  }
  
    // A method that calculates and applies a steering force towards a target
  // STEER = DESIRED MINUS VELOCITY
  private PVector seek(PVector target) {
    PVector desired = PVector.sub(target, pos);  // A vector pointing from the location to the target
    // Scale to maximum speed
    desired.normalize();
    desired.mult(maxParticleSpeed);//desired.mult(maxspeed);

    // Above two lines of code below could be condensed with new PVector setMag() method
    // Not using this method until Processing.js catches up
    // desired.setMag(maxspeed);

    // Steering = Desired minus Velocity
    PVector steer = PVector.sub(desired, velocity);
    steer.limit(maxforce);  // Limit to maximum steering force
    return steer;
  }
  
  
  
  void runFlocking(ArrayList<Particle> particles, float[] distances, int nActive) {
    //flock(particles, distances, nActive);
    
    PVector sep = separate(particles,distances,nActive);   // Separation
    PVector ali = align(particles,distances,nActive);      // Alignment
    PVector coh = cohesion(particles,distances,nActive);   // Cohesion
    PVector hom = backHome();
    // Arbitrarily weight these forces
    sep.mult(separationForce);
    ali.mult(alignmentForce);
    coh.mult(cohesionForce);
    hom.mult(homeForce);
    
    // Add the force vectors to acceleration
    applyForce(sep);
    applyForce(ali);
    applyForce(coh);
    applyForce(hom);    
    
    
    //updateFromFlocking();
    
    
    // Update velocity
    velocity.add(acceleration);
    // Limit speed
    velocity.limit(maxParticleSpeed);//velocity.limit(maxspeed);
    //println(velocity, "    ", maxParticleSpeed);
    //rotation = velocity;
    pos.add(velocity);
    // Reset acceleration to 0 each cycle
    acceleration.mult(0);    
  }

  private void applyForce(PVector force) {
    // We could add mass here if we want A = F / M
    acceleration.add(force);
  }

//  // We accumulate a new acceleration each time based on three rules
//  private void flock(ArrayList<Particle> particles, float[] distances, int nActive) {
//    //float[] distances = getDistances(particles);
//    PVector sep = separate(particles,distances);   // Separation
//    PVector ali = align(particles,distances);      // Alignment
//    PVector coh = cohesion(particles,distances);   // Cohesion
//    PVector hom = backHome();
//    // Arbitrarily weight these forces
//    sep.mult(separationForce);
//    ali.mult(alignmentForce);
//    coh.mult(cohesionForce);
//    hom.mult(homeForce);
//    
//    // Add the force vectors to acceleration
//    applyForce(sep);
//    applyForce(ali);
//    applyForce(coh);
//    applyForce(hom);
//  }

//  private void updateFromFlocking() {
//    // Update velocity
//    velocity.add(acceleration);
//    // Limit speed
//    velocity.limit(maxParticleSpeed);//velocity.limit(maxspeed);
//    //println(velocity, "    ", maxParticleSpeed);
//    //rotation = velocity;
//    pos.add(velocity);
//    // Reset acceleration to 0 each cycle
//    acceleration.mult(0);
//  } 
} 
