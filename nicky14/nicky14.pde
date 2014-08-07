import ddf.minim.ugens.Sink;
import ddf.minim.effects.LowPassFS;
import ddf.minim.effects.ChebFilter;
import ddf.minim.effects.IIRFilter;
import ddf.minim.effects.*;
import ddf.minim.*;
import ddf.minim.ugens.*;
import ddf.minim.spi.*; // for AudioStream


import java.awt.Frame;
import java.awt.BorderLayout;
import controlP5.*;

//private ControlP5 cp5;

ControlFrame cf;

MidiInput midiInput;

int numParticles = 2000;
//ArrayList<Particle> particles;
Flock flock;

int thisFrameForChangingShapes = 0;
float cameraDist;

CDF cdf1, cdf2;

PFont aFont;

//boolean changingShapes = false;
boolean rotating = false;
boolean iterating = true;
boolean flocking = true;
boolean showInfo = false;
OnscreenInfo onscreenInfo;

boolean volToSpeedReversed = false;
float maxParticleSpeed = 30.0;

float YRotationSpeed;
float timeYRotation;
float controlXRotation;
float controlYRotation;
float zScale;

float separationForce = 3.0; 
float alignmentForce = 2.0;    
float cohesionForce = 2.0;
float homeForce = 6.0;

float audioLevel = 0.2;
float audioThreshold = 0.03;
//float AudioSplitFreq = 1200.0;
float forceMax = 6.0;

int makeNthFrameToPNG = 0; //0 for no video
int videoPNGCount = 0;

Webcam webcam;
//AudioIn audioIn;
Minim minim;
FreqBalance freqBalance;

PImage img0;
PImage img1;

//-----------------------------------------------------------------


void resetVariables () {
  cameraDist = 500;
  YRotationSpeed = 0.025;
  timeYRotation = 0.0;
  controlXRotation = 0.0;
  controlYRotation = 0.0;
  zScale = 0.5;  
}


float yRotation () {
  return timeYRotation + controlYRotation; 
}

void setup () {  
  size(1200, 800, P3D); //3D renderer
  if (frame != null) {
    frame.setResizable(true);
  }
  smooth();
  background(0);
  aFont = createFont("Times New Roman", 8, true);
  textFont(aFont);
  textAlign(CENTER,CENTER); 
  fill(255);
  
  //load the stamp images  
  String path = "../../resources/";
  img0 = loadImage(path + "NICOLA_STEMPEL_AKTUELL_GROESSE-1_0_crop.png");
  img1 = loadImage(path + "NICOLA_STEMPEL_AKTUELL_GROESSE-1_1_crop.png");
  if (img0 == null || img1 == null) {
    println("Unable to load stamp images. Check resources directory location and contents");    
  }  
  
  
  cdf1 = new CDF();
  cdf2 = new CDF();
  
  resetVariables();
  
  //CP5 - extra controller window -----------------------------------
  //cp5 = new ControlP5(this);
  
  // by calling function addControlFrame() a
  // new frame is created and an instance of class
  // ControlFrame is instanziated.
  cf = addControlFrame("control", 600, 600);
  //==================================================================

  //setup midi controller 
  midiInput = new MidiInput(this);
  
  midiInput.plugControllerToControlFrameSlider(0,cf.slAudioThreshold);
  midiInput.plugControllerToControlFrameSlider(1,cf.slNumActiveParticles);
  midiInput.plugControllerToControlFrameSlider(2,cf.slAudioSplitFreq);
  midiInput.plugControllerToControlFrameSlider(3,cf.slSeparationForce);
  midiInput.plugControllerToControlFrameSlider(4,cf.slAlignmentForce);
  midiInput.plugControllerToControlFrameSlider(5,cf.slCohesionForce);
  midiInput.plugControllerToControlFrameSlider(6,cf.slHomeForce);
  midiInput.plugControllerToControlFrameSlider(7,cf.slNumberInCDF2);

  //setup inputs
  //audioIn = new AudioIn(this);
  minim = new Minim(this);
  freqBalance = new FreqBalance( 1200.0 );
  //webcam = new Webcam(this);

  //set up cdf functions
  cdf1.setupPDF2DFromImageFile("heap.png");
  cdf2.setupPDF2DFromImageFile("cross.png");
  
  onscreenInfo = new OnscreenInfo();
  
  //make the flock
  flock = new Flock(numParticles, cdf1 );
  
  println("width " , width);
  println("height ", height);
  
  long allocated = Runtime.getRuntime().totalMemory();
  long free = Runtime.getRuntime().freeMemory();
  long maximum = Runtime.getRuntime().maxMemory();
  
  println("allocated mem ", allocated/1024/1024);
  println("free mem ", free/1024/1024);
  println("maximum mem ", maximum/1024/1024);
};



