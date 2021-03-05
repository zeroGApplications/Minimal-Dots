public class Saver {
  
  String filename;
  
  
  // gamedata to be saved
  int theme;
  int darkmode;
  int[] scores;
  int[] highscores;
  int[][] board_data;
  int[][] specials_map;

  public Saver(boolean reset) {
    filename = "save_file.txt";
    
    theme = 0;
    darkmode = 0;
    scores = new int[4];
    highscores = new int[4];
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
  }
  
  public void generateFresh() {
    scores = new int[]{0,0,0,0};
    highscores = new int[]{0,0,0,0};
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
      highscores = int(split(lines[3], ' '));
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
    res[0] = str(board.theme);
    res[1] = board.darkmode?"1":"0";
    res[2] = join(toStringArray(board.scores), ' ');
    res[3] = join(toStringArray(board.highscores), ' ');
    for(int y=0;y<10;y++) {
      res[4+y] = join(toStringArray(board.f[y]), ' ');
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
  
  private String[] toStringArray(int[] arr) {
    String[] res = new String[arr.length];
    for(int i=0; i<arr.length; i++) {
      res[i] = str(arr[i]);
    }
    return res;
  }
}
