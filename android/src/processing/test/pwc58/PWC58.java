package processing.test.pwc58;

import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class PWC58 extends PApplet {

// TODO and IDEA LOG: /documentation/*.Docx
GameState CurrentGameState;
GameState NextGameState;
PImage[] textures;
PShape[] shapes;
int[] colors;

// setup canvas window
public void setup() {
  
  frameRate(24);
  imageMode(CENTER);
  shapeMode(CENTER);

  // Load Texture Images
  textures = new PImage[7];
  for (int ind = 1; ind<=6; ind++)
    textures[ind-1] = loadImage("rock"+ind+".png");

  // Load Vectorized Shapes
  shapes = new PShape[2];
  shapes[0] = loadShape("ship.svg");
  shapes[1] = loadShape("enemy1.svg");

  // Set Resource Colors
  colors = new int[]{0xffb9f2ff, 0xffffb9c3, 0xffecffb9, 0xffffb9f8, 0xffffe3b9};

  // Initialize Level
  CurrentGameState = new MainMenu();
  NextGameState = new Level();
}

public void draw() {
  background(15); // Draw Background Color, TODO: add stars and paralax?
  CurrentGameState.update(); // Update level data models 
  CurrentGameState.display(); // Draw Frame

  // Draw Graphical User Interface (GUI)
  drawDebugGUI(new PVector(5, 10));
  drawResourceGUI(new PVector(width-100, 5));
}

// Draw Development / Debug GUI
public void drawDebugGUI(PVector location) {
  if (!menuGameState()) {
    pushMatrix();
    translate(location.x, location.y);
    text("Vel: "+((Level)CurrentGameState).player.current_ship.velocity, 0, 0);
    text("Mag: "+((Level)CurrentGameState).player.current_ship.velocity.mag(), 0, 10);
    text("health: "+((Level)CurrentGameState).player.current_ship.getHealth(), 0, 20);
    text("harvest: "+((Level)CurrentGameState).player.current_ship.is_harvesting, 0, 30);
    text("Wave Started: "+((Level)CurrentGameState).WaveList.WavesInitalized, 0, 40);
    text("Waves: "+((Level)CurrentGameState).WaveList.waves.size(), 0, 50);
    text("Current Wave: "+((Level)CurrentGameState).WaveList.currentWave, 0, 60);
    text("Enemys: "+((Level)CurrentGameState).WaveList.countAliveShips(), 0, 70);
    popMatrix();
  }
}

// Draw Ship Stats etc
public void drawPlayerGUI() {
}

// Draw Resource Totals and Gathering GUI
public void drawResourceGUI(PVector location) {
  if (!menuGameState()) {
    pushMatrix();
    translate(location.x, location.y);
    fill(34);
    rect(0, 0, 100, 55);
    fill(255);
    fill(colors[0]);
    text(((Level)CurrentGameState).player.rm.getResource(Resources.LYONDINE), 0, 12.5f);
    fill(colors[1]);
    text(((Level)CurrentGameState).player.rm.getResource(Resources.AZUTALITE), 0, 22.5f);
    fill(colors[2]);
    text(((Level)CurrentGameState).player.rm.getResource(Resources.ILLIUBISITE), 0, 32.5f);
    fill(colors[3]);
    text(((Level)CurrentGameState).player.rm.getResource(Resources.BYNTHITE), 0, 42.5f);
    fill(colors[4]);
    text(((Level)CurrentGameState).player.rm.getResource(Resources.REALINUM), 0, 52.5f);
    popMatrix();
  }
}

public boolean menuGameState() {
  return CurrentGameState instanceof MainMenu;
}

public void nextGameState(){
  CurrentGameState = NextGameState;
  NextGameState = null;
}

// Pass Input Events
public void keyPressed() {
  CurrentGameState.onKeyPressed();
}

public void mousePressed() {
  touchStarted();
}

public void touchStarted() {
  CurrentGameState.onMousePressed();
}

// UTIL Function for Android PVector Copy
public PVector copyVector(PVector p) {
  PVector temp = (new PVector());
  temp.x = p.x;
  temp.y = p.y;
  temp.z = 0.0f;
  return temp;
}
class Asteroid extends Mover {
  int texture_id;
  int col;
  float rotation, rotation_step;
  Resources resourceType;
  Asteroid(PVector pos) {
    this(pos, random(25, 70));
  }

  Asteroid(PVector pos, float m) {
    super(pos, m);
    velocity = PVector.random2D();
    velocity.limit(.2f);
    rotation = random(0, TWO_PI);
    texture_id = floor(random(0, 5.99f));
    setResourceType(floor(random(0, colors.length-.001f)));
    rotation_step = random(-0.05f, 0.05f);
  }

  public void update() {
    super.update();
    rotation = (rotation+rotation_step)%TWO_PI;
    checkBounds();
  }
  public void display() {
    pushMatrix();
    translate(location.x, location.y);
    rotate(rotation);
    tint(colors[col], 225);
    image(textures[texture_id], 0, 0, mass*2, mass*2);
    popMatrix();
  }

  public void setResourceType(int zeroTofour) {
    col = zeroTofour;
    switch(zeroTofour) {
    case 0:
      resourceType = Resources.LYONDINE;
      break;
    case 1:
      resourceType = Resources.AZUTALITE;
      break;
    case 2:
      resourceType = Resources.ILLIUBISITE;
      break;
    case 3:
      resourceType = Resources.BYNTHITE;
      break;
    case 4:
      resourceType = Resources.REALINUM;
      break;
    }
  }

  public boolean isInHarvestRange(PVector pos) {
    return dist(pos.x, pos.y, this.location.x, this.location.y)<=mass;
  }

  public float harvest(float rate) {
    if (rate <= mass) {
      mass -= rate;
      return rate;
    } else {
      float m_tmp = mass;
      mass = 0;
      return m_tmp;
    }
  }

  public void  checkBounds() {
    if (!(location.x < width+mass && location.x > -mass && location.y < height+mass && location.y > -mass)) {
      velocity = PVector.random2D();
      velocity.limit(.2f);
      rotation = random(0, TWO_PI);
      texture_id = floor(random(0, 5.99f));
      col = floor(random(0, colors.length-.001f));
      setResourceType(col);
      rotation_step = random(-0.05f, 0.05f);
      mass = random(25, 70);
      location = new PVector(random(0, width), width+130);
      float temp = random(100);
      if (temp < 25) {
        location.x = -mass;
      } else if (temp < 50) {
        location.x = width+mass;
      } else if (temp < 75) {
        location.y = height+mass;
      } else if (temp < 100) {
        location.y = -mass;
      }
    }
  }
}
class EnemyShip extends Ship {
  EnemyShip(Player p, PVector pos) {
    super(p,pos, 45, .5f, 550, 250, false);
    setDisplayRatio(new PVector(190, 315));
    setHealth(100);
    setFireRate(15);
    setBulletSpeed(9);
    setDamage(3);
  }

  public void update() {
    super.update();
    if (dist(location.x, location.y, ((Level)CurrentGameState).player.current_ship.location.x, ((Level)CurrentGameState).player.current_ship.location.y)<=this.los)
      super.setTarget(((Level)CurrentGameState).player.current_ship.location, true); // true means aggressive, attack this target
    else {
      super.setTarget(findNearestAsteroid().location, false); // false means non-aggressive don't attack, implies harvest
    }
  }

  public void display() {
    pushMatrix();
    translate(location.x, location.y);
    rotate(velocity.heading()+PI/2);
    noTint();
    shape(shapes[1], 0, 0, mass*display_ratio.x, mass*display_ratio.y);
    popMatrix();
    noStroke();
    fill(200, 55);
    ellipse(target.x, target.y, 20, 20);
    text("H: "+this.getHealth(), location.x, location.y);
  }
}
class GUIButton {
  PVector size, position;
  String name;
  float btnTextSize;
  PFont btnFont;
  boolean pressed;

  GUIButton(String name, PVector pos, PVector size, float txtSize) {
    this(name, pos, size, txtSize, createFont("Georgia", txtSize));
  }

  GUIButton(String btnName, PVector btnPos, PVector size, float btnTextSize, PFont btnFont) {
    name = btnName;
    this.position = btnPos;
    this.size = size;
    this.btnFont = btnFont;
    this.btnTextSize = btnTextSize;
    this.pressed = false;
  }

  public void display() {
    textSize(this.btnTextSize);
    //textFont(this.btnFont);
    //textAlign(CENTER, CENTER);

    if (!this.pressed) {
      fill(0, 110, 100);
      rect(this.position.x, this.position.y + height / 150, this.size.x, this.size.y, 15);
      fill(0, 150, 140);
      rect(this.position.x, this.position.y, this.size.x, this.size.y, 15);
      fill(255);
      text(this.name, this.position.x + (this.size.x / 2), this.position.y + (this.size.y / 2));
    } else {
      fill(0, 60, 55);
      rect(this.position.x, this.position.y, this.size.x, this.size.y, 15);
      fill(0, 100, 90);
      rect(this.position.x, this.position.y + height / 150, this.size.x, this.size.y, 15);
      fill(180);
      text(this.name, this.position.x + this.size.x / 2, this.position.y + this.size.y / 2 + height / 150);
    }
  }

  public boolean onButton(int x, int y) {
    return (x >= this.position.x && y >= this.position.y && x <= this.position.x + this.size.x && y <= this.position.y + this.size.y);
  }
}
class GameState {
  // Display Objects
  ArrayList<Mover> DisplayObjects;

  // GameState Constructor
  GameState() {
    // Setup Game State
    DisplayObjects = new ArrayList<Mover>(); // list of all objects that should be displayed this frame
  }

  // Update All Display Object Data Models / GUI's and Waves
  public void update() {
    for (int i = DisplayObjects.size()-1; i>=0; i--) {
      DisplayObjects.get(i).update();
    }
  }

  // Draw Level Frame
  public void display() {
    for (int i = DisplayObjects.size()-1; i>=0; i--) {
      DisplayObjects.get(i).display();
    }
  }

  // Add n Asteroids to the Display Objects
  public ArrayList<Asteroid> generateRandomAsteroids(int count) {
    ArrayList<Asteroid> asteroids = new ArrayList<Asteroid>();
    for (int i = 0; i <= count; i++) {
      // add at any random location within screen view, mass between 35 and 55
      asteroids.add(new Asteroid(new PVector(random(width), random(height), random(35, 55))));
    }

    return asteroids;
  }

  // Add collection of Asteroid Objects
  public void addAsteroids(ArrayList<Asteroid> asteroids) {
    DisplayObjects.addAll(asteroids);
  }

  // generate and add asteroids to display list
  public void addRandomAsteroids() {
    addRandomAsteroids(10);
  }

  // generate n asteroids and add to display list
  public void addRandomAsteroids(int n) {
    addAsteroids(generateRandomAsteroids(n));
  }


  // ------------------ pass input events ------------------
  public void onKeyPressed() {
    //null
  }

  public void onMousePressed() {
    // null
  }
  // ------------------ end input events ------------------
}
class GunItem extends Item {
  float[] effects;

  GunItem(String name, float fireRate, float damage, float bulletSpeed, float[] cost) {
    this(name, new float[]{fireRate, damage, bulletSpeed}, cost);
  }

  GunItem(String name, float[] effects, float[] cost) {
    super(name, ItemType.GUN, cost);
    this.effects = effects;
  }

  public void applyEffect(UserPlayer p) {
    p.current_ship.setFireRate(floor(effects[0]));
    p.current_ship.setDamage(effects[1]);
    p.current_ship.setBulletSpeed(effects[2]);
  }
}
class HullItem extends Item{
  float[] effects;
  
  HullItem(String name, float healthRegen, float maxHealth, float[] cost){
    this(name, new float[]{healthRegen,maxHealth},cost);
  }
  
  HullItem(String name, float[] effects, float[] cost){
    super(name, ItemType.HULL, cost);
    this.effects = effects;
  }
  
  public void applyEffect(UserPlayer p){
    p.current_ship.setHealthRegen(effects[0]);
    p.current_ship.setMaxHealth(effects[1]);
  }
}
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
  
  public void applyEffect(UserPlayer p){
    println("null item");
  }
}
enum ItemType {
  GUN("gun"), 
    ENGINE("engine"), 
    HULL("hull"), 
    SHIP("ship"), 
    DRILL("drill");

