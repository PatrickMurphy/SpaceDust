class GameState {
  // Display Objects
  ArrayList<Mover> DisplayObjects;
  HashMap<String, ArrayList<Mover>> DisplayMap;

  // GameState Constructor
  GameState() {
    // Setup Game State
    DisplayObjects = new ArrayList<Mover>(); // list of all objects that should be displayed this frame
    DisplayMap = new HashMap<String, ArrayList<Mover>>();
    DisplayMap.put("EnemyShip", new ArrayList<Mover>());
    DisplayMap.put("PioneerShip", new ArrayList<Mover>());
    DisplayMap.put("Asteroid", new ArrayList<Mover>());
    DisplayMap.put("ResourceDrop", new ArrayList<Mover>());
    DisplayMap.put("GUIPercentBar", new ArrayList<Mover>()); 
    DisplayMap.put("Projectile", new ArrayList<Mover>());
  }

  // Update All Display Object Data Models / GUI's and Waves
  void update() {
    for (ArrayList<Mover> value : DisplayMap.values()) {
      for (int i = value.size() - 1; i>=0; i--) {
        value.get(i).update();
      }
    }
  }

  // Draw Level Frame
  void display() {
    for (ArrayList<Mover> value : DisplayMap.values()) {
      for (int i = value.size() - 1; i>=0; i--) {
        value.get(i).display();
      }
    }
  }

  // Add n Asteroids to the Display Objects
  ArrayList<Asteroid> generateRandomAsteroids(int count) {
    ArrayList<Asteroid> asteroids = new ArrayList<Asteroid>();
    for (int i = 0; i <= count; i++) {
      // add at any random location within screen view, mass between 35 and 55
      asteroids.add(new Asteroid(new PVector(random(width), random(height), random(35, 55))));
    }

    return asteroids;
  }

  // Add collection of Asteroid Objects
  void addAsteroids(ArrayList<Asteroid> asteroids) {
    DisplayMap.get("Asteroid").addAll(asteroids);
  }

  // generate and add asteroids to display list
  void addRandomAsteroids() {
    addRandomAsteroids(10);
  }

  // generate n asteroids and add to display list
  void addRandomAsteroids(int n) {
    addAsteroids(generateRandomAsteroids(n));
  }


  // ------------------ pass input events ------------------
  void onKeyPressed() {
    //null
  }

  void onMousePressed() {
    // null
  }
  // ------------------ end input events ------------------
}