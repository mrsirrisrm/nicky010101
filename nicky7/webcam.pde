import processing.video.*;

class Webcam {
  
  private Capture cam;
  
  Webcam  (PApplet parent) {
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
      cam = new Capture(parent, cameras[0]);
      cam.start();     
    }  
  }
  
  PImage imageFromWebcam (int imgWidth, int imgHeight) {
    img = new PImage(imgWidth,imgHeight);
    //read camera
    if (cam.available() == true) {
      cam.read();
      //copy camera image to PIMage img
      img.copy(cam , 0 , 0 , cam.width , cam.height , 0 , 0 , img.width , img.height);
    }
    
    return img;
  }

}
