public class DrawerGUI {
	
	PVector position;
	PVector dimension;
	float length;
	float time;
	float radius;
	int direction;
	boolean active;
	boolean pressed;
	int options;
	float option_radius;
	float spacing;
	float padding;
	int[] colors;
	PImage icon;
	
	public DrawerGUI(PVector nposition, PVector ndimension, int[] ncolors, PImage nicon) {
		position = nposition;
		dimension = ndimension;
		options = ncolors.length;
		padding = 40 * GUI_SIZE_MULTIPLYER;
		time = 0;
		radius = 120 * GUI_SIZE_MULTIPLYER;
		direction = LEFT;
		active = false;
		pressed = false;
		option_radius = radius-padding;
		length = options * radius;
		spacing = (length - padding) / options;
		colors = ncolors;
		icon = nicon;
	}
	
	public void show() {
		int clr1 = DARKMODE ? 100 : 220;
		int clr2 = DARKMODE ? 80 : 240;
		
		if (time > 0) {
			stroke(clr2);
			strokeWeight(radius);
			
			float tmpx = position.x + dimension.x * length;
			float tmpy = position.y + dimension.y * length;
			float value = getformulaValue();
			tmpx = lerp(position.x, tmpx, value);
			tmpy = lerp(position.y, tmpy, value);
			line(position.x, position.y, tmpx, tmpy);
			
			
			for (int i = 0; i < options; i++) {
				PVector tmp = getOptionPosition(i);
				if (dimension.x * tmpx + padding > dimension.x * tmp.x) {
					noStroke();
					fill(colors[i]);
					ellipse(tmp.x, tmp.y, option_radius, option_radius);
				}
			}
		}
		
		noStroke();
		fill(clr1);
		ellipse(position.x, position.y, radius, radius);
		
		tint(DARKMODE ? 180 : 120);
		if (active && pressed) {
			image(icon, position.x, position.y, (radius - padding) * 0.9, (radius - padding) * 0.9);
		} else {
			image(icon, position.x, position.y, radius - padding, radius - padding);
		}
		noTint();
	}
	
	public void update() {
		if (!active) {
			pressed = false;
			return;
		}
		if (direction == LEFT) {
			if (time < 1) {
				time += 0.05;
			} else {
				direction = RIGHT;
				active = false;
			}
			return;
		}
		
		if (direction == RIGHT && time > 0) {
			time -= 0.05;
		} else {
			direction = LEFT;
			active = false;
		}
	}
	
	public void press() {
		if (dist(mouseX, mouseY, position.x, position.y) <= radius * 0.8) {
			active = true;
			pressed = true;
		}
	}

	
	public PVector getOptionPosition(int index) {
		return new PVector(position.x + (dimension.x * length) - (dimension.x * spacing * index), position.y);
	}
	
	public int select() {
		for (int i = 0; i < options; i++) {
			PVector tmp = getOptionPosition(i);
			if (dist(mouseX, mouseY, tmp.x, tmp.y) <= option_radius * 0.8) {
				return i;
			}
		}
		return -1;
	}
	
	public boolean extended() {
		return !active && time > 0;
	}
	
	public void close() {
		active = true;
	}
	
	public float getformulaValue() {
		float res = 1;
		if (time < 1 && direction == LEFT) {
			res = spring_equation(time);
		} else if (time > 0 && direction == RIGHT) {
			res = max(0, 1 - spring_equation(1 - time));
		}
		return res;
	}
}
