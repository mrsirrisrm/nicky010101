Flock flock;
ControlFrame cf;
InputData inputData;

boolean iterating = true;
boolean flocking = true;
boolean moveChunks = true;

float maxParticleSpeed = 2.8;
float separationForce = 3.0; 
float alignmentForce = 2.0;    
float cohesionForce = 2.0;
float antiGridForce = 5.0;
float antiGridForce2 = 1.0;
ArrayList<HomeForce> homeForces = new ArrayList<HomeForce>();
float gridSpeedModifier = 0.0;
final float initialTransitionSpeedModifier = 0.002;
float transitionSpeedModifier = initialTransitionSpeedModifier;
float freeSpeedModifier = 0.3;
float disorderingSpeedModifier = 0.6;

final float imageScaling = 1.0;

//float audioThreshold = 0.03;
final float forceMax = 6.0;
float maxInitialDistFromCenter = 0;

final String chunksFile = "/Users/martin/Pictures/nicky/NickyChunkIndices.dat";
Sequence sequence;// = new Sequence(sequenceFile);

final String frameOutputDir = "/Users/martin/Movies/pfAdamB1h/";
final String recordedMovesFile = "recordedMoves.txt";
final int makeNthFrameToPNG = 0; //0 for no video
int firstVideoFrame = -1;
int lastVideoFrame = 9000;
final int videoOversample = 1;
int videoPNGCount = 0;
final float targetVideoFrameRate = 25.0;

boolean shutdownCalled = false;

String positionsFile = "/Users/martin/Movies/processingPositionsAdam/outputPositionsB2.dat";
int inputPositionsMode = 0; //0 : nothing  1 : write positions to file  2 : read positions from file
int inputPositionsStartFromFrame = 0;  //   <--------------------------------*************
boolean fullDraw = true;
boolean useMiniFlocks = true;
float disorderingRadius;
float disorderingInverseRate = 0;

float motionSmoothing = 0.05;

PImage img0;
PImage img1;

PImage img0HD;
PImage img1HD;

Random randForInts = new Random();

//-----------------------------------------------------------------


void setup () {
  randomSeed(0);
  noiseSeed(0);  
  size(1920, 1080, P3D);
  //size(round(0.66*1920), round(0.66*1080), P3D);
  //size(round(0.5*1920), round(0.5*1080), P3D); 
  if (frame != null) {
    frame.setResizable(false);
  }
  smooth();
  background(255);
  imageMode(CENTER); 
  fill(255);
  
  //add more homeForces than we will need
  while (homeForces.size() < 32) {
    homeForces.add(new HomeForce());
  }
  
  sequence = new Sequence(dataPath("sequence.txt"));
    
  //load the stamp images  
  String path = "../../resources/";
  img0 = loadImage(path + "NICOLA_STEMPEL_AKTUELL_GROESSE-1_0_crop.png");
  img1 = loadImage(path + "NICOLA_STEMPEL_AKTUELL_GROESSE-1_1_crop.png");
  img0HD = loadImage(path + "NICOLA_STEMPEL_AKTUELL_GROESSE-1_0_crop HD.png");
  img1HD = loadImage(path + "NICOLA_STEMPEL_AKTUELL_GROESSE-1_1_crop HD.png");
  if (img0 == null || img1 == null) {
    println("Unable to load stamp images. Check resources directory location and contents");    
  }  
  texture(img0);
  
  inputData = new InputData();
     
  //int COUNT = 19942; 
  //int COUNT = 9912;
  int COUNT = 3000;  
  flock = new Flock( COUNT , inputPositionsMode, inputPositionsStartFromFrame);
  
  if (inputPositionsMode != 2) {
    maxInitialDistFromCenter = flock.setupPolarGrid(COUNT,0);
    flock.assignChunksFromFile2( chunksFile , maxInitialDistFromCenter * 1.005);
    flock.assignChunkVelocities(0.005);
    flock.tempSetAllBackToGrid();
    disorderingRadius = maxInitialDistFromCenter;
  }

  cf = addControlFrame("control", 400, 200); //<>//
};



void draw () {
  background(255);
  
  if (videoOversample == 1 || (frameCount % videoOversample) == 1) {
    int theFrame = frameCount / videoOversample + inputPositionsStartFromFrame;
    sequence.checkForAction(theFrame);
      
    // eroding particles from chunks
    if (theFrame % 2 == 0) {
      flock.erodeFromChunks();
    }
        
    // DISORDERING
    flock.freeParticlesGreaterThanRadius(disorderingRadius);
    if (disorderingInverseRate > 0) {
      disorderingRadius -= maxInitialDistFromCenter / disorderingInverseRate;
    }
    flock.runStateChangeCountdown();
  
    inputData.deriveValues();                       
              
    if (inputPositionsMode == 2) {
      flock.readPositionsFromFile(frameCount == 1);
    } else {
      if (flocking) {
        if (useMiniFlocks) {
          //if (frameCount % 1 == 0) {
          flock.assignMiniFlocks();
          //}
          flock.calcMiniFlocksForcesAndMotion();
        } else {
          flock.allRunFlocking();
        }
      }
      
      if (iterating) {
        flock.allRotate(); 
      }
      
      if (moveChunks) {
        flock.moveChunks();
      }
      
      //write output positions
      if (inputPositionsMode == 1) {
        flock.writePositionsToFile(theFrame % 8 == 0);
      }
    }
  }
 
  //END calcs, start DRAWING
  flock.allDraw( videoOversample , (frameCount - 1) % videoOversample );
  
  camera(width/2 + inputData.cameraX, height/2 + inputData.cameraY, inputData.smoothedSmoothedCameraDist, 
          width/2 + inputData.cameraX, height/2 + inputData.cameraY, 0, 
          0.0, 1.0, 0.0);      

  if (makeNthFrameToPNG != 0) { 
    if ((frameCount > 1) && (frameCount - 2) % makeNthFrameToPNG == 0) {
      if (frameCount - 2 >= firstVideoFrame && frameCount - 2 <= lastVideoFrame) {    
        String frameNum = String.format("%05d", videoPNGCount); 
        saveFrame(frameOutputDir + "frame_" + frameNum + ".png");
        videoPNGCount++;
      }
    }
  } 
  cf.mainFrameRate = 0.75*cf.mainFrameRate + 0.25*this.frameRate; //show the main PApplet framerate on the control frame, with a little bit of averaging
  cf.mainFrameCount = this.frameCount;  
  cf.statesCounts = new int[5];
  for (int n = 0; n < flock.xs.length; n++) {
    cf.statesCounts[flock.states[n]]++;
  }
}
