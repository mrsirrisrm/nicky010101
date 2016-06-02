import processing.sound.*;
import beads.*;
import java.util.Arrays; 

AudioContext ac;

void setup() {
  size(640, 360);
  background(255);

  ac = new AudioContext();
  
  WavePlayer wp1 = imagePlayer(loadImage("/Users/martin/Pictures/nicky/Nicky3_1/n3_2_a.png"));
  WavePlayer wp2 = imagePlayer(loadImage("/Users/martin/Pictures/nicky/Nicky3_1/n3_2_b.png"));
  WavePlayer wp3 = imagePlayer(loadImage("/Users/martin/Pictures/nicky/Nicky3_1/n3_2_c.png"));
  
  Plug p = new Plug(ac);
  p.addInput(wp1);
  p.addInput(wp2);
  p.addInput(wp3);

  BiquadFilter filt = new BiquadFilter(ac, 1, BiquadFilter.Type.BUTTERWORTH_LP);
  filt.setFrequency(3000).setQ(2).setGain(.4);
  
  filt.addInput(p);
  
  Gain g = new Gain(ac, 1, 0.1);
  g.addInput(filt);
  ac.out.addInput(g);
  ac.start();  
}

void draw() { 
  background(0);  
} 

int[] bufferFromImage(PImage im) {
  final int d = (int)Math.sqrt(im.width * im.height / 4096);
  int p = 0;
  int[] b = new int[4096];
  for (int i = 0; i < im.width; i += d) {
    for (int j = 0; j < im.height; j += d) {
      int s = 0;
      for (int m = 0; m < d; m++) {
        for (int n = 0; n < d; n++) {
          s += im.get(i+m,j+n) >> 16 & 0xFF;    
        }
      }
      int c = s / (d*d);
      
      if (p < b.length) {
        b[p++] = c;
      }
    }
  }
  return b;
}

int bufferMax(int[] b) {
  int mx = 0;
  for (int i = 0; i < b.length; i++) {
    if (b[i] > mx) {
      mx = b[i];
    }
  }
  return mx;
}

WavePlayer imagePlayer(PImage im) {
  int[] qq1 = bufferFromImage(im);
  int mx1 = bufferMax(qq1);

  Envelope freqEnv1 = new Envelope(ac, 50);
  int segmentTimeMS = 80;
  float slowdown = 64;
  for (int i = 0; i < 4096; i++) {
    freqEnv1.addSegment(qq1[i] / slowdown, segmentTimeMS);
  }

  Buffer b1 = Buffer.NOISE;
  for (int i = 0; i < 4096; i++) {
    b1.buf[i] = 2*(qq1[i] / (float)mx1 - 0.5);
  }
   
  return new WavePlayer(ac, freqEnv1, b1);
}