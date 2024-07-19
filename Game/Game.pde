boolean is2D = false;

//TANK
float TANK_SPEED = 1; //Speed of tanks
float TANK_SIZE = 10; //Size of tanks
ArrayList<Tank> tanks = new ArrayList<Tank>();
int PLAYERS = 2, AI = 1, player, winner; //Number of tanks, how many of which are AI, the current player and winner
int col, row; //Used as a temporary variable to store a position, declared here for efficiency

//DISPLAY
PGraphics hud, game; //Holds 2d hud and 3d game displays
int lod = 10; //Level of detail, (positive) Factor to divide the land into columns and rows (Recommended 10 but can go above/below slightly for more or less detail - values: 1 to 100)
int w = 1920; //Width of game world (Not window)
int h = 1080; //Height of game world (Not window)
int cols = w/lod, rows = h/lod; //Number of columns and rows in the land mesh
int smooth = 2; //0,2,3,4,8x anti-aliasing : lower = better fps

//LAND
Land[][] land = new Land[cols][rows]; //Land, terrain of the game world
float minH = 0, maxH = 250;   //Min and max terrain height
int TREES = 8; //Trees

//FORCES
float maxGravity = 0.5, maxWind = 0.1;
PVector gravity = new PVector(0,0,-maxGravity), wind = new PVector(random(-maxWind, maxWind),0,0);        //Gravity and wind vectors affecting ammo

//VIEW
boolean altView; //alternative view
float orbitRadius; //Zoom on zoom-able (camera) views/perspectives
View view; //Current view/perspective

//AI
PVector direction = new PVector(0,0,0);
float x, y, elevation, strength;
boolean thinking = true;
float error = 0; //Difficulty of AI
int DIFFICULTY = 3;

//Buffs
int BUFFS = 3;
Buff[] buffs;

//Gameplay
State state = State.GAME_START;
boolean showDetails = true; //Whether to show details on HUD
boolean restart = true;
boolean reset = true;
int WIN_SCORE = 3;

Button addPlayer;
Button removePlayer;
Button addAI;
Button removeAI;
Button addDifficulty;
Button removeDifficulty;
Button addBuffs;
Button removeBuffs;
Button addTrees;
Button removeTrees;
Button addScore;
Button removeScore;
Button toggle2D;
Button startGame;

void setup() {
  
  //Buttons
  addPlayer = new Button(width/2 + width/10, height/2.35, 15, 15);
  removePlayer = new Button(width/2 - width/10, height/2.35, 15, 15);
  addAI = new Button(width/2 + width/10, height/2, 15, 15);
  removeAI = new Button(width/2 - width/10, height/2, 15, 15);
  addDifficulty = new Button(width/2 + width/10, height/1.75, 15, 15);
  removeDifficulty = new Button(width/2 - width/10, height/1.75, 15, 15);
  addBuffs = new Button(width/2 + width/10, height/1.55, 15, 15);
  removeBuffs = new Button(width/2 - width/10, height/1.55, 15, 15);
  addTrees = new Button(width/2 + width/10, height/1.38, 15, 15);
  removeTrees = new Button(width/2 - width/10, height/1.38, 15, 15);
  addScore = new Button(width/2 + width/10, height/1.25, 15, 15);
  removeScore = new Button(width/2 - width/10, height/1.25, 15, 15);
  toggle2D = new Button(width/2, height/1.18, 20, 15);
  startGame = new Button(width/2, height/1.1, 90, 30);
  
  //DISPLAY
  //size(1280, 720, P2D);
  fullScreen(P2D, SPAN);
  hud = createGraphics(width, height, JAVA2D);
  game = createGraphics(width, height, P3D);
  
  if(smooth != 2 && smooth != 3 && smooth != 4 && smooth != 8) {
    hud.noSmooth();
    game.noSmooth();
  } else {
    hud.smooth(smooth);
    game.smooth(smooth);
  }
}

void drawMenu(){
  background(255);
}

