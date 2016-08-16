import fisica.*;
import peasy.PeasyCam;
import java.util.List;

PeasyCam cam;
List<FWorld> worlds = new ArrayList<FWorld>();

void setup(){
  size(600, 400, P3D);
  smooth();
  //hint(DISABLE_DEPTH_TEST);

  cam = new PeasyCam(this, 400);
  Fisica.init(this);

  while (worlds.size() < 3) {
    FWorld world = new FWorld();
    worlds.add(world);
    world.setEdges(this, color(0,0,0,0));
    world.remove(world.top);
    world.setGravity(0, 500);
  }
}

void draw() {
  background(255);

  for (FWorld world: worlds) {
    if (world.getBodyCount() < 400 && random(1000) < 600) {
      createNewBox(world);
    }
    
    wind(world);
    world.step();
    
    List<FBody> bodies = world.getBodies();
    for (FBody body: bodies) {
      if (body instanceof Text && random(10000) < 5) {
        world.removeBody(body);
      }
    }
  }
  
  for (int i = worlds.size() - 1; i >= 0; i--) {
    pushMatrix();
    translate(-300,-200,-i * 100.);
    worlds.get(i).draw(this);
    popMatrix();
  }
}

void createNewBox(FWorld world) {
  Text t = new Text(random(1000) < 500);
  t.setPosition(width/2 + -100 + 200*noise(frameCount * 0.03,worlds.indexOf(world)), height*0.1);
  t.setRotation(random(-1, 1));
  t.setFill(255);
  t.setNoStroke();
  t.setRestitution(0.5);
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