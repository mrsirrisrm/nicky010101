import ddf.minim.*;
import ddf.minim.ugens.Sink;
import ddf.minim.effects.LowPassFS;
import ddf.minim.effects.ChebFilter;
import ddf.minim.effects.IIRFilter;
import ddf.minim.effects.*;

import ddf.minim.ugens.*;
import ddf.minim.spi.*; // for AudioStream

class FreqBalance {
  private Minim minim;
  private AudioOutput out;
  private LiveInput in;
  private IIRFilter lowFilter;
  private Multiplier invert;
  private EnvelopeFollower loEnv;
  private EnvelopeFollower highEnv;
  private Sink sink;
  //private Summer sum;
    
  public float aPrevHighLev = 0.0, aPrevLowLev = 0.0;
  public float mix = 0.0;
  private final float levelDecay = 0.8;
  
  private float logLev = 0.0;
  private float prevAudioLevel = 100.;
  private float dLevdtSmoothed = 0.0;
  public float logdVdt = 0.00001; 
  //private float dLevdtSmoothFactor = 0.5; 
  
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
  
    lowFilter = new LowPassFS(splitFrequency, in.sampleRate());
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
  }
  
  public void close() {
    in.close();
    out.close();
    minim.stop();
  }
  
  public void update () {
    aPrevLowLev *= levelDecay;
    aPrevLowLev += loEnv.getLastValues()[0];
    if (aPrevLowLev < 0.001) { aPrevLowLev = 0.001; }
    
    aPrevHighLev *= levelDecay;
    aPrevHighLev += highEnv.getLastValues()[0];
    if (aPrevHighLev < 0.001) { aPrevHighLev = 0.001; }
    
    //println(aPrevLowLev);
    mix = log( aPrevHighLev / aPrevLowLev );
    
    logLev = logLev * 0.66 + log(uncompressedLevel() / 0.0001);
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
    //println(prevAudioLevel);
  }
  
  private float compressorLimiter(float d, float lowThresh, float highThresh, float ratio) {
    if (d < lowThresh) {
      return lowThresh + (d - lowThresh) * ratio;  
    } else if (d > 18.0) {
      return highThresh + (d - highThresh) * ratio;
    } else {
      return d;
    }
  }
 
  public void setSplitFrequency (float splitFrequency) {
    lowFilter.setFreq( splitFrequency );  
  } 
  
  public float greaterLevel () {
    return max( aPrevHighLev, aPrevLowLev );
  }
  
  private float uncompressedLevel() {
    return aPrevHighLev + aPrevLowLev;
  }
  
  public float level() {
    return compressorLimiter(this.uncompressedLevel(), 14.0, 18.0, 0.33);
  }
  
  public float prevLowLev() {
    //return aPrevLowLev;
    return exp(compressorLimiter(log(aPrevLowLev),-4.0,-2.0,0.33));
  }
  
  public float prevHighLev() {
    //return aPrevHighLev;
    return exp(compressorLimiter(log(aPrevHighLev),-4.0,-2.0,0.33));
  }  
}
