static final int kWest = 0;
static final int kEast = 1;
float windStrength = 1;

class Tmp {
  int ind = -1;
  float x = Float.NaN;
  
  void clear() {
    ind = -1;
    x = Float.NaN;
  }
}

class Wind {

  static final float WindSpacingScale = 0.02,
    WindTimeScale = 0.05,
    searchSize = 5;
    
  Tmp[] tmps = new Tmp[h0]; //per height pixel

  Wind() {
    for (int j = 0; j < h0; j++) {
      tmps[j] = new Tmp();
    }
  }
  
  void wind(FWorld world, int index) {  
    int dir = ((frameCount / 400) % 2 == 0) ? kWest : kEast; //alternating directions
    
    for (int j = 0; j < h0; j++) {
      tmps[j].clear();
    }

    List<FBody> bodies = world.getBodies();
    if (dir == kWest || dir == kEast) {
      //find left or rightmost particle for each row
      for (int n = 0; n < bodies.size(); n++) {
        int mnj = max(0, round(bodies.get(n).getY() - searchSize));
        int mxj = min(h0, round(bodies.get(n).getY() + searchSize));
        for (int j = mnj; j < mxj; j++) {
          if ((dir == kWest && 
            (tmps[j].ind == -1 || bodies.get(n).getX() < tmps[j].x)) || 
            (dir == kEast && 
            (tmps[j].ind == -1 || bodies.get(n).getX() > tmps[j].x))) {
            tmps[j].ind = n;
            tmps[j].x = bodies.get(n).getX();
          }
        }
      }
    } 
    
    try {
      float windStrengthX = (-0.55 + noise(frameCount*0.002, 100*index + (frameCount * 0.002)))*windStrength;
      //float windStrengthX = random(-1.0,1.0)*windStrength; 
      for (int i = 0; i < tmps.length; i++) {
        if (tmps[i].ind == -1) {continue;}
        
        //apply force to particles, and change angle somewhat to make it look a little turbulent
        float q = (noise(i*WindSpacingScale,frameCount*WindTimeScale) - 0.5) * PI * 0.7;
        float wsX = cos(q) * windStrengthX;// + sin(q) * windStrengthY;
        float wsY = sin(q) * windStrengthX;// + cos(q) * windStrengthY;
        
        if (tmps[i].ind >= 0) {
          FBody body = bodies.get(tmps[i].ind); 
          float n = noise(i*WindSpacingScale,frameCount*WindTimeScale+10);
          body.addImpulse(wsX * n, wsY * n);
        }
      }
    } catch(Exception e) {
    }
  }
}