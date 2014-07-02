class CDF {

  //int ID;
  String sourceFile;
  PImage img;
  int[] imgYPDF;
  int[][] imgPDF;
  int[] imgYCDF;
  int[][] imgCDF;

  public CDF () {
    sourceFile = "";
  }
  
  public void setupPDF2DFromImageFile (String filename) {
    //loading image 
    String path = "../../resources/";
    sourceFile = path + filename;
    img = loadImage(sourceFile);
    if (img == null) {
      println("Unable to load image. Check resources directory location and contents");    
    } else {
      setupPDF2DFromImage ();
    }
  }
  
  public void setupPDF2DFromImage () {
  
    img.resize( width , height );
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
      } 
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
  
  public int weightedRandomInt2DX () {
    int i = 0;
    int compare = int(random(0,2147483646) % imgYCDF[imgYCDF.length - 1]); 
    while (i < imgYCDF.length && imgYCDF[i] < compare) {
      i++;  
    }
    return i;
  }
  
  public int weightedRandomInt2DY (int x) {
    int j = 0;
    int compare = int(random(0,2147483646) % imgCDF[x][imgCDF[x].length - 1]); 
    while (j < imgCDF[x].length && imgCDF[x][j] < compare) {
      j++;  
    }
    return j;
  }
    
  public float randomZ () {
    return random(-width / 2 , width / 2);
  }

}
