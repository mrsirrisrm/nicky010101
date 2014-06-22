
import java.awt.Frame;
import java.awt.BorderLayout;
import controlP5.*;

private ControlP5 cp5;

ControlFrame cf;

int numParticles = 1000;
//ArrayList<Particle> particles;
Flock flock;

int thisFrameForChangingShapes = 0;
float cameraDist;

CDF cdf1, cdf2;

PFont aFont;

boolean changingShapes = false;
boolean rotating = false;
boolean iterating = true;
boolean flocking = true;
boolean showInfo = false;
OnscreenInfo onscreenInfo;

boolean volToSeparation = false;
boolean volToAlignment = false;
boolean volToCohesion = false;

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
float forceMax = 6.0;

int makeNthFrameToPNG = 0; //0 for no video
int videoPNGCount = 0;

Webcam webcam;
AudioIn audioIn;

//-----------------------------------------------------------------


void resetVariables () {
  cameraDist = 500;
  //dissolveProbability = 0.0;
  YRotationSpeed = 0.025;
  timeYRotation = 0.0;
  controlXRotation = 0.0;
  controlYRotation = 0.0;
  //fadeSpeed = 20.0;
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
  
  cdf1 = new CDF();
  cdf2 = new CDF();
  
  resetVariables();
  
  //CP5 - extra controller window -----------------------------------
  cp5 = new ControlP5(this);
  
  // by calling function addControlFrame() a
  // new frame is created and an instance of class
  // ControlFrame is instanziated.
  cf = addControlFrame("control", 600, 600);
  //==================================================================

  //setup inputs
  //audioIn = new AudioIn(this);
  //webcam = new Webcam(this);

  //set up cdf functions
  cdf2.setupPDF2DFromImageFile("cross.png");
  cdf1.setupPDF2DFromImageFile("heap.png");
  
  onscreenInfo = new OnscreenInfo();
  
  //make the flock
  flock = new Flock(numParticles);
  
  //cdf1.moveAllItems ();
  for (Particle part : flock.particles) {
    part.CDFParent = cdf1;
  }
  cdf1.vectorAllItemsFromImageCDF ();
  
  println("width " , size().width);
  println("height ", size().height);
  
  long allocated = Runtime.getRuntime().totalMemory();
  long free = Runtime.getRuntime().freeMemory();
  long maximum = Runtime.getRuntime().maxMemory();
  
  println("allocated mem ", allocated/1024/1024);
  println("free mem ", free/1024/1024);
  println("maximum mem ", maximum/1024/1024);
};



void draw () {
  background(0, 0, 0);
  
  //to get mic input
  //audioLevel = audioIn.level(); 
  
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
   
  //volume to flocking params
  if (volToSeparation) {
    separationForce = audioLevel * forceMax; 
    //println(separationForce);
  } 
  if (volToAlignment) {
    alignmentForce = audioLevel * forceMax; 
    //println(alignmentForce);
  }
  if (volToCohesion) {
    cohesionForce = audioLevel * forceMax;
   //println(cohesionForce); 
  }

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
  cf.updateSliders();
  
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
}
