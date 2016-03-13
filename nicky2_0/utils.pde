class HomeForce {
  float x = 0,y = 0,force = 0,radius = 1;  
}

class DistTuple {
  int ind;
  float dist;
  DistTuple(int i, float d) {
    ind = i;
    dist = d;
  }
}

class DistTupleComparator implements Comparator {
  int compare(Object o1, Object o2) {
    float d1 = ((DistTuple) o1).dist;
    float d2 = ((DistTuple) o2).dist;
    if (d1 == d2) {
      return 0; 
    } else if (d1 > d2) {
      return 1;
    } else return -1;
  }
}

float imgWidth(boolean isOne) {
  if (isOne) {
    return img1.width * Flock.imgScaleBy;
  } else {
    return img0.width * Flock.imgScaleBy;
  }
}

float imgHeight(boolean isOne) {
  if (isOne) {
    return img1.height * Flock.imgScaleBy;
  } else {
    return img0.height * Flock.imgScaleBy;
  }  
}

public void dotDraw(float x, float y) {
    //tint(tint);
    pushMatrix();
    translate( x, y); 
    point(0,0);    
    popMatrix(); 
}

public void textDraw (float x, float y, float rotation) {
  //tint(tint);
  pushMatrix();
  translate( x, y); 
  rotate(rotation);               
  //text( this.getText() , 0 , 0 ); 
  popMatrix();
}

public void imgDraw (float x, float y, float dx, float dy, float rotation, float drotation, boolean isOne, color tint, int videoOversample, int thisSample) {
  tint(tint);
  pushMatrix();
  if (videoOversample == 1 ) {
    translate( width / 2 + (x - width / 2) , height / 2 + (y - height / 2)); 
    rotate( rotation );
  } else {
    //to oversample video, rewind the position and rotation using the vel, multiplied by the appropriate oversampling factor
    float oversamplingFactor = float(videoOversample - thisSample) / float(videoOversample); 
    translate( width  / 2 + (x - dx * oversamplingFactor - width  / 2), 
               height / 2 + (y - dy * oversamplingFactor - height / 2)); 
    rotate(rotation - drotation * oversamplingFactor);               
  }
  
  if (isOne) {
    image(img1, 0, 0, imgWidth(isOne) , imgHeight(isOne) );
  } else {
    image(img0, 0, 0, imgWidth(isOne) , imgHeight(isOne) );
  }
  
  popMatrix();
}

float maxSpeed() {
  return maxParticleSpeed * freeSpeedModifier;
}

float distanceToAppletCenter(float x, float y) {
  float dx = x - width  / 2;
  float dy = y - height / 2;
  return sqrt(dx * dx + dy * dy);
}

void drawPolysFromFile(String fileName, float maxInitialDistFromCenter) {  
  stroke(50);
  strokeWeight(2.0 );
  
  String[] ss = loadStrings(fileName );
  //for (String s : ss) {
  for (int k = 0; k < ss.length; k++) {
    String s = ss[k];
    String[] points = split(s,";");
    int[] xs = new int[points.length - 1];
    int[] ys = new int[points.length - 1];
    for (int i = 0; i < xs.length; i++) {
      if (points[i].length() > 0) {
        String[] xy = split(points[i],",");
        if (xy.length == 2) {       
          xs[i] = round(width  / 2 + 2.0 * (float(xy[0]) - 0.5) * maxInitialDistFromCenter);
          ys[i] = round(height / 2 + 2.0 * (float(xy[1]) - 0.5) * maxInitialDistFromCenter);
        }
      }
    }
       
    if (xs.length > 2) {
      //println(xs);
      for (int i = 1; i < xs.length; i++) {
        //if (i == 1) {
        line(xs[i - 1], ys[i - 1], xs[i], ys[i]);
      }
    } 
  }

  stroke(255,0,0);
  strokeWeight(3.0);

  for (int k = 6; k < 7; k++) {
    String s = ss[k];
    String[] points = split(s,";");
    int[] xs = new int[points.length - 1];
    int[] ys = new int[points.length - 1];
    for (int i = 0; i < xs.length; i++) {
      if (points[i].length() > 0) {
        String[] xy = split(points[i],",");
        if (xy.length == 2) {       
          xs[i] = round(width  / 2 + 2.0 * (float(xy[0]) - 0.5) * maxInitialDistFromCenter);
          ys[i] = round(height / 2 + 2.0 * (float(xy[1]) - 0.5) * maxInitialDistFromCenter);
        }
      }
    }
       
    if (xs.length > 2) {
      //println(xs);
      for (int i = 1; i < xs.length; i++) {
        //if (i == 1) {
        line(xs[i - 1], ys[i - 1], xs[i], ys[i]);
      }
    } 
  }  
}