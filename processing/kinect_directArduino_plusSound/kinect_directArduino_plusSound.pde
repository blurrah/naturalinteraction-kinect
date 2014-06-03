/* Import scripts
 ================================================== */
import SimpleOpenNI.*;
import processing.serial.*;
import ddf.minim.*;

/* Definitie componenten
 ================================================== */
SimpleOpenNI context;
Serial arduinoPort;
Minim minim;
AudioPlayer player1;
AudioPlayer player2;
AudioPlayer player3;

/* Constante variabelen
 ================================================== */
boolean tickPlayerThread1 = true;
boolean tickPlayerThread2 = true;
boolean tickPlayerThread3 = true;

color[] userClr = new color[] { 
  color(255, 0, 0), 
  color(0, 255, 0), 
  color(0, 0, 255), 
  color(255, 255, 0), 
  color(0, 255, 255)
};
PVector com = new PVector();                                   
PVector com2d = new PVector();  

/* Niet constante variabelen
 ================================================== */
int time;

/* Setup functie
 ================================================== */
void setup() {
  // View configuration
  size(640, 480);
  background(200, 0, 0);
  stroke(0, 0, 255);
  strokeWeight(3);
  smooth();

  time = millis();

  // Arduino configuration
  //arduinoPort = new Serial(this, "/dev/tty.usbmodem1411", 9600);

  // Audio configuration
  minim = new Minim(this);
  player1 = minim.loadFile("box2.mp3");
  player2 = minim.loadFile("box3.mp3");
  player3 = minim.loadFile("box4.mp3");

  // Kinect configuration
  context = new SimpleOpenNI(this);
  if (context.isInit() == false) {
    println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
    exit();
    return;
  }
  context.enableDepth();
  context.enableUser();
}

/* Draw functie
 ================================================== */
void draw() {
  context.update();
  //image(context.depthImage(),0,0);
  image(context.userImage(), 0, 0);

  int[] userList = context.getUsers();
  for (int i=0;i<userList.length;i++) {
    if (context.isTrackingSkeleton(userList[i])) {
      stroke(userClr[ (userList[i] - 1) % userClr.length ] );
      drawSkeleton(userList[i]);
    }      

    if (context.getCoM(userList[i], com)) {
      context.convertRealWorldToProjective(com, com2d);
      stroke(100, 255, 0);
      strokeWeight(1);
      beginShape(LINES);
      vertex(com2d.x, com2d.y - 5);
      vertex(com2d.x, com2d.y + 5);
      vertex(com2d.x - 5, com2d.y);
      vertex(com2d.x + 5, com2d.y);
      endShape();

      fill(255, 255, 255);
      text(Integer.toString(userList[i]), com2d.x, com2d.y);
    }
  }
}

/* Take direction function
 ================================================== */
void takeDirection(int userId) {
  PVector leftHand = new PVector();
  PVector leftElbow = new PVector();
  PVector leftShoulder = new PVector();
  PVector rightHand = new PVector();
  PVector rightElbow = new PVector();
  PVector rightShoulder = new PVector();
  
  context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_HAND,leftHand);
  context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_ELBOW,leftElbow);
  context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_SHOULDER,leftShoulder);
  context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_HAND,rightHand);
  context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_ELBOW,rightElbow);
  context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_SHOULDER,rightShoulder);
  
  /*
     * Serial mapping stuff
     -1  Niks
     0   ServoA HIGH
     1   ServoA LOW
     2   ServoB HIGH
     3   ServoB LOW
     4   rfA    HIGH
     5   rfA    LOW
     6   rfB    HIGH
     7   rfB    LOW
     8   rfC    HIGH
     9   rfC    LOW
   */
  
  // Start defining variables
  int leftHandX = parseInt(leftHand.x);
  int leftHandY = parseInt(leftHand.y);
  int leftElbowY = parseInt(leftElbow.y);
  int leftShoulderX = parseInt(leftShoulder.x);
  
  int rightHandX = parseInt(rightHand.x);
  int rightHandY = parseInt(rightHand.y);
  int rightElbowY = parseInt(rightElbow.y);
  int rightShoulderX = parseInt(rightShoulder.x);
}

/* Draw skeleton functie
 ================================================== */
void drawSkeleton(int userId) {
  // to get the 3d joint data
  /*
    PVector jointPos = new PVector();
    context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_NECK,jointPos);
    println(jointPos);
  */

  context.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);

  context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);

  context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);

  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);

  context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);

  context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);
}

/* Delay timer functie
 ================================================== */
void audioPlay(int player) {
  int wait[];

  switch(player) {
  case 0:
    // misschien een parseInt
    player1.play();
    tickPlayerThread1 = false;
    //wait[0] = player1.length();
    if (millis() - time >= player1.length()) {
      player1.rewind();
      tickPlayerThread1 = true;
    }
    break;
  case 1:
    player2.play();
    tickPlayerThread2 = false;

    if (millis() - time >= player2.length()) {
      player2.rewind();
      tickPlayerThread2 = true;
    }
    break;
  case 2:
    player3.play();
    tickPlayerThread3 = false;

    if (millis() - time >= player3.length()) {
      player3.rewind();
      tickPlayerThread3 = true;
    }
    break;
  };
}

/* SimpleOpenNI events
 ================================================== */
void onNewUser(SimpleOpenNI curContext, int userId) {
  println("onNewUser - userId: " + userId);
  println("\tstart tracking skeleton");
  curContext.startTrackingSkeleton(userId);
}

void onLostUser(SimpleOpenNI curContext, int userId) {
  println("onLostUser - userId: " + userId);
}

void onVisibleUser(SimpleOpenNI curContext, int userId) {
  println("onVisibleUser - userId: " + userId);
}

