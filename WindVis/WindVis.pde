// uwnd stores the 'u' component of the wind.
// The 'u' component is the east-west component of the wind.
// Positive values indicate eastward wind, and negative
// values indicate westward wind.  This is measured
// in meters per second.
Table uwnd;

// vwnd stores the 'v' component of the wind, which measures the
// north-south component of the wind.  Positive values indicate
// northward wind, and negative values indicate southward wind.
Table vwnd;

// An image to use for the background.  The image I provide is a
// modified version of this wikipedia image:
//https://commons.wikimedia.org/wiki/File:Equirectangular_projection_SW.jpg
// If you want to use your own image, you should take an equirectangular
// map and pick out the subset that corresponds to the range from
// 135W to 65W, and from 55N to 25N

PImage img;
int numOfParticles = 2000;
ArrayList <Particle> particles = new ArrayList<Particle>();
int maxLifeTime = 200;
float h = 0.3;


void setup() {
  // If this doesn't work on your computer, you can remove the 'P3D'
  // parameter.  On many computers, having P3D should make it run faster
  size(700, 400);
  pixelDensity(displayDensity());
  
  img = loadImage("background.png");
  uwnd = loadTable("uwnd.csv");
  vwnd = loadTable("vwnd.csv");
  createParticles();
  
}

// create particles
void createParticles(){
  for(int i = 0; i < numOfParticles; i++){
    float tempX = random(0, width);
    float tempY = random(0, height);
    int tempLifeTime = int(random(0, maxLifeTime));
    Particle thisParticle = new Particle(tempX, tempY, tempLifeTime);
    particles.add(thisParticle);
  
  }
}


void draw() {
  background(255);
  image(img, 0, 0, width, height);
  drawMouseLine();
  drawParticles();
  
  
  
}

void drawMouseLine() {
  // Convert from pixel coordinates into coordinates
  // corresponding to the data.
  float a = mouseX * uwnd.getColumnCount() / width;
  float b = mouseY * uwnd.getRowCount() / height;
  
  // Since a positive 'v' value indicates north, we need to
  // negate it so that it works in the same coordinates as Processing
  // does.
  float dx = readInterp(uwnd, a, b) * 10; //<>//
  float dy = -readInterp(vwnd, a, b) * 10; //<>//
  strokeWeight(2);
  line(mouseX, mouseY, mouseX + dx, mouseY + dy);
}


void drawParticles(){
  for(Particle point: particles){
    strokeWeight(4);
    beginShape(POINTS);
    vertex(point.posX, point.posY);
    point.decay();
    endShape();
    updatePos(point);
  }

}



// Reads a bilinearly-interpolated value at the given a and b
// coordinates.  Both a and b should be in data coordinates.
float readInterp(Table tab, float a, float b) {

  // TODO: do bilinear interpolation
  //int x1 = floor(a); //<>//
  //int y1 = floor(b); //<>//
  //int x2 = ceil(a); //<>//
  //int y2 = ceil(b); //<>//
  
  int x1 = int(a-1);
  int x2 = int(a+1);
  int y1 = int(b-1);
  int y2 = int(b+1);
  
  
  float f1 = (x2-a)/(x2-x1)*readRaw(tab, x1, y1) + (a-x1)/(x2-x1)*readRaw(tab, x2, y1); //<>//
  float f2 = (x2-a)/(x2-x1)*readRaw(tab, x1, y2) + (a-x1)/(x2-x1)*readRaw(tab, x2, y2); //<>//
  
  float value = (y2-b)/(y2-y1)*f1+(b-y1)/(y2-y1)*f2; //<>//
  
  
  return value;
}

// Reads a raw value 
float readRaw(Table tab, int x, int y) {
  if (x < 0) {
    x = 0;
  }
  if (x >= tab.getColumnCount()) {
    x = tab.getColumnCount() - 1;
  }
  if (y < 0) {
    y = 0;
  }
  if (y >= tab.getRowCount()) {
    y = tab.getRowCount() - 1;
  }
  return tab.getFloat(y,x);
}


float[]  euler(float curX, float curY){
  float[] newPos = new float[2];
  float dx = readInterp(uwnd, curX, curY) * h;
  float dy = -readInterp(vwnd, curX, curY) * h;
  float newY = curY + dy;
  float newX = curX + dx;
  newPos[0] = newX;
  newPos[1] = newY;
  return newPos;
}

float[] RK4(float curX, float curY){
  float[] newPos = new float[2];
  float dx1 = readInterp(uwnd, curX, curY)*h;
  float dy1 = -readInterp(vwnd, curX, curY)*h;
  
  //float k1X = curX + dx1;
  //float k1Y = curY + dy1;
  
  float k1X = dx1;
  float k1Y = dy1;
  
  float mid1X = curX+h*k1X/2;
  float mid1Y = curY+h*k1Y/2;
  
  float k2X = readInterp(uwnd, mid1X, mid1Y);
  float k2Y = readInterp(vwnd, mid1X, mid1Y);
  
  float mid2X = mid1X + h*k2X/2;
  float mid2Y = mid1Y + h*k2Y/2;
  
  float k3X = readInterp(uwnd, mid2X, mid2Y);
  float k3Y = readInterp(vwnd, mid2X, mid2Y);
  
  float mid3X = mid2X + h*k3X;
  float mid3Y = mid2Y + h*k3Y;
  
  float k4X = readInterp(uwnd, mid3X, mid3Y);
  float k4Y = readInterp(vwnd, mid3X, mid3Y);
  
  float newX = curX + h/6*(k1X+k2X+k3X+k4X);
  float newY = curY + h/6*(k1Y+k2Y+k3Y+k4Y);
  
  newPos[0] = newX;
  newPos[1] = newY;
  
  return newPos;
}

void updatePos(Particle thisPoint){
  if(thisPoint.lifeTime > 0){
    float curX = thisPoint.posX;
    float curY = thisPoint.posY;
    float[] newPos = RK4(curX, curY);
    float newX = newPos[0];
    float newY = newPos[1];
    thisPoint.posX = newX;
    thisPoint.posY = newY;
  }else{
    thisPoint.lifeTime = maxLifeTime;
    thisPoint.posX = random(width);
    thisPoint.posY = random(height);
  }
}