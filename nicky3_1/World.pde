class World extends FWorld {
  
  int maxBodyCount;
  static final int addBodyProbability = 30000, //3000, 
    removeBodiesAfterFrame = 400,
    removeBodyProbability = 3;
    
  static final float gravityX = 20, gravityY = 500, gravityY0 = 40,
    attractorStrength = 2500;
  final float[] attractorYs = {0.7,0.85,1.0};
  
  boolean threadActive = false;
  List<Attractor> attractors = new ArrayList<Attractor>();
  Wind wind = new Wind();

  World(int w, int h,  float attractorX, int bodyCount) {
    super();
    
    this.maxBodyCount = bodyCount;
    this.setEdges(0,0,w,h, color(0,0,0,0));
    this.remove(this.top);
    this.setGravity(0, gravityY);

    for (float attractorY: attractorYs) {
      attractors.add(new Attractor(attractorX, h0 * attractorY, attractorStrength));
    }
  }
  
  void wind(int index) {
    wind.wind(this, index);
  }
  
  void step(int index) {
    
    this.setGravity(gravityX * sin(0.03 * frameCount), 
      gravityY0 + gravityY * (((frameCount % 70)) / 70.f));
    
    
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