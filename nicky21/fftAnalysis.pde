import ddf.minim.spi.*; // for AudioStream
import ddf.minim.analysis.*;

class FFTAnalysis {
  private Minim minim;  
  private AudioInput in;
  private FFT fft;
  private float[] previousSpect;
  public float[] previousPeakiness = new float[200];
  public static final int updatePerFrames = 3;
  
  public FFTAnalysis ( PApplet parent ) {
    minim = new Minim(parent);
       
    in = minim.getLineIn(Minim.MONO, 4096, 22050 ); //get fs somehow?
    fft = new FFT( in.bufferSize() , in.sampleRate() );
    fft.window( FFT.BLACKMAN );
    float[] pSpec = powerSpec();
    previousSpect = new float[pSpec.length];
  }
  
  public void close() {
    in.close();
    minim.stop();
  }
  
  public void update () {
    float[] pSpec = powerSpec();
    for (int i = 0; i < previousSpect.length; i++ ) {
      previousSpect[i] = previousSpect[i] * 0.75 + pSpec[i];
    }
    fft.forward( in.left ); //do fft on the new buffer
    
    for (int i = previousPeakiness.length - 1; i > 0 ; i-- ) {
      previousPeakiness[i] = previousPeakiness[i - 1];
    }
    
    previousPeakiness[0] = spectralPeakiness();
    if (Double.isNaN(previousPeakiness[0]) ) {
      previousPeakiness[0] = 0;
    }
  }
  
  private float[] powerSpec () {
    float [] re = fft.getSpectrumReal();
    float [] im = fft.getSpectrumImaginary();
    
    float[] power = new float[re.length / 2];
    
    for (int i = 0; i < power.length; i++) {
      power[i] = re[i]*re[i] + im[i]*im[i];
      //if (Double.isNaN(power[i])) {
      //  power[i] = 0;
      //}
    }  
    
    return power;
  }

  private float spectralPeakiness() {
    float num = 0.;
    float den = 0.;
    for (int i = 2; i < previousSpect.length; i++) {
      num += log(previousSpect[i]);
      den += previousSpect[i];
    }
    num = exp(num / previousSpect.length);
    den /= previousSpect.length;
    return -log(num / den);
  }
  
//  private float spectralFlux () {
//    float flux = 0;
//    for (int i = 2; i < previousSpect.length; i++) {
//      flux += abs(log(previousSpect[i]) - log(fft.getBand(i)));
//    }
//    return flux;
//  }
}
