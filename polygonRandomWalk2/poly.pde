import java.awt.Polygon;
import java.awt.Point;
import java.util.Arrays;
import java.util.Comparator;
import java.util.Collections;

class Poly extends Polygon {
  
  color tint;
  PVector vel = new PVector(0,0);
  PVector pos = new PVector(0,0);
  
  Poly () {
    tint = randColor();  
  }
  
  Poly (float radius) {
    tint = randColor();
    int np = 360;
    for (int i = 0; i < np; i++) {
      addPoint(round(width  / 2 + radius * cos(2.0 * i * PI / np)),
               round(height / 2 + radius * sin(2.0 * i * PI / np)));
    }
  }
  
  Poly (Polygon aPoly) {
    tint = randColor();
    for (int i = 0; i < aPoly.npoints; i++) {
      addPoint(aPoly.xpoints[i],aPoly.ypoints[i]);
    }
  }
  
  private color randColor() {
    return color(round(random(255)),round(random(255)),round(random(255)));
  }
  
  public void drawPoints() {
    fill(tint);
    beginShape();
    for (int i = 0; i < npoints; i++) {
      vertex(xpoints[i] + pos.x,ypoints[i] + pos.y);  
    }
    endShape();
  }
  
  public int area() {
    float sum_but_no_result = 0;

    for (int i = 0; i< (npoints-1); i++) {
      sum_but_no_result += xpoints[i]*ypoints[i+1] + ypoints[i]*xpoints[i+1];
    }
    sum_but_no_result += xpoints[npoints-1]*ypoints[0] + ypoints[npoints-1]*xpoints[0];

    float sum = (float)Math.abs(sum_but_no_result) / 2.0f;
    return round(sum);
  }
  
  
  public Poly[] splitRandomWalk() {
    int startInd = round(random(npoints - 1));
    Walk walk;
    
    //keep generating walks until we get one that doesn't self intersect
    do {
      walk = new Walk(xpoints[startInd],ypoints[startInd],this);
    } while (walk.intersects || walk.mps.size() < 10);
    
    float minDist = 99999999;
    int endInd = 0;
    MyPoint lastPoint = walk.mps.get(walk.mps.size() - 1);
    for (int i = 0; i < npoints; i++) {
      if (lastPoint.distSquaredTo(xpoints[i],ypoints[i]) < minDist) {
        endInd = i;
        minDist = lastPoint.distSquaredTo(xpoints[i],ypoints[i]);
      } 
    }
    
    boolean reversed = true;
    if (startInd > endInd) {
      int tmp = startInd;
      startInd = endInd;
      endInd = tmp;
      reversed = !reversed;
    }       

    Poly[] returnPoly = new Poly[2];
    returnPoly[0] = new Poly();
    for (int i = startInd; i < endInd; i++) {
      returnPoly[0].addPoint(xpoints[i],ypoints[i]);
    }
    for (int i = 0; i < walk.mps.size(); i++) {
      if (reversed) {
        returnPoly[0].addPoint(walk.mps.get(walk.mps.size() -1 - i).x,walk.mps.get(walk.mps.size() - 1 - i).y);
      } else {
        returnPoly[0].addPoint(walk.mps.get(i).x,walk.mps.get(i).y);
      }      
    }
    
    returnPoly[1] = new Poly();
    for (int i = 0; i < startInd; i++) {
      returnPoly[1].addPoint(xpoints[i],ypoints[i]);
    }
    for (int i = 0; i < walk.mps.size(); i++) {
      if (reversed) {
        returnPoly[1].addPoint(walk.mps.get(i).x,walk.mps.get(i).y);
      } else {
        returnPoly[1].addPoint(walk.mps.get(walk.mps.size() -1 - i).x,walk.mps.get(walk.mps.size() - 1 - i).y);        
      }
    }
    for (int i = endInd; i < npoints; i++) {
      returnPoly[1].addPoint(xpoints[i],ypoints[i]);
    }
          
    return returnPoly;
  }
  
  
  
