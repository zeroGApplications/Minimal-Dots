import java.util.Arrays;
import java.util.List;
import java.util.LinkedList;

public class Board {
	
	int wdh;
	int hgt;
	ArrayList<LinkedList<Tile>> tiles;
	
	int theme;
	int[][] themes;
	int[][] dark_themes;
	ArrayList<Color> colors;
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
		
		colors = new ArrayList<Color>(Arrays.asList(
			Color.Cyan(),
			Color.Magenta(),
			Color.Yellow(),
			Color.Black()
		));

		scores = saver.scores;
		scores_goal = new int[scores.length];
		for (int i = 0; i < scores.length; i++) {
			scores_goal[i] = scores[i];
		}
		highscores = saver.highscores;
		
		tiles = new ArrayList<LinkedList<Tile>>();
		
		for (int x = 0; x < wdh; x++) {
			tiles.add(new LinkedList<Tile>());
			
			for (int y = 0; y < hgt; y++) {				
				tiles.get(x).add(new Tile(getPointAt(x, y), saver.board_data[x][y]));
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
				if (tiles.get(x).size() > y) {
					tiles.get(x).get(y).show(this);
				}
			}
		}
		
		for (int i = 0; i < scores.length; i++) {
			noStroke();
			fill(DARKMODE ? 255 : 0);
			PVector spos = getScoresLocation(i);
			text(number(scores[i]), spos.x - 25 * GUI_SIZE_MULTIPLYER, spos.y);
			fill(rgb(colors.get(i)));
			ellipse(spos.x,spos.y,score_radius,score_radius);
			if (highscores[i] > scores[i]) {
				stroke(rgb(colors.get(i)));
				strokeWeight(score_radius);
				rect(spos.x, spos.y - 95 * GUI_SIZE_MULTIPLYER, 130 * GUI_SIZE_MULTIPLYER, 50 * GUI_SIZE_MULTIPLYER, 5);
				
				if (colors.get(i).luminocity() > 0.5) {
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
				tile.show(this);
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

	public int generateColorId() {
		return int(random(0, colors.size()));
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
		int res_y = hgt - int((point.y - offset.y) / spacing);
		if (res_x < 0 || res_x >= wdh || res_y < 0 || res_y >= hgt) {
			return null;
		}
		return new PVector(res_x, res_y);
	}
	
	PVector getPointAt(int x, int y) {
		float res_x = offset.x + x * spacing;
		float res_y = offset.y + (hgt - y) * spacing;
		return new PVector(res_x, res_y);
	}

	Tile getTileAt(int x, int y) {
		return tiles.get(x).get(y);
	}
	
	Color getClrAt(int x, int y) {
		return colors.get(getTileAt(x, y).clr_id);
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

		line.points.sort((p1, p2) -> new Float(p1.y).compareTo(new Float(p2.y)));

		if (line.multicolored) {
			colors.add(line.mix_color);
			ArrayList<Tile> kept_tiles = new ArrayList<Tile>();

			for (int i = 0; i < line.mix_color.multiplyer; i++) {
				PVector coord = getCoordsAtPoint(line.points.get(i));
				int px = int(coord.x);
				int py = int(coord.y);
				int new_clr_id = colors.size() - 1;
				getTileAt(px, py).clr_id = new_clr_id;
			}
			for (int i = line.mix_color.multiplyer; i < line.points.size(); i++) {
				PVector coord = getCoordsAtPoint(line.points.get(i));
				int px = int(coord.x);
				int py = int(coord.y);

				tiles.get(px).remove(py);
			}
		} else {
			for (PVector point : line.points) {
				PVector coord = getCoordsAtPoint(point);
				int px = int(coord.x);
				int py = int(coord.y);

        		Tile current_tile = getTileAt(px, py);

				Tile animated_tile = new Tile(point, new PVector(width/2.0, height - 100), current_tile.clr_id, 80, 30);
				animated_tiles.add(animated_tile);
				
				if (!current_tile.special()) {
					EffectType effectType = current_tile.effect;
					Effect effect = new Effect(effectType);
					current_tile.effect = EffectType.NONE;
					switch(effect.effect) {
						case NONE: break;
						case CLEAR_COLOR: effect.clr = current_tile.clr_id; break;
						case CLEAR_LINE_HORIZONTAL: effect.position.y = py; break;
						case CLEAR_LINE_VERTICAL: effect.position.x = px; break;
					}
					effects.add(effect);
				}

				//scores_goal[field[px][py]]++;
				tiles.get(px).remove(py);
			}
		}
		
		fall();
	}
	
	public void fall() {
		for (int x = 0; x < wdh; x++) {
			int line_height = tiles.get(x).size();
			for (int y = 0; y < line_height; y++) { 
				Tile current_tile = getTileAt(x, y);
				if (!pointsEqual(getPointAt(x, y), current_tile.pos)) {
					current_tile.start = current_tile.pos;
					current_tile.end = getPointAt(x, y);
				}
			}

			if (line_height == hgt) {
				continue;
			}

			for (int y = line_height; y < hgt; y++) {
				int y_index = hgt + y-line_height;
				tiles.get(x).add(new Tile(getPointAt(x, y_index), getPointAt(x, y), generateColorId()));
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
      		//colors = new IntList(dark_themes[theme]);
		} else {
			//colors = new IntList(themes[theme]);
		}
	}
}
