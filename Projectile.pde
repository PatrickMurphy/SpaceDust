class Projectile extends Mover {
  Ship parentShip;
  float speed, damage;

  Projectile(Ship parent, float ms, float damage) {
    super(copyVector(parent.location), 2);
    this.parentShip = parent;
    speed = ms;
    this.damage = damage;
    this.velocity = copyVector(parent.velocity);
    this.velocity.setMag(speed+this.velocity.mag()); // bullet speed + ship speed
  }

  float getWidth() {
    return damage/3;
  }
  float getHeight() {
    return damage/3;
  }

  float getRadius() {
    return (damage/3)/2;
  }

  boolean hitCheck(Ship s) {
    return s != parentShip && dist(s.location.x,s.location.y,this.location.x,this.location.y) <= s.mass/2;
  }

  void display() {
    fill(255, 0, 0);
    ellipse(location.x, location.y, getWidth(), getHeight());
  }
}