class ResourceDrop extends Mover {
  Resources resource;
  float value;
  int col;
  boolean active;
  float rotation;
  ResourceDrop(PVector pos, int col, Resources r, float v) {
    super(pos, v);
    resource = r;
    this.col = col;
    value = v;
    this.velocity = PVector.random2D();
    this.active = true;
    this.rotation = random(0, 3.14);
  }

  void update() {
    if (this.active) {
      super.update();
      rotation = rotation+0.01;
      if (rotation > 3.14)
        rotation = 0;
    }
  }

  void consume(Ship s) {
    if (this.active) {
      s.addResource(resource, value);
      this.active = false;
    }
  }

  void display() {
    if (this.active) {
      println("disp");
      pushMatrix();
      fill(colors[col]);
      rotate(rotation);
      rect(location.x, location.y, value, value);
      popMatrix();
    }
  }
}