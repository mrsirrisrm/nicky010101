PolyList polys = new PolyList();
PolyList oldPolys = new PolyList();


void setup() {
  size(700,700,P2D);
  smooth();
  
  polys.polys.add(new Poly(350));
}

void draw() {
  background(255);
  
  strokeWeight( 3.0 ); 
  stroke(60);
  
  polys.drawAll();
  polys.iterate();
  
  fill(0,0,180);
  rect(0,0,20,20);
  fill(0,180,0);
  rect(20,0,20,20);
}

void mouseClicked() {
  //println(mouseX, mouseY);
  if (mouseX < 20 && mouseY < 20) {
    polys.flyApart();
    return;
  } 
  
  if (mouseX < 2*20 && mouseY < 20) {
    println("to file");
    polys.toFile("chunks.txt");
    return;
  }   
  
  if (mouseButton == LEFT) {
    for (Poly p : polys.polys) {
      if (p.contains(mouseX,mouseY)) {
        polys.splitPoly(p,mouseX,mouseY);
        break;
      }
    }  
  } else {
    if (oldPolys.polys.size() > 0 ) {
       polys.copyList(oldPolys);
    }
  }
}
