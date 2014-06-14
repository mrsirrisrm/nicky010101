void fadeLastSceneBy (int fadeBy) {
  for (int i = 0; i < scrnWidth; i++) {
    for (int j = 0; j < scrnWidth; j++) {
      int fadeRedBy = fadeBy;
      int fadeBlueBy = fadeBy;
      int fadeGreenBy = fadeBy;
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
