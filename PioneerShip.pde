class PioneerShip extends Ship {
  PioneerShip(Player p, PVector pos) {
    super(p, pos, 100, 6, 25, 25, true);
    setDisplayRatio(new PVector(315, 190));
    setDamage(25);
    setBulletSpeed(15);
  }

  String getName() {
    return "PioneerShip";
  }
  
  void update(){
    if(health>0){
      super.update();
    }
  }
  
  void display() {
    if (health>0) {
      super.display();
      pushMatrix();
      translate(location.x, location.y);
      rotate(velocity.heading()+PI/2);
      noTint();
      shape(shapes[0], 0, 0, mass*display_ratio.x, mass*display_ratio.y);
      popMatrix();
      noStroke();
      fill(200, 55);
      ellipse(target.x, target.y, 20, 20);
    }
  }
}