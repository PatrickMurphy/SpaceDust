class UpgradeGUI {
  int pressFrames = 0;
  int pressFrames1 = 0;
  boolean windowOpen = false;
  PVector buttonPosition;
  ArrayList<Item> ItemList;
  ArrayList<Integer> Inventory;
  PVector dimensions;

  UpgradeGUI() {
    this(new PVector(width*.9, height*.85), new PVector(width*.1, min(width*.1, height*.15)));
  }
  UpgradeGUI(PVector pos, PVector dim) {
    buttonPosition = pos;
    dimensions = dim;
    ItemList = new ArrayList<Item>();
    ItemList.add(new GunItem("Machine Gun", new float[]{5, 10, 17}, new float[]{0, 0, 750, 0, 0}));
    ItemList.add(new GunItem("Lightning Gun", new float[]{8, 10, 70}, new float[]{0, 0, 1000, 250, 400}));
    ItemList.add(new GunItem("Mini Gun", new float[]{3, 7, 20}, new float[]{1, 0, 1, 0, 0}));
    ItemList.add(new GunItem("Mega Gun", new float[]{50, 100, 5}, new float[]{0, 1000, 600, 0, 0}));
    ItemList.add(new HullItem("Azutalite Hull", new float[]{.2, 1000}, new float[]{0, 3000, 750, 0, 0}));

    Inventory = new ArrayList<Integer>();
  }

  void update() {
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

    if (pressFrames1 >= 3 && windowOpen) {
      int buttonPressed = displayUpgradeWindowButtonClicked();
      Item i = ItemList.get(buttonPressed);
      if (((Level)CurrentGameState).player.rm.canAfford(i.cost)) {
        ((Level)CurrentGameState).player.addItem(i);
        Inventory.add(buttonPressed);
      }
      pressFrames1 = 0;
    }
  }

  int countOwned() {
    return ((Level)CurrentGameState).player.items.size();
  }

  int countAffordable() {
    int cnt = 0;
    for (Item i : ItemList) {
      if(!((Level)CurrentGameState).player.items.contains(i) && ((Level)CurrentGameState).player.rm.canAfford(i.cost)){
        cnt++;
      }
    }
    return cnt;
  }

  void display() {
    if (windowOpen) {
      displayUpgradeWindow();
    }
    displayUpgradeButton();
  }

  void displayUpgradeButton() {
    pushStyle();
    fill(255);
    textSize(22);
    text("Upgrade", buttonPosition.x+textWidth("Upgrade")/2, buttonPosition.y+height*.07);
    textSize(12);
    text(countAffordable(),buttonPosition.x+textWidth("Upgrade")/2, buttonPosition.y+height*.09);
    fill(255, 55);
    rect(buttonPosition.x, buttonPosition.y, dimensions.x, dimensions.y);
    popStyle();
  }

  void displayUpgradeWindow() {
    fill(255, 70);
    rect(width*.05, height*.05, width - width*.1, height*.05);
    rect(width*.05, height*.05, width - width*.1, height - height * .1);
    float x = width*.05+10;
    float y = height*.1+20;
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

  int displayUpgradeWindowButtonClicked() {
    int cols =3;
    float x = width*.05+10;
    float y = height*.1+20;
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

  boolean displayUpgradeButtonClicked() {
    return(mousePressed && (mouseX >= buttonPosition.x && mouseX <= buttonPosition.x + dimensions.x) && (mouseY >= buttonPosition.y && mouseY <= buttonPosition.y + dimensions.y));
  }
}