PVector GUI_SIZE_MULTIPLYERS = new PVector(0, 0);
float GUI_SIZE_MULTIPLYER = 0.0;
float SPECIAL_TILE_PROBABILITY = 0.02;
boolean DARKMODE = false;

void initialize(float wdh, float hgt) {
	GUI_SIZE_MULTIPLYERS = new PVector(wdh / 1080.0, hgt / 1920.0);
	GUI_SIZE_MULTIPLYER = min(GUI_SIZE_MULTIPLYERS.x, GUI_SIZE_MULTIPLYERS.y);
}

public enum EffectType {
	NONE, CLEAR_COLOR, CLEAR_LINE_HORIZONTAL, CLEAR_LINE_VERTICAL;
}

public float spring_equation(float x) {
	return -0.5 * exp(-6 * x) * (-2 * exp(6 * x) + sin(8 * x) + 2 * cos(8 * x));
}
