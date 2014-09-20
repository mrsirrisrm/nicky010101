class MyPoint extends Point {
  //float xp;
  //float yp;
  float noiseScale = 0.01;
  float stepSize = 4.0;
  
  float angle = random(2*PI);
  float maxDist = random(10);
  
  MyPoint (int ax, int ay) {
    x = ax;
    y = ay;
    
    randomSeed(System.nanoTime());
    //xp = random(1000);
    //yp = random(1000,2000);
  } 
  
  public MyPoint randomStep () {
    //xp += noiseScale;
    //yp += noiseScale;
    
    MyPoint mp = new MyPoint(x,y);
    //mp.stepBy( angle + 0.5 * PI * (noise(xp) - 0.5) , maxDist * noise(yp) );
    //mp.stepBy( angle + random(-0.2,0.2) , maxDist * noise(yp) );
    mp.stepBy( angle + random(-0.2,0.2) , random(2,maxDist) ); //must have a minimum, otherwise we will still be on the same spot as before
    
    //MyPoint mp = new MyPoint(round(x + stepSize * (noise(xp) - 0.5)),
    //                         round(y + stepSize * (noise(yp) - 0.5)) );
    //mp.xp = xp;
    //mp.yp = yp;
     
    return mp;
  }
  
  private void stepBy (float ang, float d) {
    angle = ang;
    x += d * cos(ang);
    y += d * sin(ang);  
  }
  
  public String toString() {
    return str(x) + "  " + str(y);    
  }
  
  public float distSquaredTo(int ax, int ay) {
    return (ax - x)*(ax - x) + (ay - y)*(ay - y); 
  }
}
