// TODO and IDEA LOG: /documentation/*.Docx
GameState CurrentGameState;
GameState NextGameState;
PImage[] textures;
PShape[] shapes;
color[] colors;
GUIButton fireButton;
// setup canvas window
void setup() {
  size(displayWidth, displayHeight, P2D);
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
  colors = new color[]{#b9f2ff, #ffb9c3, #ecffb9, #ffb9f8, #ffe3b9};

  // Initialize Level
  CurrentGameState = new MainMenu();
  NextGameState = new Level();
  
  fireButton = new GUIButton("Fire", new PVector((width/2)-width*.225, height-(height*0.12)), new PVector(width*.45, height * 0.10), 25);
}

void draw() {
  background(15); // Draw Background Color, TODO: add stars and paralax?
  if(mousePressed){
    touchStarted();
  }
  CurrentGameState.update(); // Update level data models 
  CurrentGameState.display(); // Draw Frame

  // Draw Graphical User Interface (GUI)
  //drawDebugGUI(new PVector(5, 10));
  if (!menuGameState()){
    drawPlayerGUI();
    if (mousePressed) {
        if (fireButton.onButton(mouseX, mouseY)) {
          ((Level)CurrentGameState).player.current_ship.fire();
      }
    }
    fireButton.display();  
  }
}

// Draw Development / Debug GUI
void drawDebugGUI(PVector location) {
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
    text("Seconds: " + ((Level)CurrentGameState).WaveList.seconds_until_next_wave(), 0, 80);
    text("Seconds2: " + ((Level)CurrentGameState).WaveList.seconds_wave_length(), 0, 90);
    popMatrix();
  }
}

// Draw Ship Stats etc
void drawPlayerGUI() {
  fill(200, 35);
  rect(0, height*.85, width, height*.15);
  drawResourceGUI(new PVector(width*.2, height*.87));
  pushStyle();
  textSize(48);
  text(((Level)CurrentGameState).WaveList.currentWave,width*.06, height*.92);
  text(((Level)CurrentGameState).WaveList.countAliveShips(),width*.1, height*.92);
 
  textSize(20);
  text("Wave",width*.054, height*.94);
  text("Enemies",width*.094, height*.94);
  popStyle();
}

// Draw Resource Totals and Gathering GUI
void drawResourceGUI(PVector location) {
  if (!menuGameState()) {
    pushMatrix();
    translate(location.x, location.y);
    fill(34);
    rect(0, 0, 100, 55);
    fill(255);
    fill(colors[0]);
    text(floor(((Level)CurrentGameState).player.rm.getResource(Resources.LYONDINE)), 0, 12.5);
    fill(colors[1]);
    text(floor(((Level)CurrentGameState).player.rm.getResource(Resources.AZUTALITE)), 0, 22.5);
    fill(colors[2]);
    text(floor(((Level)CurrentGameState).player.rm.getResource(Resources.ILLIUBISITE)), 0, 32.5);
    fill(colors[3]);
    text(floor(((Level)CurrentGameState).player.rm.getResource(Resources.BYNTHITE)), 0, 42.5);
    fill(colors[4]);
    text(floor(((Level)CurrentGameState).player.rm.getResource(Resources.REALINUM)), 0, 52.5);
    popMatrix();
  }
}

boolean menuGameState() {
  return CurrentGameState instanceof MainMenu;
}

void nextGameState() {
  CurrentGameState = NextGameState;
  NextGameState = null;
}

// Pass Input Events
void keyPressed() {
  CurrentGameState.onKeyPressed();
}

//void mousePressed() {
//  touchStarted();
//}

void touchStarted() {
  if(mouseY <= height*.85)
    CurrentGameState.onMousePressed(); // else player gui on mouse pressed (need to create class)
}

// UTIL Function for Android PVector Copy
PVector copyVector(PVector p) {
  PVector temp = (new PVector());
  temp.x = p.x;
  temp.y = p.y;
  temp.z = 0.0;
  return temp;
}