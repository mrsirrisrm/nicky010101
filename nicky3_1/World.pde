class World extends FWorld {
  
  int maxBodyCount;
  static final int addBodyProbability = 30000, //3000, 
    removeBodiesAfterFrame = 400,
    removeBodyProbability = 3;
    
  static final float gravityX = 20;//, gravityY = 550, gravityY0 = 50,
    //attractorStrength = 2500,
    //gravityModSpeed = 55.;
  final float[] attractorYs = {0.7,0.85,1.0};
  
  boolean threadActive = false;
  List<Attractor> attractors = new ArrayList<Attractor>();
  Wind wind;
  boolean visible;

  World(int w, int h,  float attractorX, int bodyCount, boolean visible) {
    super();
    
    this.visible = visible;
    this.wind = new Wind(h);
    this.maxBodyCount = bodyCount;
    this.setEdges(0,0,w,h, color(0,0,0,0));
    this.remove(this.top);
    this.setGravity(0, 0);

    for (float attractorY: attractorYs) {
      attractors.add(new Attractor(attractorX, h * attractorY, 0));
    }
  }
  
  void wind(int index) {
    wind.wind(this, index);
  }
  
  void step(int index) {
    
    this.setGravity(gravityX * sin(0.03 * frameCount), 
      scheme.gY0 + scheme.gY * (((frameCount % scheme.gModSpeed)) / scheme.gModSpeed));
    
    
    if (this.getBodyCount() < maxBodyCount && random(10000) < addBodyProbability) {
      createNewBox(this, index);
    }    
    
    this.wind(index);
    
    try {
      this.step(slow ? 1./60./2.7 : 1./60.);
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