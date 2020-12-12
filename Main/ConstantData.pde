public static class ConstantData {
  
  static PVector gui_size_multiplyers;
  static float gui_size_multiplyer;
  
  public static void initialize(float wdh, float hgt) {
    gui_size_multiplyers = new PVector(wdh/1080.0, hgt/1920.0);
    gui_size_multiplyer = (gui_size_multiplyers.x < gui_size_multiplyers.y) ? 
      gui_size_multiplyers.x : 
      gui_size_multiplyers.y;
  }
  
  public enum EffectType {
    NONE, CLEAR_COLOR, CLEAR_LINE_HORIZONTAL, CLEAR_LINE_VERTICAL;
  }
  
}
