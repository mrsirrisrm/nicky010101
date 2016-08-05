class Text extends FBox {
  
  boolean isOne;
  float textOffset;
  int worldInd;
  int created = frameCount;

  Text(boolean _isOne, int _worldInd) {    
    super(_isOne ? 5 : 10, textAscent() + textDescent());
    this.worldInd = _worldInd;
    isOne = _isOne;    
    textOffset = textAscent() - getHeight()/2;
  }
  
  boolean isNew() {
    return frameCount - created < 30;
  }
  
  void draw(PGraphics applet) {
    super.draw(applet);

    preDraw(applet);
    
    World world = worlds.get(worldInd);    
    int yTint = 0;
    
    if (!isNew()) {
      int tintScaleY = world.getTintScaleY(getX());
      yTint = round((getY() - tintScaleY) * 3);
    }
    
    int tint = max(0, min(255, worldInd * 60 + yTint));    
    fill(0);
    stroke(0);
    textAlign(CENTER);
    text(isOne ? "1" : "0", 0, textOffset);
    postDraw(applet);
  }
  
}