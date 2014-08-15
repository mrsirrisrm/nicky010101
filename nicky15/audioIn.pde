import ddf.minim.*;

class AudioIn {
 
  private Minim minim;
  private AudioInput audioIn;
  
  AudioIn (PApplet parent) {
    //audio input
    minim = new Minim(parent);  
    audioIn = minim.getLineIn(Minim.MONO);  
  }
  
  public float level () {
    return audioIn.left.level();
  }

}
