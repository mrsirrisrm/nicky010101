class InputData {
  //from audio inputs
  float prevLowLev = 0.1; 
  float prevHighLev = 0.1; 
  float mix = 0.0;   
  float peakiness = 5.0;
  float logLev = 0.1; 
  float logdVdt = 0.1; 
  float dLevdtSmoothed = 0.1;
  
  //from control inputs
  float maxParticleSpeed = 30.0;
  float homeForce = 2.0;
  float audioThreshold = 0.02;
  float cameraDist = 800;
  float dVdtSensitivity = 0.0;
  float peakinessSensitivity = 0.0;
  
  boolean dVdtToParticleXVelocity = false;
  boolean peakinessToParticleYVelocity = false;
  
  //internal
  private int currentInputLine = 0;
  private String[] inputLines;
  
  //derived
  float peakiness2 = peakiness*peakiness;
  float logLev2 = logLev * logLev;
  float smoothedCameraDist = 2000.0;
  
  //static
  private static final float cameraSmoothing = 0.1;
 
  public void setAll(float aprevLowLev, 
                     float aprevHighLev, 
                     float amix, 
                     float apeakiness,
                     float alogLev, 
                     float alogdVdt, 
                     float adLevdtSmoothed) {
    this.prevLowLev = aprevLowLev; 
    this.prevHighLev = aprevHighLev; 
    this.mix = amix; 
    this.peakiness = apeakiness;
    this.logLev = alogLev; 
    this.logdVdt = alogdVdt; 
    this.dLevdtSmoothed = adLevdtSmoothed;

    //derived
    deriveValues(); 
  }
  
  public void deriveValues() {
    this.peakiness2 = this.peakiness * this.peakiness;
    this.logLev2 = this.logLev * this.logLev;
    float camDiff = this.cameraDist - this.smoothedCameraDist; 
    if (abs(camDiff) > 1) { 
      this.smoothedCameraDist += camDiff * cameraSmoothing;      
    }
  }
  
  public String output() {
    return str(millis()) + "," +
           str(this.prevLowLev) + "," + 
           str(this.prevHighLev) + "," + 
           str(this.mix) + "," + 
           str(this.peakiness) + "," +
           str(this.logLev) + "," + 
           str(this.logdVdt) + "," + 
           str(this.dLevdtSmoothed) + "," +
           
           str(this.maxParticleSpeed) + "," +
           str(this.homeForce) + "," +
           str(this.audioThreshold) + "," +
           str(this.cameraDist) + "," +
           str(this.dVdtSensitivity) + "," +
           str(this.peakinessSensitivity) + "," + 
           
           str(this.dVdtToParticleXVelocity) + "," + 
           str(this.peakinessToParticleYVelocity) + ";";
  }
  
  public void readInputLine() {
    if (currentInputLine < inputLines.length - 1) {
      String[] list = split(inputLines[currentInputLine],",");
      
      int lineMillis;
      try {lineMillis = Integer.parseInt(list[0]);} catch(NumberFormatException e) {lineMillis = 0;}
      if (1000.0 * float(frameCount) / targetVideoFrameRate > lineMillis) {
        currentInputLine++;
        
        //audio
        try {this.prevLowLev = Float.parseFloat(list[1]); } catch(NumberFormatException e) {}
        try {this.prevHighLev = Float.parseFloat(list[2]); } catch(NumberFormatException e) {}
        try {this.mix = Float.parseFloat(list[3]); } catch(NumberFormatException e) {}
        try {this.peakiness = Float.parseFloat(list[4]);} catch(NumberFormatException e) {}
        try {this.logLev = Float.parseFloat(list[5]); } catch(NumberFormatException e) {}
        try {this.logdVdt = Float.parseFloat(list[6]); } catch(NumberFormatException e) {}
        try {this.dLevdtSmoothed = Float.parseFloat(list[7]);} catch(NumberFormatException e) {}
        
        //controls
        try {this.maxParticleSpeed = Float.parseFloat(list[8]); } catch(NumberFormatException e) {}
        try {this.homeForce = Float.parseFloat(list[9]);} catch(NumberFormatException e) {}
        try {this.audioThreshold = Float.parseFloat(list[10]);} catch(NumberFormatException e) {}
        try {this.cameraDist = Float.parseFloat(list[11]);} catch(NumberFormatException e) {}
        try {this.dVdtSensitivity = Float.parseFloat(list[12]);} catch(NumberFormatException e) {}
        try {this.peakinessSensitivity = Float.parseFloat(list[13]); } catch(NumberFormatException e) {}
        
        this.dVdtToParticleXVelocity = list[14].equals("true"); 
        this.peakinessToParticleYVelocity = list[15].equals("true");
      }
     
    } else {
      inputDataMode = 0; //at end of file, pass control back to the controller
    }
  }
  
  public void loadInput(String filename) {
    inputLines = loadStrings(filename);
    readInputLine();    
  }

}
