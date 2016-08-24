class Scheme {
  float windStrength, gY0, gY, gModSpeed, attractorStrength;
  int lengthSecs;
  String name;
  
  long changeAtMillis = -1;
  
  Scheme(float windStrength, float gY0, float gY, float gModSpeed, float attractorStrength, int lengthSecs, String name) {
    this.windStrength = windStrength;
    this.gY0 = gY0;
    this.gY = gY;
    this.gModSpeed = gModSpeed;
    this.attractorStrength = attractorStrength;
    this.lengthSecs = lengthSecs;
    this.name = name;
  }
  
  void activate() {
    this.changeAtMillis = millis() + 1000 * lengthSecs;
    println(this.name);
  }
  
  boolean shouldChange() {
    return millis() >= this.changeAtMillis;
  }
  
}