public class Tile {
  
  PVector start;
  PVector end;
  PVector pos;
  float r_start;
  float r_end;
  float r;
  float t = 0;
  int clr_id;
  boolean done;
  boolean special;
  boolean selected;
  
  public Tile(PVector nstart, PVector nend, int nclr_id) {
    start = nstart;
    pos = start;
    end = nend;
    r_start = 60;
    r = r_start;
    r_end = 60;
    clr_id = nclr_id;
    done = false;
    selected = false;
  }
  
  public Tile(PVector nstart, PVector nend, 
              int nclr_id, 
              float nr_start, float nr_end) {
    start = nstart;
    pos = start;
    end = nend;
    clr_id = nclr_id;
    done = false;
    r_start = nr_start;
    r_end = nr_end;
    selected = false;
  }
  
  public Tile(PVector nstart, int nclr_id) {
    start = nstart;
    pos = start;
    r_start = 60;
    r = r_start;
    r_end = 60;
    clr_id = nclr_id;
    done = false;
    if(random(0,1)>0.99) {
      special = true;
    }
    selected = false;
  }
  
  public float formula(float x) {
    return -0.5*exp(-6*x)*(-2*exp(6*x)+sin(8*x)+2*cos(8*x));
    //(-pow(cos(x*TWO_PI),0.2)+1)/2.0f;
  }
  
  public void show(int[] clrs) {
    if(selected) {
      r += 20;
    }
    if(special) {
      if(selected) {
        fill(clrs[clr_id]);
      } else {
        noFill();
      }
      stroke(clrs[clr_id]);
      strokeWeight(20);
      rect(pos.x,pos.y,r-20,r-20, 10);
    } else {
      noStroke();
      fill(clrs[clr_id]);
      ellipse(pos.x,pos.y,r,r);
    }
    if(selected) {
      r -= 20;
    }
  }
  
  public void update() {
    if(end == null) {
      return;
    }
    float tmp = formula(t);
    pos = PVector.lerp(start, end, tmp);
    r = lerp(r_start, r_end, tmp);
    if(t < 1) {
      t += 0.02;
    } else {
      done = true;
    }
  }
  
  public void reset() {
    t = 0;
    if(end != null) {
      start = end.copy();
      end = null;
    }
    done = false;
  }
  
  public void select() {
    selected = true;
  }
  public void deselect() {
    selected = false;
  }
}