import cc.arduino.*; //<>// //<>//
import org.firmata.*;
import processing.video.*;
import processing.serial.*;


Movie video1, video2, video3;
Arduino arduino;

int [] inputs = new int[6];
int [] oldinputs = new int[6];
int [] videoclip = new int[] {0, 0, 0};

float R, G, B = 0;
float scale = 64;
int lastread = 0;
int divider = 10;

PFont font;
PFont font2;

PVector target;
PVector[] points;

float x, y, angle, ease = 0.5;
boolean easing = true;
int num=140, frames=165;
int tsize = 41, // tile size
  margin = 5, // margin size
  tnumber = 9;  // number of points (lager row) 
int[][] link, // connections
  nlink;  // next connections
float idx;  // index used to interpolate between old and new connections
PGraphics pg;


int nFrames = 512;
ArrayList shapes;
Phasor phasor;
Phasor phasorAmp;
Phasor phasorWidth;
Phasor phasorHeight;
Phasor phasorColor;
float offsetX;
float offsetY;

class Phasor {
  float phase = 0.0;
  float inc;

  Phasor(float inc_) {
    inc = inc_;
  }

  Phasor(float inc_, float phase_) {
    inc = inc_;
    phase = phase_;
  }

  void update() {
    phase += inc;

    if (phase >= 1.0) {
      phase -= 1.0;
    }
    if (phase < 0.0) {
      phase += 1.0;
    }
  }
}

class Ring extends Shapes {
  float r;  // Radius

  Ring(float x, float y, float r_) {
    v.x = x;
    v.y = y;
    r = r_;
  }


  void update() {
    ellipse(v.x + offsetX, v.y + offsetY, r, r);
  }
}

class Shapes {
  PVector v;

  Shapes() {
    v = new PVector();
  }

  void update() {
  }
}


PVector getVCoordinates(PVector v, float d, float a) {
  return new PVector(v.x + d * cos(a), v.y + d * sin(a));
}

PVector getVCoordinates(float x, float y, float d, float a) {
  return new PVector(x + d * cos(a), y + d * sin(a));
}
color bgcolor;
int [] arduinoinputs = new int [] {4, 5, 6, 7, 8, 9};

void readinputs()
{
  for (int i=0; i<6; i++)
    inputs[i] = arduino.analogRead(arduinoinputs[i])/100 ;
}
void rememberinputs()
{
  for (int i=0; i<6; i++)
    oldinputs[i] = inputs[i] ;
}

void DisposeMovie(Movie e) 
{ 
e.dispose(); 
unregisterMethod("dispose", e); 
g.removeCache(e); 
}

void changeBG() 
{ 
  if (inputs[0]/divider > oldinputs[0]/divider) 
  { 
    videoclip[0] = (videoclip[0] ^ 1); 
    videoclip[1] = 0; 
    videoclip[2] = 0; 
    if (videoclip[0] == 1) { 
      DisposeMovie(video2); 
      DisposeMovie(video3); 
      video1 = new Movie(this, "video1.mp4"); 
      video1.frameRate(25); 
      video1.loop(); 
      video1.play();
    }
  }
    if (inputs[1]/divider > oldinputs[1]/divider) 
    { 
      videoclip[0] = 0; 
      videoclip[2] = 0; 
      videoclip[1] = (videoclip[1] ^ 1); 
      if (videoclip[1] == 1) { 
        DisposeMovie(video1); 
        DisposeMovie(video3); 
       // g.removeCache(video2);
        video2 = new Movie(this, "video2.mp4"); 
        video2.frameRate(25); 
        video2.loop(); 
        video2.play();
      }
    }
       if (inputs[2]/divider > oldinputs[2]/divider) 
      { 
        videoclip[0] = 0; 
        videoclip[1] = 0; 
        videoclip[2] = (videoclip[2] ^ 1); 
        if (videoclip[2] == 0) { 
          DisposeMovie(video1); 
          DisposeMovie(video2); 

          video3 = new Movie(this, "video3.mp4"); 
          video3.frameRate(25); 
          video3.loop(); 
          video3.play();
        }
      }
      
        int bkchanged = 0; 
        if (inputs[3]/divider > oldinputs[3]/divider) 
        { 
          R = random(scale); 
          bkchanged = 1;
        } 
        if (inputs[4]/divider > oldinputs[4]/divider) 
        { 
          G = random(scale); 
          bkchanged = 1;
        } 
        if (inputs[5]/divider > oldinputs[5]/divider) 
        { 
          B = random(scale); 
          bkchanged = 1;
        } 
        if (bkchanged == 1 ) 
        { 
          bgcolor = color(R, G, B); 
          // background(bgcolor);
        } 

        rememberinputs();
      }
    

