import java.util.LinkedList;

Saver saver;
Board board;
Line line;
DrawerGUI themegui;
DrawerGUI resetgui;
boolean debugmode = false;
LinkedList<Effect> effect_queue;
int effect_delay;

void settings() {
	if (!debugmode) {
		fullScreen();
	} else {
		//size(720, 1280);
		
		//size(1080, 1920);
		size(800, 800);
	}
	smooth();
}

void setup() {
	orientation(PORTRAIT);
	background(0);
	
	PImage theme_gui_icon = loadImage("ThemeGUIIcon.png");
	PImage reset_gui_icon = loadImage("ResetGUIIcon.png");
	
	initialize(width, height);
	
	saver = new Saver(false);
	board = new Board(saver);
	line = new Line(40);
	themegui = new DrawerGUI(new PVector(100, 150), new PVector(1, 0), board.getThemePreview(), theme_gui_icon);
	resetgui = new DrawerGUI(new PVector(width-100, 150), new PVector(-1, 0), new int[]{#ff5577, #55ff77}, reset_gui_icon);
	
	effect_queue = new LinkedList<Effect>();
	effect_delay = 10;
	
	if (saver.darkmode == 1) {
		DARKMODE = true;
		applyDarkmode();
	} else {
		DARKMODE = false;
	}
	
	textSize(50*GUI_SIZE_MULTIPLYER);
	textAlign(RIGHT, CENTER);
	rectMode(CENTER);
	imageMode(CENTER);
	
	if (debugmode) {
		//frameRate(5);
	}
}

void draw() {
	background(DARKMODE ? 0 : 255);
	
	if (!effect_queue.isEmpty() && effect_delay <= 0) {
		effect_delay = 10;
		Effect effect = effect_queue.remove();
		effect.constructLine(board);
		board.clearLine(effect.line, effect_queue);
	}
	effect_delay--;
	
	if (mousePressed) {
		PVector coords = board.getCoordsAtMouse();
		if (coords != null) {
			if (!line.drawing) {
				line.beginDraw(board.getClrAt(
					int(coords.x),
					int(coords.y)));
			}
			if (line.points.size() < 1 || board.isVonNeumannNeighbor(board.getCoordsAtPoint(line.getLast()), coords)) {
				if (board.getClrAt(int(coords.x), int(coords.y)) == line.clr) {
					line.feed(board.getPointAtCoords(int(coords.x), int(coords.y)));
				}
			}
		}
	}
	
	board.update();
	board.updateSelection(line);
	themegui.update();
	resetgui.update();
	
	board.show();
	line.show();
	themegui.show();
	resetgui.show();
}

void mouseReleased() {
	if (line.drawing) {
		board.clearLine(line, effect_queue);
		line.reset();
	}
}

void mousePressed() {
	themegui.press();
	if (themegui.extended()) {
		int option = themegui.select();
		if (option != -1 && option != 3) {
			board.setTheme(option);
		} else if (option == 3) {
			DARKMODE = !DARKMODE;
			applyDarkmode();
		} else {
			themegui.close();
		}
	}
	
	resetgui.press();
	if (resetgui.extended()) {
		int option = resetgui.select();
		if (option == 1) {
			Saver tmp_saver = new Saver(true);
			tmp_saver.theme = board.theme;
			tmp_saver.highscores = board.highscores;
			board = new Board(tmp_saver);
			board.setTheme(board.theme);
			effect_queue.clear();
			resetgui.close();
		} else {
			resetgui.close();
		}
	}
}

void stop() {
	saver.saveData(board);
}

void applyDarkmode() {
	board.setTheme(board.theme);
	themegui.colors = board.getThemePreview();
}
