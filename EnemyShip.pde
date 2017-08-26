class EnemyShip extends Ship {
  EnemyShip(Player p, PVector pos) {
    this(p, pos, 1);
  }

  EnemyShip(Player p, PVector pos, float scale) {
    super(p, pos, 45*(1+((scale-1)/2)), .5, 550, 250*(1+((scale-1)/2)), false);
    setDisplayRatio(new PVector(190, 315));
    setHealth(100*scale);
    setMaxHealth(100*scale);
    setFireRate(floor(15*scale));
    setBulletSpeed(9*scale);
    setDamage(3*scale);
  }

  String getName() {
    return "EnemyShip";
  }

  void update() {
    super.update();
    if (!target_aggression) {
      if (dist(location.x, location.y, ((Level)CurrentGameState).player.current_ship.location.x, ((Level)CurrentGameState).player.current_ship.location.y)<=this.los && inBounds())
        super.setTarget(((Level)CurrentGameState).player.current_ship.location, true); // true means aggressive, attack this target
      else {
        Asteroid nearAst = findNearestAsteroid();
        if (nearAst.inBounds()) {
          super.setTarget(nearAst.location, false); // false means non-aggressive don't attack, implies harvest
        }
      }
    }
    // seperate function removed
    seperate();
  }

  void seperate() {
    // if within x distance of ships
    PVector seperationVector = new PVector(0, 0, 0);
    int sepCount = 0;
    float range = 50;
    float avgDist = 0;
    for (int i = 0; i< ((Level)CurrentGameState).DisplayMap.get("EnemyShip").size(); i++) {
      Mover m = ((Level)CurrentGameState).DisplayMap.get("EnemyShip").get(i);
      if (m instanceof EnemyShip) {
        Ship s = (Ship)m;
        //if (s.parentPlayer == ((Level)CurrentGameState).enemyPlayer) {
        // do something
        if (s.distance(this) < range) {
          avgDist += s.distance(this);
          PVector sepVect = s.location.copy().sub(this.location);
          sepCount++;
          if (sepCount==1) {
            seperationVector = sepVect;
          } else {
            seperationVector.add(sepVect);
          }
        }
        //}
      }
    }

    if (sepCount>0) {
      avgDist = avgDist/sepCount;
      seperationVector = new PVector(seperationVector.x/sepCount, seperationVector.y/sepCount, seperationVector.z/sepCount);
      stroke(255);
      seperationVector.normalize().mult(-1);
      seperationVector.setMag(map(avgDist, 0, range, 35, .0001));
      // println(seperationVector);
      //line(location.x, location.y, location.x + seperationVector.x, location.y + seperationVector.y);
      noStroke();
      applyForce(seperationVector);
    }
  }

  void display() {
    super.display();
    pushMatrix();
    translate(location.x, location.y);
    rotate(velocity.heading()+PI/2);
    noTint();
    shape(shapes[1], 0, 0, mass*display_ratio.x, mass*display_ratio.y);
    popMatrix();
    noStroke();
    fill(200, 55);
    ellipse(target.x, target.y, 20, 20);
  }
}