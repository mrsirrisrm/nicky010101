class World extends FWorld {
  
  boolean threadActive = false;
  List<Attractor> attractors = new ArrayList<Attractor>();
  Wind wind = new Wind();
  
  static final float gravityY = 500,
    attractorStrength = 3500;
  
  World(PApplet applet,  float attractorX) {
    super();
    
    this.setEdges(applet, color(0,0,0,0));
    this.remove(this.top);
    this.setGravity(0, gravityY);

    attractors.add(new Attractor(attractorX, height * 0.7, attractorStrength));
    attractors.add(new Attractor(attractorX, height * 0.85, attractorStrength));
    //attractors.add(new Attractor(attractorX, height * 1.0, attractorStrength));
  }
  
  void wind(int index) {
    wind.wind(this, index);
  }
    
}