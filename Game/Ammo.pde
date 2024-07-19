final class Ammo extends Particle {

  Gun gun;
  float x, y, z;
  boolean firing;  //Whether the ammo is being fired
  Move energyRate;
  int blast, amount;

  final static float ENERGY_MAX = 100;  //Default and maximum energy -> strength of the shot
  final static int BLAST_MAX = 3;
  final static int AMMO_MAX = 1;

  public Ammo(Gun gun) {
    super(new PVector(0, 0, 0), 1, 0.95, gun.tank.size/5, ENERGY_MAX/3);
    this.gun = gun;
    this.energyRate = Move.NONE;
    this.blast = BLAST_MAX;
    this.amount = 0;
  }

  void draw() {
    if (this.firing) {
      game.translate(x,y,z);
      game.strokeWeight(0);
      game.fill(0);
      game.sphere(this.size + ((this.energy/ENERGY_MAX) * 3));
    } else if (this.gun.tank.turn) {
      game.translate(this.gun.pos.x, this.gun.pos.y, this.gun.pos.z);
      game.rotateZ(this.gun.rPos.z);
      game.rotateX(this.gun.rPos.x);
      game.stroke(this.gun.tank.colour,100);
      game.strokeWeight(3);
      game.line(0,0,0,0,-energy * 5,0);
    }
  }

  void update() {
    if(this.gun.tank.turn) {
      switch(this.energyRate) {
        case UP:
          energy += 0.1;
          break;
        case DOWN:
          energy -= 0.1;
          break;
        default:
      }
      this.energy = constrain(this.energy, 0, ENERGY_MAX); //Limit the energy between 0 and max energy
      if(this.firing) {
        this.addForce(gravity); //Gravity
        this.addForce(wind);    //Wind
        super.update();
        //Spherical to Cartesian: https://en.wikipedia.org/wiki/Spherical_coordinate_system
        x = ((this.pos.y * sin(HALF_PI + this.gun.rPos.x) * cos(HALF_PI + this.gun.rPos.z)) + this.gun.pos.x + this.pos.x);
        y = ((this.pos.y * sin(HALF_PI + this.gun.rPos.x) * sin(HALF_PI + this.gun.rPos.z)) + this.gun.pos.y);
        z = (this.gun.pos.z + this.pos.z - (this.pos.y * cos(HALF_PI + this.gun.rPos.x)));
      }
    }     
  }
}