void restart() {
  tanks.clear();
  //LAND
  for (int y = 0; y < rows; y++)
    for (int x = 0; x < cols; x++)
      land[x][y] = new Land(0, color(0));
  
  //TANKS
  for(int i = 0; i < PLAYERS; i++)
    tanks.add(new Tank(new PVector(0,0,0), color(random(255), random(255), random(255)), 1, TANK_SIZE, TANK_SPEED));

  //- AI
  for(int i = 0; i < AI; i++)
    tanks.get(i).ai = true;
  if (DIFFICULTY == 1) error = 50;
  else if (DIFFICULTY == 2) error = 25;
  else error = 0;
    
  //BUFFS
  buffs = new Buff[BUFFS];
  
  //- Starting player
  player = (int)random(tanks.size()); //Random player starts
  tanks.get(player).turn = true;
  tanks.get(player).gun.ammo.amount = 1; //Give one ammo to start
  winner = -1;
  
  setLand();
  setTanks();
  genTrees();
  genBuffs();
  resetView();
}

//Renders and runs the game
void draw() {
  background(255);
  textAlign(CENTER, CENTER);
  rectMode(RADIUS);

  switch(state) {
    case GAME_START : //Title screen
      fill(0, 0);
      startGame.draw();
      addPlayer.draw();
      removePlayer.draw();
      addAI.draw();
      removeAI.draw();
      addDifficulty.draw();
      removeDifficulty.draw();
      addBuffs.draw();
      removeBuffs.draw();
      addTrees.draw();
      removeTrees.draw();
      addScore.draw();
      removeScore.draw();
      toggle2D.draw();

      fill(0);
      textSize(100);
      text("Particle Artillery (3D)", width/2, height/4);
      
      textSize(25);
      text("+", addPlayer.x, addPlayer.y);
      text("Players: " + PLAYERS, (addPlayer.x+removePlayer.x)/2, (addPlayer.y+removePlayer.y)/2);
      text("-", removePlayer.x, removePlayer.y);
      text("+", addAI.x, addAI.y);
      text("AI: " + AI, (addAI.x+removeAI.x)/2, (addAI.y+removeAI.y)/2);
      text("-", removeAI.x, removeAI.y);
      text("+", addDifficulty.x, addDifficulty.y);
      text("Difficulty: " + DIFFICULTY, (addDifficulty.x+removeDifficulty.x)/2, (addDifficulty.y+removeDifficulty.y)/2);
      text("-", removeDifficulty.x, removeDifficulty.y);
      text("+", addBuffs.x, addBuffs.y);
      text("Buffs: " + BUFFS, (addBuffs.x+removeBuffs.x)/2, (addBuffs.y+removeBuffs.y)/2);
      text("-", removeBuffs.x, removeBuffs.y);
      text("+", addTrees.x, addTrees.y);
      text("Trees: " + TREES, (addTrees.x+removeTrees.x)/2, (addTrees.y+removeTrees.y)/2);
      text("-", removeTrees.x, removeTrees.y);
      text("+", addScore.x, addScore.y);
      text("Win score: " + WIN_SCORE, (addScore.x+removeScore.x)/2, (addScore.y+removeScore.y)/2);
      text("-", removeScore.x, removeScore.y);
      text(is2D ? "2D" : "3D", toggle2D.x, toggle2D.y);
      textSize(35);
      text("PLAY", startGame.x, startGame.y);
      
      break;
    case GAME_PLAY : //Game screen
      drawGame();
      drawHUD();
      image(game, 0, 0);
      image(hud, 0, 0);
      break;
      
    case GAME_OVER : //End screen
      textSize(100);
      for(int i = 0; i < tanks.size(); i++){
        if(tanks.get(i).score >= WIN_SCORE)
          winner = i;
        tanks.get(i).turn = false;
      }

      text("Player " + (winner+1) + " wins", width/2, height/2);
      textSize(35);
      text("Click to restart!", startGame.x, startGame.y);
      
      showDetails = false;
      drawHUD();
      image(hud, 0, 0);
      break;
  }
}

