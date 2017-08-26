class GUIPercentBar extends Mover {
  color c1, c2;
  PVector dimensions,offset;
  GUIPercentBar(PVector pos, PVector dim, PVector offset) {
    this(pos,dim,offset,color(255,0,0),color(0,255,0));
  }
    GUIPercentBar(PVector pos, PVector dim,PVector off, color c1, color c2) {
      super(pos, 0);
      this.c1 = c1;
      this.c2 = c2;
      dimensions = dim;
      offset = off;
    }  
    void display(float pct) {
      noStroke();
      fill(c1);
      rect(location.x+offset.x, location.y+offset.y, dimensions.x, dimensions.y);
      fill(c2);
      rect(location.x+offset.x, location.y+offset.y, dimensions.x*pct, dimensions.y);
      stroke(255,55);
      line(location.x+offset.x, location.y+offset.y,location.x, location.y);
      noStroke();
    }
  }