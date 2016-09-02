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
  
  void myWind(int index) {
    wind.wind(this, iteration, index);
  }
  
  void myStep(int index) {    
    
    this.setGravity(gravityX * sin(0.03 * iteration), 
      scheme.gY0 + scheme.gY * (((iteration % scheme.gModSpeed)) / scheme.gModSpeed));
        
    if (this.getBodyCount() == 0 || (this.getBodyCount() < maxBodyCount && random(10000) < addBodyProbability)) {
      this.createNewBox(iteration, index);
    }    
    
    if (iteration > 20) {
      this.myWind(index);
    }
    
    try {
      this.step(slow ? 1./60./2.7 : 1./60.);
    } catch(AssertionError e) {
      println(e);
    } catch(Exception e) {
      println(e);
    }
    
    for (FBody body: (List<FBody>)this.getBodies()) {
      if (!(body instanceof Text)) continue;
      
      if (!isWarmup && iteration > removeBodiesAfterFrame && random(10000) < removeBodyProbability) {
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
  
  private void createNewBox(long iteration, int index) {
    try {
      Text t = new Text(random(1000) < 500, iteration);
      t.setPosition(w0[index]/2 + -200 + 400*noise(iteration * 0.03, index), 
        -h0[index]);
      t.setRotation(random(-1, 1));
      t.setFill(255);
      t.setNoStroke();
      t.setRestitution(0.56);
      //density default = 1.0
      //t.setDensity(5.0);
      //t.setFriction(0.5);
      this.add(t);
    } catch(Exception e) {
      println(e);
    }
  }

    
}