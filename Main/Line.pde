public class Line {
	
	ArrayList<PVector> points;
	ArrayList<Integer> colors;
	PVector last_mouse_coords;
	color mix_color;
	int cooldown;
	boolean drawing;
	boolean multicolored;
	float radius;
	
	public Line(float nradius) {
		radius = nradius * GUI_SIZE_MULTIPLYER;
		points = new ArrayList<PVector>();
		colors = new ArrayList<Integer>();
		last_mouse_coords = new PVector(-1, -1);
		reset();
	}

	public void reset() {
		points.clear();
		colors.clear();
		mix_color = 0;
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
			if (pointsEqual(point, board.getPointAtCoords(x, y))) {
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

		if (mix_color == board.getClrAt(x, y) || cooldown == 0 || points.isEmpty()) {
			feed(board.getPointAtCoords(x, y));
			colors.add(board.getClrAt(x, y));
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
			stroke(mix_color);
			line(point.x, point.y, prev_point.x, prev_point.y);
		}
	}
	
	public boolean pointsEqual(PVector p1, PVector p2) {
		if (p1 == null || p2 == null) {
			return false;
		}
		float EPSYLON = 0.01;
		return abs(p1.x - p2.x) < EPSYLON && abs(p1.y - p2.y) < EPSYLON;
		
	}

	public void mixColors() {
		float r_sum = 0, g_sum = 0, b_sum = 0;
		float r, g, b;
		float max_luminocity = 0;
		for(color clr : colors) {
			r = red(clr) / 255.0;
			g = green(clr) / 255.0;
			b = blue(clr) / 255.0;
			float luminocity = r * 0.2126 + g * 0.7152 + b * 0.0722;
			max_luminocity = max(luminocity, max_luminocity);
			r_sum += r;
			g_sum += g;
			b_sum += b;
		}

		float count = colors.size();
		r = r_sum / count;
		g = g_sum / count;
		b = b_sum / count;

		float average_luminocity = r * 0.2126 + g * 0.7152 + b * 0.0722;
		float luminocity_difference = (max_luminocity - average_luminocity) / 2.0;

		r += luminocity_difference * 0.2126;
		g += luminocity_difference * 0.7152;
		b += luminocity_difference * 0.0722;

		mix_color = color(r * 255.0, g * 255.0, b * 255.0);

		colorMode(HSB);
		float hue = hue(mix_color);
		float saturation = min(saturation(mix_color) * 1.2, 255.0);
		float value = brightness(mix_color);
		mix_color = color(hue, saturation, value);
		colorMode(RGB);

		multicolored = (mix_color != colors.get(0));
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
