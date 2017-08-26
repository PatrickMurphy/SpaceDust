class MainMenu extends GameState {
  String menu_state; // menu, settings, about
  GUIButton play, settings, about, back;
  MainMenu() {
    super();
    menu_state = "menu";
    play = new GUIButton("Play", new PVector(width*0.1, height*0.4), new PVector(width*.8, height * 0.15), 25);
    settings = new GUIButton("Settings", new PVector(width*0.1, height*0.575), new PVector(width*.8, height * 0.15), 25);
    about = new GUIButton("About", new PVector(width*0.1, height*(0.575+(0.575-0.4))), new PVector(width*.8, height * 0.15), 25);
    back = new GUIButton("< Back", new PVector(width*.8, height * 0.15), new PVector(textWidth("< Back")*5.25, textWidth("< Back")), 12);

    addRandomAsteroids(30);
  }

  void update() {
    super.update();
    if (mousePressed) {
      if (menu_state == "menu") {
        if (play.onButton(mouseX, mouseY)) {
          nextGameState();
        }
        if (settings.onButton(mouseX, mouseY)) {
          menu_state = "settings";
        }
        if (about.onButton(mouseX, mouseY)) {
          menu_state = "about";
        }
      } else {
        if(back.onButton(mouseX,mouseY)){
          menu_state = "menu";
        }
      }
    }
  }
  void display() {
    super.display();
    if(menu_state == "settings") {
      display_settings();
    }else if(menu_state == "about"){
      display_about();
    }else{
      display_menu();
    }
  }

  void display_menu() {
    pushStyle();
    textSize(225);
    text("Space Dust", width*.1, height*.2);
    popStyle();

    play.display();
    settings.display();
    about.display();
  }
  void display_settings() {
    background(100);
    text("settings", width*.1, height*.2);
    back.display();
  }
  void display_about() {
    background(100);
    text("about!", width*.1, height*.2);
    back.display();
  }
}