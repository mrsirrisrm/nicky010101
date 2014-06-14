ControlFrame addControlFrame(String theName, int theWidth, int theHeight) {
  Frame f = new Frame(theName);
  ControlFrame p = new ControlFrame(this, theWidth, theHeight);
  f.add(p);
  p.init();
  f.setTitle(theName);
  f.setSize(p.w, p.h);
  f.setLocation(100, 100);
  f.setResizable(false);
  f.setVisible(true);
  return p;
}

// the ControlFrame class extends PApplet, so we 
// are creating a new processing applet inside a
// new frame with a controlP5 object loaded
public class ControlFrame extends PApplet {
  int w, h;
  
  //private final static float rotateOnKeypressByRadians = 0.1;
  private final static float rotateFactor = 0.02;
  private final static int movesPerRotate = 8;  
  private final static float zoomFactor = 0.02;
  private final static int movesPerZoom = 8;
  private ArrayList<Float> rotationMoves = new ArrayList<Float>();
  private ArrayList<Float> zoomMoves = new ArrayList<Float>();  
 
  Slider slYRotation;
  
  CheckBox cbRotating;
  CheckBox cbIterating;
  CheckBox cbChangingShapes;
  CheckBox cbFlocking;

  CheckBox cbVolToSeparation;
  CheckBox cbVolToAlignment;
  CheckBox cbVolToCohesion;
  
  Button btXPLus100;
  Button btXMinus100;
  Button btYPlus100;
  Button btYMinus100;
  Button btZoomIn;
  Button btZoomOut;
  Button btRotateRight;
  Button btRotateLeft;
  
  public float getZoom () {
    if (zoomMoves.size() == 0) {
      return 1.0;
    } else {
      float z = zoomMoves.get(0);
      zoomMoves.remove(0);
      return z;
    }
  }
  
  public float getYRotation () {
    if (rotationMoves.size() == 0) {
      return 0.0;
    } else {
      float r = rotationMoves.get(0);
      rotationMoves.remove(0);
      return r;
    }
  }
  
  public void setup() {
    color cbCol = color(2,119,168);
    size(w, h);
    frameRate(25);
    cp5 = new ControlP5(this);
    
    //general sliders
    cp5.addSlider("X Rotation")
                  .plugTo(parent,"controlXRotation")
                  .setRange(0, 2*PI)
                  .setPosition(10,30);
    slYRotation = cp5.addSlider("Y Rotation")
                  .plugTo(parent,"controlYRotation")
                  .setRange(0, 2*PI)
                  .setPosition(10,50);
    cp5.addSlider("fadeSpeed")
                  .plugTo(parent,"fadeSpeed")
                  .setRange(0, 100)
                  .setPosition(10,70)
                  .setValue(50);
    cp5.addSlider("dissolveProbability")
                  .plugTo(parent,"dissolveProbability")
                  .setRange(0, 1)
                  .setPosition(10,90)
                  .setValue(0.0);
    cp5.addSlider("Z Scale")
                  .plugTo(parent,"zScale")
                  .setRange(0, 1)
                  .setPosition(10,110)
                  .setValue(0.5);
    cp5.addSlider("YRotationSpeed")
                  .plugTo(parent,"YRotationSpeed")
                  .setRange(-0.2, 0.2)
                  .setPosition(10,130)
                  .setValue(0.025);
    
    
    //checkboxes controll item general behaviours
      cbRotating = cp5.addCheckBox("cbRotating")
                .setPosition(10, 170)
                .setColorForeground(color(120))
                .setColorActive(cbCol)
                .setColorLabel(color(255))
                .setSize(20, 15)
                .addItem("rotating", 0);        
      cbIterating = cp5.addCheckBox("cbIterating")
                .setPosition(10, 190)
                .setColorForeground(color(120))
                .setColorActive(cbCol)
                .setColorLabel(color(255))
                .setSize(20, 15)
                .addItem("iterating", 0);
      cbChangingShapes = cp5.addCheckBox("cbChangingShapes")
                .setPosition(10, 210)
                .setColorForeground(color(120))
                .setColorActive(cbCol)
                .setColorLabel(color(255))
                .setSize(20, 15)
                .addItem("changing shapes", 0);   
                
      cbFlocking = cp5.addCheckBox("cbFlocking")
                .setPosition(10, 230)
                .setColorForeground(color(120))
                .setColorActive(cbCol)
                .setColorLabel(color(255))
                .setSize(20, 15)
                .addItem("flocking", 0);                  
   
   //force sliders
    cp5.addSlider("separationForce")
                .plugTo(parent,"separationForce")
                .setRange(0.0, forceMax)
                .setPosition(10,270)
                .setValue(3.0);
    cp5.addSlider("alignmentForce" )
                .plugTo(parent,"alignmentForce" )
                .setRange(0.0, forceMax)
                .setPosition(10,290)
                .setValue(2.0);
    cp5.addSlider("cohesionForce"  )
                .plugTo(parent,"cohesionForce"  )
                .setRange(0.0, forceMax)
                .setPosition(10,310)
                .setValue(2.0);
   
   //force checkbuttons
      cbVolToSeparation = cp5.addCheckBox("cbVolToSeparation")
                .setPosition(220, 270)
                .setColorForeground(color(120))
                .setColorActive(cbCol)
                .setColorLabel(color(255))
                .setSize(20, 15)
                .addItem("V->Separation", 0); 
      cbVolToAlignment = cp5.addCheckBox("cbVolToAlignment")
                .setPosition(220, 290)
                .setColorForeground(color(120))
                .setColorActive(cbCol)
                .setColorLabel(color(255))
                .setSize(20, 15)
                .addItem("V->Alignment", 0); 
      cbVolToCohesion = cp5.addCheckBox("cbVolToCohesion")
                .setPosition(220, 310)
                .setColorForeground(color(120))
                .setColorActive(cbCol)
                .setColorLabel(color(255))
                .setSize(20, 15)
                .addItem("V->Cohesion", 0); 
               
          
     //view control buttons     
     btXPLus100 = cp5.addButton("x+") //move to current screen right (may not be +x!) 
       .setValue(100)
       .setPosition(90,370)
       .setSize(20,20);  
     btXMinus100 = cp5.addButton("x-")//move to current screen left (may not be -x!)
       .setValue(-100)
       .setPosition(50,370)
       .setSize(20,20);        
     btYPlus100 = cp5.addButton("y+")
       .setValue(100)
       .setPosition(70,390)
       .setSize(20,20);  
     btYMinus100 = cp5.addButton("y-")
       .setValue(-100)
       .setPosition(70,350)
       .setSize(20,20);   
  
     btZoomIn = cp5.addButton("z+") 
       .setValue(1.0/1.08)
       .setPosition(150,350)
       .setSize(20,20); 
     btZoomOut = cp5.addButton("z-") 
       .setValue(1.08)
       .setPosition(150,390)
       .setSize(20,20); 
     btRotateRight = cp5.addButton("r+") 
       .setValue(1.08)
       .setPosition(170,370)
       .setSize(20,20);  
     btRotateLeft = cp5.addButton("r-") 
       .setValue(1.08)
       .setPosition(130,370)
       .setSize(20,20); 
  
    updateCheckboxes(); 
  }

