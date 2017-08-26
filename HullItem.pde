class HullItem extends Item{
  float[] effects;
  
  HullItem(String name, float healthRegen, float maxHealth, float[] cost){
    this(name, new float[]{healthRegen,maxHealth},cost);
  }
  
  HullItem(String name, float[] effects, float[] cost){
    super(name, ItemType.HULL, cost);
    this.effects = effects;
  }
  
  void applyEffect(UserPlayer p){
    p.current_ship.setHealthRegen(effects[0]);
    p.current_ship.setMaxHealth(effects[1]);
  }
}