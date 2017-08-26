class Mover {
  PVector location, acceleration, velocity;
  float mass;
  Mover(PVector pos, float m) {
    mass = m;
    location = pos;
    velocity = new PVector(0, 0);
    acceleration = new PVector(0, 0);
  }

  void applyForce(PVector force) {
    PVector f = PVector.div(force, mass);
    acceleration.add(f);
  }
  
  boolean inBounds(){
    return (location.x < width+mass && location.x > -mass && location.y < height+mass && location.y > -mass);
  }

  void update() {
    velocity.add(acceleration);
    location.add(velocity);
    acceleration.mult(0);
  }
  
  float distance(Mover m){
    return dist(m.location.x,m.location.y,this.location.x,this.location.y);
  }
  
   void display() {
    fill(color(200,0,0),127);
    ellipse(location.x,location.y,mass*1.6,mass*1.6);
  }
}