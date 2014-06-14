class Flock { 

  private ArrayList<Particle> particles; //somehow this is being called from outside class?
 
  private PVector[] vectorsToAdd = new PVector[10];
  
  Flock (int numParticles) {
     //create particles
    particles = new ArrayList<Particle>(numParticles);
    for (int i = 0; i < numParticles; i++) {
      particles.add( new Particle(new PVector(0.0 , 0.0 , 0.0)) );
    }
    
    for (PVector vector : vectorsToAdd) {
      vector = new PVector(0, 0, 0);
    } 
  }
  
  public void allTextDraw () {
    for (Particle part : particles) {
      part.textDraw();
    }
  }
  
  public void allRunFlocking () {
    for (Particle part : particles) {
      part.runFlocking(particles);
    }
  }

  public void allIterate () {
    for (Particle part : particles) {
      part.iterate();
    }
  }  
  
  public void addVectorToAll (PVector vector) {
    for (Particle part : particles) {
      part.target.add(vector); 
    } 
  }
  
}
