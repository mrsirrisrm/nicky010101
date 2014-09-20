class Walk {
  ArrayList<MyPoint> mps = new ArrayList<MyPoint>();
  boolean intersects = false; 
   
  Walk (int x, int y, Poly poly) {
    mps.add(new MyPoint(x,y));    
  
    while (true) {
      MyPoint mp = mps.get(mps.size() - 1).randomStep();
      
      //check for lines that self-intersect
      for (MyPoint mp0 : mps) {
        if (mp.x == mp0.x && mp.y == mp0.y) {
          intersects = true;
          return;
        }
      } 
      
      //check for exited the polygon
      if (poly.contains(mp)) {
        mps.add(mp);
      } else {
        break; //break out of while
      }
    }
  }

  Walk (int x, int y, Poly poly, Walk walk) {
    mps.add(new MyPoint(x,y));
    mps.get(0).angle = walk.mps.get(0).angle + PI; //so they start in opposite directions
  
    while (true) {
      MyPoint mp = mps.get(mps.size() - 1).randomStep();
      
      //check for lines that self-intersect
      for (MyPoint mp0 : mps) {
        if (mp.x == mp0.x && mp.y == mp0.y) {
          intersects = true;
          return;
        }
      } 
      
      for (MyPoint mp0 : walk.mps) {
        if (mp.x == mp0.x && mp.y == mp0.y) {
          intersects = true;
          return;
        }
      }
      
      //check for exited the polygon
      if (poly.contains(mp)) {
        mps.add(mp);
      } else {
        break; //break out of while
      }
    }
  }
  
  public void appendWalk(Walk walk) {
    for (MyPoint mp : walk.mps) {
      mps.add(mp);
    }
  }
  
}
