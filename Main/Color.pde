import java.util.ArrayList;

public class Color {

	// primary colors
	final float CYAN[]     = {0.0000f, 0.7411f, 0.9960f}; //#00BDFE
	final float MAGENTA[]  = {1.0000f, 0.0039f, 0.5960f}; //#FF0198
	final float YELLOW[]   = {0.9960f, 0.9019f, 0.0000f}; //#FEE600
	final float BLACK[]    = {0.0000f, 0.0000f, 0.0000f}; //#000000

	// luminocity coefficients
	final float r_coeff = 0.2126;
	final float g_coeff = 0.7152;
	final float b_coeff = 0.0722;
	
	// amounts of primary colors
	int c, m, y, k;

	// number of duplicates in the colors
	int multiplyer;

	// the rgb mix values
	float r, g, b;

	public Color() {
		c = 0;
		m = 0;
		y = 0;
		k = 0;
		multiplyer = 1;
		r = 0.0;
		g = 0.0;
		b = 0.0;
	}

	public void add(Color in) {
		c += in.c;
		m += in.m;
		y += in.y;
		k += in.k;
	}

	public int weight() {
		return c + m + y + k;
	}

	public boolean isPrimary() {
		return weight() <= 1;
	}

	public void reduce() {
		int extra_multiplyer = gcd(c, gcd(m, gcd(y, k)));
		c /= extra_multiplyer;
		m /= extra_multiplyer;
		y /= extra_multiplyer;
		k /= extra_multiplyer;
		multiplyer *= extra_multiplyer;
	}

	public float luminocity() {
		return r * r_coeff + g * g_coeff + b * b_coeff;
	}

	// requires the color to be reduced
	public void computeRGB() {
		float r_sum = CYAN[0] * c + MAGENTA[0] * m + YELLOW[0] * y;
		float g_sum = CYAN[1] * c + MAGENTA[1] * m + YELLOW[1] * y;
		float b_sum = CYAN[2] * c + MAGENTA[2] * m + YELLOW[2] * y;

		int weight = weight();

		r = r_sum / weight;
		g = g_sum / weight;
		b = b_sum / weight;
	}

	public void optimiseColor(float missing_luminocity, float missing_saturation) {
		r += missing_luminocity * r_coeff;
		g += missing_luminocity * g_coeff;
		b += missing_luminocity * b_coeff;

		r = Math.min(r, 1.0);
		g = Math.min(g, 1.0);
		b = Math.min(b, 1.0);

		/*
		int ir = (int)(r * 255.0);
		int ig = (int)(g * 255.0);
		int ib = (int)(b * 255.0);
		float[] hsv = java.awt.Color.RGBtoHSB(ir, ig, ib, null);
		float h = hsv[0];
		float s = Math.min(hsv[1] * (1.0 + missing_saturation), 1.0);
		float v = hsv[2];
		float[] rgb = new java.awt.Color(java.awt.Color.HSBtoRGB(h, s, v)).getColorComponents(null);
		r = rgb[0];
		g = rgb[1];
		b = rgb[2];
		*/
	}

	public Color fromMixColors(ArrayList<Color> colors) {
		for(Color clr : colors) {
			add(clr);
		}

		reduce();

		if (equals(colors.get(0))) {
			Color result = colors.get(0).copy();
			result.multiplyer = multiplyer;
			return result;

		} else {
			computeRGB();
			optimiseColor(0.1, 0.2);
			return this;
		}
	}

	public Color setCyan() {
		c = 1;
		r = CYAN[0];
		g = CYAN[1];
		b = CYAN[2];
		return this;
	}

	public Color setMagenta() {
		m = 1;
		r = MAGENTA[0];
		g = MAGENTA[1];
		b = MAGENTA[2];
		return this;
	}

	public Color setYellow() {
		y = 1;
		r = YELLOW[0];
		g = YELLOW[1];
		b = YELLOW[2];
		return this;
	}

	public Color setBlack() {
		k = 1;
		return this;
	}

	public boolean equals(Color other) {
		return c == other.c &&
			   m == other.m &&
			   y == other.y &&
			   k == other.k;
	}

	public String toString() {
		return "Color: (" + c + "c, " + m + "m, " + y + "y, " + k + "k) | ( " + r + "r, " + g + "g, " + b + "b)";
	}

	public Color copy() {
		Color copy = new Color();
		copy.c = c;
		copy.m = m;
		copy.y = y;
		copy.k = k;
		copy.multiplyer = multiplyer;
		copy.r = r;
		copy.g = g;
		copy.b = b;
		return copy;
	}

	private int gcd(int a, int b) {
		if (b == 0) {
			return a;
		}
		return gcd(b, a % b);
	}
}
