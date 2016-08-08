import fisica.*;
import peasy.PeasyCam;
import java.util.List;
import processing.video.*;
//Movie movie;

static final boolean threaded = true;
static final int worldCount = 3;

PeasyCam cam;
List<World> worlds = new ArrayList<World>();
//List<List<Attractor>> attractors = new ArrayList<List<Attractor>>();

float[] attractorXs = {500.f, 50.f, 400.f};

void setup(){
  size(600, 400, P3D);
  //fullScreen(P3D);
  smooth();
  randomSeed(0);
  //hint(DISABLE_DEPTH_TEST);
  
  //movie = new Movie(this, "/Users/martin/Movies/gravityWaves3D1.mov");
  //movie.play();

  cam = new PeasyCam(this, 400);
  Fisica.init(this);

  while (worlds.size() < 3) {
    World world = new World(this, attractorXs[worlds.size()]);
    worlds.add(world);    
  }
  
  if (threaded) {
    //noLoop();
    //doCalcs();
  }
}

void draw() {
  //print("d");
  background(0,255,0);
  //image(movie, 0, 0);  
  
  for (int i = worlds.size() - 1; i >= 0; i--) {
    pushMatrix();
    translate(-300,-200,-i * 100.);
    if (!worlds.get(i).threadActive) {
      worlds.get(i).draw(this);    
    }
    popMatrix();
  }
  
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
      worldStep(worlds.get(i), i);
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

void worldStep(World world, int index) {
  if (world.getBodyCount() < 600 && random(1000) < 300) {
    createNewBox(world, index);
  }    
  
  world.wind(index);
  
  try {
    world.step();
  } catch(Exception e) {
  }
  
  for (FBody body: (List<FBody>)world.getBodies()) {
    if (!(body instanceof Text)) continue;
    
    if (frameCount > 200 && random(10000) < 5) {
      world.removeBody(body);
      continue;
    }

    for (Attractor att: world.attractors) {
      att.applyToBody(body);
    }    
  }
  
  world.threadActive = false;
  
  if (threaded && allThreadsFinished()) {     
    //redraw();
  }
}

void worldStep0() {
  worldStep(worlds.get(0), 0);  
}

void worldStep1() {
  worldStep(worlds.get(1), 1);
}

void worldStep2() {
  worldStep(worlds.get(2), 2);
}