public class Line {
	
	ArrayList<PVector> points;
	ArrayList<Color> colors;
	PVector last_mouse_coords;
	Color mix_color;
	int cooldown;
	boolean drawing;
	boolean multicolored;
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
	}

	public void update(Board board) {
		PVector coords = new PVector();
		if(!isValidMousePosition(board, coords)) {
			return;
		}

		if (points.size() > 1 && pointsEqual(coords, board.getCoordsAtPoint(getSecondToLast()))) {
			removeLastSelection();
			return;
		}

		int x = int(coords.x);
		int y = int(coords.y);
		for (PVector point : points) {
			if (pointsEqual(point, board.getPointAt(x, y))) {
				return;
			}
		}

		Color current_color = board.getClrAt(x, y);
		boolean becoming_multicolored = !colors.isEmpty() && !current_color.equals(colors.get(0));
		int combined_weight = getCombinedWeight() + current_color.weight();
		if (multicolored || becoming_multicolored) {
			if (points.size() > 8 || combined_weight > 9 || board.getTileAt(x, y).special()) {
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
		}
	}
	
	public void feed(PVector point) {
		points.add(point);
	}
	
	public void show() {    
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

	public void mixColors() {
		mix_color = Color.fromMixColors(colors);
		multicolored = !mix_color.equals(colors.get(0));
	}

	public int getCombinedWeight() {
		int result = 0;
		for (Color clr : colors) {
			result += clr.weight();
		}
		return result;
	}

	public void removeLastSelection() {
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
