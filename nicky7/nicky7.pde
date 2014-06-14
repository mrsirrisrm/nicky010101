import processing.video.*;
import ddf.minim.*;

Minim minim;
AudioInput audioIn;

int t = 0;

int rows = 500;

int scrnWidth = 600;
int scrnHeight = 600;

float[] cdfX = new float[scrnWidth];
float[] cdfY = new float[scrnHeight];
float cdfSumX = 0;
float cdfSumY = 0;

PFont[] fonts = new PFont[16];

PImage img;
int[] imgYPDF;
int[][] imgPDF;
int[] imgYCDF;
int[][] imgCDF;

int[] luminanceHistogram = new int[16];

int audioLevel = 0;

boolean showInfo = false;

Capture cam;

//---------------------------------------------------------------

int luminanceFromColor (color c) {
  //println(hex(c));
  int R = (c >> 16) & 0xFF;
  int G = (c >> 8) & 0xFF;
  int B = c & 0xFF;
  int Y = round(0.2126 * float(R) + 0.7152 * float(G) + 0.0722 * float(B));
  
  int indx = Y / 16;
  if (indx < luminanceHistogram.length) { 
    luminanceHistogram[indx]++;
  }
  
  return distortRange(Y, 30, 150);
}

int distortRange (int a, int mn, int mx) {
  int b;
 if (a < mn) {
  return 0;
 } else if (a > mx) {
  return 255;
 } else {
  float f = (a - mn) / (mx - mn);
  return round(f * 255.0); 
 }
}

void setupPDF2DFromImageFile (String filename) {
  //loading image  
  img = loadImage(filename);
  setupPDF2DFromImage ();
}
  
void setupPDF2DFromImage () {
  img.resize( scrnWidth , scrnHeight );
  img.loadPixels();
  
  for (int i = 0; i < luminanceHistogram.length; i++) {
   luminanceHistogram[i] = 0; 
  }
  
  //println(img.width, " x " , img.height);
  
  imgYPDF = new int[img.width];
  imgPDF = new int[img.width][img.height];
  //int dimension = img.width * img.height;
  
  //in X direction 
  for (int i = 0; i < img.width; i++) {
    imgYPDF[i] = 0;
    for (int j = 0; j < img.height; j++) {
      //get luminance of this pixel
      //imgPDF[i][j] = (img.pixels[i + j*img.width] >> 16) & 0xFF;
      imgPDF[i][j] = 255 - luminanceFromColor(img.pixels[i + j*img.width]);
      imgYPDF[i] = imgYPDF[i] + imgPDF[i][j];     
    } 
  }
  
  //covering whole array
  imgYCDF = new int[img.width];
  imgCDF = new int[img.width][img.height];
  imgYCDF[0] = imgYPDF[0];
  for (int i = 1; i < imgYCDF.length; i++) {   
     imgYCDF[i] = imgYCDF[i - 1] + imgYPDF[i];
     
     imgCDF[i][0] = imgPDF[i][0];
     for (int j = 1; j < img.height; j++) {
       imgCDF[i][j] = imgCDF[i][j - 1] + imgPDF[i][j];
    }  
  } 
} 

int weightedRandomInt2DX () {
  int i = 0;
  int compare = int(random(0,2147483646) % imgYCDF[imgYCDF.length - 1]); 
  while (i < imgYCDF.length && imgYCDF[i] < compare) {
    i++;  
  }
  return i;
}

int weightedRandomInt2DY (int x) {
  int j = 0;
  int compare = int(random(0,2147483646) % imgCDF[x][imgCDF[x].length - 1]); 
  while (j < imgCDF[x].length && imgCDF[x][j] < compare) {
    j++;  
  }
  return j;
}

int[] getPDF2DHeapAtX (int x) {
  //deprecated
  
  int[] pdf = new int[img.height];
  for (int i = 0; i < img.height; i++) {
    pdf[i] = (img.pixels[x + i*img.width] >> 24) & 0xFF; 
  }  
  
  return pdf;
}


void moveAllItems () {
   for (int i = 0; i < items.length; i++) {
    items[i].moveTo(0 , 0); 
  } 
}



