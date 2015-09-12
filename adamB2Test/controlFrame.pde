import controlP5.*;
import java.awt.Frame;
import java.awt.BorderLayout;

ControlFrame addControlFrame(String theName, int theWidth, int theHeight) {
  Frame f = new Frame(theName);
  ControlFrame p = new ControlFrame(this, theWidth, theHeight);
  f.add(p);
  p.init();
  f.setTitle(theName);
  f.setSize(p.w, p.h);
  f.setLocation(100, 100);
  f.setResizable(false);
  f.setVisible(true);
  p.parent = this;
  return p;
}

// the ControlFrame class extends PApplet, so we 
// are creating a new processing applet inside a
// new frame with a controlP5 object loaded
public class ControlFrame extends PApplet {
  private int w, h;
  private int updateAudioFeedbackOnNthFrame = 5;
  public  float mainFrameRate = 0.0;
  public  int mainFrameCount = 0;
  
  private ControlP5 cp5;
  private Object parent;  
 
  int activeSliderY = 0;
  
  int[] miniFlocksCounts = new int[0];
  int[] statesCounts = new int[5]; 
   
  //Slider slMaxParticleSpeed; 
  //Slider slParticleScale;
  //Slider slCameraDist;
    
  public void setup() {
    background(40);
    
    size(w, h);
    frameRate(5);
    cp5 = new ControlP5(this);
  }

  public ControlFrame(Object theParent, int theWidth, int theHeight) {
    parent = theParent;
    w = theWidth;
    h = theHeight;
  }

  public ControlP5 control() {
    return cp5;
  }
  
  void controlEvent(ControlEvent theEvent) {        
    //if (theEvent.isFrom( slCameraDist ) ) {
    //  inputData.cameraDist = slCameraDist.getValue();
    //}
  }
      
    
  public void draw() {
    if (this.frameCount % updateAudioFeedbackOnNthFrame == 0) {
      //draw the audio feedback cues
      
      background(40);  
    
      text("Framerate: " + str(round(mainFrameRate)) + ",   main framecount: " + str(mainFrameCount) + ", time: " + str(mainFrameCount / targetVideoFrameRate), 20, height - 90);
      
      if (makeNthFrameToPNG == 0) { 
        text("Not creating video frames", 20, height - 30);
      } else {
        text("Output png every " + str(makeNthFrameToPNG) + " frames", 20, height - 30);
      }
      
      if (inputPositionsMode == 1) {
        text("Writing input positions to file", 20, height - 50);
      } else if (inputPositionsMode == 2) {
        text("Reading input positions from file", 20, height - 50);
      } else {
        text("Normal input positions", 20, height - 50);
      }
      
      text("states counts " + str(statesCounts[0]) + " " + str(statesCounts[1]) + " " + str(statesCounts[2]) + " " + str(statesCounts[3]) + " " + str(statesCounts[4]), 20, height - 110);
      
      if (activeSliderY > 0) {
        fill(255);
        noStroke();
        ellipse(5,activeSliderY + 5,10,10);
      }
      
      //stroke(255.0);
      //strokeWeight(3.0);
      for (int i = 0; i < miniFlocksCounts.length; i++) {
        point(150 + 3*i, height - 50 - miniFlocksCounts[i]);
      }
  
      if (makeNthFrameToPNG != 0 && frameCount - 2 >= firstVideoFrame && frameCount - 2 <= lastVideoFrame) { 
        text("video State : ** making frames **", 20, height - 130);
      } else {    
        text("video State : not making frames", 20, height - 130);
      }
    } 
  }  
}
