class OnscreenInfo {
 int[] luminanceHistogram = new int[16];
 
 OnscreenInfo () {
   
 }
 
 
 public void showVideo () {
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
 }

 public void showAudio (float audioLevel) { 
    //show audiolev bar onscreen
    rect(0 , 0 , round(scrnWidth*audioLevel) , 20);     
 }
  
}
