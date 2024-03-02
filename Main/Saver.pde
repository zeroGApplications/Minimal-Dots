import java.io.File;

public class Saver {
	
	String filename;
	
	
	// gamedata to be saved
	int theme;
	int darkmode;
	int[] scores;
	int[] highscores;
	int[][] board_data;
	EffectType[][] specials_map;

	public Saver(boolean reset) {
		filename = sketchPath("save_file.txt");
		
		theme = 0;
		darkmode = 0;
		scores = new int[4];
		highscores = new int[4];
		board_data = new int[10][10];
		specials_map = new EffectType[10][10];

		File f = new File(filename);
		if (f.isFile() && !reset) {
			loadData();
		} else {
			String[] arr = new String[]{""};
			saveStrings(filename, arr);
			generateFresh();
		}
		
		noStroke();
	}
	
	public void generateFresh() {
		scores = new int[]{0, 0, 0, 0};
		highscores = new int[]{0, 0, 0, 0};
		for (int x = 0; x < 10; x++) {
			for (int y = 0; y < 10; y++) {
				board_data[x][y] = int(random(0, 4));
				specials_map[x][y] = EffectType.NONE;
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
			for (int y = 0; y < 10; y++) {
				board_data[y] = int(split(lines[4 + y], ' '));
			}
			for (int y = 0; y < 10; y++) {
				for (int x = 0; x < 10; x++) {
					int effectIndex = int(split(lines[14 + y], ' ')[x]);
					specials_map[y][x] = EffectType.values()[effectIndex];
				}
			}
		} catch(IndexOutOfBoundsException e) {
			println("Error: data not loaded");
			generateFresh();
		}
	}

	public void saveData(Board board) {
		String[] res = new String[24];
		res[0] = nf(board.theme, 0);
		res[1] = nf(DARKMODE ? 1 : 0, 0);
		res[2] = join(nf(board.scores, 0), ' ');
		res[3] = join(nf(board.highscores, 0), ' ');
		for(int y = 0; y < 10; y++) {
			res[4 + y] = join(nf(board.field[y], 0), ' ');
		}
		for(int x = 0; x < 10; x++) {
			String[] tmp = new String[10];
			for(int y = 0; y < 10; y++) {
				tmp[y] = nf(board.tiles.get(x).get(y).effect.ordinal(), 0);
			}
			res[14 + x] = join(tmp, ' ');
		}
		saveStrings(filename, res);
	}
	
	
	
}
