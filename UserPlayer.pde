class UserPlayer extends Player {
  Ship current_ship;
  ArrayList<Item> items;
  UserPlayer() {
    super();
    items = new ArrayList<Item>();
  }
  
  Ship getShip(){
    return current_ship;
  }

  void addShip(Ship cs) {
    current_ship = cs;
  }
  
  void addItem(Item i){
    rm.useResource(i.cost);
    i.applyEffect(this);
    if(i.type != ItemType.SHIP){
      items.add(i);
    }
  }
  
  void applyItems(){
    for(Item i : items)
      i.applyEffect(this);
  }

  void onKeyPressed() {
    current_ship.onKeyPressed();
  }

  void onMousePressed() {
    current_ship.onMousePressed();
  }
}