  final String text;

  private ItemType(final String text) {
    this.text = text;
  }

  public String toString() {
    return text;
  }
}
class Level extends GameState {
  UpgradeGUI upgradeGui;

  // Teams/Players
  UserPlayer player;
  Player enemyPlayer;

  // Data  Model Objects
  ProjectileManager ProjectileArrayList;
  WaveManager WaveList;
  ShipManager ShipArrayList;
  int asteroid_count;

  // Default Level Constructor
  Level() {
    this(20);
  }

  // Level Constructor
  Level(int asteroid_count) {
    super();
    this.asteroid_count = asteroid_count;

    // Setup Level
    upgradeGui = new UpgradeGUI(); // GUI display Manager

    // Create Player for Human User & Enemy Team (For Resource pooling and who bullets should hit?)
    player = new UserPlayer();
    enemyPlayer = new Player();

    // Data Lists to manage All Ships and Projectiles
    ShipArrayList = new ShipManager();
    ProjectileArrayList = new ProjectileManager();
    WaveList = new WaveManager();

    // Add User Ship to Player / Ship List
    player.addShip(new PioneerShip(player, new PVector(width, height)));
    ShipArrayList.addNew(player.current_ship);

    addRandomAsteroids(asteroid_count);// Add Initial Asteroids
  }