  public void updateSliders () {
    while (controlYRotation < 0.0) {
      controlYRotation += 2*PI;  
    }
    slYRotation.setValue(controlYRotation % (2*PI));    
  }

  private void updateCheckboxes () {
   if (rotating) {
      cbRotating.activate(0); 
    } else {
      cbRotating.deactivate(0);
    }
    
    if (iterating) {
      cbIterating.activate(0); 
    } else {
      cbIterating.deactivate(0);
    }
    
    if (changingShapes) {
      cbChangingShapes.activate(0); 
    } else {
      cbChangingShapes.deactivate(0);
    } 
 
    if (flocking) {
      cbFlocking.activate(0); 
    } else {
      cbFlocking.deactivate(0);
    } 
    
    //--------------hook up vol to flocking params---------------------
    if (volToSeparation) {
      cbVolToSeparation.activate(0);  
    } else {
      cbVolToSeparation.deactivate(0);
    }

    if (volToAlignment) {
      cbVolToAlignment.activate(0);  
    } else {
      cbVolToAlignment.deactivate(0);
    }

    if (volToCohesion) {
      cbVolToCohesion.activate(0);  
    } else {
      cbVolToCohesion.deactivate(0);
    } 
  }


  //================================================================

  public void draw() {
      background(40);
  }
  
  private ControlFrame() {
  }

  public ControlFrame(Object theParent, int theWidth, int theHeight) {
    parent = theParent;
    w = theWidth;
    h = theHeight;
  }

  public ControlP5 control() {
    return cp5;
  }
  
  void controlEvent(ControlEvent theEvent) {
    if (theEvent.isFrom(cbRotating)) {
      rotating = cbRotating.getState(0);
    }
    
    if (theEvent.isFrom(cbIterating)) {
      iterating = cbIterating.getState(0);
    }
    
    if (theEvent.isFrom(cbChangingShapes)) {
      changingShapes = cbChangingShapes.getState(0);
    }
    
    if (theEvent.isFrom(cbFlocking)) {
      flocking = cbFlocking.getState(0);
    }
    
    //-----------------volume to flocking params---------------------------
    if (theEvent.isFrom(cbVolToSeparation)) {
      volToSeparation = cbVolToSeparation.getState(0);
    }
    
    if (theEvent.isFrom(cbVolToAlignment)) {
      volToAlignment = cbVolToAlignment.getState(0);
    }
    
    if (theEvent.isFrom(cbVolToCohesion)) {
      volToCohesion = cbVolToCohesion.getState(0);
    }
    
    
    //----------------------------view control buttons---------------------------
    if (theEvent.isFrom(btXPLus100) || theEvent.isFrom(btXMinus100)) {
      //need to account for onscreen rotation about the y axis. Ignoring x axis rotation as it gets too difficult!
      flock.addVectorToAll(new PVector(cos(yRotation()) * theEvent.getValue(),
                           0.0, 
                           -sin(yRotation()) * theEvent.getValue()));
    }
    
    if (theEvent.isFrom(btYPlus100) || theEvent.isFrom(btYMinus100)) {
      flock.addVectorToAll(new PVector(0.0,
                                       theEvent.getValue(),
                                       0.0));
    }
    
    if (theEvent.isFrom(btZoomIn)) {
      zoomIn();
    }
    
    if (theEvent.isFrom(btZoomOut)) {
      zoomOut();
    }
    
    if (theEvent.isFrom(btRotateRight)) {
      rotateRight();
    }
    
    if (theEvent.isFrom(btRotateLeft)) {
      rotateLeft();
    }
    
  }
   
