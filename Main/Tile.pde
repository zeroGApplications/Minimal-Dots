public class Tile {
	
	PVector start;
	PVector end;
	PVector pos;
	float radius_start;
	float radius_end;
	float radius;
	float time;
	int clr_id;
	boolean done;
	boolean selected;
	EffectType effect;

	public Tile(PVector nstart, PVector nend, int nclr_id, float nr_start, float nr_end) {
		start = nstart;
		pos = start;
		end = nend;
		clr_id = nclr_id;
		time = 0;
		radius_start = nr_start * GUI_SIZE_MULTIPLYER;
		radius_end = nr_end * GUI_SIZE_MULTIPLYER;
		radius = radius_start;
		done = false;
		selected = false;
		effect = EffectType.NONE;
	}
	
	public Tile(PVector nstart, PVector nend, int nclr_id) {
		this(nstart, nend, nclr_id, 60, 60);
	}
	
	public Tile(PVector nstart, int nclr_id) {
		this(nstart, nstart, nclr_id, 60, 60);
    if (random(0, 1) < SPECIAL_TILE_PROBABILITY) {
      effect = EffectType.values()[int(random(1, 4))];
    }
	}
	
	public void show(int[] clrs) {
		float margin = 20 * GUI_SIZE_MULTIPLYER;
		if (selected) {
			radius  += margin;
		}

		float lineWidth = radius / 3.0;
		float rectangleRoundness = radius / 8.0;

		switch(effect) {
			case NONE:
				noStroke();
				fill(clrs[clr_id]);
				ellipse(pos.x, pos.y, radius, radius);
				break;
			case CLEAR_COLOR:
				if (selected) {
					fill(clrs[clr_id]);
				} else {
					noFill();
				}
				stroke(clrs[clr_id]);
				strokeWeight(lineWidth);
				rect(pos.x, pos.y, radius - margin, radius - margin, rectangleRoundness);
				break;
			case CLEAR_LINE_HORIZONTAL:
				if (selected) {
					stroke(clrs[clr_id]);
					strokeWeight(lineWidth);
					fill(clrs[clr_id]);
					rect(pos.x, pos.y, radius - margin, (radius - margin) / 2.0, rectangleRoundness);
				} else {
					stroke(clrs[clr_id]);
					strokeWeight(lineWidth * 1.5);
					line(pos.x - (radius - margin) / 2.0, pos.y, pos.x + (radius - margin) / 2.0, pos.y);
				}
				break;
			case CLEAR_LINE_VERTICAL:
				if (selected) {
					stroke(clrs[clr_id]);
					strokeWeight(lineWidth);
					fill(clrs[clr_id]);
					rect(pos.x, pos.y, (radius - margin) / 2.0, radius - margin, rectangleRoundness);
				} else {
					stroke(clrs[clr_id]);
					strokeWeight(lineWidth * 1.5);
					line(pos.x, pos.y - (radius - margin) / 2.0, pos.x, pos.y + (radius - margin) / 2.0);
				}
		}
		
		if (selected) {
			radius -= margin;
		}
	}
	
	public void update() {
		if (end == null) {
			return;
		}
		float tmp = spring_equation(time);
		pos = PVector.lerp(start, end, tmp);
		radius = lerp(radius_start, radius_end, tmp);
		if (time < 1) {
			time  += 0.02;
		} else {
			done = true;
		}
	}
	
	public void reset() {
		time = 0;
		if (end != null) {
			start = end.copy();
			end = null;
		}
		done = false;
	}
	
	public void select() {
		selected = true;
	}
	public void deselect() {
		selected = false;
	}
}
