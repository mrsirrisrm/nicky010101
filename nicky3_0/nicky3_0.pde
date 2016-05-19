import punktiert.math.Vec;
import punktiert.physics.*;
import peasy.PeasyCam;

//world objects
MyPhysics[] physics;
PeasyCam cam;
BConstantForce[] gravtitys;
BConstantForce[] toCenters;

PImage img0;
PImage img1;


//number of particles in the scene
int amount = 500;

public void setup() {
  size(800, 600, P3D);
  fill(0, 255);
  noStroke();
  
  cam = new PeasyCam(this, 800);

  //load the stamp images  
  String path = "../../resources/";
  print("load");
  img0 = loadImage(path + "NICOLA_STEMPEL_AKTUELL_GROESSE-1_0_crop.png");
  img1 = loadImage(path + "NICOLA_STEMPEL_AKTUELL_GROESSE-1_1_crop.png");
  print("loaded");
  
  physics = new MyPhysics[3];
  gravtitys = new BConstantForce[physics.length];
  for (int j = 0; j < physics.length; j++) {
    //VPhysics ( Vec min, Vec max)
    physics[j] = new MyPhysics(new Vec(0,0), new Vec(width, height), j * 100.0);
    physics[j].physics.setfriction(.05f);    
    
    gravtitys[j] = new BConstantForce(new Vec());
    gravtitys[j].setForce(new Vec(width*.5f, 99999).normalizeTo(.03f));
    physics[j].physics.addBehavior(gravtitys[j]);
  
    for (int i = 0; i < amount; i++) {
      float rad = 5;
      Vec pos = new Vec (random(rad, width-rad), random(rad, height-rad));
      float weight = rad;
      //create particle (Vec pos, mass, radius)
      MyParticle particle = new MyParticle(pos, weight, rad, random(1000) < 500);
      //add Collision Behavior
      particle.addBehavior(new BCollision().setLimit(.04));
      //add particle to world
      physics[j].physics.addParticle(particle);
    }
  }
}

public void draw() {
  background(255);
  
  for (MyPhysics pp: physics) {
    pp.physics.update();
  }
  
  //set Force related to mousePos and limit the length to .05
  //for (BConstantForce f: forces) {
  //  f.setForce(new Vec(width*.5f-mouseX, height*.5f-mouseY).normalizeTo(.03f));
  //}
  
  pushMatrix();
  translate(-400,-400);
  for (MyPhysics pp: physics) {
    for (VParticle p: pp.physics.particles) {
      //ellipse(p.x, p.y, p.getRadius()*2, p.getRadius()*2);
      MyParticle mp = (MyParticle)p; 
      imgDraw(p.x,p.y,pp.z,0,mp.isOne);
    }
  }
  popMatrix();
}
  
  
public void imgDraw (float x, float y, float z, float rotation, boolean isOne) {
  tint(0);
  pushMatrix();
    
  translate( width / 2 + (x - width / 2) , height / 2 + (y - height / 2), z); 
  rotate( rotation );
  
  float scale = 0.2;
  if (isOne) {
    image(img1, 0, 0, imgWidth(isOne)*scale , imgHeight(isOne)*scale );
  } else {
    image(img0, 0, 0, imgWidth(isOne)*scale , imgHeight(isOne)*scale );
  }
  
  popMatrix();
}

float imgWidth(boolean isOne) {
  return isOne ? img1.width : img0.width;
}

float imgHeight(boolean isOne) {
  return isOne ? img1.height : img0.height;  
}
  