class ShipManager extends ArrayList<Ship> {
  ArrayList<Ship> newShips;
  ShipManager() {
    super();
    newShips = new ArrayList<Ship>();
  }

  void addNewShips() {
    if (newShips.size() > 0) {
      //println(newShips.get(0).getClass().getName());
      ((Level)CurrentGameState).DisplayMap.get(newShips.get(0).getName()).addAll(newShips); // add to correct ship with name of class function
      this.addAll(newShips);
      newShips.clear();
    }
  }

  ArrayList<Ship> init_addNewShips() {
    ArrayList<Ship> tmp = new ArrayList<Ship>(newShips);
    this.addAll(newShips);
    newShips.clear();
    return tmp;
  }

  void addNew(Ship s) {
    newShips.add(s);
  }

  void addAll(ArrayList<Ship> ships) {
    newShips.addAll(ships);
  }

  void remove(Ship s) {
    super.remove(s);
    ((Level)CurrentGameState).DisplayMap.get(s.getName()).remove(s); // remove from correct list using name of class
  }
}