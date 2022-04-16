import java.util.Arrays;
import java.util.List;

public class Board {
	
	int wdh;
	int hgt;
	int[][] field;
	ArrayList<ArrayList<Tile>> tiles;
	
	int theme;
	int[][] themes;
	int[][] dark_themes;
	IntList colors;
	int[] scores;
	int[] scores_goal;
	int[] highscores;
	
	float spacing;
	PVector offset;
	float score_radius;
	
	ArrayList<Tile> animated_tiles;
		
	public Board(Saver saver) {
		spacing = 90 * GUI_SIZE_MULTIPLYER;
		score_radius = 30 * GUI_SIZE_MULTIPLYER;
		
		int field_size = width / int(spacing);
		wdh = min(10,field_size);
		hgt = wdh;
		
		offset = new PVector(
		   (width - ((wdh - 1) * spacing)) / 2.0,
		   (height - ((hgt - 1) * spacing)) / 2.0);
		
		
		theme = saver.theme;
		themes = new int[][]{
			{#ffdd77, #77ddff, #ddff77, #ff77dd} ,
			{#ffcc33, #3388ff, #33dd55, #ff3333} ,
			{#ffe66d, #4ecdc4, #292f36 ,#ff6b7b} ,
			{#00BDFE, #FF0198, #FEE600 ,#000000} ,
			{0} ,
		};
		dark_themes = new int[][]{
			{#eac435, #345995, #03cea4, #ca1551} ,
			{#ffcc33, #3388ff, #33dd55, #ff3333} ,
			{#ffe66d, #4ecdc4, #eef4ed ,#ff6b7b} ,
			{#00BDFE, #FF0198, #FEE600 ,#ffffff} ,
			{255} ,
		};
		
		colors = new IntList(themes[theme]);
		scores = saver.scores;
		scores_goal = new int[scores.length];
		for (int i = 0; i < scores.length; i++) {
			scores_goal[i] = scores[i];
		}
		highscores = saver.highscores;
		
		field = new int[wdh][hgt];
		tiles = new ArrayList<ArrayList<Tile>>();
		
		for (int x = 0; x < wdh; x++) {
			tiles.add(new ArrayList<Tile>());
			
			for (int y = 0; y < hgt; y++) {
				field[x][y] = saver.board_data[x][y];
				
				tiles.get(x).add(new Tile(getPointAtCoords(x,y), field[x][y]));
				tiles.get(x).get(y).effect = EffectType.NONE;
			}
		}
		
		for (int x = 0; x < wdh; x++) {
			for (int y = 0; y < hgt; y++) {
				tiles.get(x).get(y).effect = saver.specials_map[x][y];
			}
		}
		
		animated_tiles = new ArrayList<Tile>();
	}
	
	void show() {
		for (int x = 0; x < wdh; x++) {
			for (int y = 0; y < hgt; y++) {
				if (field[x][y] != -1) {
					if (tiles.get(x).size() > y) {
						tiles.get(x).get(y).show(colors);
					}
				}
			}
		}
		
		for (int i = 0; i < scores.length; i++) {
			noStroke();
			fill(DARKMODE ? 255 : 0);
			PVector spos = getScoresLocation(i);
			text(number(scores[i]), spos.x - 25 * GUI_SIZE_MULTIPLYER, spos.y);
			fill(colors.get(i));
			ellipse(spos.x,spos.y,score_radius,score_radius);
			if (highscores[i] > scores[i]) {
				stroke(colors.get(i));
				strokeWeight(score_radius);
				rect(spos.x, spos.y - 95 * GUI_SIZE_MULTIPLYER, 130 * GUI_SIZE_MULTIPLYER, 50 * GUI_SIZE_MULTIPLYER, 5);
				
				if (brightness(colors.get(i)) > 100) {
					fill(0);
				} else {
					fill(255);
				}
				
				textAlign(CENTER, CENTER);
				text(number(highscores[i]), spos.x, spos.y - 100 * GUI_SIZE_MULTIPLYER);
				textAlign(RIGHT, CENTER);
			} 
		}
		
		if (animated_tiles.size() > 0) {
			for (Tile tile : animated_tiles) {
				tile.show(colors);
			}
		}
	}
	
	public void update() {
		for (int x = 0; x < wdh; x++) {
			for (int y = 0; y < hgt; y++) {
				if (tiles.get(x).size() > y) {
					tiles.get(x).get(y).update();
					if (tiles.get(x).get(y).done) {
						tiles.get(x).get(y).reset();
					}
				}
			}
		}  
		
		if (animated_tiles.size() > 0) {
			for (Tile tile : animated_tiles) {
				tile.update();
			}
			for (int i = 0; i < animated_tiles.size(); i++) {
				Tile tmp = animated_tiles.get(i);
				if (tmp.done) {
					animated_tiles.remove(i);
					i--;
				}
			}
		}
		
		for (int i = 0; i < scores.length; i++) {
			assert(scores[i] <= scores_goal[i]);
			if (highscores[i] < scores[i]) {
				highscores[i] = scores[i];
			}
			if (scores_goal[i] > scores[i]) {
				scores[i]++;
			}
		}
	}
	
	public void updateSelection(Line line) {
		for (int x = 0; x < wdh; x++) {
			for (int y = 0; y < hgt; y++) {
				tiles.get(x).get(y).deselect();
			}
		}
		for (PVector point : line.points) {
			PVector coord = getCoordsAtPoint(point);
			int px = int(coord.x);
			int py = int(coord.y);
			tiles.get(px).get(py).select(line.mix_color);
		}
	}
	
	public String number(int num) {
		if (num >= 10000) {
			return nf(num / 1000.0f, 0, 1) + "k";
		} else if (num >= 1000) {
			return nf(num / 1000.0f, 0, 2) + "k";
		} else {
			return num + "";
		}
	}
	
	public PVector getScoresLocation(int index) {
		float xi = width / 2.0
			- ((scores.length - 1) / 2.0) * 210 * GUI_SIZE_MULTIPLYER
			+ index * 210 * GUI_SIZE_MULTIPLYER;
		float y = height - 250 * GUI_SIZE_MULTIPLYER;
		return new PVector(xi, y);
	}
	
	PVector getCoordsAtMouse() {
		return getCoordsAtPoint(new PVector(mouseX + spacing / 2.0, mouseY  + spacing / 2.0));
	}
	
	PVector getCoordsAtPoint(PVector point) {
		int res_x = int((point.x - offset.x) / spacing);
		int res_y = int((point.y - offset.y) / spacing);
		if (res_x < 0 || res_x >= wdh || res_y < 0 || res_y >= hgt || field[res_x][res_y] == -1) {
			return null;
		}
		return new PVector(res_x, res_y);
	}
	
	PVector getPointAtCoords(int x, int y) {
		float res_x = offset.x + x * spacing;
		float res_y = offset.y + y * spacing;
		return new PVector(res_x, res_y);
	}
	
	int getClrAt(int x, int y) {
		return colors.get(field[x][y]);
	}
	
	public boolean isVonNeumannNeighbor(PVector p1, PVector p2) {
		int diffx = abs(int(p1.x) - int(p2.x));
		int diffy = abs(int(p1.y) - int(p2.y));
		return diffx + diffy == 1;
	}
	
	public void clearLine(Line line, LinkedList<Effect> effects) {
		if (line.points.size() < 3) {
			return;
		}
		for (PVector point : line.points) {
			PVector coord = getCoordsAtPoint(point);
			int px = int(coord.x);
			int py = int(coord.y);
			scores_goal[field[px][py]]++;
			
			Tile tile = new Tile(point, getScoresLocation(field[px][py]), field[px][py], 80, 30);
			
			animated_tiles.add(tile);
			
			if (tiles.get(px).get(py).effect != EffectType.NONE) {
				EffectType effectType = tiles.get(px).get(py).effect;
				Effect effect = new Effect(effectType);
				tiles.get(px).get(py).effect = EffectType.NONE;
				switch(effect.effect) {
					case NONE: break;
					case CLEAR_COLOR: effect.clr = field[px][py]; break;
					case CLEAR_LINE_HORIZONTAL: effect.position.y = py; break;
					case CLEAR_LINE_VERTICAL: effect.position.x = px; break;
				}
				effects.add(effect);
			}
			field[px][py] = -1;
			tiles.get(px).set(py, null);
		}
		
		fall();
		
		for (int x = 0; x < wdh; x++) {
			for (int y = 0; y < tiles.get(x).size(); y++) {
				if (tiles.get(x).get(y) == null) {
					tiles.get(x).remove(y);
					y--;
				}
			}
		}
		for (int x = 0; x < wdh; x++) {
			int diff = hgt - tiles.get(x).size();
			if (diff > 0) {
				for (int i = 0; i < diff; i++) {
					tiles.get(x).add(0,new Tile(
						new PVector(offset.x + x * spacing,offset.y - (i + 1) * spacing),
						field[x][diff - 1 - i]));
				}
			}
			for (int y = 0; y < hgt; y++) {
				PVector tmp = getCoordsAtPoint(tiles.get(x).get(y).pos);
				if (tmp == null || int(tmp.y) != y) {
					tiles.get(x).get(y).reset();
					tiles.get(x).get(y).end = getPointAtCoords(x,y);
				}
			}
		} 
	}
	
	public void fall() {
		for (int x = 0; x < wdh; x++) {
			int index = hgt - 1;
			for (int y = hgt - 1; y >=  0; y--) {
				int tmp = field[x][y];
				if (tmp != -1) {
					field[x][y] = -1;
					field[x][index] = tmp;
					index--;
				}
			}
		}
		
		for (int y = 0; y < hgt; y++) {
			for (int x = 0; x < wdh; x++) {
				if (field[x][y] == -1) {
					field[x][y] = int(random(0,4));
				}
			}
		}
	}
	
	public int[] getThemePreview() {
		int[] res = new int[themes.length];
		for (int i = 0; i < themes.length; i++) {
			if (DARKMODE) {
				res[i] = dark_themes[i][0];
			} else {
				res[i] = themes[i][0];
			}
		}
		return res;
	}
	
	public void setTheme(int index) {
		theme = index;
		if (DARKMODE) {
      		colors = new IntList(dark_themes[theme]);
		} else {
			colors = new IntList(themes[theme]);
		}
	}
}
