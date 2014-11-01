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
  ControlP5 cp5;
  Object parent; 
  
  private int w, h;
  private int updateAudioFeedbackOnNthFrame = 5;
  public  float mainFrameRate = 0.0;
  
  int activeSliderY = 0;
  
  private final static float zoomFactor = 0.02;
  private final static int movesPerZoom = 8;
  private ArrayList<Float> zoomMoves = new ArrayList<Float>();

  private int nChangingCDF = 0;
  private int nChangingCDFFrameCount = 0;  
 
  //Slider slYRotation;
  Slider slNumberInCDF2;
  Slider slAudioSplitFreq;
  Slider slAudioThreshold;
  Slider slSpeedAudioComparison; 
  
  //Slider slSeparationForce;
  //Slider slAlignmentForce;
  //Slider slCohesionForce;
  Slider slHomeForce;
  //Slider slNumActiveParticles;
  //Slider slZScale;
  Slider sldVdtSensitivity;
  Slider slSpectralPeakinessSensitivity;
  
  CheckBox cbdVdtToCohesion;
  CheckBox cbPeakinessSense;
  CheckBox cbPeakinessToParticleYVelocity;
  CheckBox cbdVdtToParticleXVelocity;
    
  Button btXPLus100;
  Button btXMinus100;
  Button btYPlus100;
  Button btYMinus100;
  Button btZoomIn;
  Button btZoomOut;
  
  Button btHeap1;
  Button btCross1;
  Button btHeap2;
  Button btCross2;  

  //constructors--------------------------
  public ControlFrame(Object theParent, int theWidth, int theHeight) {
    parent = theParent;
    w = theWidth;
    h = theHeight;
  }

  public ControlP5 control() {
    return cp5;
  }
  //--------------------------------
 
  public void setup() {
    background(40);
    
    textSize( 10 );
  
    color cbCol = color(2,119,168);
    size(w, h);
    frameRate(25);
    cp5 = new ControlP5(this);
    
    //PFont p = createFont("Verdana", 8);
    //cp5.setControlFont(p );

    
    //==========knobs in red=======================================================
    int moveKnobsY = 20; 
     
    //purple
    slNumberInCDF2 = cp5.addSlider("CDF2  particles")
                  .setRange(0, 1.0)
                  .setPosition(10,110 + moveKnobsY)
                  .setSize(300,10)
                  .setValue(0.0)
                  .setColorBackground(color(80,0,80))
                  .setColorActive(color(160,0,160))
                  .setColorForeground(color(160,0,160)); 
    slAudioSplitFreq = cp5.addSlider("Split  frequency")
                  .setRange(0, 6.38) //NB reversed sense. the range is 60 hz to 5000 hz, so log2(5000 / 60) = 6.38
                  .setPosition(10,130 + moveKnobsY)
                  .setSize(300,10)
                  .setValue(2.65) //approx 800 Hz
                  .setColorBackground(color(80,0,80))
                  .setColorActive(color(160,0,160))
                  .setColorForeground(color(160,0,160));             

    //blue
    slSpectralPeakinessSensitivity = cp5.addSlider("peakiness  sensitivity")
                  .setRange(0., 1.)
                  .plugTo(parent,"peakinessSensitivity" )
                  .setPosition(10,210 + moveKnobsY)
                  .setSize(300,10)
                  .setValue(0.5);
    sldVdtSensitivity = cp5.addSlider("dVdt  sensitivity")
                  .setRange(0., 10.)
                  .plugTo(parent,"dVdtSensitivity" )
                  .setPosition(10,230 + moveKnobsY)
                  .setSize(300,10)
                  .setValue(3.0);
                  
//    slNumActiveParticles = cp5.addSlider("activeParticles"  )
//                 .setRange(0.0, flock.maxParticles())
//                 .setPosition(10,190 + moveKnobsY)
//                 .setSize(300,10)
//                 .setValue(flock.nActive)
//                 .setColorBackground(color(100,0,0))
//                 .setColorActive(color(200,0,0))
//                 .setColorForeground(color(200,0,0));
//    slZScale = cp5.addSlider("Z Scale")
//                  .plugTo(parent,"zScale")
//                  .setRange(0, 1)
//                  .setPosition(10,210 + moveKnobsY)
//                  .setSize(300,10)
//                  .setValue(0.5)
//                  .setColorBackground(color(100,0,0))
//                  .setColorActive(color(200,0,0))
//                  .setColorForeground(color(200,0,0));               
                
    //==========sliders in blue====================================
    int moveSlidersY = 20;
    
    //red
//    slSeparationForce = cp5.addSlider("separationForce")
//                .plugTo(parent,"separationForce")
//                .setRange(0.0, forceMax)
//                .setPosition(10,250 + moveSlidersY)
//                .setSize(300,10)
//                .setValue(2.2);
//    slAlignmentForce = cp5.addSlider("alignmentForce" )
//                .plugTo(parent,"alignmentForce" )
//                .setRange(0.0, forceMax)
//                .setPosition(10,270 + moveSlidersY)
//                .setSize(300,10)
//                .setValue(2.0);
//    slCohesionForce = cp5.addSlider("cohesionForce"  )
//                .plugTo(parent,"cohesionForce"  )
//                .setRange(0.0, forceMax)
//                .setPosition(10,290 + moveSlidersY)
//                .setSize(300,10)
//                .setValue(2.0);
    slHomeForce = cp5.addSlider("home  Force"  )
                .plugTo(parent,"homeForce"  )
                .setRange(0.0, forceMax)
                .setPosition(10,290 + moveSlidersY)
                .setSize(300,10)
                .setValue(2.0)
                .setColorBackground(color(100,0,0))
                .setColorActive(color(200,0,0))
                .setColorForeground(color(200,0,0));                

                
    //green
    slSpeedAudioComparison = cp5.addSlider("particle  Speed"  )
                  .setRange(0.0 , 0.3)
                  .setPosition(10,350 + moveSlidersY)
                  .setSize(300,10)
                  .setValue(0.133)
                  .setColorBackground(color(0,60,0))
                  .setColorActive(color(0,150,0))
                  .setColorForeground(color(0,150,0));
    slAudioThreshold = cp5.addSlider("Audio  threshold")
                  .setRange(0.001, 0.06)
                  .plugTo(parent,"audioThreshold" )
                  .setPosition(10,370 + moveSlidersY)
                  .setSize(300,10)
                  .setValue(0.02)
                  .setColorBackground(color(0,60,0))
                  .setColorActive(color(0,150,0))
                  .setColorForeground(color(0,150,0));
      

          
    //------------checkboxes controll item general behaviours-------------------------
      cbdVdtToCohesion = cp5.addCheckBox("cbdVdtToCohesion")
                .setPosition(430, 230 + moveKnobsY)
                .setColorForeground(color(120))
                .setColorActive(cbCol)
                .setColorLabel(color(255))
                .setSize(20, 15)
                .addItem("dVdt +-", 0);        
      cbdVdtToParticleXVelocity = cp5.addCheckBox("cbdVdtToX")
                .setPosition(510, 230 + moveKnobsY)
                .setColorForeground(color(120))
                .setColorActive(cbCol)
                .setColorLabel(color(255))
                .setSize(20, 15)
                .addItem("dVdt  to  X", 0);            
      cbPeakinessSense = cp5.addCheckBox("cbPeakiness")
                .setPosition(430, 210 + moveKnobsY)
                .setColorForeground(color(120))
                .setColorActive(cbCol)
                .setColorLabel(color(255))
                .setSize(20, 15)
                .addItem("peakiness +-", 0);   
      cbPeakinessToParticleYVelocity = cp5.addCheckBox("cbPeakinessToY")
                .setPosition(510, 210 + moveKnobsY)
                .setColorForeground(color(120))
                .setColorActive(cbCol)
                .setColorLabel(color(255))
                .setSize(20, 15)
                .addItem("peakiness  to  Y", 0);    
          
     //-----------view control buttons  -------------------------------------------
    int moveButtonsDown = 90;   
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
      
    btHeap1 = cp5.addButton("1:heap") 
       .setValue(0)
       .setPosition(250,350 + moveButtonsDown)
       .setSize(20,20);
   btCross1 = cp5.addButton("1:cross") 
       .setValue(0)
       .setPosition(290,350 + moveButtonsDown)
       .setSize(20,20);

    btHeap2 = cp5.addButton("2:heap") 
       .setValue(0)
       .setPosition(250,390 + moveButtonsDown)
       .setSize(20,20);
   btCross2 = cp5.addButton("2:cross") 
       .setValue(0)
       .setPosition(290,390 + moveButtonsDown)
       .setSize(20,20);

    updateCheckboxes(); 
  }

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
        
        if (freqBalance.prevLowLev() > audioThreshold && freqBalance.prevLowLev() > freqBalance.prevHighLev()) {
          stroke(c);
        } else {
          stroke(255);
        }
        line(this.width - 80,
             this.height - pxForStartAudioLevelBar,
             this.width - 80,
             this.height - (pxForStartAudioLevelBar + 
                            pxForMaxAudioThreshold * freqBalance.prevLowLev() / slAudioThreshold.getMax()) );      
        
        if (freqBalance.prevHighLev() > audioThreshold && freqBalance.prevHighLev() > freqBalance.prevLowLev()) {
          stroke(c);
        } else {
          stroke(255);
        }
        line(this.width - 40,
             this.height - pxForStartAudioLevelBar,
             this.width - 40,
             this.height - (pxForStartAudioLevelBar + pxForMaxAudioThreshold * freqBalance.prevHighLev() / slAudioThreshold.getMax()) );      
  
        //line showing threshold
        stroke(255);
        strokeWeight(3.0);
        strokeCap(NORMAL);     
        line(this.width - 100,
             this.height - (pxForStartAudioLevelBar + pxForMaxAudioThreshold * slAudioThreshold.getValue() / slAudioThreshold.getMax() ),
             this.width - 20,
             this.height - (pxForStartAudioLevelBar + pxForMaxAudioThreshold * slAudioThreshold.getValue() / slAudioThreshold.getMax() ) );
       
        if (showDVDT) { 
          //line showing dV/dt
          stroke(0,255,0);
          strokeWeight(12.0);
          strokeCap(ROUND);
          line(this.width - 120,
               this.height - pxForStartAudioLevelBar,
               this.width - 120, //<>//
               this.height - (pxForStartAudioLevelBar + 10.0 * (freqBalance.logdVdt) ) );
        }
       
        //strokeWeight( 1.0 );  
        //strokeCap(NORMAL);
        //for (int i = 0; i < 299; i++) {
        //  line(i + 200, 100 - freqBalance.logdVdts[i], i + 201, 100 - freqBalance.logdVdts[(i + 1)]);  
        //}     
       
       
        //FFT
        if (showPeakiness) {
          stroke(180);
          strokeWeight( 1.0 );
          strokeCap( NORMAL );
          line(300, 50, 300 + fft.previousPeakiness.length, 50);
          
          stroke(255);
          strokeWeight( 2.0 );
          strokeCap( NORMAL );
          float fftScale = 3;
          for (int i = 1; i < fft.previousPeakiness.length; i++) {
            line(i - 1 + 300, 
                 50 - fftScale * fft.previousPeakiness[i - 1],//log(freqBalance.previousSpect[ i - 1 ]), 
                 i + 300, 
                 50 - fftScale * fft.previousPeakiness[i] ); //log(freqBalance.previousSpect[ i ]));
          }
          
         
          //spectral flatness
          //text(str(fft.previousPeakiness[0]),100,100);
          stroke(0,180,230);
          strokeWeight(12.0);
          strokeCap(ROUND);
          line(this.width - 160,
              this.height - pxForStartAudioLevelBar,
              this.width - 160,
              this.height - (pxForStartAudioLevelBar + 30. * fft.previousPeakiness[0] ) );
        } //peakiness

        //show the portion in each CDF
        float sz = 100.0;
        noStroke();
        fill(140);
        rect(50,10,sz,sz);
        rect(250,10,sz,sz);
        fill(255);
        float q = float(flock.numberInCDF(cdf1)) / flock.nActive;
        rect(50 ,110 - q * sz,100,q * sz);
        rect(250,110 - (1 - q) * sz,100,(1 - q) * sz);
     
        //show the images for each CDF
        image(cdf1.img,50,10,sz,sz);
        image(cdf2.img,250,10,sz,sz);
     
        //arrows showing movement between cdfs   
        if (this.nChangingCDFFrameCount > 0) {
          if (this.nChangingCDF > 0) {
            if (q == 0) {
              stroke(140); //cdf2 already full
            } else {
              stroke(255);
            }
            strokeWeight(6.0);
            strokeCap(ROUND);
            line(210,30,230,50);
            line(210,70,230,50);
          } else if (this.nChangingCDF < 0) {
            if (q == 1) {
              stroke(140); //cdf1 already full
            } else {
              stroke(255);
            }
            strokeWeight(6.0);
            strokeCap(ROUND);  
            line(200,30,180,50);
            line(200,70,180,50);
          }
          this.nChangingCDFFrameCount--;
        }   
      }
    } 
  } //draw
    
  void controlEvent(ControlEvent theEvent) {    
    if (theEvent.isFrom(cbdVdtToCohesion)) {
      dVdtToCohesion = cbdVdtToCohesion.getState(0);
    }
    
    if (theEvent.isFrom(cbPeakinessSense)) {
      peakinessSense = cbPeakinessSense.getState(0);
    }
    
    if (theEvent.isFrom(cbPeakinessToParticleYVelocity)) {
      peakinessToParticleYVelocity = cbPeakinessToParticleYVelocity.getState(0);
    }

    if (theEvent.isFrom(cbdVdtToParticleXVelocity)) {
      dVdtToParticleXVelocity = cbdVdtToParticleXVelocity.getState(0);
    }
       
    //----------------------------view control buttons---------------------------
    if (theEvent.isFrom(btXPLus100) || theEvent.isFrom(btXMinus100)) {
      flock.addVectorToAll(new PVector(theEvent.getValue(), 0.0, 0.0));
    }
    
    if (theEvent.isFrom(btYPlus100) || theEvent.isFrom(btYMinus100)) {
      flock.addVectorToAll(new PVector(0.0, theEvent.getValue(), 0.0));
    }
    
    if (theEvent.isFrom(btZoomIn)) {
      zoomIn();
    }
    
    if (theEvent.isFrom(btZoomOut)) {
      zoomOut();
    }
    
    if (theEvent.isFrom(btHeap1)) {
      sendAllToCDFWithImage(cdf1, "heap.png");
    }

    if (theEvent.isFrom(btCross1)) {
      sendAllToCDFWithImage(cdf1, "cross.png");
    }    
        
    if (theEvent.isFrom(btHeap2)) {
      sendAllToCDFWithImage(cdf2, "heap.png");
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
      freqBalance.setSplitFrequency( getSplitFreq() );
    }
    
    //if (theEvent.isFrom( slNumActiveParticles )) {
    //  flock.setNumActiveParticles( round(slNumActiveParticles.getValue()) );
    //}  
  } //updateEvent
  
  public void updateSliders () {
    float portionInCDF2 = float(flock.numberInCDF(cdf2)) / float(flock.nActive);
    slNumberInCDF2.setValue(portionInCDF2);
  }

  private void updateCheckboxes () {
    if (dVdtToCohesion) {
      cbdVdtToCohesion.activate(0);
    } else {
      cbdVdtToCohesion.deactivate(0);
    }
    
    if (peakinessSense) {
      cbPeakinessSense.activate(0);
    } else {
      cbPeakinessSense.deactivate(0);
    }
    
    if (peakinessToParticleYVelocity) {
      cbPeakinessToParticleYVelocity.activate(0);
    } else {
      cbPeakinessToParticleYVelocity.deactivate(0);
    }
    
    if (dVdtToParticleXVelocity) {
      cbdVdtToParticleXVelocity.activate(0);
    } else {
      cbdVdtToParticleXVelocity.deactivate(0);
    }
    
  }  
   
  private float getSplitFreq () {
    // slider should range from 60 Hz to 5000 Hz , so 6.38 = log2(5000 / 60)
    if (slAudioSplitFreq == null) {
      return 1000;
    } else {
      return 60.0 * ( pow(2.0, slAudioSplitFreq.getMax() - slAudioSplitFreq.getValue() ) ) ;
    }
  } 
   
   private void sendAllToCDFWithImage (CDF cdf, String filename) {
     cdf.setupPDF2DFromImageFile(filename);
     flock.changeNCDF( flock.nActive, cdf );
     flock.vectorAllItemsFromImageCDF ( cdf );
   }
   
  //detect keypresses when control frame has focus
  void keyPressed() {
    final int k = keyCode;
    
    //arrow keys - moving the view--------------------------   
    if (k == 107 || k == 33) zoomIn();
    if (k == 109 || k == 34) zoomOut();

    //mac keycodes?  104 38 up, 98 40 down, 100 37 left, 102 39 right
    //right, left
    if (k == 102 || k == 39) flock.addVectorToAll(new PVector(btXPLus100 .getValue(), 0.0, 0.0));
    if (k == 100 || k == 37) flock.addVectorToAll(new PVector(btXMinus100.getValue(), 0.0, 0.0));    
    //up, down
    if (k == 104 || k == 38) flock.addVectorToAll(new PVector(0.0, btYMinus100.getValue(), 0.0));
    if (k == 98  || k == 40) flock.addVectorToAll(new PVector(0.0, btYPlus100 .getValue(), 0.0));

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
  
  public float getZoom () {
    if (zoomMoves.size() == 0) {
      return 1.0;
    } else {
      float z = zoomMoves.get(0);
      zoomMoves.remove(0);
      return z;
    }
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
  
  void showNChangingCDF(int n) {
    if (n != 0) {
      this.nChangingCDF = n;
      this.nChangingCDFFrameCount = 5;
    }
  }
} //Class ControlFrame