//Renders the 3d game
void drawGame() {
  game.beginDraw();
  //Background
  game.background(255); //White
  game.lights();
  game.noFill();
  
  //Land
  game.pushMatrix(); //Save position
  for (int y = 0; y < rows-1; y++) {
    game.beginShape(TRIANGLE_STRIP);
    game.noStroke();
    for (int x = 0; x < cols; x++) {
      game.fill(land[x][y].colour); //land colour
      game.vertex(x*lod, y*lod, land[x][y].z);
      game.fill(land[x][y+1].colour); //land colour
      game.vertex(x*lod, (y+1)*lod, land[x][y+1].z);
    }
    game.endShape();
  }
  game.popMatrix(); //Restore saved position

  //Tanks
  for(Tank tank : tanks)
    tank.run();
    
  //Buffs
  for(Buff buff : buffs)
    buff.run();
    
  //Collisions
  //- Constrain tank within land
    tanks.get(player).pos.x = constrain(tanks.get(player).pos.x, 0 + tanks.get(player).size/2, w - lod - tanks.get(player).size/2); //X Y and Z (arrays indexed from 0 -> -lod)
    tanks.get(player).pos.y = constrain(tanks.get(player).pos.y, 0 + tanks.get(player).size/2, h - lod - tanks.get(player).size/2); //-size/2 in order to keep model within the bounds of the land
    tanks.get(player).pos.z = land[(int)tanks.get(player).pos.x/lod][(int)tanks.get(player).pos.y/lod].z + tanks.get(player).size/2;
    
  //- Disallow tank climbing too high/falling too low
    col = (int)tanks.get(player).pos.x/lod;
    row = (int)tanks.get(player).pos.y/lod;
    switch(tanks.get(player).moving) {
      case NONE :
        break;
      case UP :
        row = (int)Math.max(0, (tanks.get(player).pos.y/lod) - 1);
        break;
      case DOWN :
        row = (int)Math.min((tanks.get(player).pos.y/lod) + 1, rows-1);
        break;
      case LEFT :
        col = (int)Math.max(0, (tanks.get(player).pos.x/lod) - 1);
        break;
      case RIGHT :
        col = (int)Math.min((tanks.get(player).pos.x/lod) + 1, cols - 1);
        break;
    }
    if(Math.abs(land[col][row].z - (tanks.get(player).pos.z - tanks.get(player).size/2)) >= tanks.get(player).size*2/3) //Stops tank from climbing/falling: 2/3 size of tank = height of tracks
      tanks.get(player).acc.mult(0);
      
  //- Disallow tanks colliding with eachother
  for(Tank tank : tanks)
    if(!tanks.get(player).equals(tank) && dist(col*lod, row*lod, land[col][row].z + tanks.get(player).size/2, tank.pos.x, tank.pos.y, tank.pos.z) <= tank.size/2 + tanks.get(player).size/2)
      tanks.get(player).acc.mult(0);
  
  //Buff/Tank collision
  for(Buff buff : buffs) {
    if(dist(buff.pos.x, buff.pos.y, tanks.get(player).pos.x, tanks.get(player).pos.y) < buff.size/2 + tanks.get(player).size/2) {
      switch(buff.power) {
        case FUEL :
          tanks.get(player).fuel = Tank.FUEL_MAX;
          break;
        case BLAST :
          tanks.get(player).gun.ammo.blast += random(Ammo.BLAST_MAX, Ammo.BLAST_MAX *2);
          break;
        case AMMO :
          tanks.get(player).gun.ammo.amount += random(1, Ammo.AMMO_MAX);
          break;
      }
      buff.spawn(); //Spawn new buff in new location
    }
  }

  //- Ammo within boundaries
  if(tanks.get(player).turn && tanks.get(player).gun.ammo.firing) {
    col = Math.round(tanks.get(player).gun.ammo.x/lod);
    row = Math.round(tanks.get(player).gun.ammo.y/lod);
    
    //Checking collision with land
    if(col >= 0 && col < cols && row >= 0 && row < rows) { //Within land
      if(tanks.get(player).gun.ammo.z <= land[col][row].z) { //Collision with land
        for (int r = Math.max(0, row-tanks.get(player).gun.ammo.blast); r <= Math.min(row+tanks.get(player).gun.ammo.blast,rows-1); r++) { //Blast radius
          for (int c = Math.max(0, col-tanks.get(player).gun.ammo.blast); c <= Math.min(col+tanks.get(player).gun.ammo.blast,cols-1); c++) {
            if(Math.pow(c-col, 2) + Math.pow(r-row, 2) <= tanks.get(player).gun.ammo.blast*tanks.get(player).gun.ammo.blast && land[c][r].z > minH) { //Destroy (blast) radius around land hit
              land[c][r].z -= tanks.get(player).size/2;
              land[c][r].colour = color(lerpColor(land[col][row].colour, tanks.get(player).colour, 0.01));
            }
          }
        }
        for(Tank tank : tanks){ //Check if tank hit by radius blast (simplification: assume tanks on ground, no need to check Z coord)
          if(Math.pow(((tank.pos.x/lod)-col), 2) + Math.pow(((tank.pos.y/lod)-row), 2) <= tanks.get(player).gun.ammo.blast*tanks.get(player).gun.ammo.blast) {
            hit(tanks.get(player), tank, 1);
          }
        }
        land[col][row].colour = color(lerpColor(land[col][row].colour, tanks.get(player).colour, 0.01)); //Damage the land hit directly further
        land[col][row].z -= tanks.get(player).size/2;
        endTurn();
      } else {
        for(Tank tank : tanks){ //Check if tank hit by bullet directly
          if(dist(tanks.get(player).gun.ammo.x, tanks.get(player).gun.ammo.y, tanks.get(player).gun.ammo.z, tank.pos.x, tank.pos.y, tank.pos.z) <= tank.size/2 + tanks.get(player).gun.ammo.size/2) {
            hit(tanks.get(player), tank, 2);
            endTurn();
          }
        }
      }
    } else if(tanks.get(player).gun.ammo.z <= minH) //Under land (outside of land space)
      endTurn();
  }
      
  //View
  switch(view){
    case TOP_DOWN :
      orbitRadius = constrain(orbitRadius, -tanks.get(player).size * 50, tanks.get(player).size * 100);
      game.camera(width/2.0, height + orbitRadius, height - orbitRadius, width/2.0, height/2.0, 0, 0, 0, -1);
      //game.camera(width/2.0, height/2.0, (height/2.0) / tan(PI*30.0 / 180.0) + orbitRadius, width/2.0, height/2.0, 0, 0, 1, 0);
      if(altView) game.camera(tanks.get(player).pos.x, tanks.get(player).pos.y, (height/2.0) / tan(PI*30.0 / 180.0) + orbitRadius, tanks.get(player).pos.x, tanks.get(player).pos.y, tanks.get(player).pos.z, 0, 1, 0);
      break;
      
    case THIRD_PERSON :
      orbitRadius = constrain(orbitRadius, tanks.get(player).size * 10, tanks.get(player).size * 50);
      game.camera(tanks.get(player).pos.x, orbitRadius + tanks.get(player).pos.y, map(-tanks.get(player).gun.rPos.x, 0, HALF_PI/2, tanks.get(player).pos.z + 50, maxH + 50), tanks.get(player).pos.x, tanks.get(player).pos.y, tanks.get(player).pos.z, 0, 0, -1);
      if(altView) game.camera(cos(tanks.get(player).gun.rPos.z + HALF_PI) * orbitRadius + tanks.get(player).pos.x, sin(tanks.get(player).gun.rPos.z + HALF_PI) * orbitRadius + tanks.get(player).pos.y, map(tanks.get(player).gun.rPos.x, -HALF_PI/2, 0, tanks.get(player).pos.z + 50, maxH + 50), tanks.get(player).pos.x, tanks.get(player).pos.y, tanks.get(player).pos.z, 0, 0, -1);
      //System.out.println(orbitRadius);
      break;
  }
  
  //AI
  if(tanks.get(player).ai && tanks.get(player).turn && !tanks.get(player).gun.ammo.firing) {
    if(thinking) {  //1. Thinking
    
      //Moving
      x=0; y=0;
      for(Tank tank : tanks) { //Calculate where to move (towards players)
        if(!tank.equals(tanks.get(player))) {
          y+= tanks.get(player).pos.y-(tank.pos.y + random(error)); //Could round with  however too strong/suicidal, could offset but dont want preference?
          x+= tanks.get(player).pos.x-(tank.pos.x + random(error)); 
          if(x > 0) x -= tanks.get(player).gun.ammo.blast;
          else x += tanks.get(player).gun.ammo.blast;
        }
      }
      
      //Aiming: z axis
      int target = 0;
      while(target == player) target++;
      direction.set(new PVector(tanks.get(player).pos.x, tanks.get(player).pos.y).sub(new PVector(tanks.get(target).pos.x, tanks.get(target).pos.y)));
     
      //Aiming: x axis
      elevation = map(direction.mag(), 0, max(w, h), 0, HALF_PI/2);
      //Aiming: y axis
      strength = map(direction.mag(), 0, max(w, h), tanks.get(player).gun.ammo.blast, Ammo.ENERGY_MAX);
      
      thinking = false;
      
    } else if(tanks.get(player).fuel > 0) {  //2. Moving
      if(y > 0) {
        tanks.get(player).moving = Move.UP;
      } else if(y < 0) {
        tanks.get(player).moving = Move.DOWN;
      } else if(x > 0) {
        tanks.get(player).moving = Move.LEFT;
      } else if (x < 0) {
        tanks.get(player).moving = Move.RIGHT;
      } else {
        tanks.get(player).fuel = 0; //Don't move - shoot
      }
      thinking = true;
      
    } else if(Math.abs(tanks.get(player).gun.rPos.z - (direction.heading() - HALF_PI)) > map(random(error), 0, 360, 0, TWO_PI)) { //3. Aiming: Z axis
      //if(tanks.get(player).gun.rPos.z > direction.heading() - HALF_PI) {
      //  tanks.get(player).gun.aiming = Move.LEFT;
      //} else {
      //  tanks.get(player).gun.aiming = Move.RIGHT;
      //}
      //thinking = true;
      tanks.get(player).gun.rPos.z = direction.heading() - HALF_PI;
      
    } else if(elevation + tanks.get(player).gun.rPos.x > map(random(error), 0, 45, 0, HALF_PI/2)) { //4. Aiming: X axis
      //if(tanks.get(player).gun.rPos.x < elevation)
      //  tanks.get(player).gun.aiming = Move.UP;
      //else
      //  tanks.get(player).gun.aiming = Move.DOWN;
      //thinking = true;
      tanks.get(player).gun.rPos.x = -elevation;
      
    } else if (Math.abs(tanks.get(player).gun.ammo.energy - strength) > random(error)) { //5. Aiming: Y axis
      //if(tanks.get(player).gun.ammo.energy < strength)
      //  tanks.get(player).gun.ammo.energyRate = Move.UP;
      //else
      //  tanks.get(player).gun.ammo.energyRate = Move.DOWN;
      //thinking = true;
      tanks.get(player).gun.ammo.energy = strength;
      
    } else {  //6. Firing
      fire(); 
      thinking = true;
    }
  }
    
  game.endDraw();
}

