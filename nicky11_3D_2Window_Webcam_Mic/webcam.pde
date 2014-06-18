import processing.video.*;

class Webcam {
  boolean available = false;
  private Capture cam;
  
  Webcam  (PApplet parent) {
    //webcam
    String[] cameras = Capture.list();
    
    if (cameras.length == 0) {
      println("There are no cameras available for capture.");
      //exit();
    } else {
      //println("Available cameras:");
      //for (int i = 0; i < cameras.length; i++) {
      //  println(cameras[i]);
      //}
      
      // The camera can be initialized directly using an 
      // element from the array returned by list():
      cam = new Capture(parent, cameras[0]);
      cam.start();
      available = true;     
    }  
  }
  
  PImage imageFromWebcam (int imgWidth, int imgHeight) {
    img = new PImage(imgWidth,imgHeight);
    //read camera
    if (available) {
      if (cam.available() == true) {
        cam.read();
        //copy camera image to PIMage img
        img.copy(cam , 0 , 0 , cam.width , cam.height , 0 , 0 , img.width , img.height);
      }
    } else {
      println("No camera available");
    }
    
    return img;
  }
}
