class Attractor {
  float x = 0,y = 0,mag = 1;

  Attractor(float _x, float _y, float _mag) {
    this.x = _x;
    this.y = _y;
    this.mag = _mag;
  }
  
  void applyToBody(FBody body) {
    float dx = this.x - body.getX(), dy =this.y - body.getY(), dist = sqrt(dx*dx + dy*dy);    
    PVector p = new PVector(dx,dy);
    p.normalize();    
    body.addForce(p.x * this.mag / dist, p.y * this.mag / dist);
  }

}