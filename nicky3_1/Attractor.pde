class Attractor {
  float x = 0,y = 0;//,mag = 1;
  static final float maxDistSquared = 160000; 

  Attractor(float _x, float _y, float _mag) {
    this.x = _x;
    this.y = _y;
    //this.mag = _mag;
  }
  
  void applyToBody(FBody body) {
    float dx = this.x - body.getX(), dy =this.y - body.getY();
    float magSquared = dx*dx + dy*dy;
    if (magSquared > maxDistSquared) {return;}
    
    float normdx = dx / magSquared, normdy = dy / magSquared;
    body.addForce(normdx * scheme.attractorStrength, normdy * scheme.attractorStrength);
  }

}