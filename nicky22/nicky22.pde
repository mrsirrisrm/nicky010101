int inputDataMode = 0; //0 : normal, 1 : write moves to file, 2 : read moves from file. NB 2 can be set back to 0 when the file ends
final int makeNthFrameToPNG = 0; //0 : no video, 1 : write video
final String videoOutputDir = System.getProperty("user.home") + "/Movies/processingFrames"; //set to some directory in your home folder


Flock flock;
ControlFrame cf;
MidiInput midiInput;
CDF cdf1, cdf2;
FreqBalance freqBalance;
FFTAnalysis fft;
InputData inputData;
PImage img0; //stamp image
PImage img1; //stamp image

final float zScale = 0.25;
final float separationForce = 2.2; 
final float alignmentForce = 2.0;    
final float cohesionForce = 2.0;
final float forceMax = 4.5;
final boolean useFFT = true;
final boolean showPeakiness = false;
final boolean showDVDT = false;
final float moveParticlesBetweenCDFSensitivity = 6.0;
final float targetVideoFrameRate = 25.0;

int videoPNGCount = 0;
String outString = "";
boolean shutdownCalled = false;
//-----------------------------------------------------------------


void setup () {
  randomSeed(0);
  noiseSeed(0);
  prepareExitHandler();  
  size(1200, 800, P3D); //3D renderer
  if (frame != null) {
    frame.setResizable(true);
    //frame.setUndecorated(true);
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
  
  inputData = new InputData();
  if (inputDataMode == 2) {
    inputData.loadInput( "recordedMoves.txt" );
  }
    
  cdf1 = new CDF();
  cdf2 = new CDF();
    
  //set up cdf functions
  cdf1.setupPDF2DFromImageFile("heap.png");
  cdf2.setupPDF2DFromImageFile("cross.png");
  
  //make the flock
  flock = new Flock( 1200 , 1200 ,  cdf1 );
  
  cf = addControlFrame("control", 700, 600);
   
  //setup midi controller
  midiInput = new MidiInput(this);
  midiInput.plugControllerSlider(0,cf.slSplitFreq);
  if (useFFT) {
    midiInput.plugControllerSlider(1,cf.slSpectralPeakinessSensitivity);
  }
  midiInput.plugControllerSlider(2,cf.sldVdtSensitivity);
  midiInput.plugControllerSlider(3,cf.slHomeForce);
  midiInput.plugControllerSlider(4,cf.slParticleSpeed);
  midiInput.plugControllerSlider(5,cf.slAudioThreshold);
  midiInput.plugControllerSlider(6,cf.slZoom);
  
  midiInput.plugControllerSlider(7,cf.slNumberInCDF2); //offscreen
  
  //midiInput.plugControllerKnob(18,cf.slAudioSplitFreq);
  //midiInput.plugControllerKnob(19,cf.sldVdtSensitivity);
  //midiInput.plugControllerKnob(20,cf.slSpectralPeakinessSensitivity);
  //midiInput.plugControllerKnob(23,cf.slNumberInCDF2);

  //audio input analysis 
  freqBalance = new FreqBalance( this, cf.getSplitFreq() );
  if (useFFT) {
    fft = new FFTAnalysis( this );
  }

  println("width " , width);
  println("height ", height);
  
  long allocated = Runtime.getRuntime().totalMemory();
  long free = Runtime.getRuntime().freeMemory();
  long maximum = Runtime.getRuntime().maxMemory();
  
  println("allocated mem ", allocated/1024/1024);
  println("free mem ", free/1024/1024);
  println("maximum mem ", maximum/1024/1024);
  
  //wait before start drawing to give all frames a chance to initialise
  //int m = millis();
  //while (millis() < m + 2000) {
  //  print("");
  //}
  while (cf.frameCount < 2) {
    print("");
  }  
};



void draw () {
  background(0);
    
  if (inputDataMode == 2) {
    inputData.readInputLine();
    println("input line ", inputData.currentInputLine, " approx time (s)", float(frameCount) / targetVideoFrameRate );
  } else {
    //to get mic input 
    freqBalance.update();
    
    if (frameCount % FFTAnalysis.updatePerFrames == 0 && useFFT) {
      thread("doFFTUpdateThread");//fft.update();
    }  
    
    inputData.maxParticleSpeed = map(freqBalance.level(),
                                     0.0,
                                     1.0,
                                     cf.slParticleSpeed.getMin(),
                                     cf.slParticleSpeed.getValue());
    if (inputData.maxParticleSpeed > cf.slParticleSpeed.getMax()) {
      println("setting maxMaxSpeed ", cf.slParticleSpeed.getMax());
      inputData.maxParticleSpeed = cf.slParticleSpeed.getMax();
    }
    
    inputData.prevLowLev = freqBalance.prevLowLev();
    inputData.prevHighLev = freqBalance.prevHighLev();
    inputData.mix = freqBalance.mix;
    if (useFFT) {
      inputData.peakiness = fft.previousPeakiness[0];
    }
    inputData.logLev = freqBalance.logLev;
    inputData.logdVdt = freqBalance.logdVdt;
    inputData.dLevdtSmoothed = freqBalance.dLevdtSmoothed;
                     
    if (inputDataMode == 1) {
      outString += inputData.output();
    }                     
  }
  inputData.deriveValues();

  int numToMove = flock.runInputStep(inputData); //THIS IS THE MAIN FUNCTION
  cf.showNChangingCDF( numToMove );    
      
          
  if (frameCount % 5 == 0) {  
    cf.updateSlidersAndText(frameRate);    
  }
  
  camera(width/2, height/2, inputData.smoothedSmoothedCameraDist, 
          width/2, height/2, 0, 
          0.0, 1.0, 0.0);
          
  if (makeNthFrameToPNG != 0) { 
    if (frameCount > 1 && frameCount % makeNthFrameToPNG == 0) {    
      saveFrame(videoOutputDir + "/frame_" + String.format("%04d", videoPNGCount) + ".png");
      videoPNGCount++;
    }
  }  //<>//
}

//capture midi messages and send to midiInput object
void controllerChange(int channel, int number, int value) {
  midiInput.controllerChange(channel,number,value);
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

void prepareExitHandler () {
  Runtime.getRuntime().addShutdownHook(new Thread(new Runnable() {
    public void run () {
      if (!shutdownCalled) {
        shutdownCalled = true;
        
//        println(outString);
//        if (inputDataMode == 1) {
//          String[] list = split(outString, ';');
//          saveStrings("recordedMoves.txt", list);
//        }
    
        freqBalance.close();
        if (useFFT) {
          fft.close();
        }
      }
    }
  }));
}

void writeOutputMoves() {
  //println(outString);
  String[] list = split(outString, ';');
  saveStrings("recordedMoves.txt", list);
}
