final class Gun extends Particle {
  
  Tank tank;
  Ammo ammo;
  Move aiming;  //The movement state of the gun
  
  public Gun(Tank tank) {
    super(new PVector(tank.pos.x, tank.pos.y, tank.pos.z + tank.size/4), 1, 0, tank.size, 0.01 * tank.energy);
    this.tank = tank;
    this.ammo = new Ammo(this);
    aiming = Move.NONE;
    if(is2D) this.rPos.z = HALF_PI;
  }
  
  public void run() {
    super.run(); //Run itself
    ammo.run();   //But also its ammo
  }
  
  void draw(){
    game.translate(this.pos.x, this.pos.y, this.pos.z);
    game.rotateZ(this.rPos.z);
    game.rotateX(this.rPos.x);
    game.rotateY(this.rPos.y); //Unused
    game.translate(0, -this.size*0.8, 0); //Move pivot point
    game.fill(this.tank.colour);
    game.box(this.size/4, this.size*1.5, this.size/4); //Draw gun
  };
  
  void update() {
    super.update();
    this.pos.set(this.tank.pos.x, this.tank.pos.y, this.tank.pos.z + this.size/4);
    switch(aiming) {
    case NONE:
      break;
    case UP:
      this.addTorque(new PVector(-this.energy, 0, 0));
      break;
    case LEFT:
      if(is2D) this.rPos.z = -HALF_PI;
      else this.addTorque(new PVector(0, 0, -this.energy));
      break;
    case DOWN:
      this.addTorque(new PVector(this.energy, 0, 0));
      break;
    case RIGHT:
      if(is2D) this.rPos.z = HALF_PI;
      else this.addTorque(new PVector(0, 0, this.energy));
      break;
    }
    this.rPos.x = constrain(this.rPos.x, -HALF_PI/2, 0);
    if(Math.abs(this.rPos.z) > TWO_PI) this.rPos.z = 0; //Reset
  }
}
