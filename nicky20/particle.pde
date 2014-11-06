class Particle { 
  //position
  public  PVector pos; 
  private PVector velocity; 
  private PVector acceleration;
  
  //rotation
  private PVector rotation;
  private PVector rotationVelocity;
    
  //home position
  private PVector home;
  
  public  boolean isOne;
  public  boolean useImage = true;
  private static final float maxRotationSpeed = 0.06;
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
    velocity = new PVector(random(-vMax,vMax) , random(-vMax,vMax), random(-vMax,vMax));
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
    home = vector;
    CDFParent = sender;
  }
  
  private String getText () {
    return (isOne ? "I" : "0");
  }
  
  String toString() {
    return "x " + str(pos.x) + ", y " + str(pos.y) + ", z" + str(pos.z) + ", roation x " + str(rotation.x) + ", y " + str(rotation.y) + ", z" + str(rotation.z);  
  }
  
  public void rotateIt (InputData inputData) {
    PVector rotVel = new PVector(rotationVelocity.x,rotationVelocity.y,rotationVelocity.z);
    if (inputData.peakiness2 > 0) {
      rotVel.mult( 30.0 / inputData.peakiness2 );
    }
    if (inputData.logLev2 > 0) {
      rotVel.mult(inputData.logLev2 / 300.0);
    }
    rotation.add( rotVel );
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
  private PVector separate (ArrayList<Particle> particles, float[] distances, int nActive, InputData input) {
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

      // Implement Reynolds: Steering = Desired - Velocity
      steer.normalize();
      steer.mult(input.maxParticleSpeed);//steer.mult(maxspeed);
      steer.sub(velocity);
      steer.limit(maxforce);
    }
    return steer;
  }
  
    // Alignment
  // For every nearby boid in the system, calculate the average velocity
  private PVector align (ArrayList<Particle> particles, float[] distances, int nActive, InputData input) {
    float neighbordist = 100;
    PVector sum = new PVector(0, 0, 0);
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

      // Implement Reynolds: Steering = Desired - Velocity
      sum.normalize();
      sum.mult(input.maxParticleSpeed);//sum.mult(maxspeed);
      PVector steer = PVector.sub(sum, velocity);
      steer.limit(maxforce);
      return steer;
    } 
    else {
      return new PVector(0, 0, 0);
    }
  }
  
  // Cohesion
  // For the average location (i.e. center) of all nearby boids, calculate steering vector towards that location
  private PVector cohesion (ArrayList<Particle> particles, float[] distances, int nActive, InputData input) {
    float neighbordist = 100;
    PVector sum = new PVector(0, 0, 0);   // Start with empty vector to accumulate all locations
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
      return seek(sum, input);  // Steer towards the location
    } 
    else {
      return new PVector(0, 0, 0);
    }
  }
  
  //BackHome
  private PVector backHome (InputData input) {    
    return seek(home, input);
  }
  
    // A method that calculates and applies a steering force towards a target
  // STEER = DESIRED MINUS VELOCITY
  private PVector seek(PVector target, InputData input) {
    PVector desired = PVector.sub(target, pos);  // A vector pointing from the location to the target
    // Scale to maximum speed
    desired.normalize();
    desired.mult(input.maxParticleSpeed);//desired.mult(maxspeed);

    // Steering = Desired minus Velocity
    PVector steer = PVector.sub(desired, velocity);
    steer.limit(maxforce);  // Limit to maximum steering force
    return steer;
  }
  
  
  
  void runFlocking(ArrayList<Particle> particles, 
                   float[] distances, 
                   int nActive, 
                   InputData input) {//float logdVdt,float adVdtSensitivity,float peakiness,float aPeakinessSensitivity,float dLevdtSmoothed,boolean adVdtToParticleXVelocity,boolean aPeakinessToParticleYVelocity) {    
    PVector sep = separate(particles,distances,nActive,input);   // Separation
    PVector ali = align(particles,distances,nActive,input);      // Alignment
    PVector coh = cohesion(particles,distances,nActive,input);   // Cohesion
    PVector hom = backHome(input);
    
    // Arbitrarily weight these forces
    float sepForce = separationForce;
    if (input.dVdtSensitivity > 0) {
      sepForce += input.dVdtSensitivity * input.logdVdt;
    }
    if (input.peakinessSensitivity > 0) {
      sepForce += input.peakinessSensitivity * input.peakiness;
    }
    sep.mult(sepForce);
    
    float aliForce = alignmentForce;
    ali.mult(aliForce);
    
    float cohForce = cohesionForce;
    if (input.dVdtSensitivity < 0) {
      cohForce += -input.dVdtSensitivity * input.logdVdt;
    }
    if (input.peakinessSensitivity < 0) {
      cohForce += -input.peakinessSensitivity * input.peakiness;
    }    
    coh.mult(cohForce);
    
    hom.mult(input.homeForce);
    
    // Add the force vectors to acceleration
    applyForce(sep);
    applyForce(ali);
    applyForce(coh);
    applyForce(hom);    
        
    // Update velocity
    velocity.add(acceleration);
    // Limit speed
    float mxSpeed = input.maxParticleSpeed;
    mxSpeed += input.dVdtSensitivity * input.logdVdt;
    mxSpeed += input.peakinessSensitivity * input.peakiness;
    velocity.limit(mxSpeed);
    
    PVector tmpVelocity = new PVector(velocity.x, velocity.y, velocity.z);
    if (input.dVdtToParticleXVelocity) {
      tmpVelocity.x *= input.dVdtSensitivity * input.dLevdtSmoothed * 2.0; 
    }
    if (input.peakinessToParticleYVelocity) {
      tmpVelocity.y *= input.peakinessSensitivity * input.peakiness * 0.25;
    } 
    pos.add(tmpVelocity);
    
    acceleration.x = 0;
    acceleration.y = 0;
    acceleration.z = 0;
  }

  private void applyForce(PVector force) {
    // We could add mass here if we want A = F / M
    acceleration.add(force);
  } 
} 
