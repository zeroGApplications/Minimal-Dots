public class Effect {
	
	Line line;
	EffectType effect;
	PVector position;
	int clr;
	
	public Effect(EffectType neffect) {
		effect = neffect;
		position = new PVector(0, 0);
		clr = 0;
	}
	
	public void constructLine(Board board) {
		line = new Line(-1);
		switch (effect) {
			case NONE: break;
			case CLEAR_COLOR: constructClearColorLine(board); break;
			case CLEAR_LINE_HORIZONTAL: constructClearHorizontalLine(board); break;
			case CLEAR_LINE_VERTICAL: constructClearVerticalLine(board); break;
		}
	}
	
	public void constructClearColorLine(Board board) {
		for (int y = 0; y < board.hgt; y++) {
			for (int x = 0; x < board.wdh; x++) {
				if (board.field[x][y] == clr) {
					line.feed(board.getPointAtCoords(x, y));
				}
			}
		}
	}
	
	public void constructClearHorizontalLine(Board board) {
		for (int x = 0; x < board.wdh; x++) {
			line.feed(board.getPointAtCoords(x, int(position.y)));
		}
	}
	
	public void constructClearVerticalLine(Board board) {
		for (int y = 0; y < board.hgt; y++) {
			line.feed(board.getPointAtCoords(int(position.x), y));
		}
	}
}
