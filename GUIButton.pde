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

  void display() {
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

  boolean onButton(int x, int y) {
    return (x >= this.position.x && y >= this.position.y && x <= this.position.x + this.size.x && y <= this.position.y + this.size.y);
  }
}