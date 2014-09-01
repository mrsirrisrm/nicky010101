import ddf.minim.*;
import ddf.minim.ugens.Sink;
import ddf.minim.effects.LowPassFS;
import ddf.minim.effects.ChebFilter;
import ddf.minim.effects.IIRFilter;
import ddf.minim.effects.*;

import ddf.minim.ugens.*;
import ddf.minim.spi.*; // for AudioStream

import ddf.minim.analysis.*;

class FreqBalance {
  private Minim minim;
  private AudioOutput out;
  LiveInput in;
  IIRFilter lowFilter;
  Multiplier invert;
  EnvelopeFollower loEnv;
  EnvelopeFollower highEnv;
  Sink sink;
  Summer sum;
  
  AudioInput inFFT;
  FFT fft;
  
  float prevHighLev = 0.0, prevLowLev = 0.0;
  float mix = 0.0;
  final float levelDecay = 0.8;
  
  private float logLev = 0.0;
  private float prevAudioLevel = 100.;
  private float dLevdtSmoothed = 0.0;
  float logdVdt = 0.00001; 
  float dLevdtSmoothFactor = 0.5; 
  //float[] logdVdts = new float[300];
  //int ii = 0;
  public float[] previousSpect;
  public float[] previousFlatness = new float[400];
  
  public FreqBalance ( PApplet parent , float splitFrequency ) {

    minim = new Minim(parent);
    
    out = minim.getLineOut();
    
    // ask for an input with the same audio properties as the output.
    AudioStream inputStream = minim.getInputStream( out.getFormat().getChannels(), 
                                                    out.bufferSize(), 
                                                    out.sampleRate(), 
                                                    out.getFormat().getSampleSizeInBits());
                                                   
    // construct a LiveInput by giving it an InputStream from minim.                                                  
    in = new LiveInput( inputStream );
  
    lowFilter = new LowPassFS(splitFrequency, out.sampleRate());
    invert = new Multiplier(-1.0f);
    
    sink = new Sink();
     
    loEnv = new EnvelopeFollower( 0.05,   // attack time in seconds
                                      1.0, // release time in seconds
                                      1024 // size of buffer to analyze 
                                    );
    highEnv = new EnvelopeFollower( 0.05,   // attack time in seconds
                                      1.0, // release time in seconds
                                      1024 // size of buffer to analyze 
                                    );                                  
    Summer sum = new Summer();
    //Summer sumOut = new Summer();
                              
    in.patch(lowFilter).patch(loEnv).patch(sink).patch(out);
    lowFilter.patch(invert).patch(sum).patch(highEnv).patch(sink);
    in.patch(sum);
    
    
    inFFT = minim.getLineIn(Minim.MONO, 4096 * 4, out.sampleRate() );
    fft = new FFT( inFFT.bufferSize() , inFFT.sampleRate() );
    fft.window( FFT.BLACKMAN );
    previousSpect = new float[fft.specSize()];
  }
  
  public void update () {
    prevLowLev *= levelDecay;
    prevLowLev += loEnv.getLastValues()[0];
    if (prevLowLev < 0.001) { prevLowLev = 0.001; }
    
    prevHighLev *= levelDecay;
    prevHighLev += highEnv.getLastValues()[0];
    if (prevHighLev < 0.001) { prevHighLev = 0.001; }
    
    mix = log( prevHighLev / prevLowLev );
    
    
    
    logLev = logLev * 0.66 + log(level() / 0.0001);
    float diff = abs( logLev - prevAudioLevel );
    if (diff == 0.0) diff = 1.0e-10;
    dLevdtSmoothed = diff / prevAudioLevel;//dLevdtSmoothed * dLevdtSmoothFactor + diff / prevAudioLevel;
    if (frameCount < 20) {
      logdVdt = 0.;
    } else {
      logdVdt = 1.0e2 * dLevdtSmoothed;
    }
    
    //if (frameCount % 10 == 0) {
    //  println( "lev", logLev, "prev", prevAudioLevel, "diff", diff, "dLev", dLevdtSmoothed, "log", logdVdt );
    //}
    //logdVdts[ii] = logdVdt;
    //ii = (ii + 1) % 300;
    
    prevAudioLevel = logLev;
  }
  
 
  public void setSplitFrequency (float splitFrequency) {
    lowFilter.setFreq( splitFrequency );  
  } 
  
  public float greaterLevel () {
    return max( prevHighLev, prevLowLev );
  }
  
  public float level() {
    return prevHighLev + prevLowLev;
  }
  
  
  
  
  public void updateFFT () {
    for (int i = 0; i < fft.specSize(); i++ ) {
      previousSpect[i] = previousSpect[i] * 0.75 + fft.getBand(i);
    }
    fft.forward( inFFT.left );
    
    for (int i = 1; i < previousFlatness.length; i++ ) {
      previousFlatness[i - 1] = previousFlatness[i];
    }
    
    previousFlatness[previousFlatness.length - 1] = spectralFlatness();
  }
  
  public float spectralFlatness() {
    float num = 0.;
    float den = 0.;
    for (int i = 2; i < fft.specSize() ; i++) {
      num += log(previousSpect[i]);
      den += previousSpect[i];
    }
    num = exp(num / fft.specSize());
    den /= fft.specSize();
    return log(num / den);
  }
  
  public float spectralFlux () {
    float flux = 0;
    for (int i = 2; i < fft.specSize(); i++) {
      flux += abs(log(previousSpect[i]) - log(fft.getBand(i)));
    }
    return flux;
  }
}
