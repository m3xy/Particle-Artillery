final class Tank extends Particle {
  
  final static float FUEL_MAX = 300;
  
  Gun gun;
  color colour;
  Move moving;    //The movement state of the tank
  boolean turn, ai;
  int score;
  float fuel;
  
  
  public Tank(PVector pos, color colour, float mass, float size, float speed){
    super(pos, mass, 0, size, speed); //Initialising position, mass, health and damping factor of Tank
    this.gun = new Gun(this); //Initialising Tank with a gun
    this.colour = colour;
    this.moving = Move.NONE;
    this.turn = false;
    this.score = 0;
    this.fuel = FUEL_MAX;
    this.ai = false; //Initially
  }
  
  public void run() {
    super.run(); //Run itself
    gun.run();   //But also its gun
  }
  
  public void draw() {
    game.translate(this.pos.x, this.pos.y, this.pos.z); //Translate to the position of the tank
    game.rotateZ(this.rPos.z);
    game.fill(this.colour);
    game.stroke(0);
    game.strokeWeight(2);
    //game.box(0.8 * size, size, 0.8 * size);
    game.box(this.size);
  }
  
  public void update() {
    super.update(); //Integration
    if(this.fuel > 0)
      switch(this.moving) {
        case NONE :
          break;
        case UP :
          if(!is2D) {
            this.rPos.z = 0;
            this.addForce(new PVector(0, -this.energy, 0));
            this.fuel -= this.energy;
          }
          break;
        case DOWN :
          if(!is2D) {
            this.rPos.z = PI;
            this.addForce(new PVector(0, this.energy, 0));
            this.fuel -= this.energy;
          }
          break;
        case LEFT :
          this.rPos.z = -PI/2;
          this.addForce(new PVector(-this.energy, 0, 0));
          this.fuel -= this.energy;
          break;
        case RIGHT :
          this.rPos.z = PI/2;
          this.addForce(new PVector(this.energy, 0, 0));
          this.fuel -= this.energy;
          break;
      }
    this.fuel = constrain(this.fuel, 0, FUEL_MAX);
  }
}

void setTanks() {
  if(!is2D) {
    //Equally spaced spawns (spawn in circle so tanks equally far apart)
    int r = (int)(Math.min(cols/2, rows/2) - 1);
    for(int i = 0; i < PLAYERS; i++) {
       float angle = (TWO_PI*i)/PLAYERS;
       col = (int)(cols/2 + (r*cos(angle)));
       row = (int)(rows/2 + (r*sin(angle)));
       tanks.get(i).pos.set(col*lod, row*lod, land[col][row].z + tanks.get(i).size/2);
    }
  } else {
    //Random spawn
    //PVector pos;
    //for(int i = 0; i < PLAYERS; i++) {
    //  pos = findPos();
    //  tanks.get(i).pos.set(pos);
    //}
    
    //Equally spaced spawns
    for(int i = 0; i < PLAYERS; i++) {
      col = ((cols*i)/PLAYERS) + (cols/(PLAYERS*2));
      row = rows/2;
      tanks.get(i).pos.set(col*lod, row*lod, land[col][row].z + tanks.get(i).size/2);
    }
      
  }
}
