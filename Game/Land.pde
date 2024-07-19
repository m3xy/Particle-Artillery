final class Land {
  
  float z; //Height of the land
  color colour; //Colour of the land
  
  Land(float z, color colour) {
    this.z = z;
    this.colour = colour;
  } 
}

void setLand() {
  
  //LAND
  float yoff = 0;
  for (int y = 0; y < rows; y++) {
    float xoff = 0;
    for (int x = 0; x < cols; x++) {
      float z = map(noise(xoff, yoff), 0, 1, minH, maxH); //Height determined by Perlin noise values
      land[x][y].z = z;
      land[x][y].colour = color(map(z, minH, maxH, 25, 230));
      xoff+=map(lod, 1, 100, 0.01, 0.15);
    }
    yoff+=map(lod, 1, 100, 0.01, 0.15);
  }
}

void genTrees() {

  //TREES
  for(int i = 0; i < TREES; i++){
    PVector pos = findPos();
    land[(int)pos.x/lod][(int)pos.y/lod].z += random(TANK_SIZE*2, TANK_SIZE*2.5);
  }
}

//boolean destroyable(int col, int row) { //Deprecated: (Now check if land is too high/low)
//  System.out.println("Hit: " + col + " : " + row);
//  //Check neighbouring land
  
//  for (int r = Math.max(0, row-1); r <= Math.min(row+1,rows-1); r++) {
//    for (int c = Math.max(0, col-1); c <= Math.min(col+1,cols-1); c++) {
//      if(Math.sqrt(Math.pow(col-c, 2) + Math.pow(row - r, 2)) <= 1 && land[col][row].z < land[c][r].z-size/4){
//        System.out.println("land: " + c + ":" + r + " is taller");
//        return false;
//      }
//    }
//  }
//  return true;
//}