  // Update All Display Object Data Models / GUI's and Waves
  public void update() {
    super.update();
    upgradeGui.update();
    // move back to end of update
    WaveList.addNewShips();
    WaveList.update();
    ProjectileArrayList.addNewBullets();
    ShipArrayList.addNewShips();
    // move back --------
  }

  // Draw Level Frame
  public void display() {
    super.display();
    textSize(14);
    upgradeGui.display();
  }

  // ------------------ pass input events ------------------
  public void onKeyPressed() {
    player.onKeyPressed();
  }

  public void onMousePressed() {
    player.onMousePressed();
  }
  // ------------------ end input events ------------------
}
class MainMenu extends GameState{
  
  GUIButton play, settings, about;
  MainMenu(){
    super();
    play = new GUIButton("Play",new PVector(width*0.1f,height*0.4f),new PVector(width*.8f,height * 0.15f),25);
    settings = new GUIButton("Settings",new PVector(width*0.1f,height*0.575f),new PVector(width*.8f,height * 0.15f),25);
    about = new GUIButton("About",new PVector(width*0.1f,height*(0.575f+(0.575f-0.4f))),new PVector(width*.8f,height * 0.15f),25);
    
    addRandomAsteroids(30);
  }
  
  public void update(){
    super.update();
    if(play.onButton(mouseX,mouseY) && mousePressed){
      nextGameState();
    }
  }
  public void display(){
    super.display();
    
    text("Awesome Title!", width*.1f, height*.2f);
    
    play.display();
    settings.display();
    about.display();
  }
}
class Mover {
  PVector location, acceleration, velocity;
  float mass;
  Mover(PVector pos, float m) {
    mass = m;
    location = pos;
    velocity = new PVector(0, 0);
    acceleration = new PVector(0, 0);
  }

