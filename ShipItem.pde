class ShipItem extends Item{
  Ship ship;
  ShipItem(String name, Ship ship,float[] cost){
    super(name, ItemType.SHIP, cost);
    this.ship = ship;
  }
  
  void applyEffect(UserPlayer p){
    p.addShip(ship);
    p.applyItems();
  }
}