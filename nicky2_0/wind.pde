static final int kWest = 0;
static final int kEast = 1;

class Tmp {
  int ind = -1;
  float x = Float.NaN;
}

static final float WindSpacingScale = 0.02;
static final float WindTimeScale = 0.02;

void wind() {  
  int dir = ((frameCount / 400) % 2 == 0) ? kWest : kEast;
  
  Tmp[] tmps = new Tmp[height]; //per height pixel
  for (int j = 0; j < height; j++) {
    tmps[j] = new Tmp();
  }
  
  float size = 5;
  
  if (dir == kWest || dir == kEast) {
    //find left or rightmost particle for each row
    for (int n = 0; n < flock.ys.length; n++) {
      int mnj = max(0, round(flock.ys[n] - size));
      int mxj = min(height, round(flock.ys[n] + size));
      for (int j = mnj; j < mxj; j++) {
        if ((dir == kWest && (tmps[j].ind == -1 || flock.xs[n] < tmps[j].x)) || (dir == kEast && (tmps[j].ind == -1 || flock.xs[n] > tmps[j].x))) {
          tmps[j].ind = n;
          tmps[j].x = flock.xs[n];
        }
      }
    }
  } 
  
  float windStrengthX = dir == kWest ? 1 : -1;
  float windStrengthY = 0;
  for (int i = 0; i < tmps.length; i++) {
    if (tmps[i].ind == -1) {continue;}
    
    //apply force to particles
    flock.dxs[tmps[i].ind] += windStrengthX * noise(i*WindSpacingScale,frameCount*WindTimeScale); 
    flock.dys[tmps[i].ind] += windStrengthY * noise(i*WindSpacingScale,frameCount*WindTimeScale); 
  }
  
  //debug: tint
  flock.tints = new color[flock.tints.length];
  for (Tmp t: tmps) {
    if (t.ind == -1) {continue;}
    flock.tints[t.ind] = color(255,0,0);
  }
}