public class Line {
	
	ArrayList<PVector> points;
	int clr;
	boolean drawing;
	float radius;
	
	public Line(float nradius) {
		radius = nradius * GUI_SIZE_MULTIPLYER;
		points = new ArrayList<PVector>();
		reset();
	}
	
	public void feed(PVector point) {
		if (points.size() > 1 && pointsEqual(point, points.get(points.size() - 2))) {
			removeLast();
			return;
		}
		
		for (PVector linePoint : points) {
			if (pointsEqual(linePoint, point)) {
				return;
			}
		}
		
		points.add(point);
	}
	
	public void reset() {
		points.clear();
		clr = 0;
		drawing = false;
	}
	
	public void beginDraw(int nclr) {
		drawing = true;
		clr = nclr;
	}
	
	public PVector getLast() {
		return points.get(points.size() - 1);
	}
	
	public void removeLast() {
		points.remove(points.size() - 1);
	}
	
	public void show() {    
		if (points.size() < 2) {
			return;
		}
	 
		strokeWeight(radius);
		for (int i = 1; i < points.size(); i++) {
			PVector point = points.get(i);
			PVector prev_point = points.get(i - 1);
			stroke(clr);
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
}
