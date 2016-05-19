class MyParticle extends VParticle {
  boolean isOne = false;
  
  MyParticle(Vec pos, float weight, float rad, boolean isOne) {
    super(pos, weight, rad);
    this.isOne = isOne;
  }
}