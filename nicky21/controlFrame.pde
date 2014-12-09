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
  
  //private final static float zoomFactor = 0.02;
  //private final static int movesPerZoom = 8;
  //private ArrayList<Float> zoomMoves = new ArrayList<Float>();

  private int nChangingCDF = 0;
  private int nChangingCDFFrameCount = 0;  
 
  Slider slNumberInCDF2;
  Slider slSplitFreq;
  Slider slAudioThreshold;
  Slider slParticleSpeed; 
  
  //Slider slSeparationForce;
  //Slider slAlignmentForce;
  //Slider slCohesionForce;
  Slider slHomeForce;
  Slider sldVdtSensitivity;
  Slider slSpectralPeakinessSensitivity;
  Slider slZoom;
  
  CheckBox cbPeakinessToParticleYVelocity;
  CheckBox cbdVdtToParticleXVelocity;
    
  Button btXPLus100;
  Button btXMinus100;
  Button btYPlus100;
  Button btYMinus100;
  //Button btZoomIn;
  //Button btZoomOut;
  
  Button btHeap1;
  Button btCross1;
  Button btHeap2;
  Button btCross2;  
  
  Button btWriteMovesFile;

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
    //frameRate( 5 );
    background(40);
    
    textSize( 10 );
  
    color cbCol = color(2,119,168);
    size(w, h);
    frameRate(25);
    cp5 = new ControlP5(this);
    
    //PFont p = createFont("Verdana", 8);
    //cp5.setControlFont(p );

    
    //=================================================================
    int moveKnobsY = 20; 
     
    //purple
    slNumberInCDF2 = cp5.addSlider("CDF2  particles")
                  .setRange(0, 1.0)
                  .setPosition(10,-50) //110 + moveKnobsY)
                  .setSize(300,10)
                  .setValue(0.0)
                  .setColorBackground(color(80,0,80))
                  .setColorActive(color(160,0,160))
                  .setColorForeground(color(160,0,160)); 
    slSplitFreq = cp5.addSlider("Split  frequency")
                  .setRange(0, 6.38) //NB reversed sense. the range is 60 hz to 5000 hz, so log2(5000 / 60) = 6.38
                  .setPosition(10,130 + moveKnobsY)
                  .setSize(300,10)
                  .setValue(2.65) //approx 800 Hz
                  .setColorBackground(color(80,0,80))
                  .setColorActive(color(160,0,160))
                  .setColorForeground(color(160,0,160));             

    //blue
    if (useFFT) {
      slSpectralPeakinessSensitivity = cp5.addSlider("peakiness  sensitivity")
                    .setRange(-1., 1.)
                    .setPosition(10,210 + moveKnobsY)
                    .setSize(300,10)
                    .setValue(0.0);
    }
    sldVdtSensitivity = cp5.addSlider("dVdt  sensitivity")
                  .setRange(-10., 10.)
                  .setPosition(10,230 + moveKnobsY)
                  .setSize(300,10)
                  .setValue(0.0);
                
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
                .setRange(0.0, forceMax)
                .setPosition(10,290 + moveSlidersY)
                .setSize(300,10)
                .setValue(2.0)
                .setColorBackground(color(100,0,0))
                .setColorActive(color(200,0,0))
                .setColorForeground(color(200,0,0));                

                
    //green
    slParticleSpeed = cp5.addSlider("particle  Speed"  )
                  .setRange(0.5 , 20.0)
                  .setPosition(10,350 + moveSlidersY)
                  .setSize(300,10)
                  .setValue(10.0)
                  .setColorBackground(color(0,60,0))
                  .setColorActive(color(0,150,0))
                  .setColorForeground(color(0,150,0));
    slAudioThreshold = cp5.addSlider("Audio  threshold")
                  .setRange(0.001, 0.06)
                  .setPosition(10,-50) //offscreen
                  .setSize(300,10)
                  .setValue(0.02)
                  .setColorBackground(color(100,50,0))
                  .setColorActive(color(200,100,0))
                  .setColorForeground(color(200,100,0));
      

    slZoom = cp5.addSlider("Zoom")
                  .setRange(200, 1600)
                  .setPosition(10,390 + moveSlidersY) 
                  .setSize(300,10)
                  .setValue(800)
                  .setColorBackground(color(100,100,50))
                  .setColorActive(color(200,200,100))
                  .setColorForeground(color(200,200,100));
          
    //------------checkboxes controll item general behaviours-------------------------
