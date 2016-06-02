import beads.*;
import org.jaudiolibs.beads.*;
import java.util.Arrays; 
import java.util.List;

AudioContext ac;

float[][] buffers;

void setup() {
  size(200,200);
  
  JavaSoundAudioIO jio = new JavaSoundAudioIO();
  //JavaSoundAudioIO.printMixerInfo();
  jio.selectMixer(0);
  ac = new AudioContext(jio);
  Gain g = new Gain(ac, 2, 1.0);

  randomSeed(0);
  noiseSeed(0);
  String dir = "/Users/martin/Desktop/nickySamples/";
  String[] files = {"Obama.mp3","Trump.mp3","Sadiq Khan.mp3"};
  buffers = new float[files.length][0];
  for (int j = 0; j < files.length; j++) {
    buffers[j] = setupSampleBuffer(SampleManager.sample(dir + files[j]));
  }

  List<Babble> beads = new ArrayList<Babble>();
  while (beads.size() < 20) {
    Babble mb = new Babble(ac, 1, buffers[beads.size() % files.length]);    
    beads.add(mb);
    g.addInput(mb);
  }
  
  ac.out.addInput(g);
  ac.start();  
}

void draw() {}

float[] setupSampleBuffer(Sample sample) {
  float[] samps = new float[sample.getNumChannels()];
  float[] buffer = new float[(int)sample.getNumFrames()];
  for (int i = 0; i < (int)sample.getNumFrames(); i++) {
    sample.getFrame(i,samps);
    buffer[i] = samps[0];
  }
  return buffer;
}
 
class Babble extends UGen {
  float[] buffer;
  int count, startPos = 0, bufSize;
  final int updateAfter = 60, activeProbability = 200;
  float[][] windows = new float[updateAfter][0];
  boolean active = false;
  
  Babble(AudioContext context, int outs, float[] buffer) {
    super(context, outs);
    
    this.buffer = buffer; 
    count = (int)random(updateAfter);
    
    bufSize = this.bufOut[0].length;
    int totalLength = updateAfter * bufSize;
    for (int j = 0; j < updateAfter; j++) {
      windows[j] = new float[bufSize];
      for (int i = 0; i < bufSize; i++) {
        int pos = j * bufSize  + i;
        if (pos <= totalLength / 2) {        
          windows[j][i] = sqrt( (float)pos / (totalLength / 2));
        } else {
          windows[j][i] = sqrt((float)(totalLength - pos) / (totalLength / 2));
        }
      }
    }
  }
  
  public void calculateBuffer() {
    count++;
    
    int bufInd = count % updateAfter;
    for (int i = 0; i < bufSize; i++) {
      if (active) {        
        bufOut[0][i] = buffer[startPos + i] * windows[bufInd][i];        
      } else {
        bufOut[0][i] = 0;
      }
    }
    
    if (count % updateAfter == 0) {
      startPos = (int)random(0, buffer.length - updateAfter*bufSize - 1);
      active = random(1000) < activeProbability;
    } else {
      startPos += bufSize;
    }
  }    
  
}