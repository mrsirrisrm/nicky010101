class Text extends FBox {
  
  boolean isOne;
  float textOffset;
  int created = frameCount;

  Text(boolean _isOne) {    
    super(_isOne ? 5 : 10, textAscent() + textDescent());
    isOne = _isOne;    
    textOffset = textAscent() - getHeight()/2;
  }
  
  boolean isNew() {
    return frameCount - created < 30;
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