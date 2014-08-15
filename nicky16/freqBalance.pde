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
  LiveInput in;
  IIRFilter lowFilter;
  Multiplier invert;
  EnvelopeFollower loEnv;
  EnvelopeFollower highEnv;
  Sink sink;
  Summer sum;
  float prevHighLev = 0.0, prevLowLev = 0.0;
  float mix = 0.0;
  final float levelDecay = 0.8; 

  
  
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
  }
  
  public void update () {
    prevLowLev *= levelDecay;
    prevLowLev += loEnv.getLastValues()[0];
    if (prevLowLev < 0.001) { prevLowLev = 0.001; }
    
    prevHighLev *= levelDecay;
    prevHighLev += highEnv.getLastValues()[0];
    if (prevHighLev < 0.001) { prevHighLev = 0.001; }
    
    mix = log( prevHighLev / prevLowLev );
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
}
