class Ship extends Mover { //<>//
  // display debug messages?
  boolean debug = false;

  // ship properties
  float max_speed;
  float los, fire_range;
  int fireRate_frames = 10;
  int lastFireFrame = -fireRate_frames;
  float damage = 10;
  float bullet_speed = 12;
  float health = 1000;
  float maxHealth = 1000;
  float healthRegen = 0;
  String name = "Ship";

  // ship states & concrete variables
  Player parentPlayer; // who's side is this ship on?
  PVector display_ratio; // display ratios percentage for scaling
  PriorityQueue<PVector> waypoints; // a list of target locations, ************************currently ************ NOT IN USE ************************
  PVector target; // current navigation target location
  boolean newTarget;  // has this ship just recieved a new navigation target
  boolean target_aggression; // should this ship fire at the target when in range?
  boolean userControlled; // is this ship a human user controllable ship?
  boolean is_harvesting; // is this ship currently harvesting an asteriod?, default false
  boolean stationary; // is this ship stationary (at most recent target), default false
  Asteroid current_harvest;

  GUIPercentBar healthBar;

  HashMap<Resources, Float> resources;

  Ship(Player player, PVector pos, float m, float ms, float los, float fr) {
    this(player, pos, m, ms, los, fr, false);
  }
  Ship(Player player, PVector pos, float m, float ms, float line_of_sight, float fire_range, boolean user) {
    super(pos, m);
    parentPlayer = player;
    userControlled = user;
    target = copyVector(location);
    max_speed = ms;
    los = line_of_sight;
    this.fire_range = fire_range;
    stationary = false;
    waypoints = new PriorityQueue<PVector>();
    display_ratio = new PVector(100, 100);
    is_harvesting = false;
    healthBar = new GUIPercentBar(location, new PVector(75, 3), new PVector(mass/3, -mass/3));
    current_harvest = null;
    resources = new HashMap<Resources, Float>();
    resources.put(Resources.LYONDINE, 0.0);
    resources.put(Resources.AZUTALITE, 0.0);
    resources.put(Resources.ILLIUBISITE, 0.0);
    resources.put(Resources.BYNTHITE, 0.0);
    resources.put(Resources.REALINUM, 0.0);
  }
  String getName() {
    return name;
  }
  void update() {
    super.update();
    // regen health
    health = min(health+healthRegen, maxHealth);
    float current_dist_to_target = dist(location.x, location.y, target.x, target.y);
    if (!atTarget()) {
      if (current_dist_to_target<=fire_range && target_aggression) {
        inRange();
      } else if (current_dist_to_target<=7) {
        inRange();
      } else { //if (current_dist_to_target>fire_range && target_aggression)
        accelerate();
      }
    } else {
      if (debug) println("atTarget : " + userControlled);
      stationary = true;
    }
    if (stationary == true) {
      if (userControlled) {
        lookAt(new PVector(mouseX, mouseY));
      } else {
        lookAt(copyVector(target));
      }
    }
    velocity.limit(max_speed);
    findCollisions();
    harvest();
    consumeResourceDrops();
    avoidShips();
  }
  void display() {
    healthBar.display(health/maxHealth);

    if (is_harvesting) {
      fill(current_harvest.getColor(), 45);
      stroke(current_harvest.getColor(), 75);
      ellipse(location.x, location.y, mass, mass);
    }
  }

  /* ---------------
   Properties, setters and getters
   ----------------*/

  void setHealth(float h) {
    health = h;
  }

  float getHealth() {
    return health;
  }

  void setMaxHealth(float mh) {
    maxHealth = mh;
  }

  void setHealthRegen(float hr) {
    healthRegen = hr;
  }

  void setFireRate(int frames) {
    fireRate_frames = frames;
  }
  void setDamage(float d) {
    damage = d;
  }
  void setBulletSpeed(float bs) {
    bullet_speed = bs;
  }

  void setDisplayRatio(PVector dr) {
    display_ratio = dr;
    dr.normalize();
    display_ratio = dr;
  }
  /* ---------------
   Target & Pathing
   ----------------*/

