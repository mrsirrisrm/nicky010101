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
