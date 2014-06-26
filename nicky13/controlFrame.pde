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
  p.parent = this;
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
  Slider numberInCDF1;
  
  CheckBox cbRotating;
  CheckBox cbIterating;
  CheckBox cbChangingShapes;
  CheckBox cbFlocking;
  CheckBox cbShowInfo;

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
  Button btWebcam;
  
  Button btHeap1;
  Button btCross1;
  Button btHeap2;
  Button btCross2;  
  Button btSendToCDF1;
  Button btSendToCDF2;
  
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
  
  private void webcamShot (CDF cdf) { 
    println("Webcam shot");
    cdf.img = webcam.imageFromWebcam(width,height);
    //draw it to this frame
    image(cdf.img, 300, 10, 200, 200); 
    //move items based on cam image
    cdf.setupPDF2DFromImage ();
    flock.moveAllItemsFromImageCDF (cdf);
  }
  
  public void setup() {
    background(40);
    
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
//    cp5.addSlider("fadeSpeed")
//                  .plugTo(parent,"fadeSpeed")
//                  .setRange(0, 100)
//                  .setPosition(10,70)
//                  .setValue(100);
//    cp5.addSlider("dissolveProbability")
//                  .plugTo(parent,"dissolveProbability")
//                  .setRange(0, 1)
//                  .setPosition(10,90)
//                  .setValue(1.0);
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
    
    numberInCDF1 = cp5.addSlider("CDF1 particles")
                  .setRange(0, 1.0)
                  .setPosition(10,370)
                  .setSize(300,10)
                  .setValue(1.0);
 
    
    
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
     cbShowInfo = cp5.addCheckBox("cbShowInfo")
                .setPosition(150, 170)
                .setColorForeground(color(120))
                .setColorActive(cbCol)
                .setColorLabel(color(255))
                .setSize(20, 15)
                .addItem("showInfo", 0);
   
   
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
  cp5.addSlider("homeForce"  )
                .plugTo(parent,"homeForce"  )
                .setRange(0.0, forceMax)
                .setPosition(10,330)
                .setValue(2.0);                
  cp5.addSlider("maxSpeed"  )
                .plugTo(parent,"maxParticleSpeed"  )
                .setRange(0.0, Particle.maxMaxSpeed)
                .setPosition(10,350)
                .setSize(300,10)
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
    int moveButtonsDown = 50;   
     btXPLus100 = cp5.addButton("x+") //move to current screen right (may not be +x!) 
       .setValue(100)
       .setPosition(90,370 + moveButtonsDown)
       .setSize(20,20);  
     btXMinus100 = cp5.addButton("x-")//move to current screen left (may not be -x!)
       .setValue(-100)
       .setPosition(50,370 + moveButtonsDown)
       .setSize(20,20);        
     btYPlus100 = cp5.addButton("y+")
       .setValue(100)
       .setPosition(70,390 + moveButtonsDown)
       .setSize(20,20);  
     btYMinus100 = cp5.addButton("y-")
       .setValue(-100)
       .setPosition(70,350 + moveButtonsDown)
       .setSize(20,20);   
  
     btZoomIn = cp5.addButton("z+") 
       .setValue(1.0/1.08)
       .setPosition(150,350 + moveButtonsDown)
       .setSize(20,20); 
     btZoomOut = cp5.addButton("z-") 
       .setValue(1.08)
       .setPosition(150,390 + moveButtonsDown)
       .setSize(20,20); 
     btRotateRight = cp5.addButton("r+") 
       .setValue(1.08)
       .setPosition(170,370 + moveButtonsDown)
       .setSize(20,20);  
     btRotateLeft = cp5.addButton("r-") 
       .setValue(1.08)
       .setPosition(130,370 + moveButtonsDown)
       .setSize(20,20);
      
     btWebcam = cp5.addButton("webcam") 
       .setValue(0)
       .setPosition(250,10)
       .setSize(20,20);
  
    btHeap1 = cp5.addButton("1:heap") 
       .setValue(0)
       .setPosition(250,370 + moveButtonsDown)
       .setSize(20,20);
   btCross1 = cp5.addButton("1:cross") 
       .setValue(0)
       .setPosition(290,370 + moveButtonsDown)
       .setSize(20,20);
   btSendToCDF2 = cp5.addButton("send N v") 
       .setValue(20)
       .setPosition(330,370 + moveButtonsDown)
       .setSize(20,20);    

    btHeap2 = cp5.addButton("2:heap") 
       .setValue(0)
       .setPosition(250,410 + moveButtonsDown)
       .setSize(20,20);
   btCross2 = cp5.addButton("2:cross") 
       .setValue(0)
       .setPosition(290,410 + moveButtonsDown)
       .setSize(20,20);
   btSendToCDF1 = cp5.addButton("send N ^") 
       .setValue(20)
       .setPosition(330,410 + moveButtonsDown)
       .setSize(20,20);    

  
    updateCheckboxes(); 
  }

  public void updateSliders () {
    while (controlYRotation < 0.0) {
      controlYRotation += 2*PI;  
    }
    slYRotation.setValue(controlYRotation % (2*PI));

    float portionInCDF1 = float(flock.numberInCDF(cdf1)) / float(flock.particles.size());
    numberInCDF1.setValue(portionInCDF1);    
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
    
    if (showInfo) {
      cbShowInfo.activate(0);
    } else {
      cbShowInfo.deactivate(0);
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
      //background(40);
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
    
    if (theEvent.isFrom(cbShowInfo)) {
      showInfo = cbShowInfo.getState(0);
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
    
    if (theEvent.isFrom(btWebcam)) {
      webcamShot (cdf1);
    }
    
    if (theEvent.isFrom(btHeap1)) {
      sendAllToCDFWithImage(cdf1, "heap.png");
      //cdf1.setupPDF2DFromImageFile("heap.png");
      //flock.changeNCDF(flock.particles.size(), cdf1);
      //cdf1.vectorAllItemsFromImageCDF ();
    }

    if (theEvent.isFrom(btCross1)) {
      sendAllToCDFWithImage(cdf1, "cross.png");
      //cdf1.setupPDF2DFromImageFile("cross.png");
      //flock.changeNCDF(flock.particles.size(), cdf1);
      //cdf1.vectorAllItemsFromImageCDF ();
    }    
    
    if (theEvent.isFrom(btSendToCDF2)) {
      flock.changeNCDF(50,cdf2);
    }
    
    
    
    if (theEvent.isFrom(btHeap2)) {
      sendAllToCDFWithImage(cdf2, "heap.png");
      //cdf2.setupPDF2DFromImageFile("heap.png");
      //flock.changeNCDF(flock.particles.size(), cdf2);
      //cdf2.vectorAllItemsFromImageCDF ();
    }

    if (theEvent.isFrom(btCross2)) {
      sendAllToCDFWithImage(cdf2, "cross.png");
      //cdf2.setupPDF2DFromImageFile("cross.png");
      //flock.changeNCDF(flock.particles.size(), cdf2);
      //cdf2.vectorAllItemsFromImageCDF ();
    }    
    
    if (theEvent.isFrom( btSendToCDF1 )) {
      flock.changeNCDF( 50 , cdf1 );
    }
    
    if (theEvent.isFrom( numberInCDF1 )) {
      int targetNumberCDF1 = round(numberInCDF1.getValue() * flock.particles.size());
      if ( targetNumberCDF1 > flock.numberInCDF(cdf1 )) {
        flock.makeNInCDF( targetNumberCDF1 , cdf1 );
      } else {
        flock.makeNInCDF( flock.particles.size() - targetNumberCDF1 , cdf2 );
      }
    }
    
  }
   
   private void sendAllToCDFWithImage (CDF cdf, String filename) {
     cdf.setupPDF2DFromImageFile(filename);
     flock.changeNCDF(flock.particles.size(), cdf);
     cdf.vectorAllItemsFromImageCDF ();
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
    
    //rotating the camera
    if (k == 'Q') {
      volToSpeedReversed = !volToSpeedReversed;  
    }
    
    //flocking
    if (k == 'F') {
      flocking = !flocking;  
    }    
    
    //redrawing - pause 
    if (k == 'P') {
      //println(this.parent);
      //if (this.parent.looping) parent.noLoop();
      //else parent.loop();
    }
    
    if (k == 'W') {
      webcamShot (cdf1);
    }
    
    
    
    //arrow keys - moving the view--------------------------
    
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

float[] triangular (int len) {
  float[] pdf = new float[len];
  for (int i = 0; i < len; i++) {
    if (i < len/2) {
      pdf[i] = float(i + 1) / float((len + 1)/2);
      pdf[len - i - 1] = pdf[i]; 
    } 
  }
  return pdf;
}