  void setTarget(PVector t) {
    setTarget(t, false);
  }
  void setTarget(PVector t, boolean aggressive) {
    setTarget(t, aggressive, false);
  }

  void setTarget(PVector t, boolean aggressive, boolean reset) {
    target = t;
    target_aggression = aggressive;
    if (reset)
      velocity.setMag(velocity.mag()*.98);
  }

  boolean atTarget() {
    return atTarget(0.0);
  }
  boolean atTarget(float range) {
    if (range <= 0.0) {
      return target.x == location.x && target.y == location.y;
    } else {
      return dist(target.x, target.y, location.x, location.y) <= range;
    }
  }

  /* -------------------------------------------------
   Verbs
   ---------------------------------------------------*/
   
  Projectile createProjectile() {
    return new Projectile(this, bullet_speed, damage);
  }

  /* ---------------
   basic actions
   ----------------*/
  // fire a projectile towards the current orientation
  void fire() {
    if (frameCount - lastFireFrame >= fireRate_frames) {
      ((Level)CurrentGameState).ProjectileArrayList.addNew(createProjectile());
      lastFireFrame = frameCount;
    }
  }

  // start to slow, called when in a range of target, ariving behavior
  void brake() {          
    if (debug) println("call brake : " + userControlled);
    PVector brakeVect = copyVector(velocity);
    brakeVect.mult(-1);
    brakeVect.mult(0.0001);
    applyForce(brakeVect);//friction
  }

  // accelerate towards the current target within speed limits
  void accelerate() {
    if (debug) println("call accel : " + userControlled);
    stationary = false;
    PVector accelVect = PVector.sub(target, location);
    accelVect.mult(map(max(min(velocity.mag(), 0), max_speed), 0, max_speed, .1, .7));
    accelVect.sub(velocity);
    applyForce(accelVect);
  }

  // look at (orient ship towards) the target
  void lookAt(PVector t) {
    if (debug) println("call lookAt " + stationary + "  : " + userControlled);
    PVector tempVect = new PVector(t.x, t.y);
    tempVect.sub(location);
    tempVect.setMag(0.00001);
    velocity = tempVect;
  }

  // boid actions (within 60 distance, 100 magnitude)
  void avoidShips() {
    avoidShips(60, 700);
  }

  // boid actions 
  void avoidShips(float radius, float mag) {
    Ship NearShip = findNearestShip(radius);
    if (NearShip!=null) {
      PVector nearLoc = copyVector(NearShip.location);
      nearLoc.sub(location);
      // nearLoc.mult(-1);
      nearLoc.setMag(mag);
      applyForce(nearLoc);
    }
  }
  
  
  /* ---------------
   end basic actions
   ----------------*/

  // harvest any resouces that are under you
  boolean harvest() {
    Asteroid a = findNearestAsteroid();
    if (a.isInHarvestRange(this.location)) {
      is_harvesting = true;
      current_harvest = a;
      addResource(a.resourceType, a.harvest(.005)*10);
    } else {
      is_harvesting = false;
      current_harvest = null;
    }
    return is_harvesting;
  }

  // the action called when in range of the target
  void inRange() {
    if (debug) println("call inRange : " + userControlled);
    stationary = true;
    velocity.setMag(0.00001);
    if (target_aggression)
      fire();
    if (userControlled)
      target = copyVector(location);
  }

  /* ---------------
   Resource / Inventory related functions
   ----------------*/

  // action add resouce to inventory
  void addResource(Resources r, float v) {
    parentPlayer.rm.addResource(r, v);
    resources.put(r, resources.get(r)+v);
  }

  // pick up any resource drops within radius (15.0)
  void consumeResourceDrops() {
    consumeResourceDrops(15.0);
  }

  // pick up any resource drops within radius
  void consumeResourceDrops(float radius) {
    for (Mover rd : ((Level)CurrentGameState).DisplayMap.get("ResourceDrop")) {
      if (rd.distance(this)<radius) {
        ((ResourceDrop)rd).consume(this);
      }
    }
  }


