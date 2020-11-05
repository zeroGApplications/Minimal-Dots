public class DrawerGUI {
  
  PVector pos;
  PVector dim;
  float length;
  float t;
  float r;
  boolean dir;
  boolean active;
  int options;
  float r_opt;
  float s;
  float padding;
  int[] clrs;
  boolean darkmode;
  PImage icon;
  
  public DrawerGUI(PVector npos, PVector ndim, int[] nclrs, PImage nicon) {
    pos = npos;
    dim = ndim;
    options = nclrs.length;
    padding = 40*ConstantData.gui_size_multiplyer;
    t = 0;
    r = 120*ConstantData.gui_size_multiplyer;
    dir = false;
    active = false;
    r_opt = r-padding;
    length = options*r;
    s = (length-padding)/options;
    clrs = nclrs;
    darkmode = false;
    icon = nicon;
  }
  
  public void show() {
    int clr1 = darkmode?100:220;
    int clr2 = darkmode?80:240;
    
    if(t > 0) {
      stroke(clr2);
      strokeWeight(r);
      
      float tmpx = pos.x+dim.x*length;
      float tmpy = pos.y+dim.y*length;
      float ftmp = getFormulaValue();
      tmpx = lerp(pos.x,tmpx,ftmp);
      tmpy = lerp(pos.y,tmpy,ftmp);
      line(pos.x, pos.y, tmpx, tmpy);
      
      
      for(int i=0; i<options; i++) {
        PVector tmp = getOptionPosition(i);
        if(dim.x*tmpx+padding > dim.x*tmp.x) {
          noStroke();
          fill(clrs[i]);
          ellipse(tmp.x, tmp.y, r_opt, r_opt);
        }
      }
    }
    
    noStroke();
    fill(clr1);
    ellipse(pos.x,pos.y,r,r);
    if(active) {
      float tmp = getFormulaValue();
      translate(pos.x,pos.y);
      rotate(-TWO_PI*tmp);
      drawIcon(0,0);
      rotate(TWO_PI*tmp);
      translate(-pos.x,-pos.y);
      
    } else {
      drawIcon(pos.x,pos.y);
    }
  }
  
  private void drawIcon(float nx, float ny) {
    tint(darkmode?180:120);
    image(icon,nx,ny,r-padding,r-padding);
    noTint();
  }
  
  public void update() {
    if(!active) {
      return;
    }
    if(!dir) {
      if(t < 1) {
        t += 0.05;
      } else {
        dir = true;
        active = false;
      }
      return;
    }
    
    if(dir && t > 0) {
      t -= 0.05;
    } else {
      dir = false;
      active = false;
    }
  }
  
  public void press() {
    if(dist(mouseX,mouseY,pos.x,pos.y) <= r*0.8) {
      active = true;
    }
  }
  
  public float formula(float x) {
    return -0.5*exp(-6*x)*(-2*exp(6*x)+sin(8*x)+2*cos(8*x));
  }
  
  public PVector getOptionPosition(int index) {
    return new PVector(pos.x+(dim.x*length)-(dim.x*s*index), pos.y);
  }
  
  public int select() {
    for(int i=0; i<options; i++) {
      PVector tmp = getOptionPosition(i);
      if(dist(mouseX,mouseY,tmp.x,tmp.y) <= r_opt*0.8) {
        return i;
      }
    }
    return -1;
  }
  
  public boolean extended() {
    return !active && t > 0;
  }
  
  public void close() {
    active = true;
  }
  
  public float getFormulaValue() {
    float res = 1;
    if(t < 1 && !dir) {
      res = formula(t);
    } else if(t > 0 && dir) {
      res = max(0,1-formula(1-t));
    }
    return res;
  }
}
