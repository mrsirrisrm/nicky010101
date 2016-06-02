import beads.*;
import java.util.Arrays; 

AudioContext ac;

void setup() {
  size(300,300);
  ac = new AudioContext();
  String audioFileName = "/Users/martin/Desktop/Obama Osama.wav";
  Sample sample = SampleManager.sample(audioFileName);
  GranularSamplePlayer player = new GranularSamplePlayer(ac, sample);

   //loop the sample at its end points
   player.setLoopType(SamplePlayer.LoopType.LOOP_ALTERNATING);
   //player.getLoopStartEnvelope().setValue(0);
   //player.getLoopEndEnvelope().setValue((float)sample.getLength());
   
   //player.setPosition(1000);
   player.getLoopStartEnvelope().setValue(1000);
   player.getLoopEndEnvelope().setValue(1100);
   player.setToLoopStart();
   
   player.getLoopEndUGen().
   
   //Bead endlistener = new Bead();
   //player.set setEndListener(endlistener);
   
   //control the rate of grain firing
   //Envelope grainIntervalEnvelope = new Envelope(ac, 30);
   //grainIntervalEnvelope.addSegment(20, 10000);
   //player.setGrainIntervalEnvelope(grainIntervalEnvelope);
   //control the playback rate
   //Envelope rateEnvelope = new Envelope(ac, 1);
   //rateEnvelope.addSegment(1, 5000);
   //rateEnvelope.addSegment(0, 5000);
   //rateEnvelope.addSegment(0, 2000);
   //rateEnvelope.addSegment(-0.1, 2000);
   //player.setRateEnvelope(rateEnvelope);
   //player.getEndListener().
   //a bit of noise can be nice
   //player.getRandomnessEnvelope().setValue(0.02);
   /*
   * And as before...
   */
  Gain g = new Gain(ac, 2, 0.2);
  g.addInput(player);
  ac.out.addInput(g);
  ac.start();
}


color fore = color(255, 102, 204);
color back = color(0,0,0);

void draw() {
  loadPixels();
  //set the background
  Arrays.fill(pixels, back);
  //scan across the pixels
  for(int i = 0; i < width; i++) {
    //for each pixel work out where in the current audio buffer we are
    int buffIndex = i * ac.getBufferSize() / width;
    //then work out the pixel height of the audio data at that point
    int vOffset = (int)((1 + ac.out.getValue(0, buffIndex)) * height / 2);
    //draw into Processing's convenient 1-D array of pixels
    vOffset = min(vOffset, height);
    pixels[vOffset * height + i] = fore;
  }
  updatePixels();
}