  public void applyForce(PVector force) {
    PVector f = PVector.div(force, mass);
    acceleration.add(f);
  }

  public void update() {
    velocity.add(acceleration);
    location.add(velocity);
    acceleration.mult(0);
  }
  
   public void display() {
    fill(color(200,0,0),127);
    ellipse(location.x,location.y,mass*1.6f,mass*1.6f);
  }
}
class PioneerShip extends Ship {
  PioneerShip(Player p, PVector pos) {
    super(p, pos, 100, 6, 25, 25, true);
    setDisplayRatio(new PVector(315, 190));
    setDamage(25);
    setBulletSpeed(15);
  }

  public void display() {
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
class Player {
  ResourceManager rm;
  Player() {
    rm = new ResourceManager();
  }
}
class Projectile extends Mover {
  Ship parent;
  float speed, damage;

  Projectile(Ship parent, float ms, float damage) {
    super(copyVector(parent.location), 2);
    this.parent = parent;
    speed = ms;
    this.damage = damage;
    this.velocity = copyVector(parent.velocity);
    this.velocity.setMag(speed);
  }

  public float getWidth() {
    return damage/3;
  }
  public float getHeight() {
    return damage/3;
  }

  public float getRadius() {
    return (damage/3)/2;
  }

  public boolean hitCheck(Ship s) {
    return s != parent && dist(s.location.x,s.location.y,this.location.x,this.location.y) <= s.mass/2;
  }

  public void display() {
    fill(255, 0, 0);
    ellipse(location.x, location.y, getWidth(), getHeight());
  }
}
class ProjectileManager extends ArrayList<Projectile> {
  ArrayList<Projectile> newBullets;
  ArrayList<Projectile> removeList;
  ProjectileManager() {
    super();
    newBullets = new ArrayList<Projectile>();
  }

  public void addNewBullets() {
    if (newBullets.size() >= 0) {
      ((Level)CurrentGameState).DisplayObjects.addAll(newBullets);
      this.addAll(newBullets);
      newBullets.clear();
    }
  }

  public void addNew(Projectile P) {
    newBullets.add(P);
  }

  public void removeAll(ArrayList<Projectile> l) {
    super.removeAll(l);
    ((Level)CurrentGameState).DisplayObjects.removeAll(l);
  }
}


class ResourceManager {
  Map<Resources, Float> resources;
  float resourceScale;
  
  ResourceManager(){
    this(0.0f);
  }
  
  ResourceManager(float all){
    this(all,all,all,all,all);
    resourceScale = 1000;
  }
  
  ResourceManager(float l, float a, float i, float b, float r) {
    resources = new HashMap<Resources, Float>();
    resources.put(Resources.LYONDINE, l);
    resources.put(Resources.AZUTALITE, a);
    resources.put(Resources.ILLIUBISITE, i);
    resources.put(Resources.BYNTHITE, b);
    resources.put(Resources.REALINUM, r);
  }
  
  public float getResource(Resources rKey){
    return resources.get(rKey);
  }
  
  public void addResource(Resources resourceKey, float value){
    resources.put(resourceKey,(value*resourceScale)+resources.get(resourceKey));
  }
  public boolean canAfford(float[] resources){
    boolean affordable = true;
    if(resources.length == 5){
      if(!canAfford(Resources.LYONDINE,resources[0])){
        affordable = false;
      }
      if(!canAfford(Resources.AZUTALITE,resources[1])){
        affordable = false;
      }
      if(!canAfford(Resources.ILLIUBISITE,resources[2])){
        affordable = false;
      }
      if(!canAfford(Resources.BYNTHITE,resources[3])){
        affordable = false;
      }
      if(!canAfford(Resources.REALINUM,resources[4])){
        affordable = false;
      }
    }else{
      affordable = false;
    }
    return affordable;
  }
  public boolean canAfford(Resources resourceKey, float value){
    return resources.get(resourceKey) >= value;
  }
  
  public boolean useResource(float[] cost){
    boolean bought = true;
    if(canAfford(cost)){
      useResource(Resources.LYONDINE, cost[0]);
      useResource(Resources.AZUTALITE, cost[1]);
      useResource(Resources.ILLIUBISITE, cost[2]);
      useResource(Resources.BYNTHITE, cost[3]);
      useResource(Resources.REALINUM, cost[4]);
    }else{
      bought = false;
    }
    return bought;
  }
  
  public boolean useResource(Resources resourceKey, float value){
    if(canAfford(resourceKey, value)){
      resources.put(resourceKey, resources.get(resourceKey)-value);
      return true;
    }else{
      return false;
    }
  }
}
enum Resources {
  LYONDINE("lyine"), 
    AZUTALITE("azlite"), 
    ILLIUBISITE("illite"), 
    BYNTHITE("bythite"), 
    REALINUM("realum");

  final String text;

  private Resources(final String text) {
    this.text = text;
  }

  public String toString() {
    return text;
  }
}
class Ship extends Mover {
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
    stationary = false;
  }

  public void update() {
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
    Ship NearShip = findNearestShip(35);
    if (NearShip!=null) {
      PVector nearLoc = copyVector(NearShip.location);
      nearLoc.sub(location);
      nearLoc.mult(-1);
      nearLoc.setMag(100);
      applyForce(nearLoc);
    }
  }
  public void display() {
    super.display();
  }

  public void setHealth(float h) {
    health = h;
  }

  public float getHealth() {
    return health;
  }

  public void setMaxHealth(float mh) {
    maxHealth = mh;
  }

  public void setHealthRegen(float hr) {
    healthRegen = hr;
  }

  public void setFireRate(int frames) {
    fireRate_frames = frames;
  }
  public void setDamage(float d) {
    damage = d;
  }
  public void setBulletSpeed(float bs) {
    bullet_speed = bs;
  }

  public void setTarget(PVector t) {
    setTarget(t, false);
  }
  public void setTarget(PVector t, boolean aggressive) {
    setTarget(t, aggressive, false);
  }

  public void setTarget(PVector t, boolean aggressive, boolean reset) {
    target = t;
    target_aggression = aggressive;
    if (reset)
      velocity.setMag(velocity.mag()*.98f);
  }

  public boolean atTarget() {
    return atTarget(0.0f);
  }
  public boolean atTarget(float range) {
    if (range <= 0.0f) {
      return target.x == location.x && target.y == location.y;
    } else {
      return dist(target.x, target.y, location.x, location.y) <= range;
    }
  }

  public void setDisplayRatio(PVector dr) {
    display_ratio = dr;
    dr.normalize();
    display_ratio = dr;
  }

  public Projectile getProjectile() {
    return new Projectile(this, bullet_speed, damage);
  }

  public void fire() {
    if (frameCount - lastFireFrame >= fireRate_frames) {
      ((Level)CurrentGameState).ProjectileArrayList.addNew(getProjectile());
      lastFireFrame = frameCount;
    }
  }

  public void brake() {          
    if (debug) println("call brake : " + userControlled);
    PVector brakeVect = copyVector(velocity);
    brakeVect.mult(-1);
    brakeVect.mult(0.0001f);
    applyForce(brakeVect);//friction
  }
  public void accelerate() {
    if (debug) println("call accel : " + userControlled);
    stationary = false;
    PVector accelVect = PVector.sub(target, location);
    accelVect.mult(map(max(min(velocity.mag(), 0), max_speed), 0, max_speed, .1f, .7f));
    accelVect.sub(velocity);
    applyForce(accelVect);
  }
  public void inRange() {
    if (debug) println("call inRange : " + userControlled);
    stationary = true;
    velocity.setMag(0.00001f);
    if (target_aggression)
      fire();
    if (userControlled)
      target = copyVector(location);
  }
  public void lookAt(PVector t) {
    if (debug) println("call lookAt " + stationary + "  : " + userControlled);
    PVector tempVect = new PVector(t.x, t.y);
    tempVect.sub(location);
    tempVect.setMag(0.00001f);
    velocity = tempVect;
  }

  public int hitCheckID() {
    int ret_val = -1;
    for (int i = 0; i <= ((Level)CurrentGameState).ProjectileArrayList.size(); i++) {
      Projectile p = ((Level)CurrentGameState).ProjectileArrayList.get(i);
      if (p.hitCheck(this)) {
        ret_val = i;
        break;
      }
    }
    return ret_val;
  }

  public ArrayList<Projectile> findCollisions() {
    ArrayList<Projectile> hitList = new ArrayList<Projectile>();
    for (Projectile p : ((Level)CurrentGameState).ProjectileArrayList) {
      if (p.parent.parentPlayer != parentPlayer && p.hitCheck(this)) {
        hitList.add(p);
      }
    }
    takeDamage(hitList);
    ((Level)CurrentGameState).ProjectileArrayList.removeAll(hitList);
    return hitList;
  }

  public void takeDamage(ArrayList<Projectile> p) {
    for (Projectile thisp : p)
      health -= thisp.damage;

    if (health <= 0) 
      ((Level)CurrentGameState).ShipArrayList.remove(this);
  }

  public boolean harvest() {
    Asteroid a = findNearestAsteroid();
    if (a.isInHarvestRange(this.location)) {
      is_harvesting = true;
      parentPlayer.rm.addResource(a.resourceType, a.harvest(.005f));
    } else
      is_harvesting = false;


    return is_harvesting;
  }

  public Asteroid findNearestAsteroid() {
    Asteroid currWinner = null;
    float currWinner_dist = 999999999;
    for (Mover m : CurrentGameState.DisplayObjects) {
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
  public Ship findNearestShip(float range) {
    Ship currWinner = null;
    float currWinner_dist = 999999999;
    for (Mover m : CurrentGameState.DisplayObjects) {
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


  public void onKeyPressed() {
    if (key == 'w' || key == 'W')
      applyForce(new PVector(0, -10));

    if (key == ' ')
      fire();
  }

  public void onMousePressed() {
    //if (mouseButton == LEFT) {
    // }
    // if (mouseButton == RIGHT) {
    if (velocity.mag()>.01f)
      newTarget = true;
    setTarget(new PVector(mouseX, mouseY), false);
  }
  //}
}
class ShipItem extends Item{
  Ship ship;
  ShipItem(String name, Ship ship,float[] cost){
    super(name, ItemType.SHIP, cost);
    this.ship = ship;
  }
  
  public void applyEffect(UserPlayer p){
    p.addShip(ship);
    p.applyItems();
  }
}
class ShipManager extends ArrayList<Ship> {
  ArrayList<Ship> newShips;
  ShipManager() {
    super();
    newShips = new ArrayList<Ship>();
  }

  public void addNewShips() {
    ((Level)CurrentGameState).DisplayObjects.addAll(newShips);
    this.addAll(newShips);
    newShips.clear();
  }

  public void addNew(Ship s) {
    newShips.add(s);
  }
  
  public void addAll(ArrayList<Ship> ships){
    newShips.addAll(ships);
  }

  public void remove(Ship s) {
    super.remove(s);
    ((Level)CurrentGameState).DisplayObjects.remove(s);
  }
}
class UpgradeGUI {
  int pressFrames = 0;
  int pressFrames1 = 0;
  boolean windowOpen = false;
  PVector buttonPosition;
  ArrayList<Item> ItemList;
  ArrayList<Integer> Inventory;

  UpgradeGUI() {
    this(new PVector(width-70, 75));

    ItemList = new ArrayList<Item>();
    ItemList.add(new GunItem("Machine Gun", new float[]{5, 10, 17}, new float[]{0, 0, 750, 0, 0}));
    ItemList.add(new GunItem("Lightning Gun", new float[]{8, 10, 70}, new float[]{0, 0, 1000, 250, 400}));
    ItemList.add(new GunItem("Mini Gun", new float[]{3, 7, 20}, new float[]{1, 0, 1, 0, 0}));
    ItemList.add(new GunItem("Mega Gun", new float[]{50, 100, 5}, new float[]{0, 1000, 600, 0, 0}));
    ItemList.add(new HullItem("Azutalite Hull", new float[]{.2f, 1000}, new float[]{0, 3000, 750, 0, 0}));
    
    Inventory = new ArrayList<Integer>();
  }
  UpgradeGUI(PVector pos) {
    buttonPosition = pos;
  }

  public void update() {
    if (displayUpgradeButtonClicked())
      pressFrames++;
    else
      pressFrames = 0;

    if (pressFrames >= 3) {
      windowOpen = !windowOpen;
      pressFrames = 0;
    }

    if (displayUpgradeWindowButtonClicked() != -1)
      pressFrames1++;
    else 
    pressFrames1 = 0;

    if (pressFrames1 >= 3) {
      int buttonPressed = displayUpgradeWindowButtonClicked();
      Item i = ItemList.get(buttonPressed);
      if (((Level)CurrentGameState).player.rm.canAfford(i.cost)) {
        ((Level)CurrentGameState).player.addItem(i);
        Inventory.add(buttonPressed);
      }
      pressFrames1 = 0;
    }
  }

  public void display() {
    if (windowOpen) {
      displayUpgradeWindow();
    }
    displayUpgradeButton();
  }

  public void displayUpgradeButton() {
    fill(255);
    text("Upgrade", buttonPosition.x, buttonPosition.y+25);
    fill(255, 55);
    rect(buttonPosition.x, buttonPosition.y, 50, 50);
  }

  public void displayUpgradeWindow() {
    fill(255, 70);
    rect(width*.05f, height*.05f, width - width*.1f, height*.05f);
    rect(width*.05f, height*.05f, width - width*.1f, height - height * .1f);
    float x = width*.05f+10;
    float y = height*.1f+20;
    int btn = 0;
    int cols = 3;
    for (Item ThisUpgradeDisplayItem : ItemList) {
      pushStyle();
      textAlign(CENTER);
      if (Inventory.contains(btn)) {
        fill(color(0, 0, 160), 200);
      } else {
        if (((Level)CurrentGameState).player.rm.canAfford(ThisUpgradeDisplayItem.cost))
          fill(color(0, 160, 0), 200);
        else
          fill(color(160, 0, 0), 200);
      }
      rect(x, y, 75, 75);

      fill(0);
      text(ThisUpgradeDisplayItem.name, x+(75/2), y);
      textSize(25);
      text(ThisUpgradeDisplayItem.type.toString(), x+75/2, y+(75/2));
      x += 90;
      if (btn > 0 && btn % cols-1 == 0) {
        y+=100;
        x -= (cols-1)*90;
      }
      btn++;
      popStyle();
    }
  }

  public int displayUpgradeWindowButtonClicked() {
    int cols =3;
    float x = width*.05f+10;
    float y = height*.1f+20;
    int btn = 0;
    for (Item i : ItemList) {
      if (mousePressed && (mouseX >= x && mouseX <= x+75) && (mouseY>= y && mouseY <= y+75)) {
        return btn;
      }
      x += 90;
      if (btn > 0 && btn % cols-1 == 0) {
        y+=100;
        x -= (cols-1)*90;
      }
      btn++;
    }
    return -1;
  }

  public boolean displayUpgradeButtonClicked() {
    return(mousePressed && (mouseX >= buttonPosition.x && mouseX <= buttonPosition.x + 50) && (mouseY >= buttonPosition.y && mouseY <= buttonPosition.y + 50));
  }
}
class UserPlayer extends Player {
  Ship current_ship;
  ArrayList<Item> items;
  UserPlayer() {
    super();
    items = new ArrayList<Item>();
  }

  public void addShip(Ship cs) {
    current_ship = cs;
  }
  
  public void addItem(Item i){
    rm.useResource(i.cost);
    i.applyEffect(this);
    if(i.type != ItemType.SHIP){
      items.add(i);
    }
  }
  
  public void applyItems(){
    for(Item i : items)
      i.applyEffect(this);
  }

  public void onKeyPressed() {
    current_ship.onKeyPressed();
  }

  public void onMousePressed() {
    current_ship.onMousePressed();
  }
}
class WaveManager extends ShipManager {
  int currentWave;
  boolean WavesInitalized;
  boolean waiting_for_timer;
  ArrayList<ArrayList<Ship>> waves;
  boolean debug;
  ArrayList<Integer> wave_delay_seconds;
  WaveManager() {
    super();
    debug = false;
    waves = new ArrayList<ArrayList<Ship>>();
    wave_delay_seconds = new ArrayList<Integer>();
    WavesInitalized = false;
    waiting_for_timer = false;
    currentWave = 0;
  }

  public void update() {
    int tempWave = currentWave;
    if (!WavesInitalized) {
      WavesInitalized = true;
      queueWave(generateWave(currentWave+3));
      deployWave(currentWave);
      currentWave = 1;
    } else {
      if (countAliveShips()==0) {
        waveComplete();
        tempWave++;
      }
      if (tempWave > currentWave) {
        deployNextWave();
        currentWave = tempWave;
      }
    }
  }

  public void deployNextWave() {
    deployWave(currentWave-1);
  }

  public void deployWave(int i) {
    addAll(waves.get(i));
  }

  public void waveComplete() {
    if (waves.size() <= currentWave)
      addAll(generateWave(currentWave+4));
  }

  public void queueWave(ArrayList<Ship> wave) {
    waves.add(wave);
  }

  public ArrayList<Ship> generateWave() {
    return generateWave(10);
  }
  public ArrayList<Ship> generateWave(int count) {
    ArrayList<Ship> wave = new ArrayList<Ship>();
    if (debug) println(wave);
    PVector RandomSpawn = new PVector(random(25, 90), random(0, height));
    for (int i = 0; i<count; i++) {     
      PVector rSpawn = copyVector(RandomSpawn);
      PVector randOffset = PVector.random2D();
      randOffset.setMag(random(250));
      rSpawn.add(randOffset);
      EnemyShip s = new EnemyShip(((Level)CurrentGameState).enemyPlayer, rSpawn);
      wave.add(s);
    }
    return wave;
  }

  public int countAliveShips() {
    int count = 0;
    for (Mover m : ((Level)CurrentGameState).DisplayObjects) {
      if (m instanceof EnemyShip) {
        count++;
      }
    }
    return count;
  }
}
  public void settings() {  size(displayWidth, displayHeight, P2D); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "PWC58" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
