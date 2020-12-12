public class Effect {
  
  Line line;
  ConstantData.EffectType effect;
  PVector pos;
  int clr;
  
  public Effect(ConstantData.EffectType neffect) {
    effect = neffect;
    pos = new PVector(0,0);
    clr = 0;
  }
  
  public void constructLine(Board board) {
    line = new Line(-1);
    switch(effect) {
      case NONE: break;
      case CLEAR_COLOR: construcClearColorLine(board); break;
      case CLEAR_LINE_HORIZONTAL: construcClearHorizontalLine(board); break;
      case CLEAR_LINE_VERTICAL: construcClearVerticalLine(board); break;
    }
  }
  
  public void construcClearColorLine(Board board) {
    for(int y=0;y<board.hgt;y++) {
      for(int x=0;x<board.wdh;x++) {
        if(board.f[x][y] == clr) {
          line.feed(board.getPointAtCoords(x,y));
        }
      }
    }
  }
  
  public void construcClearHorizontalLine(Board board) {
    for(int x=0;x<board.wdh;x++) {
      line.feed(board.getPointAtCoords(x, int(pos.y)));
    }
  }
  
  public void construcClearVerticalLine(Board board) {
    for(int y=0;y<board.hgt;y++) {
      line.feed(board.getPointAtCoords(int(pos.x), y));
    }
  }
}