void setup() {

  smooth();
  bgcolor = color(random(50), random(50), random(50));
  size(1280, 720);
  // fullScreen();
  // size(displayWidth, displayHeight);
  pg = createGraphics(tsize*tnumber + 2*margin, tsize*tnumber + 2*margin);
  noCursor();
  link = new int[tnumber + 1][tnumber + 1];
  nlink = new int[tnumber + 1][tnumber + 1]; 

  for (int i = 0; i < link.length; i++) {
    for (int j = 0; j < link[0].length; j++) {
      link[i][j] = nlink[i][j] = 1;
    }
  }

  configTile();
  video1 = new Movie(this, "video1.mp4"); 
  video2 = new Movie(this, "video2.mp4"); 
  video3 = new Movie(this, "video3.mp4"); 

  video1.loop();
  video2.loop();
  video3.loop();

  frameRate(200);
  video1.frameRate(60);
  video2.frameRate(60);
  video3.frameRate(60);
  noStroke();

  arduino = new Arduino(this, "COM3", 57600);

  readinputs();
  rememberinputs();  
  changeBG();

  //fullScreen();
  font = createFont("Bariol", 32);
  font2 = createFont("DS-DIGIT.TTF", 32);

  shapes = new ArrayList();
  phasor = new Phasor(1.0 / (float) nFrames);
  phasorAmp = new Phasor(1.0 / (float) nFrames * 1.1);
  phasorWidth = new Phasor(1.0 / (float) nFrames * 1.2, 0.75);
  phasorHeight = new Phasor(1.0 / (float) nFrames * 1.3, 0.75);
  phasorColor = new Phasor(1.0 / (float) nFrames * 4);
  int nShapes = 1024;
  for (int i = 0; i < nShapes; i++) {
    float foo = (sin((float) i / (float) nShapes * TWO_PI * 15) + 1.0) * 0.5 * 0.05 + 0.2;
    PVector v = getVCoordinates(width * 0.5, height * 0.5, foo * width, (float) i / (float) nShapes * TWO_PI * 3);
    shapes.add(new Ring(v.x, v.y, 3));
  }
  points = new PVector[num];
  for (int i=0; i<num; i++) {
    points[i] = new PVector(width/2, height/2);
  }
}

