public class Saver {
  
  String filename;
  
  
  // gamedata to be saved
  int theme;
  int darkmode;
  int[] scores;
  int[] high_scores; // optional
  int[][] board_data;
  int[][] specials_map;

  public Saver(boolean reset) {
    filename = "save_file.txt";
    
    theme = 0;
    darkmode = 0;
    scores = new int[4];
    high_scores = new int[4];
    board_data = new int[10][10];
    specials_map = new int[10][10];
    
    File f = dataFile(filename);
    if(f.isFile() && !reset) {
      loadData();
    } else {
      String[] arr = new String[]{""};
      saveStrings(filename, arr);
      
      generateFresh();
    }
    
    noStroke();
  }
  
  public void generateFresh() {
    scores = new int[]{0,0,0,0};
    high_scores = new int[]{0,0,0,0};
    for(int x=0;x<10;x++) {
      for(int y=0;y<10;y++) {
        board_data[x][y] = int(random(0,4));
      }
    }
  }

  public void loadData() {
    try {
      String[] lines = loadStrings(filename);
      theme = int(lines[0]);
      darkmode = int(lines[1]);
      scores = int(split(lines[2], ' '));
      high_scores = int(split(lines[3], ' '));
      for(int y=0;y<10;y++) {
        board_data[y] = int(split(lines[4+y], ' '));
      }
      for(int y=0;y<10;y++) {
        specials_map[y] = int(split(lines[14+y], ' '));
      }
    } catch(IndexOutOfBoundsException e) {
      println("Error: data not loaded");
      generateFresh();
    }
  }

  public void saveData(Board board) {
    String[] res = new String[24];
    res[0] = nf(board.theme, 0);
    res[1] = nf(board.darkmode?1:0, 0);
    res[2] = join(nf(board.scores, 0), ' ');
    res[3] = "0 0 0 0";
    for(int y=0;y<10;y++) {
      res[4+y] = join(nf(board.f[y], 0), ' ');
    }
    for(int x=0;x<10;x++) {
      String tmp = "";
      for(int y=0;y<10;y++) {
        if(board.f_show.get(x).get(y).special) {
          tmp += "1 ";
        } else {
          tmp += "0 ";
        }
      }
      res[14+x] = tmp;
    }
    saveStrings(filename, res);
  }
  
  
  
}