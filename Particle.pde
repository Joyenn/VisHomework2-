class Particle {
  float posX;
  float posY;
  int lifeTime;
  
  boolean over = false;
  
  // Create the Bubble
  Particle(float tempX, float tempY, int tempLifeTime){
    posX = tempX;
    posY = tempY;
    lifeTime = tempLifeTime;
  }
  
  void decay(){
    lifeTime = lifeTime - 1;
  }
}