void reflectinputs()
{
  int readsensors = millis();
  if (readsensors - lastread >= 150)
  {
    readinputs();
    changeBG();
    for (int i=0; i<3; i++)
    {
      print(videoclip[i]);
      print("_");
    }  
    print("___");

    print("inputs: ");
    String pref = "";
    for (int i=0; i<6; i++)
    {
      //     char ch = char(i+1+48);
      print(pref);
      print(i + 1);
      print(": ");
      print(inputs[i]);
      pref = ", ";
    }

    println();
    lastread = readsensors;
  }
}  
void update() {
  g.removeCache(video1);
  g.removeCache(video2);
  g.removeCache(video3);
}
void draw() {
  //if(video1.available()){
  //   video1.read(); 
  //}
  //  if(video2.available()){
  //   video2.read(); 
  //}
  //  if(video3.available()){
  //   video3.read(); 
  //}
  int s = second();
  int m = minute(); 
  int h = hour(); 
  String dot = ":";
  String seconds = nf(s, 2);
  String minute = nf(m, 2);
  String hour = nf(h, 2);
  fill(bgcolor);
  rect(-10, -10, width+10, height+10);
  textAlign(CENTER);
  text( hour +dot + minute + dot +seconds, width/2+inputs[0]/5, height/1.72-inputs[1]/3);
  textFont(font2, 300);
  fill(255);

  text( hour +dot + minute + dot +seconds, width/2.1, height/1.8);
  blendMode(ADD);
  tint(255, 200);

  if (idx <= 1)  drawTile();  //draw a new tile each frame while it's not entirely updated 
  //pushMatrix();
  //translate(width/2, height/2);
  //rotate(QUARTER_PI);  
  //imageMode(CENTER);
  ////image(pg, 0, 0,600,600);  
  ////  tint(255,0,0,170);
  ////  image(pg, 0, 0,604,604); 
  ////tint(255,255);
  //  tint(0,255,0,170);
  //  image(pg, 0, 0,596,596); 
  ////tint(255,255);
  //// tint(0,0,255,170);
  ////  image(pg, 0, 0,597,599); 
  ////tint(255,255);
  //popMatrix();


  tint(255, 255);
  blendMode(BLEND);
  tint(255, 100);
  imageMode(CORNER);
  blendMode(LIGHTEST);
  noStroke();
  float d = 150-inputs[0]%100;
  x = width/2+cos(angle)*d;
  y = height/2+sin(angle*2)*d;
  target = new PVector(x, y);
  PVector leader = new PVector(target.x, target.y);
  for (int i=0; i<num; i++) {
    fill(180.0/num*i+inputs[1]/200, 90+inputs[0]%140, 90+inputs[1]%180);
    PVector point = points[i];
    PVector distance = PVector.sub(leader, point);
    PVector velocity = PVector.mult(distance, ease);
    point.add(velocity);
    ellipse(point.x, point.y, 70-inputs[1]%120, 70-inputs[2]/120);
    leader = point;
  }
  angle += TWO_PI/frames;

  blendMode(BLEND);
  if (videoclip[0] ==1 ) 
image(video1, 0, 0, width, height); 
if (videoclip[1] ==1 ) 
image(video2, 0, 0, width, height); 
if (videoclip[2] ==1 ) 
image(video3, 0, 0, width, height);

  if (inputs[0]>20 || inputs[1]>20 || inputs[2]>20 || inputs[3]>20  || inputs[4]>20  || inputs[5]>20) {
    configTile();
  }

  textFont(font, 12);
  fill(255);
  text(frameRate, 100, 100);
  text("andrey belvedersky / byob vol.2", width-100, height-3);
  reflectinputs();
}



void configTile() {

  idx = 0;  // reset index

  // update ancient links
  for (int i = 0; i < link.length; i++) {
    for (int j = 0; j < link[0].length; j++) {
      link[i][j] = nlink[i][j];
    }
  }


  // create new links
  float limit = random(0.4, 0.7);  // choose frequency of conections randomly

  for (int i = 0; i < nlink.length; i++) {
    for (int j = i; j < nlink[0].length/2; j++) {

      int l = 0;      
      if (random(1) > limit)  l = 1;

      nlink[i][j] = l;  // left-top
      nlink[i][nlink[0].length - j - 1] = l;  // left-bottom

      nlink[j][i] = l;  // top-left
      nlink[nlink[0].length - j - 1][i]  = l;  // top-right

      nlink[nlink.length - 1 - i][j] = l;  // right-top
      nlink[nlink.length - 1 - i][nlink[0].length - j - 1] = l;  // right-top

      nlink[j][nlink.length - 1 - i] = l;  // bottom-left
      nlink[nlink[0].length - 1 - j][nlink.length - 1 - i] = l;  // bottom-right
    }
  }
}

void drawTile() {
  pg.beginDraw();

  pg.background(0);
  pg.noFill();
  pg.stroke(255);
  pg.strokeWeight(1+inputs[1]/80);

  for (int i = 0; i < tnumber; i++) {
    for (int j = 0; j < tnumber; j++) {
      if ((i+j)%2 == 0) {

        float top_left = tsize/2 * lerp(link[i][j], nlink[i][j], idx);
        float top_right = tsize/2 * lerp(link[i + 1][j], nlink[i + 1][j], idx);
        float bottom_right = tsize/2 * lerp(link[i + 1][j + 1], nlink[i + 1][j + 1], idx);
        float bottom_left = tsize/2 * lerp(link[i][j + 1], nlink[i][j + 1], idx);

        pg.rect(i*tsize + margin, j*tsize + margin, tsize, tsize, top_left, top_right, bottom_right, bottom_left);          
        pg.point(i*tsize + tsize/2 + margin, j*tsize+tsize/2 + margin);
      }
    }
  }

  pg.endDraw();

  // update index
  idx += 0.8;
  //idx += 0.02;
  idx = constrain(idx, 0, 1);
}

void movieEvent(Movie m) {
  m.read();
}