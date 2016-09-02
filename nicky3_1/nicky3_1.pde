import fisica.*;
import peasy.PeasyCam;
import java.util.List;
//import processing.video.*;
import ddf.minim.*;
//import ddf.minim.effects.*;
//Movie movie;

long iteration = 0;
boolean slow = true, threaded = false, isWarmup = true;
static final boolean runMainThreaded = true;
static final String soundFile = "160814_digitarch.mp3";
static final int worldCount = 3, warmupSteps = 2000;
final float[] attractorXs = {10.f/12.f, 1.f/12.f, 8.f/12.f};
final color background = color(0, 255, 0), 
  background2 = color(0, 255, 0, 40);
final int[] w0 = {900, 1050, 1200}, h0 = {400, 400, 400};
final boolean[] visibles = {true, true, true};

final int[] bodyCounts = {700, 800, 500};
final float[] xx = //{0, -100.f / w0, 0};
  {240.f / w0[0], 200.f / w0[0], 180.f / w0[0]};
final float[] yy = //{0.f/h0, 0.f/h0, -30.f/h0};//
  {140.f / h0[0], 130.f / h0[0], 120.f / h0[0]};
final float[] zz = //{80, -30, -150};
  {-0, -40, -120};
  
List<Scheme> schemes = new ArrayList<Scheme>();
Scheme scheme;
 

Minim minim;
AudioPlayer audioPlayer;

PeasyCam cam;
List<World> worlds = new ArrayList<World>();

void setup() {
  //size(600, 400, P3D);
  fullScreen(P3D);
  smooth();
  //randomSeed(0);
  //hint(DISABLE_DEPTH_TEST);

  //movie = new Movie(this, "/Users/martin/Movies/gravityWaves3D1.mov");
  //movie.play();

  schemes.add(new Scheme(4,-200,550,55,2500,120,"3 heaps"));
  schemes.add(new Scheme(4,  50,550,55,2500, 60,"flat landscape"));
  scheme = schemes.get(0);
  scheme.activate();

  cam = new PeasyCam(this, 400);
  Fisica.init(this);

  while (worlds.size() < worldCount) {
    int index = worlds.size();
    World world = new World(w0[index], h0[index], 
      attractorXs[index] * w0[index], 
      bodyCounts[index],
      visibles[index]);
    worlds.add(world);    
  }

  //warmup(2000);

  if (threaded) {
    //noLoop();
    //doCalcs();
  }
  
  minim = new Minim(this);
  audioPlayer = minim.loadFile(soundFile, 2048);
  audioPlayer.setGain(-5);
  audioPlayer.loop();

  //frameRate(20);  
  println("w", width, "h", height);
  //background(background);
}

void fade() {
  noStroke();
  fill(background2);
  pushMatrix();
  translate(0,0,-130);
  rect(-width/2, -height/2, width, height);
  popMatrix();
}

void warmupDraw() {
  background(80);
  text("Initializating... " + (int)(((float)iteration / (float)warmupSteps * 100.f)) + "%",0,0);
  
  for (int i = 0; i < 100; i++)
    doCalcs();
  //print("" + ((float)iteration / (float)warmupSteps * 100.f) + "% ");    
      
  if (iteration >= warmupSteps) {
    isWarmup = false;
    threaded = runMainThreaded;
  }
}

void draw() {  
  
  if (isWarmup) {
    warmupDraw();        
    return;
  }
 
  
  background(background);
  //fade();

  //image(movie, 0, 0);  

  for (int i = worlds.size() - 1; i >= 0; i--) {
    if (worlds.get(i).visible) {
      pushMatrix();
      translate(-width/2 + xx[i] * width, -height/2 + yy[i] * height, zz[i]);
      if (!worlds.get(i).threadActive) {
        worlds.get(i).draw(this);
      }
      popMatrix();
    }
  }

  fill(0);
  stroke(0);
  //rect(-width/2,-height/2,20,height);
  //rect(width / 2 - 20,-height/2,20,height);


  doCalcs();

  if (threaded) {
    while (!allThreadsFinished()) {
      try {
        Thread.sleep(1);
      } 
      catch(Exception e) {
      }
    }
  }
  
  if (scheme.shouldChange()) {
    int index = schemes.indexOf(scheme);
    index++;
    scheme = schemes.get(index % schemes.size());
    scheme.activate();
  }
}

void doCalcs() {  
  iteration++;
  
  for (int i = 0; i < worlds.size(); i++) {
    worlds.get(i).threadActive = true;
  }

  for (int i = 0; i < worlds.size(); i++) {
    if (threaded) {       
      thread("worldStep" + i);
    } else {
      worlds.get(i).myStep(i);
    }
  }
}

boolean allThreadsFinished() {
  for (World world : worlds) {
    if (world.threadActive) {
      return false;
    }
  }

  return true;
}

//void movieEvent(Movie m) {
//  m.read();
//}

void worldStep0() {
  worlds.get(0).myStep(0);
}

void worldStep1() {
  worlds.get(1).myStep(1);
}

void worldStep2() {
  worlds.get(2).myStep(2);
}

void keyPressed() {
  if (key == 'p') {
    if (isLooping()) {
      //noLoop();
    } else {
      //loop();
    }
  }
  
  if (key == 's') {
    //slow = !slow;
  }
}