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
    velocity.limit(.2);
    rotation = random(0, TWO_PI);
    texture_id = floor(random(0, 5.99));
    setResourceType(floor(random(0, colors.length-.001)));
    rotation_step = random(-0.05, 0.05);
  }

  void update() {
    super.update();
    rotation = (rotation+rotation_step)%TWO_PI;
    checkBounds();
  }
  void display() {
    pushMatrix();
    translate(location.x, location.y);
    rotate(rotation);
    tint(getColor(), 225);
    image(textures[texture_id], 0, 0, mass*2, mass*2);
    popMatrix();
  }

  void setResourceType(int zeroTofour) {
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
  
  color getColor(){
    return colors[col];
  }

  boolean isInHarvestRange(PVector pos) {
    return dist(pos.x, pos.y, this.location.x, this.location.y)<=mass;
  }

  float harvest(float rate) {
    if (rate <= mass) {
      mass -= rate;
      return rate;
    } else {
      float m_tmp = mass;
      mass = 0;
      return m_tmp;
    }
  }

  void reset() {
    velocity = PVector.random2D();
    velocity.limit(.2);
    rotation = random(0, TWO_PI);
    texture_id = floor(random(0, 5.99));
    col = floor(random(0, colors.length-.001));
    setResourceType(col);
    rotation_step = random(-0.05, 0.05);
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

  void  checkBounds() {
    if (!inBounds()) {
      reset();
    }
  }
}