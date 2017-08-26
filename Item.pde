class Item {
  String name;
  ItemType type;
  float[] cost;
  boolean owned;
  Item(String name, ItemType type, float[] cost){
    this.name = name;
    this.type = type;
    this.cost = cost;
    this.owned = false;
  }
  
  void applyEffect(UserPlayer p){
    println("null item");
  }
}