//Renders the 2d hud
void drawHUD() {
 hud.beginDraw();
 hud.background(0, 0); //Transparency 
 hud.stroke(0); //Outlines around shapes black
 write((int)frameRate + " fps", 0, 0, LEFT, TOP, 15, color(0), color(0));
 
 //Top
 for(int i = 0; i < tanks.size(); i++) {
   drawStats(i);
 }
 
 //Bottom
 if(showDetails)
   drawDetails();

 hud.endDraw();
}

//Writes text on HUD
void write(String text, float x, float y, int alignX, int alignY, float size, color colour, color bg)  {
  hud.fill(colour);
  hud.textSize(size);
  hud.textAlign(alignX, alignY);
  hud.text(text, x, y);
  hud.fill(bg, 100); //Default
}

//Draws a player's stats
void drawStats(int i) {
  hud.pushMatrix();
  hud.translate(width/tanks.size() * i, 0);
  if(tanks.get(i).turn)
    write("(Playing)", width/tanks.size()/2, height/13, CENTER, CENTER, 12, color(0), color(128));
  if(i == winner)
    write("(winner)", width/tanks.size()/2, height/13, CENTER, CENTER, 12, color(0), color(128));
  hud.rect(0, 0, width/tanks.size(), height/5, 0, 0, 28, 28);
  write("Player " + (i+1) + (tanks.get(i).ai ? " (AI)" : ""), width/tanks.size()/2, 25, CENTER, CENTER, 12, color(255), color(0));
  hud.fill(tanks.get(i).colour);
  hud.rect(width/tanks.size()/2 + (tanks.get(i).size*0.8) - (tanks.get(i).size*1.5), ((height/5)/4) + (tanks.get(i).size/4), tanks.get(i).size * 1.5, tanks.get(i).size/4);
  hud.rect(width/tanks.size()/2 - (tanks.get(i).size*1.5), (height/5)/4, tanks.get(i).size, tanks.get(i).size);
  for(int c = 0 ; c < tanks.get(i).gun.ammo.amount; c++) //Draw ammo
    hud.circle((c*(float)Math.pow(tanks.get(i).gun.ammo.blast, 2)) + width/tanks.size()/2, (height/5), (float)Math.pow(tanks.get(i).gun.ammo.blast, 2)); //Squared to see difference more clearly
  write("Score: " + tanks.get(i).score
  + (tanks.get(i).gun.ammo.amount > Ammo.AMMO_MAX ? "\n+ Ammo" : "")
  + (tanks.get(i).gun.ammo.blast > Ammo.BLAST_MAX ? "\n+ Blast" : ""),
  width/tanks.size()/2, (height/5)/1.5, CENTER, CENTER, 12, color(255), color(0));
  hud.popMatrix();
}

