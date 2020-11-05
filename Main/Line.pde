public class Line {
  
  ArrayList<PVector> points;
  int clr;
  boolean drawing;
  float r;
  
  public Line(float nr) {
    r = nr*ConstantData.gui_size_multiplyer;
    points = new ArrayList<PVector>();
    reset();
  }
  
  public void feed(PVector pnt) {
    if(points.size() > 1 && 
       pntsEqual(pnt, points.get(points.size()-2))) {
      removeLast();
      return;
    }
    for(PVector tmp : points) {
      if(pntsEqual(tmp, pnt)) {
        return;
      }
    }
    
    points.add(pnt);
  }
  
  public void reset() {
    points.clear();
    clr = 0;
    drawing = false;
  }
  
  public void beginDraw(int nclr) {
    drawing = true;
    clr = nclr;
  }
  
  public PVector getLast() {
    return points.get(points.size()-1);
  }
  
  public void removeLast() {
    points.remove(points.size()-1);
  }
  
  public void show() {    
    if(points.size() < 2) {
      return;
    }
   
    strokeWeight(r);
    for(int i=1; i<points.size(); i++) {
      PVector pnt = points.get(i);
      PVector prev_pnt = points.get(i-1);
      stroke(clr);
      line(pnt.x,pnt.y,prev_pnt.x,prev_pnt.y);
    }
  }
  
  public boolean pntsEqual(PVector p1, PVector p2) {
    if(p1 == null || p2 == null) {
      return false;
    }
    float EPSYLON = 0.01;
    return abs(p1.x-p2.x) < EPSYLON &&
           abs(p1.y-p2.y) < EPSYLON;
    
  }
}