//      cbdVdtToCohesion = cp5.addCheckBox("cbdVdtToCohesion")
//                .setPosition(430, 230 + moveKnobsY)
//                .setColorForeground(color(120))
//                .setColorActive(cbCol)
//                .setColorLabel(color(255))
//                .setSize(20, 15)
//                .addItem("dVdt +-", 0);        
//      cbPeakinessSense = cp5.addCheckBox("cbPeakiness")
//                .setPosition(430, 210 + moveKnobsY)
//                .setColorForeground(color(120))
//                .setColorActive(cbCol)
//                .setColorLabel(color(255))
//                .setSize(20, 15)
//                .addItem("peakiness +-", 0);   
      cbdVdtToParticleXVelocity = cp5.addCheckBox("cbdVdtToX")
                .setPosition(510, 230 + moveKnobsY)
                .setColorForeground(color(120))
                .setColorActive(cbCol)
                .setColorLabel(color(255))
                .setSize(20, 15)
                .addItem("dVdt  to  X", 0);            
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
  
//     btZoomIn = cp5.addButton("z+") 
//       .setValue(1.0/1.08)
//       .setPosition(150,350 + moveButtonsDown)
//       .setSize(20,20); 
//     btZoomOut = cp5.addButton("z-") 
//       .setValue(1.08)
//       .setPosition(150,390 + moveButtonsDown)
//       .setSize(20,20); 
      
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
       
    if (inputDataMode == 1) {
      btWriteMovesFile = cp5.addButton("write  moves") 
                 .setValue(0)
                 .setPosition(290,height - 50)
                 .setSize(20,20); 
    }

    updateCheckboxes(); 
  }

  public void draw() {
    if (frameCount % updateAudioFeedbackOnNthFrame == 0) {
      if (inputDataMode == 2) {
        background(0);
      } else {      
        background(40);
      }
      
    
      color c = color(255,100,100);
    
      text("Framerate: " + str(round(mainFrameRate)), 20, height - 50);
      if (inputDataMode == 1) {
        text("Recording data", 20, height - 35);
      } else if (inputDataMode == 2) {
        text("Reading data", 20, height - 35);
      }
      
      if (activeSliderY > 0) {
        fill(255);
        noStroke();
        ellipse(5,activeSliderY + 5,10,10);
      }
      
      stroke(255.0);
      strokeWeight(6.0);
      strokeCap(ROUND);
              
      //markers for center of peakiness/dvdt bars
      line(160,220,160,270);
      //line(160,290,160,330); 
      
      strokeWeight(12.0);        
      //lines showing level
      if (inputData != null) {
        float pxForMaxAudioThreshold = 300; 
        float pxForStartAudioLevelBar = 20;
        
        if (inputData.prevLowLev > inputData.audioThreshold && inputData.prevLowLev > inputData.prevHighLev) {
          stroke(c);
        } else {
          stroke(255);
        }
        line(this.width - 80,
             this.height - pxForStartAudioLevelBar,
             this.width - 80,
             this.height - (pxForStartAudioLevelBar + 
                            pxForMaxAudioThreshold * inputData.prevLowLev / slAudioThreshold.getMax()) );      
        
        if (inputData.prevHighLev > inputData.audioThreshold && inputData.prevHighLev > inputData.prevLowLev) {
          stroke(c);
        } else {
          stroke(255);
        }
        line(this.width - 40,
             this.height - pxForStartAudioLevelBar,
             this.width - 40,
             this.height - (pxForStartAudioLevelBar + pxForMaxAudioThreshold * inputData.prevHighLev / slAudioThreshold.getMax()) );      
  
        //line showing threshold
        stroke(200,100,0);
        strokeWeight(6.0);
        strokeCap(ROUND);     
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
               this.height - (pxForStartAudioLevelBar + 10.0 * inputData.logdVdt ) );
        }
       
        //strokeWeight( 1.0 );  
        //strokeCap(NORMAL);
        //for (int i = 0; i < 299; i++) {
        //  line(i + 200, 100 - freqBalance.logdVdts[i], i + 201, 100 - freqBalance.logdVdts[(i + 1)]);  
        //}     
       
       
        //FFT
        if (showPeakiness) {
//          stroke(180);
//          strokeWeight( 1.0 );
//          strokeCap( NORMAL );
//          line(300, 50, 300 + fft.previousPeakiness.length, 50);
//          
//          stroke(255);
//          strokeWeight( 2.0 );
//          strokeCap( NORMAL );
//          float fftScale = 3;
//          for (int i = 1; i < fft.previousPeakiness.length; i++) {
//            line(i - 1 + 300, 
//                 50 - fftScale * fft.previousPeakiness[i - 1],//log(freqBalance.previousSpect[ i - 1 ]), 
//                 i + 300, 
//                 50 - fftScale * fft.previousPeakiness[i] ); //log(freqBalance.previousSpect[ i ]));
//          }
          
         
          //spectral flatness
          stroke(0,180,230);
          strokeWeight(12.0);
          strokeCap(ROUND);
          line(this.width - 160,
              this.height - pxForStartAudioLevelBar,
              this.width - 160,
              this.height - (pxForStartAudioLevelBar + 30. * inputData.peakiness ) );
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
    //sliders
    if (theEvent.isFrom(slSpectralPeakinessSensitivity)) inputData.peakinessSensitivity = slSpectralPeakinessSensitivity.getValue();
    if (theEvent.isFrom(sldVdtSensitivity)) inputData.dVdtSensitivity = sldVdtSensitivity.getValue();
    if (theEvent.isFrom(slHomeForce)) inputData.homeForce = slHomeForce.getValue();
    if (theEvent.isFrom(slAudioThreshold)) inputData.audioThreshold = slAudioThreshold.getValue();
    if (theEvent.isFrom(cbPeakinessToParticleYVelocity)) inputData.peakinessToParticleYVelocity = cbPeakinessToParticleYVelocity.getState(0);
    if (theEvent.isFrom(cbdVdtToParticleXVelocity)) inputData.dVdtToParticleXVelocity = cbdVdtToParticleXVelocity.getState(0);
    if (theEvent.isFrom( slSplitFreq )) freqBalance.setSplitFrequency( getSplitFreq() );
    if (theEvent.isFrom( slZoom )) inputData.cameraDist = slZoom.getValue();

    //----------------------------view control buttons---------------------------
    if (theEvent.isFrom(btXPLus100) || theEvent.isFrom(btXMinus100)) flock.addVectorToAll(new PVector(theEvent.getValue(), 0.0, 0.0));
    if (theEvent.isFrom(btYPlus100) || theEvent.isFrom(btYMinus100)) flock.addVectorToAll(new PVector(0.0, theEvent.getValue(), 0.0));
    //if (theEvent.isFrom(btZoomIn)) zoomIn();
    //if (theEvent.isFrom(btZoomOut)) zoomOut();
    if (theEvent.isFrom(btHeap1)) sendAllToCDFWithImage(cdf1, "heap.png");
    if (theEvent.isFrom(btCross1)) sendAllToCDFWithImage(cdf1, "cross.png");
    if (theEvent.isFrom(btHeap2)) sendAllToCDFWithImage(cdf2, "heap.png");
    if (theEvent.isFrom(btCross2))  sendAllToCDFWithImage(cdf2, "cross.png");
    if (theEvent.isFrom(btWriteMovesFile) || inputDataMode == 1) writeOutputMoves();        
       
    if (theEvent.isFrom( slNumberInCDF2 )) {
      int targetNumberCDF2 = round(slNumberInCDF2.getValue() * flock.nActive);
      if ( targetNumberCDF2 > flock.numberInCDF(cdf2 )) {
        flock.makeNInCDF( targetNumberCDF2 , cdf2 );
      } else {
        flock.makeNInCDF( flock.nActive - targetNumberCDF2 , cdf1 );
      }
    }
  } //updateEvent
  
  public void updateSlidersAndText (float aFrameRate) {
    float portionInCDF2 = float(flock.numberInCDF(cdf2)) / float(flock.nActive);
    slNumberInCDF2.setValue(portionInCDF2);
    
    this.mainFrameRate = 0.75 * this.mainFrameRate + 0.25*aFrameRate;
  }

  public void updateCheckboxes () {
    if (inputData.peakinessToParticleYVelocity) {
      cbPeakinessToParticleYVelocity.activate(0);
    } else {
      cbPeakinessToParticleYVelocity.deactivate(0);
    }
    
    if (inputData.dVdtToParticleXVelocity) {
      cbdVdtToParticleXVelocity.activate(0);
    } else {
      cbdVdtToParticleXVelocity.deactivate(0);
    }
    
  }  
   
  private float getSplitFreq () {
    // slider should range from 60 Hz to 5000 Hz , so 6.38 = log2(5000 / 60)
    if (slSplitFreq == null) {
      return 1000;
    } else {
      return 60.0 * ( pow(2.0, slSplitFreq.getMax() - slSplitFreq.getValue() ) ) ;
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
    //if (k == 107 || k == 33) zoomIn();
    //if (k == 109 || k == 34) zoomOut();

    //mac keycodes?  104 38 up, 98 40 down, 100 37 left, 102 39 right
    //right, left
    if (k == 102 || k == 39) flock.addVectorToAll(new PVector(btXPLus100 .getValue(), 0.0, 0.0));
    if (k == 100 || k == 37) flock.addVectorToAll(new PVector(btXMinus100.getValue(), 0.0, 0.0));    
    //up, down
    if (k == 104 || k == 38) flock.addVectorToAll(new PVector(0.0, btYMinus100.getValue(), 0.0));
    if (k == 98  || k == 40) flock.addVectorToAll(new PVector(0.0, btYPlus100 .getValue(), 0.0));

    updateCheckboxes();
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