  public Poly[] splitRandomWalkFromPoint(int x, int y) {
    Poly[] returnPoly;
    
    Walk walk, walk2;
    
    //keep generating walks until we get one that doesn't self intersect
    do {
        walk = new Walk(x,y,this);
    } while (walk.intersects);
    
    int count = 0;
    do{        
      do {
        walk2 = new Walk(x,y,this,walk);
        if (count++ == 10) return null; //took too many tries, fail
      } while (walk2.intersects);
    } while ((walk.mps.size() + walk2.mps.size()) < 3);
    
    Collections.reverse(walk.mps);
    walk.appendWalk(walk2);

    float minDist = 99999999;
    int startInd = 0;
    MyPoint firstPoint = walk.mps.get(0);
    for (int i = 0; i < npoints; i++) {
      if (firstPoint.distSquaredTo(xpoints[i],ypoints[i]) < minDist) {
        startInd = i;
        minDist = firstPoint.distSquaredTo(xpoints[i],ypoints[i]);
      } 
    }
    minDist = 99999999;
    int endInd = 0;
    MyPoint lastPoint = walk.mps.get(walk.mps.size() - 1);
    for (int i = 0; i < npoints; i++) {
      if (lastPoint.distSquaredTo(xpoints[i],ypoints[i]) < minDist) {
        endInd = i;
        minDist = lastPoint.distSquaredTo(xpoints[i],ypoints[i]);
      } 
    }
            
    //boolean reversed = true;
    if (startInd > endInd) {
      int tmp = startInd;
      startInd = endInd;
      endInd = tmp;
      Collections.reverse(walk.mps);
    }

    returnPoly = new Poly[2];
    
    returnPoly[0] = new Poly();
    returnPoly[0].pos.x = pos.x;
    returnPoly[0].pos.y = pos.y;
    returnPoly[0].vel.x = vel.x;
    returnPoly[0].vel.y = vel.y;    
    for (int i = startInd; i < endInd; i++) {
      returnPoly[0].addPoint(xpoints[i],ypoints[i]);
    }
    for (int i = walk.mps.size() - 1; i >= 0; i--) {
      returnPoly[0].addPoint(walk.mps.get(i).x,walk.mps.get(i).y);
    }
    
    returnPoly[1] = new Poly();
    returnPoly[1].pos.x = pos.x;
    returnPoly[1].pos.y = pos.y;
    returnPoly[1].vel.x = vel.x;
    returnPoly[1].vel.y = vel.y;
    for (int i = 0; i < startInd; i++) {
      returnPoly[1].addPoint(xpoints[i],ypoints[i]);
    }
    for (int i = 0; i < walk.mps.size(); i++) {
      returnPoly[1].addPoint(walk.mps.get(i).x,walk.mps.get(i).y);
    }
    for (int i = endInd; i < npoints; i++) {
      returnPoly[1].addPoint(xpoints[i],ypoints[i]);
    }
          
    return returnPoly;
  }
  
  public PVector center () {
    PVector center = new PVector(0,0);
    for (int i = 0; i < npoints; i++) {
      center.x += xpoints[i];
      center.y += ypoints[i];
    }
    center.div(npoints);
    return center;
  }
  
  public void iterate() {
    pos.x += vel.x;
    pos.y += vel.y;    
    vel.mult(0.98); //some drag
  }
  
  public String toString() {
    String s = "";    
    for (int i = 0; i < npoints; i++) {
      s += str(xpoints[i]) + "," + str(ypoints[i]) + ";";
    }
    return s;
  } 

}

class PolyComparator implements Comparator {
    int compare(Object o1, Object o2) {
    int d1 = ((Poly) o1).npoints;
    int d2 = ((Poly) o2).npoints;
    if (d1 == d2) {
      return 0; 
    } else if (d1 > d2) {
      return 1;
    } else return -1;
  }  
}
