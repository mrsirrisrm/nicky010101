Flock flock;

boolean iterating = true;
boolean flocking = true;

float maxParticleSpeed = 2.8;
float separationForce = 3.0; 
float alignmentForce = 2.0;    
float cohesionForce = 2.0;
ArrayList<HomeForce> homeForces = new ArrayList<HomeForce>();
float freeSpeedModifier = 0.3;

final float imageScaling = 1.0;
final float forceMax = 6.0;

final String frameOutputDir = "/Users/martin/Movies/pfNicky2.0/";
final int makeNthFrameToPNG = 0; //0 for no video
int firstVideoFrame = -1;
int lastVideoFrame = 9000;
final int videoOversample = 1;
int videoPNGCount = 0;
final float targetVideoFrameRate = 25.0;

boolean shutdownCalled = false;

boolean fullDraw = true;
boolean useMiniFlocks = false;

float motionSmoothing = 0.05;

PImage img0;
PImage img1;

PImage img0HD;
PImage img1HD;

Random randForInts = new Random();

//-----------------------------------------------------------------


void setup () {
  size(200, 200, FX2D);
  surface.setResizable(true);
  //surface.setSize(round(0.66*1920), round(0.66*1080));
  //surface.setSize(round(0.66*1920), round(0.66*1080));
  surface.setSize(round(0.5*1920), round(0.5*1080));  
  randomSeed(0);
  noiseSeed(0);  
  background(255);
  imageMode(CENTER); 
  fill(255);
  
  //add more homeForces than we will need
  while (homeForces.size() < 32) {
    homeForces.add(new HomeForce());
  }
  
  //load the stamp images  
  String path = "../../resources/";
  img0 = loadImage(path + "NICOLA_STEMPEL_AKTUELL_GROESSE-1_0_crop.png");
  img1 = loadImage(path + "NICOLA_STEMPEL_AKTUELL_GROESSE-1_1_crop.png");
  img0HD = loadImage(path + "NICOLA_STEMPEL_AKTUELL_GROESSE-1_0_crop HD.png");
  img1HD = loadImage(path + "NICOLA_STEMPEL_AKTUELL_GROESSE-1_1_crop HD.png");
  if (img0 == null || img1 == null) {
    println("Unable to load stamp images. Check resources directory location and contents");    
  }  
  
  int COUNT = 1000;
  flock = new Flock(COUNT); 
  flock.setupRandomDistributionCenteredOn(width / 2 , round(float(height) * 0.2) , round(float(width) * 0.7 / 2.0));
}; //<>//



void draw () {
  background(255);
  
  if (videoOversample == 1 || (frameCount % videoOversample) == 1) {    
    if (flocking) {
      if (useMiniFlocks) {        
        flock.assignMiniFlocks();
        flock.calcMiniFlocksForcesAndMotion();
      } else {
        flock.allRunFlocking();
      }
       
      wind();
    }
    
    if (iterating) {
      flock.allRotate(); 
    }          
  }
 
  //END calcs, start DRAWING
  flock.allDraw( videoOversample , (frameCount - 1) % videoOversample );
  
  if (makeNthFrameToPNG != 0) { 
    if ((frameCount > 1) && (frameCount - 2) % makeNthFrameToPNG == 0) {
      if (frameCount - 2 >= firstVideoFrame && frameCount - 2 <= lastVideoFrame) {    
        String frameNum = String.format("%05d", videoPNGCount); 
        saveFrame(frameOutputDir + "frame_" + frameNum + ".png");
        videoPNGCount++;
      }
    }
  } 
  
  fill(0);
  text("" + round(frameRate), width - 50, height - 50);
}