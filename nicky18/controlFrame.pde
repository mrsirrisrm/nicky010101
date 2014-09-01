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
  
  int activeSliderY = 0;
  
  private final static float rotateFactor = 0.02;
  private final static int movesPerRotate = 8;  
  private final static float zoomFactor = 0.02;
  private final static int movesPerZoom = 8;
  private ArrayList<Float> rotationMoves = new ArrayList<Float>();
  private ArrayList<Float> zoomMoves = new ArrayList<Float>();  
 
  //Slider slYRotation;
  Slider slNumberInCDF2;
  Slider slAudioSplitFreq;
  Slider slAudioThreshold;
  Slider slSpeedAudioComparison; 
  
  Slider slSeparationForce;
  Slider slAlignmentForce;
  Slider slCohesionForce;
  Slider slHomeForce;
  Slider slNumActiveParticles;
  Slider slZScale;
  Slider sldVdtSensitivity;
  
  CheckBox cbRotating;
  CheckBox cbIterating;
  CheckBox cbFlocking;
  CheckBox cbdVdtToCohesion;
  
  Button btXPLus100;
  Button btXMinus100;
  Button btYPlus100;
  Button btYMinus100;
  Button btZoomIn;
  Button btZoomOut;
  Button btRotateRight;
  Button btRotateLeft;
  
  Button btWebcamCDF1;
  Button btWebcamCDF2;
  Button btHeap1;
  Button btCross1;
  Button btHeap2;
  Button btCross2;  
  //Button btSendToCDF1;
  //Button btSendToCDF2;
  
  public float getZoom () {
    if (zoomMoves.size() == 0) {
      return 1.0;
    } else {
      float z = zoomMoves.get(0);
      zoomMoves.remove(0);
      return z;
    }
  }
  
  public float getYRotation () {
    if (rotationMoves.size() == 0) {
      return 0.0;
    } else {
      float r = rotationMoves.get(0);
      rotationMoves.remove(0);
      return r;
    }
  }
  
  private void webcamShot (CDF cdf) {
    if (webcam != null) { 
      println("Webcam shot");
      cdf.img = webcam.imageFromWebcam(width,height);
      //draw it to this frame
      image( cdf.img, 
             300, 
             10, 
             200, 
             200); 
      //move items based on cam image
      cdf.setupPDF2DFromImage();
      flock.moveAllItemsFromImageCDF( cdf );
    }
  }
  
  public void setup() {
    background(40);
    
    color cbCol = color(2,119,168);
    size(w, h);
    frameRate(25);
    cp5 = new ControlP5(this);
    
    //===================general sliders=====================================
    cp5.addSlider("X Rotation")
                  .plugTo(parent,"controlXRotation")
                  .setRange(0, 2*PI)
                  .setPosition(10,30);
    cp5.addSlider("Y Rotation")
                  .plugTo(parent,"controlYRotation")
                  .setRange(0, 2*PI)
                  .setPosition(10,50);
    cp5.addSlider("YRotationSpeed")
                  .plugTo(parent,"YRotationSpeed")
                  .setRange(-0.2, 0.2)
                  .setPosition(10,70)
                  .setValue(0.025);
    
    //==========controlled sliders=======================================================
    slZScale = cp5.addSlider("Z Scale")
                  .plugTo(parent,"zScale")
                  .setRange(0, 1)
                  .setPosition(10,210)
                  .setSize(300,10)
                  .setValue(0.5)
                  .setColorBackground(color(100,0,0))
                  .setColorActive(color(200,0,0))
                  .setColorForeground(color(200,0,0)); 
    slNumberInCDF2 = cp5.addSlider("CDF2 particles")
                  .setRange(0, 1.0)
                  .setPosition(10,150)
                  .setSize(300,10)
                  .setValue(0.0)
                  .setColorBackground(color(100,0,0))
                  .setColorActive(color(200,0,0))
                  .setColorForeground(color(200,0,0)); 
    slAudioSplitFreq = cp5.addSlider("Split frequency")
                  .setRange(0, 6.38) //NB reversed sense. the range is 60 hz to 5000 hz, so log2(5000 / 60) = 6.38
                  .setPosition(10,170)
                  .setSize(300,10)
                  .setValue(2.65) //approx 800 Hz
                  .setColorBackground(color(100,0,0))
                  .setColorActive(color(200,0,0))
                  .setColorForeground(color(200,0,0));             
    sldVdtSensitivity = cp5.addSlider("dVdt sensitivity")
                  .setRange(0., 10.)
                  .plugTo(parent,"dVdtSensitivity" )
                  .setPosition(10,130)
                  .setSize(300,10)
                  .setValue(dVdtSensitivity)
                  .setColorBackground(color(100,0,0))
                  .setColorActive(color(200,0,0))
                  .setColorForeground(color(200,0,0));     
    slAudioThreshold = cp5.addSlider("Audio threshold")
                  .setRange(0.001, 0.06)
                  .plugTo(parent,"audioThreshold" )
                  .setPosition(10,370)
                  .setSize(300,10)
                  .setValue(0.03);
    slSpeedAudioComparison = cp5.addSlider("particleSpeed"  )
                 .setRange(0.0 , 0.3)
                 .setPosition(10,350)
                 .setSize(300,10)
                 .setValue(0.1);  
    slNumActiveParticles = cp5.addSlider("activeParticles"  )
                 .setRange(0.0, flock.maxParticles())
                 .setPosition(10,190)
                 .setSize(300,10)
                 .setValue(flock.nActive)
                 .setColorBackground(color(100,0,0))
                 .setColorActive(color(200,0,0))
                 .setColorForeground(color(200,0,0));
               
                
    //==========force sliders====================================  
    slSeparationForce = cp5.addSlider("separationForce")
                .plugTo(parent,"separationForce")
                .setRange(0.0, forceMax)
                .setPosition(10,250)
                .setSize(300,10)
                .setValue(3.0);
    slAlignmentForce = cp5.addSlider("alignmentForce" )
                .plugTo(parent,"alignmentForce" )
                .setRange(0.0, forceMax)
                .setPosition(10,270)
                .setSize(300,10)
                .setValue(2.0);
    slCohesionForce = cp5.addSlider("cohesionForce"  )
                .plugTo(parent,"cohesionForce"  )
                .setRange(0.0, forceMax)
                .setPosition(10,290)
                .setSize(300,10)
                .setValue(2.0);
    slHomeForce = cp5.addSlider("homeForce"  )
                .plugTo(parent,"homeForce"  )
                .setRange(0.0, forceMax)
                .setPosition(10,310)
                .setSize(300,10)
                .setValue(2.0);                

                
              
          
    //------------checkboxes controll item general behaviours-------------------------
      cbRotating = cp5.addCheckBox("cbRotating")
                .setPosition(10, 90)
                .setColorForeground(color(120))
                .setColorActive(cbCol)
                .setColorLabel(color(255))
                .setSize(20, 15)
                .addItem("rotating", 0);        
      cbIterating = cp5.addCheckBox("cbIterating")
                .setPosition(430, 90)
                .setColorForeground(color(120))
                .setColorActive(cbCol)
                .setColorLabel(color(255))
                .setSize(20, 15)
                .addItem("iterating", 0);
      cbFlocking = cp5.addCheckBox("cbFlocking")
                .setPosition(290, 90)
                .setColorForeground(color(120))
                .setColorActive(cbCol)
                .setColorLabel(color(255))
                .setSize(20, 15)
                .addItem("flocking", 0);
      cbdVdtToCohesion = cp5.addCheckBox("cbdVdtToCohesion")
                .setPosition(430, 130)
                .setColorForeground(color(120))
                .setColorActive(cbCol)
                .setColorLabel(color(255))
                .setSize(20, 15)
                .addItem("reverse dvdt", 0);        
          
     //-----------view control buttons  -------------------------------------------
    int moveButtonsDown = 110;   
     btXPLus100 = cp5.addButton("x+") //move to current screen right (may not be +x!) 
       .setValue(100)
       .setPosition(90,370 + moveButtonsDown)
       .setSize(20,20);  
     btXMinus100 = cp5.addButton("x-")//move to current screen left (may not be -x!)
       .setValue(-100)
       .setPosition(50,370 + moveButtonsDown)
       .setSize(20,20);        
     btYPlus100 = cp5.addButton("y+")
       .setValue(100)
       .setPosition(70,390 + moveButtonsDown)
       .setSize(20,20);  
     btYMinus100 = cp5.addButton("y-")
       .setValue(-100)
       .setPosition(70,350 + moveButtonsDown)
       .setSize(20,20);   
  
     btZoomIn = cp5.addButton("z+") 
       .setValue(1.0/1.08)
       .setPosition(150,350 + moveButtonsDown)
       .setSize(20,20); 
     btZoomOut = cp5.addButton("z-") 
       .setValue(1.08)
       .setPosition(150,390 + moveButtonsDown)
       .setSize(20,20); 
     btRotateRight = cp5.addButton("r+") 
       .setValue(1.08)
       .setPosition(170,370 + moveButtonsDown)
       .setSize(20,20);  
     btRotateLeft = cp5.addButton("r-") 
       .setValue(1.08)
       .setPosition(130,370 + moveButtonsDown)
       .setSize(20,20);
      
     btWebcamCDF1 = cp5.addButton("1:webcam") 
       .setValue(0)
       .setPosition(210,370 + moveButtonsDown)
       .setSize(20,20);
    btHeap1 = cp5.addButton("1:heap") 
       .setValue(0)
       .setPosition(250,370 + moveButtonsDown)
       .setSize(20,20);
   btCross1 = cp5.addButton("1:cross") 
       .setValue(0)
       .setPosition(290,370 + moveButtonsDown)
       .setSize(20,20);

     btWebcamCDF2 = cp5.addButton("2:webcam") 
       .setValue(0)
       .setPosition(210,410 + moveButtonsDown)
       .setSize(20,20);
    btHeap2 = cp5.addButton("2:heap") 
       .setValue(0)
       .setPosition(250,410 + moveButtonsDown)
       .setSize(20,20);
   btCross2 = cp5.addButton("2:cross") 
       .setValue(0)
       .setPosition(290,410 + moveButtonsDown)
       .setSize(20,20);

    updateCheckboxes(); 
  }

  public void updateSliders () {
    float portionInCDF2 = float(flock.numberInCDF(cdf2)) / float(flock.nActive);
    slNumberInCDF2.setValue(portionInCDF2);
  }

  private void updateCheckboxes () {
   if (rotating) {
      cbRotating.activate(0); 
    } else {
      cbRotating.deactivate(0);
    }
    
    if (iterating) {
      cbIterating.activate(0); 
    } else {
      cbIterating.deactivate(0);
    }
    
    if (flocking) {
      cbFlocking.activate(0); 
    } else {
      cbFlocking.deactivate(0);
    }   
  
    if (dVdtToCohesion) {
      cbdVdtToCohesion.activate(0);
    } else {
      cbdVdtToCohesion.deactivate(0);
    }  
  }


  //================================================================

  public void draw() {
    if (frameCount % updateAudioFeedbackOnNthFrame == 0) {
      //draw the audio feedback cues
      
      background(40);  
    
      color c = color(255,100,100);
    
      text("Framerate: " + str(round(mainFrameRate)), 20, height - 50);
      
      if (activeSliderY > 0) {
        fill(255);
        noStroke();
        ellipse(5,activeSliderY + 5,10,10);
      }
      
      stroke(255.0);
      strokeWeight(12.0);
      strokeCap(ROUND);
              
      //lines showing level
      if (freqBalance != null) {
        float pxForMaxAudioThreshold = 300; 
        float pxForStartAudioLevelBar = 20;
        
        if (freqBalance.prevLowLev > audioThreshold & freqBalance.prevLowLev > freqBalance.prevHighLev) {
          stroke(c);
        } else {
          stroke(255);
        }
        line(this.width - 80,
             this.height - pxForStartAudioLevelBar,
             this.width - 80,
             this.height - (pxForStartAudioLevelBar + 
                            pxForMaxAudioThreshold * freqBalance.prevLowLev / slAudioThreshold.getMax()) );      
        
        if (freqBalance.prevHighLev > audioThreshold & freqBalance.prevHighLev > freqBalance.prevLowLev) {
          stroke(c);
        } else {
          stroke(255);
        }
        line(this.width - 40,
             this.height - pxForStartAudioLevelBar,
             this.width - 40,
             this.height - (pxForStartAudioLevelBar + pxForMaxAudioThreshold * freqBalance.prevHighLev / slAudioThreshold.getMax()) );      
  
        //line showing threshold
        stroke(255);
        strokeWeight(3.0);
        strokeCap(NORMAL);     
        line(this.width - 100,
             this.height - (pxForStartAudioLevelBar + pxForMaxAudioThreshold * slAudioThreshold.getValue() / slAudioThreshold.getMax() ),
             this.width - 20,
             this.height - (pxForStartAudioLevelBar + pxForMaxAudioThreshold * slAudioThreshold.getValue() / slAudioThreshold.getMax() ) );
       
        //line showing dV/dt
        stroke(0,255,0);
        strokeWeight(12.0);
        strokeCap(ROUND);
        line(this.width - 120,
             this.height - pxForStartAudioLevelBar,
             this.width - 120,
             this.height - (pxForStartAudioLevelBar + 10.0 * (freqBalance.logdVdt) ) );
       
        //strokeWeight( 1.0 );  
        //strokeCap(NORMAL);
        //for (int i = 0; i < 299; i++) {
        //  line(i + 200, 100 - freqBalance.logdVdts[i], i + 201, 100 - freqBalance.logdVdts[(i + 1)]);  
        //}     
       
       
        //FFT
        stroke(180);
        strokeWeight( 1.0 );
        strokeCap( NORMAL );
        line(100, 200, 100 + freqBalance.previousFlatness.length, 200);
        
        stroke(255);
        strokeWeight( 2.0 );
        strokeCap( NORMAL );
        float fftScale = 10;
        for (int i = 1; i < freqBalance.previousFlatness.length; i++) {
          line(i - 1 + 100, 
               200 + fftScale * freqBalance.previousFlatness[i - 1],//log(freqBalance.previousSpect[ i - 1 ]), 
               i + 100, 
               200 + fftScale * freqBalance.previousFlatness[i] ); //log(freqBalance.previousSpect[ i ]));
        }
        
       
        //spectral flatness
        text(str(freqBalance.spectralFlatness()),100,100);
        stroke(0,180,230);
        strokeWeight(12.0);
        strokeCap(ROUND);
        line(this.width - 160,
            this.height - pxForStartAudioLevelBar,
            this.width - 160,
            this.height - (pxForStartAudioLevelBar - 80.0 * freqBalance.spectralFlatness() ) );
        
//        //spectral flux
//        text(str(freqBalance.spectralFlux()),200,100);
//        stroke(0,150,130);
//        strokeWeight(12.0);
//        strokeCap(ROUND);
//        line(this.width - 200,
//             this.height - pxForStartAudioLevelBar,
//             this.width - 200,
//             this.height - (pxForStartAudioLevelBar + 0.1 * freqBalance.spectralFlux() ) );
       
                     
      }
    } 
  }
  
  //private ControlFrame() {
  //}

  public ControlFrame(Object theParent, int theWidth, int theHeight) {
    parent = theParent;
    w = theWidth;
    h = theHeight;
  }

  public ControlP5 control() {
    return cp5;
  }
  
  void controlEvent(ControlEvent theEvent) {
    if (theEvent.isFrom(cbRotating)) {
      rotating = cbRotating.getState(0);
    }
    
    if (theEvent.isFrom(cbIterating)) {
      iterating = cbIterating.getState(0);
    }
    
//    if (theEvent.isFrom(cbChangingShapes)) {
//      changingShapes = cbChangingShapes.getState(0);
//    }
    
    if (theEvent.isFrom(cbFlocking)) {
      flocking = cbFlocking.getState(0);
    }
    
    if (theEvent.isFrom(cbdVdtToCohesion)) {
      dVdtToCohesion = cbdVdtToCohesion.getState(0);
    }
    
//    //-----------------volume to flocking params---------------------------
//    if (theEvent.isFrom(cbVolToSeparation)) {
//      volToSeparation = cbVolToSeparation.getState(0);
//    }
//    
//    if (theEvent.isFrom(cbVolToAlignment)) {
//      volToAlignment = cbVolToAlignment.getState(0);
//    }
//    
//    if (theEvent.isFrom(cbVolToCohesion)) {
//      volToCohesion = cbVolToCohesion.getState(0);
//    }
    
    
    //----------------------------view control buttons---------------------------
    if (theEvent.isFrom(btXPLus100) || theEvent.isFrom(btXMinus100)) {
      //need to account for onscreen rotation about the y axis. Ignoring x axis rotation as it gets too difficult!
      flock.addVectorToAll(new PVector(cos(yRotation()) * theEvent.getValue(),
                           0.0, 
                           -sin(yRotation()) * theEvent.getValue()));
    }
    
    if (theEvent.isFrom(btYPlus100) || theEvent.isFrom(btYMinus100)) {
      flock.addVectorToAll(new PVector(0.0,
                                       theEvent.getValue(),
                                       0.0));
    }
    
    if (theEvent.isFrom(btZoomIn)) {
      zoomIn();
    }
    
    if (theEvent.isFrom(btZoomOut)) {
      zoomOut();
    }
    
    if (theEvent.isFrom(btRotateRight)) {
      rotateRight();
    }
    
    if (theEvent.isFrom(btRotateLeft)) {
      rotateLeft();
    }
    
    if (theEvent.isFrom(btWebcamCDF1)) {
      webcamShot ( cdf1 );
    }
    
    if (theEvent.isFrom(btWebcamCDF2)) {
      webcamShot ( cdf2 );
    }

    if (theEvent.isFrom(btHeap1)) {
      sendAllToCDFWithImage(cdf1, "heap.png");
      //cdf1.setupPDF2DFromImageFile("heap.png");
      //flock.changeNCDF(flock.particles.size(), cdf1);
      //cdf1.vectorAllItemsFromImageCDF ();
    }

    if (theEvent.isFrom(btCross1)) {
      sendAllToCDFWithImage(cdf1, "cross.png");
      //cdf1.setupPDF2DFromImageFile("cross.png");
      //flock.changeNCDF(flock.particles.size(), cdf1);
      //cdf1.vectorAllItemsFromImageCDF ();
    }    
    
//    if (theEvent.isFrom(btSendToCDF2)) {
//      flock.changeNCDF(50,cdf2);
//    }
    
    
    
    if (theEvent.isFrom(btHeap2)) {
      sendAllToCDFWithImage(cdf2, "heap.png");
      //cdf2.setupPDF2DFromImageFile("heap.png");
      //flock.changeNCDF(flock.particles.size(), cdf2);
      //cdf2.vectorAllItemsFromImageCDF ();
    }

    if (theEvent.isFrom(btCross2)) {
      sendAllToCDFWithImage(cdf2, "cross.png");
    }    
       
    if (theEvent.isFrom( slNumberInCDF2 )) {
      int targetNumberCDF2 = round(slNumberInCDF2.getValue() * flock.nActive);
      if ( targetNumberCDF2 > flock.numberInCDF(cdf2 )) {
        flock.makeNInCDF( targetNumberCDF2 , cdf2 );
      } else {
        flock.makeNInCDF( flock.nActive - targetNumberCDF2 , cdf1 );
      }
    }
    
    if (theEvent.isFrom( slAudioSplitFreq )) {
      //println(getSplitFreq());
      freqBalance.setSplitFrequency( getSplitFreq() );
    }
    
    if (theEvent.isFrom( slNumActiveParticles )) {
      flock.setNumActiveParticles( round(slNumActiveParticles.getValue()) );
    }
    
  }
   
  private float getSplitFreq () {
    // slider should range from 60 Hz to 5000 Hz , so 6.38 = log2(5000 / 60)
    return 60.0 * ( pow(2.0, slAudioSplitFreq.getMax() - slAudioSplitFreq.getValue() ) ) ;
  } 
   
   private void sendAllToCDFWithImage (CDF cdf, String filename) {
     cdf.setupPDF2DFromImageFile(filename);
     flock.changeNCDF( flock.nActive, cdf );
     flock.vectorAllItemsFromImageCDF ( cdf );
   }
   
  //detect keypresses when control frame has focus
  void keyPressed() {
    final int k = keyCode;
    //println(k);
    
    if (k == 'Q') {
      zoomMoves.clear();
      rotationMoves.clear();
      resetVariables();
    }
    
    //iterating the particles
    if (k == 'I') {
      //iterating = !iterating;
    }
    
    //rotating the camera
    if (k == 'R') {
      //rotating = !rotating;  
    }
    
    //rotating the camera
    if (k == 'Q') {
      //volToSpeedReversed = !volToSpeedReversed;  
    }
    
    //flocking
    if (k == 'F') {
      //flocking = !flocking;  
    }    
    
    //redrawing - pause 
    if (k == 'P') {
      //println(this.parent);
      //if (this.parent.looping) parent.noLoop();
      //else parent.loop();
    }
    
    if (k == 'W') {
      webcamShot (cdf1);
    }
    
    
    
    //arrow keys - moving the view--------------------------
    
    //zoom in
    if (k == 107 || k == 33) {
      //cameraDist *= btZoomIn.getValue();     
      zoomIn();
    } 
    
    //zoom out
    if (k == 109 || k == 34) {
      //cameraDist *= btZoomOut.getValue();  
      zoomOut();
    } 

    //mac keycodes?  104 38 up, 98 40 down, 100 37 left, 102 39 right
    //right, +x  
    if (k == 102 || k == 39) {  
      flock.addVectorToAll(new PVector(cos(yRotation()) * btXPLus100.getValue(),
                           0.0, 
                           -sin(yRotation()) * btXPLus100.getValue()));
    } 

    //left, -x  
    if (k == 100 || k == 37) {  
      flock.addVectorToAll(new PVector(cos(yRotation()) * btXMinus100.getValue(),
                           0.0, 
                           -sin(yRotation()) * btXMinus100.getValue()));
    } 

    //up, -y  
    if (k == 104 || k == 38) {  
      flock.addVectorToAll(new PVector(0.0,
                                       btYMinus100.getValue(),
                                       0.0));
    } 

    //down, +y  
    if (k == 98 || k == 40) {  
      flock.addVectorToAll(new PVector(0.0,
                                       btYPlus100.getValue(),
                                       0.0));
    } 

    if (k == 97 || k == 91) {  
      //controlYRotation = (controlYRotation + rotateOnKeypressByRadians) % (2*PI);
      //updateSliders(); 
      rotateLeft();   
    } 

    if (k == 99 || k == 93) {  
      //controlYRotation = (controlYRotation - rotateOnKeypressByRadians) % (2*PI);
      //updateSliders();
      rotateRight();  
    } 

    updateCheckboxes();
  }

  
  private void zoomOut () {
    float[] moves = triangular(movesPerZoom);
    int i = 0;
    for (float f : moves) {
      if (i < zoomMoves.size()) {
        zoomMoves.set(i,zoomMoves.get(i) * (1.0 + (zoomFactor * f)));
      } else {
        zoomMoves.add(1.0 + (zoomFactor * f));
      }
      i++;
    }          
  }
  
  private void zoomIn () {
    float[] moves = triangular(movesPerZoom);
    int i = 0;
    for (float f : moves) {
      if (i < zoomMoves.size()) {
        zoomMoves.set(i,zoomMoves.get(i) * 1.0/(1.0 + (zoomFactor * f)));
      } else {
        zoomMoves.add(1.0/(1.0 + (zoomFactor * f)));
      }
      i++;
    }          
  }
  
  private void rotateLeft() {
    float[] moves = triangular(movesPerRotate);
    int i = 0;
    for (float f : moves) {
      if (i < rotationMoves.size()) {
        rotationMoves.set(i,rotationMoves.get(i) + rotateFactor * f);
      } else {
        rotationMoves.add(+ rotateFactor * f);
      }
      i++;
    }   
  }
  
  private void rotateRight() {
    float[] moves = triangular(movesPerRotate);
    int i = 0;
    for (float f : moves) {
      if (i < rotationMoves.size()) {
        rotationMoves.set(i,rotationMoves.get(i) - rotateFactor * f);
      } else {
        rotationMoves.add(- rotateFactor * f);
      }
      i++;
    }  
  }

  
  ControlP5 cp5;
  Object parent;  
}

float[] triangular (int len) {
  float[] pdf = new float[len];
  for (int i = 0; i < len; i++) {
    if (i < len/2) {
      pdf[i] = float(i + 1) / float((len + 1)/2);
      pdf[len - i - 1] = pdf[i]; 
    } 
  }
  return pdf;
}
