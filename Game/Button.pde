final class Button {
  float x,y,w,h;
  
  Button(float x, float y, float w, float h){
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }
  
  void draw() {
   rect(x,y,w,h);
  }
  
  boolean pressed() {
    return (mouseX > x-w && mouseX < x+w && mouseY > y-h && mouseY < y+h);
  }
}
