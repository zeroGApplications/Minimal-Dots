public class Line {
	
	ArrayList<PVector> points;
	ArrayList<Color> colors;
	PVector last_mouse_coords;
	Color mix_color;
	int cooldown;
	boolean drawing;
	boolean multicolored;
	int special_count;
	float radius;
	
	public Line(float nradius) {
		radius = nradius * GUI_SIZE_MULTIPLYER;
		points = new ArrayList<PVector>();
		colors = new ArrayList<Color>();
		last_mouse_coords = new PVector(-1, -1);
		reset();
	}

	public void reset() {
		points.clear();
		colors.clear();
		mix_color = new Color();
		cooldown = MULTICOLOR_COOLDOWN;
		drawing = false;
		multicolored = false;
		special_count = 0;
	}

	public void update(Board board) {
		PVector coords = new PVector();
		if(!isValidMousePosition(board, coords)) {
			return;
		}

		if (points.size() > 1 && pointsEqual(coords, board.getCoordsAtPoint(getSecondToLast()))) {
			removeLastSelection(board);
			return;
		}

		int x = int(coords.x);
		int y = int(coords.y);
		for (PVector point : points) {
			if (pointsEqual(point, board.getPointAt(x, y))) {
				return;
			}
		}

		Tile current_tile = board.getTileAt(x, y);
		Color current_color = board.getClrAt(x, y);
		boolean becoming_multicolored = !colors.isEmpty() && !current_color.equals(colors.get(0));
		int combined_weight = getCombinedWeight() + current_color.weight();
		if (multicolored || becoming_multicolored) {
			if (points.size() >= MAX_MULTICOLOR || combined_weight > MAX_MULTICOLOR || current_tile.special() || special_count > 0) {
				return;
			}
		}
		
		if (int(last_mouse_coords.x) == x && int(last_mouse_coords.y) == y && cooldown > 0) {
			cooldown--;
		} else {
			cooldown = MULTICOLOR_COOLDOWN;
		}
		last_mouse_coords = coords;

		if (!drawing) {
			drawing = true;
		}

		if (mix_color.equals(current_color) || cooldown == 0 || points.isEmpty() || multicolored) {
			feed(board.getPointAt(x, y));
			colors.add(current_color);
			mixColors();

			if (current_tile.special()) {
				special_count++;
			}
		}
	}
	
	public void feed(PVector point) {
		points.add(point);
	}
	
	public void show() {
		// the user is currently looking at one non primary tile
		boolean viewing_tile = !mix_color.isPrimary() && points.size() == 1;
		if (multicolored || viewing_tile) {
			showColorComponents();
		}

		if (points.size() < 2) {
			return;
		}
	 
		strokeWeight(radius);
		for (int i = 1; i < points.size(); i++) {
			PVector point = points.get(i);
			PVector prev_point = points.get(i - 1);
			stroke(rgb(mix_color));
			line(point.x, point.y, prev_point.x, prev_point.y);
		}
	}

	public void showColorComponents() {
		float spacing = 90 * GUI_SIZE_MULTIPLYER;
		noStroke();
		fill(240);
		rect(width / 2.0, height / 2.0 - spacing * 5.75, spacing * 6, spacing * 2.5, 20);

		if (multicolored) {
			rect(width / 2.0, height / 2.0 - spacing * 5.0, spacing * 6, spacing);

			noFill();
			stroke(rgb(mix_color));
			strokeWeight(5);
			rect(width / 2.0, height / 2.0 + spacing, spacing * 11, spacing * 11, 20);
		}

		int half = MAX_MULTICOLOR / 2;
		float x_offset = width / 2.0 - ((half - 1) / 2.0) * spacing;
		float y_offset = 400 * GUI_SIZE_MULTIPLYER;

		for (int i = 0; i < MAX_MULTICOLOR; i++) {
			noStroke();
			fill(255);
			float x = x_offset + (i % half) * spacing;
			float y = y_offset + (i / half) * spacing;
			float diameter = 50 * GUI_SIZE_MULTIPLYER; 
			ellipse(x, y, diameter, diameter);
		}

		int i = 0;
		for (Color clr : colors) {
			for (int j = 0; j < clr.weight(); j++) {
				if (j < clr.c) {
					fill(rgb(new Color().setCyan()));
				} else if(j-clr.c < clr.m) {
					fill(rgb(new Color().setMagenta()));
				} else if(j-clr.c-clr.m < clr.y) {
					fill(rgb(new Color().setYellow()));
				} else {
					fill(0);
				}

				float x = x_offset + (i % half) * spacing;
				float y = y_offset + (i / half) * spacing;
				float diameter = 55 * GUI_SIZE_MULTIPLYER; 
				ellipse(x, y, diameter, diameter);

				i++;
			}
		}
	}

	public void mixColors() {
		mix_color = new Color().fromMixColors(colors);
		multicolored = !mix_color.equals(colors.get(0));
	}

	public int getCombinedWeight() {
		int result = 0;
		for (Color clr : colors) {
			result += clr.weight();
		}
		return result;
	}

	public void removeLastSelection(Board board) {
		PVector coords = board.getCoordsAtPoint(points.get(points.size() - 1));
		Tile current_tile = board.getTileAt(int(coords.x), int(coords.y));
		if (current_tile.special()) {
			special_count--;
		}

		colors.remove(colors.size() - 1);
		points.remove(points.size() - 1);
		mixColors();
	}

	public PVector getLast() {
		return points.get(points.size() - 1);
	}

	public PVector getSecondToLast() {
		return points.get(points.size() - 2);
	}

	public boolean isValidMousePosition(Board board, PVector coords) {
		PVector result_coords = board.getCoordsAtMouse();
		if(result_coords == null) {
			return false;
		}
		coords.x = result_coords.x;
		coords.y = result_coords.y;

		return points.isEmpty() || board.isVonNeumannNeighbor(board.getCoordsAtPoint(getLast()), coords);
	}
}
