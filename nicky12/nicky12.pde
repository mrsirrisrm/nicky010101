
import java.awt.Frame;
import java.awt.BorderLayout;
import controlP5.*;

private ControlP5 cp5;

ControlFrame cf;

int numParticles = 1000;
//ArrayList<Particle> particles;
Flock flock;

int thisFrameForChangingShapes = 0;
int scrnWidth = 1200;
int scrnHeight = 800;
float cameraDist;

float[] cdfX = new float[scrnWidth];
float[] cdfY = new float[scrnHeight];
float cdfSumX = 0;
float cdfSumY = 0;

PFont aFont;

PImage img;
int[] imgYPDF;
int[][] imgPDF;
int[] imgYCDF;
int[][] imgCDF;

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

float dissolveProbability;
float YRotationSpeed;
float timeYRotation;
float controlXRotation;
float controlYRotation;
float fadeSpeed;
float zScale;

float separationForce = 3.0; 
float alignmentForce = 2.0;    
float cohesionForce = 2.0;

float audioLevel = 0.5;
float forceMax = 6.0;

int makeNthFrameToPNG = 0; //0 for no video
int videoPNGCount = 0;

Webcam webcam;
AudioIn audioIn;

//-----------------------------------------------------------------


void resetVariables () {
  cameraDist = 500;
  dissolveProbability = 0.0;
  YRotationSpeed = 0.025;
  timeYRotation = 0.0;
  controlXRotation = 0.0;
  controlYRotation = 0.0;
  fadeSpeed = 20.0;
  zScale = 0.5;  
}


float yRotation () {
  return timeYRotation + controlYRotation; 
}

void setup () {  
  size(scrnWidth, scrnHeight, P3D); //3D renderer
  if (frame != null) {
    frame.setResizable(true);
  }
  smooth();
  background(0);
  aFont = createFont("Times New Roman", 8, true);
  textFont(aFont);
  textAlign(CENTER,CENTER); 
  fill(255);
  
  resetVariables();
  
  //CP5 - extra controller window -----------------------------------
  cp5 = new ControlP5(this);
  
  // by calling function addControlFrame() a
  // new frame is created and an instance of class
  // ControlFrame is instanziated.
  cf = addControlFrame("control", 600, 600);
  //==================================================================

  //setup inputs
  audioIn = new AudioIn(this);
  webcam = new Webcam(this);

  //set up cdf functions
  setupPDF2DFromImageFile("column.png");
  
  onscreenInfo = new OnscreenInfo();
  
  //make the flock
  flock = new Flock(numParticles);
  
  moveAllItems ();
  vectorAllItemsFromImageCDF ();
  
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
  //clearing screen
  background(0, 0, 0);
  //dissolveLastSceneWithProbability(dissolveProbability);
  //fadeLastSceneBy(round(fadeSpeed)); 
  
  //to get mic input
  audioLevel = audioIn.level(); 
  
  if (volToSpeedReversed) {
    maxParticleSpeed = (0.5 - audioLevel) * Particle.maxMaxSpeed;
  } else {
    maxParticleSpeed = audioLevel * Particle.maxMaxSpeed;
  }
  if (maxParticleSpeed < 2) { maxParticleSpeed = 2; }
  //println(maxParticleSpeed);
  
//println(audioLevel);  
  
  if (showInfo) {
    //println("ddd");
    onscreenInfo.showAudio(audioLevel);  
    onscreenInfo.showVideo();   
  }
  
  //changing shapes
  if (changingShapes) {  
    if (thisFrameForChangingShapes % 300 == 0) {
      setupPDF2DFromImageFile("column.png");
      vectorAllItemsFromImageCDF ();
    } else if (thisFrameForChangingShapes % 300 == 100) {
       setupPDF2DFromImageFile("heap.png");
       vectorAllItemsFromImageCDF ();
    } else if (thisFrameForChangingShapes % 300 == 200) {
      setupPDF2DFromImageFile("cross.png");
      vectorAllItemsFromImageCDF ();
    }   
    thisFrameForChangingShapes++;
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
  
  //camera stuff  
  if (rotating) {
    timeYRotation += YRotationSpeed;
  }
  cameraDist *= cf.getZoom();
  controlYRotation = (controlYRotation + cf.getYRotation()) % (2*PI);  
  cf.updateSliders();
  
  camera(scrnWidth/2 + cameraDist*sin(yRotation()), scrnHeight/2 + cameraDist*sin(controlXRotation), cameraDist*cos(yRotation())*cos(controlXRotation), 
          scrnWidth/2, scrnHeight/2, 0, 
          0.0, 1.0, 0.0);
          
  if (makeNthFrameToPNG != 0) { 
    if (frameCount % makeNthFrameToPNG == 0) {    
      String frameNum = String.format("%04d", videoPNGCount); 
      saveFrame("/Users/martin/Movies/processingFrames/frame_" + frameNum + ".png");
      videoPNGCount++;
    }
  } 
}