  //detect keypresses when control frame has focus
  void keyPressed() {
    final int k = keyCode;
    //println(k);
    
    //cycling through the available shapes
    if (k == 'C') {
      changingShapes = !changingShapes;
    }

    if (k == 'Q') {
      zoomMoves.clear();
      rotationMoves.clear();
      resetVariables();
    }
    
    //iterating the particles
    if (k == 'I') {
      iterating = !iterating;
    }
    
    //rotating the camera
    if (k == 'R') {
      rotating = !rotating;  
    }
    
    //flocking
    if (k == 'F') {
      flocking = !flocking;  
    }    
    
    //redrawing - pause 
    if (k == 'P') {
      if (looping) noLoop();
      else loop();
    }
    
    //zoom in
    if (k == 107 || k == 33) {
      //cameraDist *= btZoomIn.getValue();     
      zoomIn();
    } 
    
    //zoom out
    if (k == 109 || k == 34) {
      //cameraDist *= btZoomOut.getValue();  
      zoomOut();
    } 

    //mac keycodes?  104 38 up, 98 40 down, 100 37 left, 102 39 right
    //right, +x  
    if (k == 102 || k == 39) {  
      flock.addVectorToAll(new PVector(cos(yRotation()) * btXPLus100.getValue(),
                           0.0, 
                           -sin(yRotation()) * btXPLus100.getValue()));
    } 

    //left, -x  
    if (k == 100 || k == 37) {  
      flock.addVectorToAll(new PVector(cos(yRotation()) * btXMinus100.getValue(),
                           0.0, 
                           -sin(yRotation()) * btXMinus100.getValue()));
    } 

    //up, -y  
    if (k == 104 || k == 38) {  
      flock.addVectorToAll(new PVector(0.0,
                                       btYMinus100.getValue(),
                                       0.0));
    } 

    //down, +y  
    if (k == 98 || k == 40) {  
      flock.addVectorToAll(new PVector(0.0,
                                       btYPlus100.getValue(),
                                       0.0));
    } 

    if (k == 97 || k == 91) {  
      //controlYRotation = (controlYRotation + rotateOnKeypressByRadians) % (2*PI);
      //updateSliders(); 
      rotateLeft();   
    } 

    if (k == 99 || k == 93) {  
      //controlYRotation = (controlYRotation - rotateOnKeypressByRadians) % (2*PI);
      //updateSliders();
      rotateRight();  
    } 

    updateCheckboxes();
  }

  
  private void zoomOut () {
    float[] moves = triangular(movesPerZoom);
    int i = 0;
    for (float f : moves) {
      if (i < zoomMoves.size()) {
        zoomMoves.set(i,zoomMoves.get(i) * (1.0 + (zoomFactor * f)));
      } else {
        zoomMoves.add(1.0 + (zoomFactor * f));
      }
      i++;
    }          
  }
  
  private void zoomIn () {
    float[] moves = triangular(movesPerZoom);
    int i = 0;
    for (float f : moves) {
      if (i < zoomMoves.size()) {
        zoomMoves.set(i,zoomMoves.get(i) * 1.0/(1.0 + (zoomFactor * f)));
      } else {
        zoomMoves.add(1.0/(1.0 + (zoomFactor * f)));
      }
      i++;
    }          
  }
  
  private void rotateLeft() {
    float[] moves = triangular(movesPerRotate);
    int i = 0;
    for (float f : moves) {
      if (i < rotationMoves.size()) {
        rotationMoves.set(i,rotationMoves.get(i) + rotateFactor * f);
      } else {
        rotationMoves.add(+ rotateFactor * f);
      }
      i++;
    }   
  }
  
  private void rotateRight() {
    float[] moves = triangular(movesPerRotate);
    int i = 0;
    for (float f : moves) {
      if (i < rotationMoves.size()) {
        rotationMoves.set(i,rotationMoves.get(i) - rotateFactor * f);
      } else {
        rotationMoves.add(- rotateFactor * f);
      }
      i++;
    }  
  }

  
  ControlP5 cp5;
  Object parent;  
}


