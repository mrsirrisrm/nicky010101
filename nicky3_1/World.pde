class World extends FWorld {
  
  boolean threadActive = false;
  int av = 16;
  static final float tintScaleDecay = 0.95;
  float[] tintScaleY, newTintScaleY;
  
  World(PApplet applet) {
    this.setEdges(applet, color(0,0,0,0));
    this.remove(this.top);
    this.setGravity(0, 500);
    tintScaleY = new float[width / av];
    newTintScaleY = new float[width / av];
  }
  
  void updateTintScaleY() {    
    for (int i = 0; i < tintScaleY.length; i++) {
      newTintScaleY[i] = height;
    }
        
    for (Object b: this.getBodies()) {
      if (b instanceof Text) {
        Text fb = (Text)b;
        int x = round(fb.getX() / av);
        if (!fb.isNew() && 
          x >= 0 && 
          x < newTintScaleY.length && 
          fb.getY() >= 0 && 
          fb.getY() < newTintScaleY[x] &&
          tintScaleY[x] - fb.getY() < 20) {
          newTintScaleY[x] = fb.getY();          
        }
      }
    }  
    
    
    for (int i = 0; i < tintScaleY.length; i++) {
      tintScaleY[i] = tintScaleY[i]*tintScaleDecay + (1 - tintScaleDecay)*newTintScaleY[i];
      
      if (frameCount % 40 == 0) {
        //print("," + tintScaleY[i]);
      }
      //println();
    }
  }
  
  int getTintScaleY(float x) {
    if (round(x) >= 0 && round(x / av) < tintScaleY.length) {
      return (int)tintScaleY[round(x / av)];
    } 
    return 0;
  }
  
}