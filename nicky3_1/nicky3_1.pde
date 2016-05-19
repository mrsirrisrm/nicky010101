import fisica.*;
import peasy.PeasyCam;
import java.util.List;

static final int worldCount = 3;

PeasyCam cam;
List<World> worlds = new ArrayList<World>();
List<List<Attractor>> attractors = new ArrayList<List<Attractor>>();

float[] attractorXs = {500.f, 50.f, 400.f};

void setup(){
  size(600, 400, P3D);
  smooth();
  randomSeed(0);
  //hint(DISABLE_DEPTH_TEST);

  cam = new PeasyCam(this, 400);
  Fisica.init(this);

  while (worlds.size() < 3) {
    World world = new World(this);
    worlds.add(world);    
    
    List<Attractor> attractorList = new ArrayList<Attractor>();
    attractors.add(attractorList);
    attractorList.add(new Attractor(attractorXs[worlds.indexOf(world)], height * 0.7, 3500));
    attractorList.add(new Attractor(attractorXs[worlds.indexOf(world)], height * 0.85, 3500));
    attractorList.add(new Attractor(attractorXs[worlds.indexOf(world)], height * 1.0, 3500));
  }
}

void draw() {
  background(255);

  for (World world: worlds) {
    if (world.getBodyCount() < 600 && random(1000) < 300) {
      createNewBox(world);
    }    
    List<Attractor> attractorList = null;
    if (worlds.indexOf(world) < attractors.size()) {
      attractorList = attractors.get(worlds.indexOf(world));
    }
    
    wind(world);
    world.step();
    
    List<FBody> bodies = world.getBodies();
    for (FBody body: bodies) {
      if (attractorList != null) {
        for (Attractor att: attractorList) {
          att.applyToBody(body);
        }
      }
      
      if (body instanceof Text && frameCount > 200 && random(10000) < 5) {
        world.removeBody(body);
      }
    }
    
    world.updateTintScaleY();
  }
  
  if (frameCount % 10 == 0) {
    //for (int i = 0; i < worlds.get(0).tintScaleY.length; i++) {
    //  print(worlds.get(0).tintScaleY[i] + " ");
    //}
    //println();
  }
  
  for (int i = worlds.size() - 1; i >= 0; i--) {
    pushMatrix();
    translate(-300,-200,-i * 100.);
    worlds.get(i).draw(this);
    popMatrix();
  }
}

void createNewBox(FWorld world) {
  Text t = new Text(random(1000) < 500, worlds.indexOf(world));
  t.setPosition(width/2 + -200 + 400*noise(frameCount * 0.03,worlds.indexOf(world)), -height);
  t.setRotation(random(-1, 1));
  t.setFill(255);
  t.setNoStroke();
  t.setRestitution(0.56);
  world.add(t);
}

void contactStarted(FContact c) {
  
  //if (c.getBody1() == wind) {
  //  wind.removeFromWorld();
  //  wind = null;
  //} else if (c.getBody2() == wind) {
  //  wind.removeFromWorld();
  //  wind = null;
  //}
}