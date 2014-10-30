Flock flock;
ControlFrame cf;
MidiInput midiInput;
CDF cdf1, cdf2;
FreqBalance freqBalance;
FFTAnalysis fft;

float cameraDist;
//PFont aFont;

boolean iterating = true;
boolean flocking = true;
boolean showInfo = false;

//boolean volToSpeedReversed = false;
float maxParticleSpeed = 30.0;

float zScale;

float separationForce = 2.2; 
float alignmentForce = 2.0;    
float cohesionForce = 2.0;
float homeForce = 6.0;

float audioThreshold = 0.02;
float dVdtSensitivity = 3.0;
boolean dVdtToCohesion = false;
boolean dVdtToParticleXVelocity = true;
float forceMax = 4.5;
float peakinessSensitivity = 0.5;
boolean peakinessSense = false;
boolean peakinessToParticleYVelocity = true;
float moveParticlesBetweenCDFSensitivity = 6.0;

int makeNthFrameToPNG = 0; //0 for no video
int videoPNGCount = 0;

//stamp images
PImage img0;
PImage img1;

boolean showPeakiness = false;
boolean showDVDT = false;

//-----------------------------------------------------------------


void resetVariables () {
  cameraDist = 800;
  zScale = 0.5;  
}

void setup () {  
  size(1200, 800, P3D); //3D renderer
  if (frame != null) {
    frame.setResizable(true);
  }
  smooth();
  background(0);
  textAlign(CENTER,CENTER);
  imageMode(CENTER);  
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
  
  //set up cdf functions
  cdf1.setupPDF2DFromImageFile("heap.png");
  cdf2.setupPDF2DFromImageFile("cross.png");
  
  //make the flock
  flock = new Flock( 2000 , 1000 ,  cdf1 );
  
  cf = addControlFrame("control", 600, 600);
  
  //setup midi controller 
  midiInput = new MidiInput(this);
  freqBalance = new FreqBalance( this, cf.getSplitFreq() );
  fft = new FFTAnalysis( this );
  
  midiInput.plugControllerSlider(0,cf.slAudioThreshold);
  midiInput.plugControllerSlider(1,cf.slSpeedAudioComparison);
  //midiInput.plugControllerSlider(2,cf.slAudioSplitFreq);
  midiInput.plugControllerSlider(3,cf.slSeparationForce);
  midiInput.plugControllerSlider(4,cf.slAlignmentForce);
  midiInput.plugControllerSlider(5,cf.slCohesionForce);
  midiInput.plugControllerSlider(6,cf.slHomeForce);
  //midiInput.plugControllerSlider(7,cf.slNumberInCDF2);
  
  midiInput.plugControllerKnob(16,cf.slZScale);
  midiInput.plugControllerKnob(17,cf.slNumActiveParticles);
  midiInput.plugControllerKnob(18,cf.slAudioSplitFreq);
  midiInput.plugControllerKnob(19,cf.sldVdtSensitivity);
  midiInput.plugControllerKnob(20,cf.slSpectralPeakinessSensitivity);
  midiInput.plugControllerKnob(23,cf.slNumberInCDF2);

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
  freqBalance.update();
  
  if (frameCount % FFTAnalysis.updatePerFrames == 0) {
    fft.update();
  }  
  
  if (freqBalance.prevHighLev() > audioThreshold || freqBalance.prevLowLev() > audioThreshold ) {
    int numToMove = round(freqBalance.mix * moveParticlesBetweenCDFSensitivity);
    cf.showNChangingCDF( numToMove );
    if (freqBalance.mix > 0 ) {
      //higher freqs dominate 
      flock.changeNCDF( numToMove , cdf2 );
    } else {
      //lower freqs dominate
      flock.changeNCDF( -numToMove , cdf1 );
    }
  }
  
  //println(freqBalance.level() );
  maxParticleSpeed = map(freqBalance.level() ,
                         0.0,
                         cf.slSpeedAudioComparison.getMax() - cf.slSpeedAudioComparison.getValue(),
                         Particle.minMinSpeed,
                         Particle.maxMaxSpeed);  
  if (maxParticleSpeed > Particle.maxMaxSpeed) {
    maxParticleSpeed = Particle.maxMaxSpeed;
  }
        
  //drawing and flocking
  flock.allTextDraw ();
  if (flocking) {
    flock.allRunFlocking();
  }
  if (iterating) {
    flock.allIterate(); //basically rotation
  }
  
  cameraDist *= cf.getZoom();
  
  if (frameCount % 5 == 0) {  
    cf.updateSliders();
  }
  
  camera(width/2, height/2, cameraDist, 
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
  
  //println(dVdtSensitivity * freqBalance.logdVdt);
}

//capture midi messages and send to midiInput object
void controllerChange(int channel, int number, int value) {
  midiInput.controllerChange(channel,number,value);
}

void stop()
{
  freqBalance.close();
  fft.close(); 
  super.stop();
}

void play () {
  loop();
}

void pause () {
  if (looping) {
    loop();
  } else {
    noLoop();
  }
}

void myStop() {
  noLoop();
}
