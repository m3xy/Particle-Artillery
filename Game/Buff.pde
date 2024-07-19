final class Buff extends Particle {
  
  PowerUp power;
  color colour;

  Buff(PVector pos) {
    super(pos, 0, 0, TANK_SIZE/2, TANK_SPEED);
    spawn();
  }
  
  void draw(){
   game.translate(this.pos.x, this.pos.y, this.pos.z);
   game.rotateX(this.rPos.x);
   game.rotateY(this.rPos.y);
   game.rotateZ(this.rPos.z);
   game.fill(255);
   game.stroke(this.colour);
   game.strokeWeight(1);
   game.box(size);
   game.sphere(size/2);
   game.line(0,0,0, 0,0,maxH);
  }
  
  void update() {
    this.pos.z = land[(int)this.pos.x/lod][(int)this.pos.y/lod].z + this.size/2;
  }
  
  void spawn() {
    this.pos = findPos();
    PowerUp[] powers = PowerUp.values();
    this.power = powers[(int)random(powers.length)];
    switch(this.power) {
      case FUEL :
        this.colour = color(100, 255, 100);
        break;
      case BLAST :
        this.colour = color(255, 100, 100);
        break;
      case AMMO :
        this.colour = color(100, 100, 255);
    }
  }
}

void genBuffs () {
  for(int i = 0; i < BUFFS; i++)
    buffs[i] = new Buff(findPos());
}