void drawDetails() {
 //Bottom
 hud.rect(0, height, width, -height/4);
 
 //-Top left
 hud.pushMatrix();
 hud.translate(0, height*3/4);
 hud.rect(0,0, map(tanks.get(player).fuel, 0, Tank.FUEL_MAX, 0, width), 25);
 write("Fuel: " + (int)map(tanks.get(player).fuel, 0, Tank.FUEL_MAX, 0, 100) + "% \nMovement\nw | a | s | d", 0, 0, LEFT, TOP, 15, color(255), color(0));
 hud.popMatrix();
 
 //-Centre Left
 hud.pushMatrix();
 hud.translate((width/3)/2, height);
 write("Elevation: " + Math.round(degrees(-tanks.get(player).gun.rPos.x)) + "°\n↑ | ↓", 0, -50, CENTER, CENTER, 15, color(255), color(0));
 hud.translate(-75, -75);
 hud.line(0, 0, 75*2, 0);
 hud.rotate(tanks.get(player).gun.rPos.x);
 hud.arc(0, 0, 100, 100, 0, -tanks.get(player).gun.rPos.x, PIE);
 hud.line(0, 0, 75*2, 0);
 hud.popMatrix();
 
 //-Centre
 hud.pushMatrix();
 hud.translate(width/2, height);
//Instructions
 write("Aim: score " + WIN_SCORE + " to win. | Note: 1 point for indirect hit, 2 points for direct hit. | Warning: Hitting self subtracts score", 0, -height/5, CENTER, CENTER, 12, color(255), color(0));
 
 //Controls
 write("TAB : Hide \n1 | 2 | Scroll : View/Zoom \nSpace : Fire!", 0, -height/5.8, CENTER, TOP, 12, color(255), color(0));
 write("Strength: " + (int)map(tanks.get(player).gun.ammo.energy, 0, Ammo.ENERGY_MAX, 0 , 100) + "%\nLMB | RMB", 0, -50, CENTER, CENTER, 15, color(255), color(0));
 //hud.rect(-((width/3)/2), -100, map(energy, 0, maxEnergy, 0 , ((width/3)/2)*2), 25);
 hud.rect(-map(tanks.get(player).gun.ammo.energy, 0, Ammo.ENERGY_MAX, 0 , ((width/3)/2)), -100, map(tanks.get(player).gun.ammo.energy, 0, Ammo.ENERGY_MAX, 0 ,((width/3)/2)*2), 25);
 hud.popMatrix();
 
 //-Centre Right
 hud.pushMatrix();
 hud.translate((2*width/3) + ((width/3)/2), height - 125);
 hud.fill(255);
 hud.textAlign(CENTER, CENTER);
 hud.text("N", 0, -45);
 hud.text("E", 45, 0);
 hud.text("S", 0, 40);
 hud.text("W", -45, 0);
 write("Direction: " + Math.round(degrees(tanks.get(player).gun.rPos.z) < 0 ? 360 + degrees(tanks.get(player).gun.rPos.z) : degrees(tanks.get(player).gun.rPos.z)) + "°\n← | →", 0, 75, CENTER, CENTER, 15, color(255), color(0));
 
 //--Wind direction
 if(Math.abs(wind.x) > 0)
   write("(" + Math.round(map(Math.abs(wind.x), 0, maxWind, 0, 100)) + "% wind)", wind.x > 0 ? 50 : -50, 15, CENTER, CENTER, 12, color(255), color(0));
 
 //--Aim direction
 hud.rotate(tanks.get(player).gun.rPos.z);
 hud.fill(0, 100);
 hud.circle(0, 0, 25 * 2 - 1);
 hud.line(0, -25, 0, 0);
 hud.popMatrix();
}

