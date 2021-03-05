public class Board {
  
  int wdh;
  int hgt;
  int[][] f; // field
  ArrayList<ArrayList<Tile>> f_show;
  
  int theme;
  int[][] themes;
  int[][] dark_themes;
  int[] clrs;
  int[] scores;
  int[] scores_goal;
  int[] highscores;
  
  float r;
  float s;
  PVector o;
  float score_r;
  
  ArrayList<Tile> animated_tiles;
  
  boolean darkmode;
  
  public Board(Saver saver) {
    r = 60*ConstantData.gui_size_multiplyer;
    s = 90*ConstantData.gui_size_multiplyer;
    
    score_r = 30*ConstantData.gui_size_multiplyer;
    
    int field_size = width/int(s);
    wdh = min(10,field_size);
    hgt = wdh;
    
    o = new PVector(
      (width-((wdh-1)*s))/2.0,
      (height-((hgt-1)*s))/2.0);
    
    
    theme = saver.theme;
    themes = new int[][]{
      {#ffdd77, #77ddff, #ddff77, #ff77dd},
      {#ffcc33, #3388ff, #33dd55, #ff3333},
      {#ffe66d, #4ecdc4, #292f36 ,#ff6b7b},
      {0},
    };
    dark_themes = new int[][]{
      {#eac435, #345995, #03cea4, #ca1551},
      {#ffcc33, #3388ff, #33dd55, #ff3333},
      {#ffe66d, #4ecdc4, #eef4ed ,#ff6b7b},
      {255},
    };
    
    clrs = themes[theme];
    scores = saver.scores;
    scores_goal = new int[scores.length];
    for(int i=0;i<scores.length;i++) {
      scores_goal[i] = scores[i];
    }
    highscores = saver.highscores;
    
    f = new int[wdh][hgt];
    f_show = new ArrayList<ArrayList<Tile>>();
      
    for(int x=0;x<wdh;x++) {
      f_show.add(new ArrayList<Tile>());
      
      for(int y=0;y<hgt;y++) {
        f[x][y] = saver.board_data[x][y];
        
        f_show.get(x).add(
          new Tile(getPointAtCoords(x,y),
                   f[x][y]));
        f_show.get(x).get(y).special = false;
      }
    }
    
    for(int x=0;x<wdh;x++) {
      for(int y=0;y<hgt;y++) {
        if(saver.specials_map[x][y] == 1) {
          f_show.get(x).get(y).special = true;
        }
      }
    }
      
    animated_tiles = new ArrayList<Tile>();
    darkmode = false;
  }
  
  void show() {
    for(int x=0;x<wdh;x++) {
      for(int y=0;y<hgt;y++) {
        if(f[x][y] != -1) {
          if(f_show.get(x).size() > y) {
            f_show.get(x).get(y).show(clrs);
          }
        }
      }
    }

    for(int i=0;i<scores.length;i++) {
      noStroke();
      fill(darkmode?255:0);
      PVector spos = getScoresLocation(i);
      text(number(scores[i]),
        spos.x-25*ConstantData.gui_size_multiplyer,
        spos.y);
      fill(clrs[i]);
      ellipse(spos.x,spos.y,score_r,score_r);
      if(highscores[i] > scores[i]) {
        
        stroke(clrs[i]);
        strokeWeight(score_r);
        rect(spos.x,
             spos.y-95*ConstantData.gui_size_multiplyer,
             130*ConstantData.gui_size_multiplyer,
             50*ConstantData.gui_size_multiplyer,10);
             
        if(brightness(clrs[i]) > 100) {
          fill(0);
        } else {
          fill(255);
        }
        
        textAlign(CENTER, CENTER);
        text(number(highscores[i]),
        spos.x,
        spos.y-100*ConstantData.gui_size_multiplyer);
        textAlign(RIGHT, CENTER);
      }
      
    }
    
    if(animated_tiles.size() > 0) {
      for(Tile tile : animated_tiles) {
        tile.show(clrs);
      }
    }
  }
  
  public void update() {
    for(int x=0;x<wdh;x++) {
      for(int y=0;y<hgt;y++) {
        if(f_show.get(x).size() > y) {
           f_show.get(x).get(y).update();
          if(f_show.get(x).get(y).done) {
            f_show.get(x).get(y).reset();
          }
        }
      }
    }  
        
    if(animated_tiles.size() > 0) {
      for(Tile tile : animated_tiles) {
        tile.update();
      }
      for(int i=0;i<animated_tiles.size();i++) {
        Tile tmp = animated_tiles.get(i);
        if(tmp.done) {
          animated_tiles.remove(i);
          i--;
        }
      }
    }
    
    for(int i=0; i<scores.length; i++) {
      assert(scores[i] <= scores_goal[i]);
      if(highscores[i] < scores[i]) {
        highscores[i] = scores[i];
      }
      if(scores_goal[i] > scores[i]) {
        scores[i]++;
      }
    }
  }
  
  public void updateSelection(Line line) {
    for(int x=0;x<wdh;x++) {
      for(int y=0;y<hgt;y++) {
        f_show.get(x).get(y).deselect();
      }
    }
    for(PVector pnt : line.points) {
      PVector coord = getCoordsAtPoint(pnt);
      int px = int(coord.x);
      int py = int(coord.y);
      f_show.get(px).get(py).select();
    }
  }
  
  public String number(int num) {
    if(num > 9990) {
      return nf(num/1000.0f, 0, 1)+"k";
    } else if(num > 999) {
      return nf(float(num)/1000.0, 0, 2)+"k";
    } else {
      return num+"";
    }
  }
  
  public PVector getScoresLocation(int index) {
    float xi = width/2.0
        -((scores.length-1)/2.0)*210*ConstantData.gui_size_multiplyer
        +index*210*ConstantData.gui_size_multiplyer;
    float y = height-250*ConstantData.gui_size_multiplyer;
    return new PVector(
      xi,
      y);
  }
  
  PVector getCoordsAtMouse() {
    int res_x = int((mouseX+s/2.0-o.x)/s);
    int res_y = int((mouseY+s/2.0-o.y)/s);
    if(res_x < 0 || res_x >= wdh ||
       res_y < 0 || res_y >= hgt ||
       f[res_x][res_y] == -1) {
      return null;
    }
    return new PVector(res_x,res_y);
  }
  
  PVector getCoordsAtPoint(PVector pnt) {
    int res_x = int((pnt.x-o.x)/s);
    int res_y = int((pnt.y-o.y)/s);
    if(res_x < 0 || res_x >= wdh ||
       res_y < 0 || res_y >= hgt ||
       f[res_x][res_y] == -1) {
      return null;
    }
    return new PVector(res_x,res_y);
  }
  
  PVector getPointAtCoords(int nx, int ny) {
    float res_x = o.x+nx*s;
    float res_y = o.y+ny*s;
    return new PVector(res_x, res_y);
  }
  
  int getClrAt(int x, int y) {
    return clrs[f[x][y]];
  }
  
  public boolean isVonNeumannNeighbor(PVector p1, PVector p2) {
    int diffx = abs(int(p1.x)-int(p2.x));
    int diffy = abs(int(p1.y)-int(p2.y));
    return diffx+diffy == 1;
  }
  
  public int clearLine(Line line) { // returns special-effect color-id
    int res = -1;
    if(l.points.size() < 3) {
      return res;
    }
    for(PVector pnt : line.points) {
      PVector coord = getCoordsAtPoint(pnt);
      int px = int(coord.x);
      int py = int(coord.y);
      scores_goal[f[px][py]]++;
      
      Tile tile = new Tile(
        pnt,
        getScoresLocation(f[px][py]),
        f[px][py],
        80,30);
      
      animated_tiles.add(tile);
      
      if(f_show.get(px).get(py).special) {
        res = f[px][py];
      }
      f[px][py] = -1;
      f_show.get(px).set(py, null);
    }
    fall();
    for(int x=0;x<wdh;x++) {
      for(int y=0;y<f_show.get(x).size();y++) {
        if(f_show.get(x).get(y) == null) {
          f_show.get(x).remove(y);
          y--;
        }
      }
    }
    for(int x=0;x<wdh;x++) {
      int diff = hgt - f_show.get(x).size();
      if(diff > 0) {
        for(int i=0;i<diff;i++) {
          f_show.get(x).add(0,new Tile(
            new PVector(o.x+x*s,o.y-(i+1)*s),
            f[x][diff-1-i]));
        }
      }
      for(int y=0;y<hgt;y++) {
        PVector tmp = getCoordsAtPoint(f_show.get(x).get(y).pos);
        if(tmp == null || int(tmp.y) != y) {
          f_show.get(x).get(y).reset();
          f_show.get(x).get(y).end = getPointAtCoords(x,y);
        }
      }
    }
    
    return res;
  }
  
  public void fall() {
    for(int x=0; x<wdh; x++) {
      int index = hgt-1;
      for(int y=hgt-1; y>=0; y--) {
        int tmp = f[x][y];
        if(tmp != -1) {
          f[x][y] = -1;
          f[x][index] = tmp;
          index--;
        }
      }
    }
    
    for(int y=0;y<hgt;y++) {
      for(int x=0;x<wdh;x++) {
        if(f[x][y] == -1) {
          f[x][y] = int(random(0,4));
        }
      }
    }
  }
  
  public void activateSpecialEffect(int val) {
    Line tmp = new Line(-1);
    for(int y=0;y<hgt;y++) {
      for(int x=0;x<wdh;x++) {
        if(f[x][y] == val) {
          tmp.feed(getPointAtCoords(x,y));
        }
      }
    }
    clearLine(tmp);
  }
  
  public int[] getThemePreview() {
    int[] res = new int[themes.length];
    for(int i=0;i<themes.length;i++) {
      if(darkmode) {
        res[i] = dark_themes[i][0];
      } else {
        res[i] = themes[i][0];
      }
    }
    return res;
  }
  
  public void setTheme(int index) {
    theme = index;
    if(darkmode) {
      clrs = dark_themes[theme];
    } else {
      clrs = themes[theme];
    }
  }
  
  public boolean isEmpty() {
    int sum = 0;
    for(int i=0; i<4; i++) {
      sum += highscores[i];
      sum += scores[i];
    }
    for(int y=0;y<hgt;y++) {
      for(int x=0;x<wdh;x++) {
        sum += f[x][y];
      }
    }
    return sum == 0;
  }
}
