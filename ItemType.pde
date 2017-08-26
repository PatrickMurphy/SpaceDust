enum ItemType {
  GUN("gun"), 
    ENGINE("engine"), 
    HULL("hull"), 
    SHIP("ship"), 
    DRILL("drill");

  final String text;

  private ItemType(final String text) {
    this.text = text;
  }

  public String toString() {
    return text;
  }
}