//Detects key presses
void keyPressed() {
  if(state != State.GAME_PLAY || tanks.get(player).ai) return;
  if (key == CODED) {  
    switch (keyCode) {  //Aim
    case UP :
      tanks.get(player).gun.aiming = Move.UP;
      break;
    case LEFT :
      tanks.get(player).gun.aiming = Move.LEFT;
      break;
    case DOWN :
      tanks.get(player).gun.aiming = Move.DOWN;
      break;
    case RIGHT :
      tanks.get(player).gun.aiming = Move.RIGHT;
      break;
    }
  } else {
    switch (key) {  //Movement
    case 'w' :
        tanks.get(player).moving = Move.UP;
      break;
    case 'a' :
        tanks.get(player).moving = Move.LEFT;
      break;
    case 's' :
        tanks.get(player).moving = Move.DOWN;
      break;
    case 'd' :
        tanks.get(player).moving = Move.RIGHT;
      break;
    case ' ' :      //Firing
      if(!tanks.get(player).gun.ammo.firing)
        fire();
      break;
    case '1' :     //Views   
      view = View.TOP_DOWN;
      altView = !altView;
      break;
    case '2' :
      view = View.THIRD_PERSON;
      altView = !altView;
      break;
    case TAB :   //HUD
      showDetails = !showDetails;
    }
  }
}

