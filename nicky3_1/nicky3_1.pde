import fisica.*;
import peasy.PeasyCam;
import java.util.List;
import processing.video.*;
//Movie movie;

boolean slow = false;
static final boolean threaded = true;
static final int worldCount = 3;
final float[] attractorXs = {10.f/12.f, 1.f/12.f, 8.f/12.f};
final color background = color(0, 255, 0), 
  background2 = color(0, 255, 0, 40);
final int w0 = 800, h0 = 400;

final int[] bodyCounts = {700, 800, 500};
final float[] xx = //{0, -100.f / w0, 0};
  {170.f / w0, 165.f / w0, 200.f / w0};
final float[] yy = //{0.f/h0, 0.f/h0, -30.f/h0};//
  { 140.f / h0, 130.f / h0, 120.f / h0 };
final float[] zz = //{80, -30, -150};
  {-0, -40, -120}; 



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

  cam = new PeasyCam(this, 400);
  Fisica.init(this);

  while (worlds.size() < worldCount) {
    World world = new World(w0, h0, 
      attractorXs[worlds.size()] * w0, 
      bodyCounts[worlds.size()]);
    worlds.add(world);    
  }

  if (threaded) {
    //noLoop();
    //doCalcs();
  }

  //frameRate(20);  
  //println(width,height);
  background(background);
}

void draw() {  
  //background(background);
  noStroke();
  fill(background2);
  pushMatrix();
  translate(0,0,-130);
  rect(-width/2, -height/2, width, height);
  popMatrix();

  //image(movie, 0, 0);  

  for (int i = worlds.size() - 1; i >= 0; i--) {
    pushMatrix();
    translate(-width/2 + xx[i] * width, -height/2 + yy[i] * height, zz[i]);
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
    while (!allThreadsFinished()) {
      try {
        Thread.sleep(1);
      } 
      catch(Exception e) {
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
  for (World world : worlds) {
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
  try {
    Text t = new Text(random(1000) < 500);
    t.setPosition(w0/2 + -200 + 400*noise(frameCount * 0.03, index), 
      -h0);
    t.setRotation(random(-1, 1));
    t.setFill(255);
    t.setNoStroke();
    t.setRestitution(0.56);
    world.add(t);
  } 
  catch(Exception e) {
  }
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

void keyPressed() {
  if (key == 'p') {
    if (isLooping()) {
      noLoop();
    } else {
      loop();
    }
  }
  
  if (key == 's') {
    slow = !slow;
  }
}