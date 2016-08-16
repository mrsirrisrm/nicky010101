import fisica.*;
import peasy.PeasyCam;
import java.util.List;
import processing.video.*;
//Movie movie;

static final boolean threaded = true;
static final int worldCount = 3;
final float[] attractorXs = {500.f, 50.f, 400.f};
final color background = color(0,255,0);

final int[] bodyCounts = {700,900,500};
final float[] xx = {0, -100, 0};
final float[] yy = {50, 50, -30};
final float[] zz = {80, -30, -150};

PeasyCam cam;
List<World> worlds = new ArrayList<World>();

void setup(){
  size(600, 400, P3D);
  //fullScreen(P3D);
  smooth();
  //randomSeed(0);
  //hint(DISABLE_DEPTH_TEST);
  
  //movie = new Movie(this, "/Users/martin/Movies/gravityWaves3D1.mov");
  //movie.play();

  cam = new PeasyCam(this, 400);
  Fisica.init(this);

  while (worlds.size() < worldCount) {
    World world = new World(this, 
      attractorXs[worlds.size()],
      bodyCounts[worlds.size()]);
    worlds.add(world);    
  }
  
  if (threaded) {
    //noLoop();
    //doCalcs();
  }
  
  //frameRate(20);
}

void draw() {  
  background(background);
  //image(movie, 0, 0);  
  
  for (int i = worlds.size() - 1; i >= 0; i--) {
    pushMatrix();
    translate(-width/2 + xx[i], -height/2 + yy[i], zz[i]);
    if (!worlds.get(i).threadActive) {
      worlds.get(i).draw(this);    
    }
    popMatrix();
  }
  
  fill(0);
  stroke(0);
  //rect(-width/2,-height/2,20,height);
  //rect(width / 2 - 20,-height/2,20,height);

  
  doCalcs();
  
  if (threaded) {
   while(!allThreadsFinished()) {
     try {
       Thread.sleep(1);
     } catch(Exception e) {
     }
   }  
  }     
}

void doCalcs() {  
  for (int i = 0; i < worlds.size(); i++) {
    worlds.get(i).threadActive = true;
  }
  
  for (int i = 0; i < worlds.size(); i++) {
    if (threaded) {       
      thread("worldStep" + i);
    } else {
      worlds.get(i).step(i);
    }
  }
}

boolean allThreadsFinished() {
  for (World world: worlds) {
    if (world.threadActive) {
      return false;
    }
  }
  
  return true;
}

void movieEvent(Movie m) {
  m.read();
}

void createNewBox(FWorld world, int index) {
  Text t = new Text(random(1000) < 500);
  t.setPosition(width/2 + -200 + 400*noise(frameCount * 0.03, index), -height);
  t.setRotation(random(-1, 1));
  t.setFill(255);
  t.setNoStroke();
  t.setRestitution(0.56);
  world.add(t);
}

void worldStep0() {
  worlds.get(0).step(0);  
}

void worldStep1() {
  worlds.get(1).step(1);
}

void worldStep2() {
  worlds.get(2).step(2);
}