//Detects key releases
void keyReleased() {
  if(state != State.GAME_PLAY || tanks.get(player).ai) return;
  if (key == CODED) {  //Aiming
    tanks.get(player).gun.aiming = Move.NONE;
  } else if (key == 'w' || key == 'a' || key == 's' || key == 'd'){ //Movement
    tanks.get(player).moving = Move.NONE;
  }
}

//Detects scrolling mouse wheel
void mouseWheel(MouseEvent event) {
  orbitRadius += 20 * event.getCount(); //Used in views to zoom
}

//Detects LMB/RMB presses
void mousePressed() {
  switch(state) {
    case GAME_START :
      if(startGame.pressed()) {
        state = State.GAME_PLAY;
        restart();
      }
      if(addPlayer.pressed())
        PLAYERS = constrain(++PLAYERS, 2, 9);
      if(removePlayer.pressed())
        PLAYERS = constrain(--PLAYERS, 2, 9);
      if(addAI.pressed())
        AI = constrain(++AI, 0, PLAYERS);
      if(removeAI.pressed())
        AI = constrain(--AI, 0, PLAYERS);
      if(addDifficulty.pressed())
        DIFFICULTY = constrain(++DIFFICULTY, 1, 3);
      if(removeDifficulty.pressed())
        DIFFICULTY = constrain(--DIFFICULTY, 1, 3);
      if(addBuffs.pressed())
        BUFFS = constrain(++BUFFS, 0, 10);
      if(removeBuffs.pressed())
        BUFFS = constrain(--BUFFS, 0, 10);
      if(addTrees.pressed())
        TREES = constrain(TREES*2, 1, 128);
      if(removeTrees.pressed())
        TREES = (int)constrain(TREES*0.5, 1, 128);
      if(addScore.pressed())
        WIN_SCORE = constrain(++WIN_SCORE, 1, 9);
      if(removeScore.pressed())
        WIN_SCORE = constrain(--WIN_SCORE, 1, 9);
      if(toggle2D.pressed())
        is2D = !is2D;
      break;
    case GAME_PLAY :
      if(tanks.get(player).ai) return;
      switch(mouseButton) {  //Decreases/increases strength of shot
         case LEFT :
           tanks.get(player).gun.ammo.energyRate = Move.DOWN;
         break;
         case RIGHT :
           tanks.get(player).gun.ammo.energyRate = Move.UP;
         break;
      }
      break;
    case GAME_OVER :  
      state = State.GAME_START;
      break;
  }
}

