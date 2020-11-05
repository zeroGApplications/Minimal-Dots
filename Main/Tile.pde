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
    r_start = 60*ConstantData.gui_size_multiplyer;
    r = r_start;
    r_end = 60*ConstantData.gui_size_multiplyer;
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
    r_start = nr_start*ConstantData.gui_size_multiplyer;
    r_end = nr_end*ConstantData.gui_size_multiplyer;
    selected = false;
  }
  
  public Tile(PVector nstart, int nclr_id) {
    start = nstart;
    pos = start;
    r_start = 60*ConstantData.gui_size_multiplyer;
    r = r_start;
    r_end = 60*ConstantData.gui_size_multiplyer;
    clr_id = nclr_id;
    done = false;
    if(random(0,1)>0.99) {
      special = true;
    }
    selected = false;
  }
  
  public float formula(float x) {
    return -0.5*exp(-6*x)*(-2*exp(6*x)+sin(8*x)+2*cos(8*x));
  }
  
  public void show(int[] clrs) {
    float margin = 20*ConstantData.gui_size_multiplyer;
    if(selected) {
      r += margin;
    }
    if(special) {
      if(selected) {
        fill(clrs[clr_id]);
      } else {
        noFill();
      }
      stroke(clrs[clr_id]);
      strokeWeight(20);
      rect(pos.x,pos.y,r-margin,r-margin, 10);
    } else {
      noStroke();
      fill(clrs[clr_id]);
      ellipse(pos.x,pos.y,r,r);
    }
    if(selected) {
      r -= margin;
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