void vectorAllItemsFromImageCDF () {
  for (int i = 0; i < items.length; i++) {
    int x = weightedRandomInt2DX () ;
    //println(x);
    
    items[i].vectorTo(x , weightedRandomInt2DY( x )); 
  }   
}

void moveAllItemsFromImageCDF () {
  for (int i = 0; i < items.length; i++) {
    int x = weightedRandomInt2DX () ;
    //println(x);
    
    items[i].moveTo(x , weightedRandomInt2DY( x )); 
  }   
}






//------------------------------------------------------------------------

class item { 
  int x = 0, y = 0; //position
  int xTarget = 0, yTarget = 0;
  float dx = 0.0, dy = 0.0; //velocity
  float ddx = 0.0, ddy = 0.0; //accel
  float friction = 0.97;
  float theta = 0;
  int updateIn; //get new values on this iteration
  int maxUpdateTime = 50;
  boolean isOne;
  int fontSize = 6;
  
  item (int ax, int ay) {  
    x = ax % scrnWidth;
    y = ay % scrnHeight; 
    dx = 0;
    dy = 0;
    ddx = 0;
    ddy = 0;
    this.getNewVector();
    isOne = random(255) < 128.0;
    theta = random(0 , 1000);
    this.refreshUpdateIn();
  }
  
  void moveTo (int ax, int ay) {
    x = ax % scrnWidth;
    y = ay % scrnHeight;   
  }
  
  void vectorTo (int ax, int ay) {
    xTarget = ax % scrnWidth;
    yTarget = ay % scrnHeight;   
  }
  
  String getText () {
    return (isOne ? "1" : "0");
  }
  
  String getInfo () {
    String[] s = {"x ", str(this.x) ,"   y ", str(this.y) , "    " ,  this.getText(), "   update in ", str(this.updateIn) };
    return join(s,"");  
  }
  
  void iterate () {
//    this.dx = this.dx * this.friction + this.ddx;
//    this.dy = this.dy * this.friction + this.ddy;
//    
//    this.x += this.dx;
//    if (this.x < 0 || this.x > scrnWidth) { 
//      this.dx = -this.dx;
//      this.ddx = -this.ddx; 
//    }   
//        
//    this.y += this.dy;
//    if (this.y < 0 || this.y > scrnHeight) { 
//      this.dy = -this.dy;
//      this.ddy = -this.ddy; 
//    }
//    
//    this.updateIn--;
//    if ( this.updateIn <= 0 ) {
//      // 
//      this.refreshUpdateIn();
//      this.getNewVector();
//    } 
    if (x != xTarget) {
      dx = (xTarget - x) / 8; 
      x = x + round(dx); 
    }
    if (y != yTarget) {
      dy = (yTarget - y) / 8;
      y = y + round(dy);  
    }

  }
  
  void refreshUpdateIn () {
    this.updateIn = int(random(0,9999)) % this.maxUpdateTime;
  }
  
  void getNewVector () {
    this.ddx = 0;//(random(0 , 9999) % 101 - 50) / 500;
    this.ddy = 0;//(random(0 , 9999) % 101 - 50) / 500;  
  }
  
  void textOnScreen () {
    translate( this.x , this.y ); 
    rotate(theta);               
    textAlign(CENTER) ;
  
    // The text is center aligned and displayed at (0,0) after translating and rotating. 
    // See Chapter 14 or a review of translation and rotation.
    
    text( this.getText() , 0 , 0 ); 
    
    rotate(-theta);
    translate( -this.x , -this.y );
 
    //text( this.getText() , this.x , this.y ); 
  }
  
    void dotOnScreen () {
    
    set( this.x , this.y , color(255 , audioLevel , 0));
 
    //text( this.getText() , this.x , this.y ); 
  }
  
} 

item[] items = new item[rows];

