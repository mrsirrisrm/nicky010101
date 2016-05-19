static final int kWest = 0;
static final int kEast = 1;

class Tmp {
  int ind = -1;
  float x = Float.NaN;
}

static final float WindSpacingScale = 0.02;
static final float WindTimeScale = 0.05;

void wind(FWorld world) {  
  int dir = ((frameCount / 400) % 2 == 0) ? kWest : kEast;
  
  Tmp[] tmps = new Tmp[height]; //per height pixel
  for (int j = 0; j < height; j++) {
    tmps[j] = new Tmp();
  }
  
  float size = 5;
  
  List<FBody> bodies = world.getBodies();
  if (dir == kWest || dir == kEast) {
    //find left or rightmost particle for each row
    for (int n = 0; n < bodies.size(); n++) {
      int mnj = max(0, round(bodies.get(n).getY() - size));
      int mxj = min(height, round(bodies.get(n).getY() + size));
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
  
  float windStrengthX = (-0.55 + noise(frameCount*0.002, 100*worlds.indexOf(world) + (frameCount * 0.002)))*0.4;
  //float windStrengthX = dir == kWest ? windStrength : -windStrength;
  float windStrengthY = 0;
  for (int i = 0; i < tmps.length; i++) {
    if (tmps[i].ind == -1) {continue;}
    
    //apply force to particles, and change angle somewhat to make it look a little turbulent
    float q = (noise(i*WindSpacingScale,frameCount*WindTimeScale) - 0.5) * PI * 0.7;
    float wsX = cos(q) * windStrengthX + sin(q) * windStrengthY;
    float wsY = sin(q) * windStrengthX + cos(q) * windStrengthY;
    
    FBody body = bodies.get(tmps[i].ind); 
    body.addImpulse(wsX * noise(i*WindSpacingScale,frameCount*WindTimeScale+10),
      wsY * noise(i*WindSpacingScale,frameCount*WindTimeScale+10)); 
  }  
}