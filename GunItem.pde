class GunItem extends Item {
  float[] effects;

  GunItem(String name, float fireRate, float damage, float bulletSpeed, float[] cost) {
    this(name, new float[]{fireRate, damage, bulletSpeed}, cost);
  }

  GunItem(String name, float[] effects, float[] cost) {
    super(name, ItemType.GUN, cost);
    this.effects = effects;
  }

  void applyEffect(UserPlayer p) {
    p.current_ship.setFireRate(floor(effects[0]));
    p.current_ship.setDamage(effects[1]);
    p.current_ship.setBulletSpeed(effects[2]);
  }
}