class Level extends GameState { //<>//
  UpgradeGUI upgradeGui;

  // Teams/Players
  UserPlayer player;
  Player enemyPlayer;

  // Data  Model Objects
  ProjectileManager ProjectileArrayList;
  WaveManager WaveList;
  ShipManager ShipArrayList;
  int asteroid_count;
  String level_state;

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
    player.addShip(new PioneerShip(player, new PVector(width*.75, height*.75)));
    ShipArrayList.addNew(player.current_ship);

    this.DisplayMap.get("EnemyShip").addAll(ShipArrayList.init_addNewShips());

    addRandomAsteroids(asteroid_count);// Add Initial Asteroids

    level_state = "run";
  }

  // Update All Display Object Data Models / GUI's and Waves
  void update() {
    super.update();
    if (player.getShip().getHealth() <= 0) {
      level_state = "dead";
    } else {
      upgradeGui.update();
      WaveList.addNewShips();
      WaveList.update();
      ProjectileArrayList.addNewBullets();
      ShipArrayList.addNewShips();
    }
  }

  // Draw Level Frame
  void display() {
    super.display();
    textSize(14);
    upgradeGui.display();

    if (level_state == "dead") {
      displayGameOver();
    }
  }

  void displayGameOver() {
    fill(55,125);
    rect(width*.25,height*.25,width*.5,height*.5);
    text("Game Over",width/2,height/2);
  }

  // ------------------ pass input events ------------------
  void onKeyPressed() {
    player.onKeyPressed();
  }

  void onMousePressed() {
    player.onMousePressed();
  }
  // ------------------ end input events ------------------
}