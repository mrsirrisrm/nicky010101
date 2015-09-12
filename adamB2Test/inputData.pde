class InputData {  
  //from control inputs
  public float maxParticleSpeed = 30.0;
  public float cameraDist = 1000;
  public float cameraX = 0;
  public float cameraY = -0;
  public float magnification = 1.0;
    
  //derived
  public float smoothedCameraDist = cameraDist;
  public float smoothedSmoothedCameraDist = cameraDist;
  
  //static
  private static final float cameraSmoothing = 0.1;
  private static final int closeupInd = 0;
  
  InputData() {
    switch (InputData.closeupInd) {
      case 1 : // from opening frame until 1 sec and 14 frames, an extreme closeup of where I've indicated on pic 1.  I've tried to make scale apparent in this in Photoshop but it's so pixelated... 
      cameraDist = 150;
      cameraX = -50;
      cameraY = 350;
      inputPositionsStartFromFrame = 0;
      firstVideoFrame = -1 - inputPositionsStartFromFrame;
      lastVideoFrame = 32 - inputPositionsStartFromFrame;
        break;  
      case 2 : // I'll also need a much much closer up of the particles in that sequence as well, so you can literally see about 10 particles in the whole frame as they are disordering.  If you are able to slow that down by a factor of 4 from what it is now, that would be excellent. 
      cameraDist = 105;
      this.magnification = 3.3;
      cameraX = -50 * this.magnification;
      cameraY = 375 * this.magnification;
      inputPositionsStartFromFrame = 0;
      firstVideoFrame = -1 - inputPositionsStartFromFrame;
      lastVideoFrame = 32 - inputPositionsStartFromFrame;
        break;
      case 3 : // From 1 sec 15 frames until 4 seconds 17 frames, it would be great to have as in pic 2, though can I hopefully assume that the 'camera' could begin by focusing on the first chunk as it breaks away from the main body and follow it as it moves outwards, trailing particles? 
      cameraDist = 150;
      cameraX = -50;
      cameraY = 350;
      inputPositionsStartFromFrame = 25;
      firstVideoFrame = 30 - inputPositionsStartFromFrame;
      lastVideoFrame = 117 - inputPositionsStartFromFrame;
        break;
      case 4 : //From 2 secs 11 frames to 5 secs 21 frames, please see pic 3, as per scale there and also please keep the camera in one spot 
      cameraDist = 150;
      cameraX = 280;
      cameraY = 150;
      inputPositionsStartFromFrame = 55;
      firstVideoFrame = 61 - inputPositionsStartFromFrame;
      lastVideoFrame = 146 - inputPositionsStartFromFrame;
        break;
      case 5 : //From 9 sec 22 frames to 15 secs 7 frames, please see pic 4., same scale as this, camera remains fixed. 
      cameraDist = 220;
      cameraX = -70;
      cameraY = 220;
      inputPositionsStartFromFrame = 240;
      firstVideoFrame = 247 - inputPositionsStartFromFrame;
      lastVideoFrame = 382 - inputPositionsStartFromFrame;
        break;      
      case 6 : //From 25 sec 11 frames to 35 secs 11 frames, please see pic 5 - same scale, fixed camera. 
      cameraDist = 300;
      cameraX = 0;
      cameraY = 0;
      inputPositionsStartFromFrame = 630;
      firstVideoFrame = 636 - inputPositionsStartFromFrame;
      lastVideoFrame = 886 - inputPositionsStartFromFrame; 
        break;        
      default : break; //<>//
    }
    //20150211: extend the videos to 3x the length
    lastVideoFrame += 2 * (lastVideoFrame - firstVideoFrame);
    
    smoothedCameraDist = cameraDist;
    smoothedSmoothedCameraDist = cameraDist;
  } 
 
 
  public void setAll(float aCameraDist) {
    this.cameraDist = aCameraDist;
    
    //derived
    deriveValues(); 
  }
  
  public void deriveValues() {    
    float camDiff = this.cameraDist - this.smoothedCameraDist; 
    if (abs(camDiff) > 1) { 
      this.smoothedCameraDist += camDiff * cameraSmoothing;      
    }
    
    camDiff = this.smoothedCameraDist - this.smoothedSmoothedCameraDist; 
    if (abs(camDiff) > 1) { 
      this.smoothedSmoothedCameraDist += camDiff * cameraSmoothing;      
    }
    
    //for closeup 3, camera tracks chunk 1 (index 0) motion
    //if (InputData.closeupInd == 3 && frameCount > 40 - inputPositionsStartFromFrame) {
    //  this.cameraX += flock.chunks.get(0).velocity.x;
    //  this.cameraY += flock.chunks.get(0).velocity.y;  
    //}
  }  
}
