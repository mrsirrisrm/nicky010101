int luminanceFromColor (color c) {
  //println(hex(c));
  int R = (c >> 16) & 0xFF;
  int G = (c >> 8) & 0xFF;
  int B = c & 0xFF;
  int Y = round(0.2126 * float(R) + 0.7152 * float(G) + 0.0722 * float(B)); 
  return distortRange(Y, 30, 150);
}

int distortRange (int a, int mn, int mx) {
  //int b;
 if (a < mn) {
  return 0;
 } else if (a > mx) {
  return 255;
 } else {
  float f = (a - mn) / (mx - mn);
  return round(f * 255.0); 
 }
}