  /* ---------------
   health & armor related functions
   ----------------*/
  void takeDamage(ArrayList<Projectile> p) {
    for (Projectile currentProjectile : p)
      health -= currentProjectile.damage;

    if (!userControlled && p.size()>0)
      setTarget(copyVector(p.get(0).parentShip.location), false); // true means aggressive, attack this target

    if (health <= 0) 
      die();
  }

  // on death: drop resources
  void die() {
    ((Level)CurrentGameState).ShipArrayList.remove(this);
    if (resources.get(Resources.LYONDINE)>0)
      ((Level)CurrentGameState).DisplayMap.get("ResourceDrop").add(new ResourceDrop(this.location.copy(), 0, Resources.LYONDINE, resources.get(Resources.LYONDINE)));
    if (resources.get(Resources.AZUTALITE)>0)
      ((Level)CurrentGameState).DisplayMap.get("ResourceDrop").add(new ResourceDrop(this.location.copy(), 1, Resources.AZUTALITE, resources.get(Resources.AZUTALITE)));
    if (resources.get(Resources.ILLIUBISITE)>0)
      ((Level)CurrentGameState).DisplayMap.get("ResourceDrop").add(new ResourceDrop(this.location.copy(), 2, Resources.ILLIUBISITE, resources.get(Resources.ILLIUBISITE)));
    if (resources.get(Resources.BYNTHITE)>0)
      ((Level)CurrentGameState).DisplayMap.get("ResourceDrop").add(new ResourceDrop(this.location.copy(), 0, Resources.BYNTHITE, resources.get(Resources.BYNTHITE)));
    if (resources.get(Resources.REALINUM)>0)
      ((Level)CurrentGameState).DisplayMap.get("ResourceDrop").add(new ResourceDrop(this.location.copy(), 0, Resources.REALINUM, resources.get(Resources.REALINUM)));
  }



  /* ---------------
   Search Functions
   ----------------*/

  ArrayList<Projectile> findCollisions() {
    ArrayList<Projectile> hitList = new ArrayList<Projectile>();
    for (Projectile p : ((Level)CurrentGameState).ProjectileArrayList) {
      if (p.parentShip.parentPlayer != parentPlayer && p.hitCheck(this)) {
        hitList.add(p);
      }
    }
    takeDamage(hitList);
    ((Level)CurrentGameState).ProjectileArrayList.removeAll(hitList);
    return hitList;
  }

  Asteroid findNearestAsteroid() {
    Asteroid currWinner = null;
    float currWinner_dist = 999999999;
    for (Mover m : CurrentGameState.DisplayMap.get("Asteroid")) {
      if (m instanceof Asteroid) {
        float tstDistance = dist(this.location.x, this.location.y, m.location.x, m.location.y);
        if (tstDistance <= currWinner_dist) {
          currWinner_dist = tstDistance;
          currWinner = (Asteroid)m;
        }
      }
    }
    return currWinner;
  }
  Ship findNearestShip(float range) {
    Ship currWinner = null;
    float currWinner_dist = 999999999;
    for (Mover m : CurrentGameState.DisplayMap.get("EnemyShip")) {
      if (m instanceof Ship) {
        float tstDistance = dist(this.location.x, this.location.y, m.location.x, m.location.y);
        if (tstDistance <= range && tstDistance <= currWinner_dist) {
          currWinner_dist = tstDistance;
          currWinner = (Ship)m;
        }
      }
    }
    for (Mover m : CurrentGameState.DisplayMap.get("PioneerShip")) {
      if (m instanceof Ship) {
        float tstDistance = dist(this.location.x, this.location.y, m.location.x, m.location.y);
        if (tstDistance <= range && tstDistance <= currWinner_dist) {
          currWinner_dist = tstDistance;
          currWinner = (Ship)m;
        }
      }
    }
    return currWinner;
  }

  /* ---------------
   input
   ----------------*/

  void onKeyPressed() {
    if (key == 'w' || key == 'W')
      applyForce(new PVector(0, -10));

    if (key == ' ')
      fire();
  }

  void onMousePressed() {
    //if (mouseButton == LEFT) {
    // }
    // if (mouseButton == RIGHT) {
    if (velocity.mag()>.01)
      newTarget = true;
    setTarget(new PVector(mouseX, mouseY), false);
  }
  //}
}