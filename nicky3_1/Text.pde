class Text extends FBox {
  
  boolean isOne;
  float textOffset;
  long created;

  //static final float scale = 3.f;

  Text(boolean isOne, long iteration) {       
    super((isOne ? 5 : 10), (textAscent() + textDescent()));
    this.created = iteration;
    this.isOne = isOne;    
    textOffset = textAscent() - getHeight()/2;
  }
  
  boolean isNew(long iteration) {
    return iteration - created < 30;
  }
  
  void draw(PGraphics applet) {
    super.draw(applet);

    preDraw(applet);    
    fill(0);
    stroke(0);
    textAlign(CENTER);
    text(isOne ? "1" : "0", 0, textOffset);
    postDraw(applet);
  }
  
}