import java.util.ArrayList;

public class Color {

	// primary colors
	static final float CYAN[]     = {0.0000f, 0.7411f, 0.9960f}; //#00BDFE
	static final float MAGENTA[]  = {1.0000f, 0.0039f, 0.5960f}; //#FF0198
	static final float YELLOW[]   = {0.9960f, 0.9019f, 0.0000f}; //#FEE600
	static final float BLACK[]    = {0.0000f, 0.0000f, 0.0000f}; //#000000

	// luminocity coefficients
	static final float r_coeff = 0.2126f;
	static final float g_coeff = 0.7152f;
	static final float b_coeff = 0.0722f;
	
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
		r = 0.0f;
		g = 0.0f;
		b = 0.0f;
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

		r = Math.min(r, 1.0f);
		g = Math.min(g, 1.0f);
		b = Math.min(b, 1.0f);

		int ir = (int)(r*255.0);
		int ig = (int)(g*255.0);
		int ib = (int)(b*255.0);
		float[] hsv = java.awt.Color.RGBtoHSB(ir, ig, ib, null);
		float h = hsv[0];
		float s = Math.min(hsv[1] * (1.0f + missing_saturation), 1.0f);
		float v = hsv[2];
		float[] rgb = new java.awt.Color(java.awt.Color.HSBtoRGB(h, s, v)).getColorComponents(null);
		r = rgb[0];
		g = rgb[1];
		b = rgb[2];
	}

	public static Color fromMixColors(ArrayList<Color> colors) {
		Color sum = new Color();

		float max_luminocity = 0;
		for(Color clr : colors) {
			max_luminocity = Math.max(clr.luminocity(), max_luminocity);
			sum.add(clr);
		}

		sum.reduce();

		if (sum.equals(colors.get(0))) {
			Color result = colors.get(0).copy();
			result.multiplyer = sum.multiplyer;
			return result;

		} else {
			sum.computeRGB();
			float luminocity_difference = (max_luminocity - sum.luminocity());
			sum.optimiseColor(luminocity_difference * 0.5f, 0.2f);
			return sum;
		}
	}

	public static Color Cyan() {
		Color cyan = new Color();
		cyan.c = 1;
		cyan.r = CYAN[0];
		cyan.g = CYAN[1];
		cyan.b = CYAN[2];
		return cyan;
	}

	public static Color Magenta() {
		Color magenta = new Color();
		magenta.m = 1;
		magenta.r = MAGENTA[0];
		magenta.g = MAGENTA[1];
		magenta.b = MAGENTA[2];
		return magenta;
	}

	public static Color Yellow() {
		Color yellow = new Color();
		yellow.y = 1;
		yellow.r = YELLOW[0];
		yellow.g = YELLOW[1];
		yellow.b = YELLOW[2];
		return yellow;
	}

	public static Color Black() {
		Color black = new Color();
		black.k = 1;
		return black;
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
