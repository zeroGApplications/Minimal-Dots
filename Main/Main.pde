Saver s;
Board b;
Line l;
DrawerGUI themegui;
DrawerGUI resetgui;
boolean darkmode;

void setup() {
  //fullScreen();
  size(720, 1280);
  orientation(PORTRAIT);
  background(0);
  
  PImage theme_gui_icon = loadImage("ThemeGUIIcon.png");
  PImage reset_gui_icon = loadImage("ResetGUIIcon.png");
  
  ConstantData.initialize(width, height);
  
  s = new Saver(false);
  b = new Board(s);
  l = new Line(40);
  themegui = new DrawerGUI(
    new PVector(100, 150),
    new PVector(1,0),
    b.getThemePreview(),
    theme_gui_icon);
  resetgui = new DrawerGUI(
    new PVector(width-100,150),
    new PVector(-1,0),
    new int[]{#ff5577, #55ff77},
    reset_gui_icon);
  
  if(s.darkmode == 1) {
    darkmode = true;
    applyDarkmode();
  } else {
    darkmode = false;
  }
  
  textSize(50*ConstantData.gui_size_multiplyer);
  textAlign(RIGHT, CENTER);
  rectMode(CENTER);
  imageMode(CENTER);
}

void draw() {
  background(darkmode?0:255);
  
  if(mousePressed) {
    PVector coords = b.getCoordsAtMouse();
    if(coords != null) {
      if(!l.drawing) {
        l.beginDraw(b.getClrAt(
          int(coords.x),
          int(coords.y)));
      }
      if(l.points.size() < 1 ||
         b.isVonNeumannNeighbor(
         b.getCoordsAtPoint(
         l.getLast()), coords)) {
        if(b.getClrAt(
          int(coords.x),
          int(coords.y)) == l.clr) {
          l.feed(b.getPointAtCoords(
            int(coords.x),
            int(coords.y)));
        }
      }
    }
  }
  
  b.update();
  b.updateSelection(l);
  themegui.update();
  resetgui.update();
  
  b.show();
  l.show();
  themegui.show();
  resetgui.show();
}

void mouseReleased() {
  if(l.drawing) {
    int effect = b.clearLine(l);
    if(effect != -1) {
      b.activateSpecialEffect(effect);
    }
    l.reset();
  }
}

void mousePressed() {
  themegui.press();
  if(themegui.extended()) {
    int option = themegui.select();
    if(option != -1 && option != 3) {
      b.setTheme(option);
    } else if(option == 3) {
      darkmode = !darkmode;
      applyDarkmode();
    } else {
      themegui.close();
    }
  }
  
  resetgui.press();
  if(resetgui.extended()) {
    int option = resetgui.select();
    if(option == 1) {
      Saver tmp = new Saver(true);
      tmp.theme = b.theme;
      Board nb = new Board(tmp);
      b = nb;
      b.darkmode = darkmode; // refresh the Borads memory that it still is in darkmode (or not)
      b.setTheme(b.theme);
      resetgui.close();
    } else {
      resetgui.close();
    }
  }
}

void stop() {
  s.saveData(b);
}

void applyDarkmode() {
  themegui.darkmode = darkmode;
  resetgui.darkmode = darkmode;
  b.darkmode = darkmode;
  b.setTheme(b.theme);
  themegui.clrs = b.getThemePreview();
}
