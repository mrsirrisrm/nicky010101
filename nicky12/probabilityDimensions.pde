void setupPDF2DFromImageFile (String filename) {
  //loading image 
  String path = "../../resources/";
  img = loadImage(path + filename);
  if (img == null) {
    println("Unable to load image. Check resources directory location and contents");    
  } else {
    setupPDF2DFromImage ();
  }
}

void setupPDF2DFromImage () {

  img.resize( scrnWidth , scrnHeight );
  img.loadPixels();
  
  //println(img.width, " x " , img.height);
  
  imgYPDF = new int[img.width];
  imgPDF = new int[img.width][img.height];
  //int dimension = img.width * img.height;
  
   
  for (int i = 0; i < img.width; i++) {
    imgYPDF[i] = 0;
    for (int j = 0; j < img.height; j++) {
      //get alpha of this pixel
      imgPDF[i][j] = (img.pixels[i + j*img.width] >> 24) & 0xFF;
      imgYPDF[i] = imgYPDF[i] + imgPDF[i][j];
      
      //if (imgPDF[i][j] > 0) { 
      //  println(imgPDF[i][j]);
      //}
      
    } 
    //if (imgYPDF[i] > 0) {
    //  println (i, "  " , imgYPDF[i]);
    //} 
  }
  

  
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


void moveAllItems () {
   for (Particle part : flock.particles) {
     part.moveTo(new PVector(weightedRandomIntX() , weightedRandomIntY(), randomZ())); 
  } 
}

void vectorAllItems () {
  for (Particle part : flock.particles) {
    part.vectorTo(new PVector(weightedRandomIntX() , weightedRandomIntY(), randomZ())); 
  } 
}

void vectorAllItemsFromImageCDF () {
  for (Particle part : flock.particles) {
    int x = weightedRandomInt2DX () ;
    //println(x);
    part.vectorTo(new PVector(x , weightedRandomInt2DY( x ), randomZ())); 
  }   
}


int weightedRandomIntX () {
  int i = 0;
  int compare = int(random(0 , 2147483646) % cdfSumX); 
  while (i < cdfX.length && cdfX[i] < compare) {
    i++;  
  }
  return i;
}

int weightedRandomIntY () {
  int i = 0;
  int compare = int(random(0,2147483646) % cdfSumY); 
  while (i < cdfY.length && cdfY[i] < compare) {
    i++;  
  }
  return i;
}

float randomZ () {
  return random(-scrnWidth / 2 , scrnWidth / 2);
}