void draw () {
  background(0);
  
  //to get mic input
  //audioLevel = audioIn.level(); 
  freqBalance.update();
  
  if (freqBalance.prevHighLev > audioThreshold || freqBalance.prevLowLev > audioThreshold ) {
    int numToMove = abs(round(freqBalance.mix * 10.0));
    if (freqBalance.mix > 0 ) {
      //higher freqs dominate 
      flock.changeNCDF( numToMove , cdf2 );
    } else {
      //lower freqs dominate
      flock.changeNCDF( numToMove , cdf1 );
    }
  }
  
  maxParticleSpeed = map(freqBalance.level() ,
                         0.0,
                         audioThreshold * 2.0,
                         cf.slMaxSpeed.getMin(),
                         cf.slMaxSpeed.getMax());
                         
  //println(freqBalance.level());
  //println(audioThreshold * 2.0);
  
  //if (volToSpeedReversed) {
  //  maxParticleSpeed = (0.5 - audioLevel) * Particle.maxMaxSpeed;
  //} else {
  //  maxParticleSpeed = audioLevel * Particle.maxMaxSpeed;
  //}
  //if (maxParticleSpeed < 2) { maxParticleSpeed = 2; }
  //println(maxParticleSpeed);
  
//println(audioLevel);  
  
  if (showInfo) {
    //println("ddd");
    onscreenInfo.showAudio(audioLevel);  
    onscreenInfo.showVideo();   
  }
   
//  //volume to flocking params
//  if (volToSeparation) {
//    separationForce = audioLevel * forceMax; 
//    //println(separationForce);
//  } 
//  if (volToAlignment) {
//    alignmentForce = audioLevel * forceMax; 
//    //println(alignmentForce);
//  }
//  if (volToCohesion) {
//    cohesionForce = audioLevel * forceMax;
//   //println(cohesionForce); 
//  }

  //drawing and flocking
  flock.allTextDraw ();
  if (flocking) {
    flock.allRunFlocking();
  }
  if (iterating) {
    flock.allIterate();
  }
  
  //3D camera stuff  
  if (rotating) {
    timeYRotation += YRotationSpeed;
  }
  cameraDist *= cf.getZoom();
  controlYRotation = (controlYRotation + cf.getYRotation()) % (2*PI);

  if (frameCount % 5 == 0) {  
    cf.updateSliders();
  }
  
  camera(width/2 + cameraDist*sin(yRotation()), height/2 + cameraDist*sin(controlXRotation), cameraDist*cos(yRotation())*cos(controlXRotation), 
          width/2, height/2, 0, 
          0.0, 1.0, 0.0);
          
  if (makeNthFrameToPNG != 0) { 
    if (frameCount % makeNthFrameToPNG == 0) {    
      String frameNum = String.format("%04d", videoPNGCount); 
      saveFrame("/Users/martin/Movies/processingFrames/frame_" + frameNum + ".png");
      videoPNGCount++;
    }
  } 
  
  //show the main PApplet framerate on the control frame, with a little bit of averaging
  cf.mainFrameRate = 0.75*cf.mainFrameRate + 0.25*frameRate;
}

//capture midi messages and send to midiInput object
void controllerChange(int channel, int number, int value) {
  midiInput.controllerChange(channel,number,value);
}
