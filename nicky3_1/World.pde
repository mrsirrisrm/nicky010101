class World extends FWorld {
  
  int maxBodyCount;
  static final int addBodyProbability = 3000, 
    removeBodiesAfterFrame = 400,
    removeBodyProbability = 3;
    
  static final float gravityX = 50, gravityY = 500,
    attractorStrength = 2500;
  final float[] attractorYs = {0.7,0.85,1.0};
  
  boolean threadActive = false;
  List<Attractor> attractors = new ArrayList<Attractor>();
  Wind wind = new Wind();

  World(PApplet applet,  float attractorX, int bodyCount) {
    super();
    
    this.maxBodyCount = bodyCount;
    this.setEdges(applet, color(0,0,0,0));
    this.remove(this.top);
    this.setGravity(0, gravityY);

    for (float attractorY: attractorYs) {
      attractors.add(new Attractor(attractorX, height * attractorY, attractorStrength));
    }
  }
  
  void wind(int index) {
    if (frameCount > 2) { //don't call noise funcs before Applet is created
      wind.wind(this, index);
    }
  }
  
  void step(int index) {
    
    this.setGravity(gravityX * sin(0.03 * frameCount), 
      gravityY * (((frameCount % 50) - 3.f) / 50.f));
    
    
    if (this.getBodyCount() < maxBodyCount && random(10000) < addBodyProbability) {
      createNewBox(this, index);
    }    
    
    this.wind(index);
    
    try {
      this.step();
    } catch(Exception e) {
    }
    
    for (FBody body: (List<FBody>)this.getBodies()) {
      if (!(body instanceof Text)) continue;
      
      if (frameCount > removeBodiesAfterFrame && random(10000) < removeBodyProbability) {
        this.removeBody(body);
        continue;
      }
  
      for (Attractor att: this.attractors) {
        att.applyToBody(body);
      }    
    }
    
    this.threadActive = false;
    
    if (threaded && allThreadsFinished()) {     
      //redraw();
    }
  }
    
}