//Detects LMB/RMB releases
void mouseReleased() {
  if(state != State.GAME_PLAY || tanks.get(player).ai) return;
  tanks.get(player).gun.ammo.energyRate = Move.NONE; //Keeps strength of shot constant
}

//Resets (camera) view
void resetView() {
  showDetails = true;
  orbitRadius = TANK_SIZE * 25;
  view = View.TOP_DOWN;
  altView = false;
}

//Fires a shot (current player)
void fire() {
  resetView();
  tanks.get(player).gun.ammo.firing = true;
  tanks.get(player).gun.ammo.addForce(new PVector(0, -tanks.get(player).gun.ammo.energy, 0));
}

//Ends turn (current player)
void endTurn() {
  //Ammo
  tanks.get(player).gun.ammo.firing = false;  //Hide bullet
  tanks.get(player).gun.ammo.vel.mult(0);     //Reset bullet (to shoot next turn)
  tanks.get(player).gun.ammo.pos.mult(0);
  
  //Gun (More efficient than within objects) 
  tanks.get(player).gun.aiming = Move.NONE; //Disable aiming
  
  //Tank
  tanks.get(player).turn = false;       //Hide shooting indicator
  tanks.get(player).moving = Move.NONE; //Disable movement
  
  //Switch turn if no ammo
  if(--tanks.get(player).gun.ammo.amount == 0) {
    player = player == PLAYERS - 1 ? 0 : player + 1;
    tanks.get(player).fuel = Tank.FUEL_MAX;            //Refuel
    tanks.get(player).gun.ammo.amount = 1;             //Give 1 ammo
    tanks.get(player).gun.ammo.blast = Ammo.BLAST_MAX; //Reset ammo type (with Ammo.BLAST_MAX blast radius)
  }

  tanks.get(player).turn = true;  //Start turn
  wind = new PVector(random(-maxWind, maxWind), 0, 0);
}

//Finds a free PVector position (not on any tanks)
PVector findPos() {
  boolean free;
  do{
    free = true;
    col = (int)random(cols);
    row = (is2D ? rows/2 : (int)random(rows));
    for(Tank tank : tanks)
      if(col == (int)(tank.pos.x/lod) && row == (int)(tank.pos.y/lod))
        free = false;
  }while(!free);
  return new PVector(col*lod, row*lod, land[col][row].z);
}

//Register tank hit
void hit(Tank t1, Tank t2, int points) {
  t1.score = t2.equals(t1) ? t1.score - points : t1.score + points;
  if(t1.score >= WIN_SCORE) {
    state = State.GAME_OVER; //restart();
  } else {
    PVector spawn = findPos();
    t2.pos.set(spawn.x, spawn.y, spawn.z + t2.size/2); 
  }
}