void setup () {  
  size(scrnWidth, scrnHeight);
  if (frame != null) {
    frame.setResizable(true);
  }
  smooth();
  background(0);
  for (int i = 0; i < fonts.length; i++) {
    fonts[i] = createFont("Times New Roman", 4 + i, true); 
  } 
  textFont(fonts[0]); 
  fill(255, 255, 255, 255);
  
  //audio input
  minim = new Minim(this);  
  audioIn = minim.getLineIn(Minim.MONO);
  
  //webcam
  String[] cameras = Capture.list();
  
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    //println("Available cameras:");
    //for (int i = 0; i < cameras.length; i++) {
    //  println(cameras[i]);
    //}
    
    // The camera can be initialized directly using an 
    // element from the array returned by list():
    cam = new Capture(this, cameras[0]);
    cam.start();     
  } 
  
  //set up cdf functions
  setupPDF2DFromImageFile("heap.png");
  
  for (int i = 0; i < items.length; i++) {
    items[i] = new item(0 , 0); 
  }
    
  println("width " , size().width);
  println("height ", size().height);
  
  long allocated = Runtime.getRuntime().totalMemory();
  long free = Runtime.getRuntime().freeMemory();
  long maximum = Runtime.getRuntime().maxMemory();
  
  println("allocated mem ", allocated/1024/1024);
  println("free mem ", free/1024/1024);
  println("maximum mem ", maximum/1024/1024);
};



void draw () {
  //background(0, 0, 0);
  //fadeLastScene ();
  dissolveLastSceneWithProbability(0.4);
  
  //read camera
  if (cam.available() == true) {
    cam.read();
  }
  //copy camera image to PIMage img
  img.copy(cam , 0 , 0 , cam.width , cam.height , 0 , 0 , img.width , img.height);
  
  //move items based on cam image
  if (t % 1 == 0) {
    setupPDF2DFromImage ();
    moveAllItemsFromImageCDF ();
  }

  //get audio level
  float lev = audioIn.left.level();
  if (lev > 0.5) {
    audioLevel = 255;
  } else {
    audioLevel = round(2.0 * 255.0 * lev);
  }
  
  //change colour based on audioLevel
  //fill(audioLevel , audioLevel , 255); 

  //use audio level to set font size
  int fontsLength = fonts.length;
  int fonti = round((fontsLength * audioLevel) / 255);
  if (fonti < 0) { fonti = 0; }
  if (fonti >= fontsLength) { fonti = fontsLength - 1; }
  textFont(fonts[fonti]);

  for (int i = 0; i < rows; i++) {
    //items[i].dotOnScreen();
    items[i].textOnScreen();
    //items[i].iterate();
  }
  
  if (showInfo) {
    //output luminance histogram
    fill(255);
    noStroke() ;
    int lmax = 0;
    for (int i = 0; i < luminanceHistogram.length; i++) {
      if (luminanceHistogram[i] > lmax) { lmax = luminanceHistogram[i]; }
    }
    for (int i = 0; i < luminanceHistogram.length; i++) {
      int h = round(60.0 * float(luminanceHistogram[i]) / float(lmax));
      rect(i*30, scrnHeight - h, 30, h);  
    }
    
    //show audiolev bar onscreen
    rect(0 , 0 , round(scrnWidth*lev) , 20);     
  }
  
  t++;
};

void keyPressed() {
  final int k = keyCode;

//println(k);

  //pause
  if (k == 80) { //p
    if (looping) { 
      noLoop();
    } else {          
      loop();
    }
  }
  
  //show audio and webcam info
  if (k == 83) { //s  
    showInfo = !showInfo;
    //println(showInfo);
  }
}

void fadeLastScene () {
  for (int i = 0; i < scrnWidth; i++) {
    for (int j = 0; j < scrnWidth; j++) {
      int fadeRedBy = 3;
      int fadeBlueBy = 10;
      int fadeGreenBy = 10;
      color c = get(i,j);
      //bitshift to get color components
      int r = (c >> 16) & 0xFF;
      int g = (c >> 8) & 0xFF;
      int b = c & 0xFF;
      r = r < fadeRedBy ? 0 : r - fadeRedBy;
      g = g < fadeGreenBy ? 0 : g - fadeGreenBy;
      b = b < fadeBlueBy ? 0 : b - fadeBlueBy;
      set(i,j,color(r,g,b));
    }
  }
}


void dissolveLastSceneWithProbability (float probability) {
  for (int i = 0; i < scrnWidth; i++) {
    for (int j = 0; j < scrnWidth; j++) {
      if ((random(0,2147483646) % 1000) < (1000*probability)) { 
        set(i,j,color(0));
      }
    }
  }
}
