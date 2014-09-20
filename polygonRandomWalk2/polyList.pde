class PolyList {
  ArrayList<Poly> polys = new ArrayList<Poly>();
  
  void splitPoly (Poly poly, int x, int y) {
    float areaRatio;
    Poly[] ps;
    do {
      ps = poly.splitRandomWalkFromPoint(x,y);
      if (ps == null) {
        println("failed to find new polygon");
        return; //taken too many tries, fail out
      }
      int a0 = ps[0].area();
      int a1 = ps[1].area();
      areaRatio = float(max(a0,a1)) / float(min(a0,a1));
    } while (areaRatio > 10);
    
    oldPolys.copyList(this);
    
    if (ps[0].area() > ps[1].area()) {
      ps[0].tint = poly.tint;
    } else {
      ps[1].tint = poly.tint;
    }
    polys.add(ps[0]);
    polys.add(ps[1]);
    polys.remove(poly);
    
    Collections.sort(polys, new PolyComparator());
    Collections.reverse(polys);
    
    println(polys.size(), " polygons in list");
  }
  
  void copyList(PolyList fromList) {
    polys.clear();
    for (Poly p : fromList.polys) {
      polys.add(p);
    }
  }
  
  void drawAll() {
    for (Poly poly : polys) {
      poly.drawPoints();
    }        
  }
  
  void flyApart () {
    println("fly apart");
    for (Poly poly : polys) {
      PVector center = poly.center();
      poly.vel.x = (center.x - width  / 2) * 0.01;
      poly.vel.y = (center.y - height / 2) * 0.01;
    }  
  }
  
  void iterate () {
    for (Poly poly : polys) {
      poly.iterate();
    }
  }
  
  void toFile (String filename) {
    String s = "";
    for (Poly poly : polys) {
      s = s + poly.toString() + "§";
    } 
    saveStrings(filename,split(s,'§'));
  }
}
