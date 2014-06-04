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
AudioPlayer player4;
AudioPlayer player5;

/* Variabelen
 ================================================== */
boolean tickPlayerThread1 = true;
boolean tickPlayerThread2 = true;
boolean tickPlayerThread3 = true;
boolean tickPlayerThread4 = true;
boolean tickPlayerThread5 = true;

color[] userClr = new color[] { 
  color(255, 0, 0), 
  color(0, 255, 0), 
  color(0, 0, 255), 
  color(255, 255, 0), 
  color(0, 255, 255)
};
PVector com = new PVector();                                   
PVector com2d = new PVector();  

int time;
int[] zValue = new int[6];
int activeUser = 0;

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
  arduinoPort = new Serial(this, "/dev/tty.usbmodem1411", 9600);

  // Audio configuration
  minim = new Minim(this);
  player1 = minim.loadFile("doos.wav"); // Case 0 Doos
  player2 = minim.loadFile("prullenbak.mp3"); // Case 2 Prullenbak
  player3 = minim.loadFile("tv.mp3"); // Case 4 RF A Televisie
  player4 = minim.loadFile("blender.mp3"); // Case 6 RF B Blender
  player5 = minim.loadFile("platenspeler.wav"); // Case 8 RF C Platenspeler

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

      fill(255, 255, 255);
      text(Integer.toString(userList[i]), com2d.x, com2d.y);

      zValue[i] = int(com2d.z);

      if (zValue.length > 0) {
        int MIN = MAX_INT; 
        int index = 0;

        for (int o=0; o < zValue.length; o++) { 
          if (zValue[o]<MIN && zValue[o] != 0.0) { 
            MIN=zValue[o]; 
            index = o;
            activeUser = index + 1;
          }
        } 

        println("Primary user: " + activeUser);
      }

      takeDirection(activeUser);
    }
  }
}

/* Take direction function
 ================================================== */
void takeDirection(int userId) {
  fill(255, 255, 255);
  textSize(14);

  PVector leftHand = new PVector();
  PVector leftElbow = new PVector();
  PVector leftShoulder = new PVector();
  PVector rightHand = new PVector();
  PVector rightElbow = new PVector();
  PVector rightShoulder = new PVector();

  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_HAND, leftHand);
  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, leftElbow);
  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, leftShoulder);
  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_HAND, rightHand);
  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, rightElbow);
  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, rightShoulder);

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

  int leftHorizontal = round((leftHandX - leftShoulderX) / 100);
  int leftVertical = round((leftHandY - leftElbowY) / 100);
  textAlign(RIGHT);
  text("X: " + leftHorizontal, com2d.x - 64, com2d.y);
  text("Y: " + leftVertical, com2d.x - 64, com2d.y + 15);

  int rightHandX = parseInt(rightHand.x);
  int rightHandY = parseInt(rightHand.y);
  int rightElbowY = parseInt(rightElbow.y);
  int rightShoulderX = parseInt(rightShoulder.x);

  int rightHorizontal = round((rightHandX - rightShoulderX) / 100);
  int rightVertical = round((rightHandY - rightElbowY) / 100);
  textAlign(LEFT);
  text("X: " + rightHorizontal, com2d.x + 64, com2d.y);
  text("Y: " + rightVertical, com2d.x + 64, com2d.y + 15);

  text("Z: " + round(com2d.z / 100), com2d.x, com2d.y + 15);
  
  if(leftVertical > rightVertical && leftVertical > -1){
    sendHValue(leftHorizontal);
  }else if(rightVertical > leftVertical && rightVertical > -1){
    sendHValue(rightHorizontal);
  }
}

/* Send horizontal value function
 ================================================== */
void sendHValue(int x) {
  switch(x) {
  case -4:
  case -3: 
    arduinoPort.write(0); // Case 0 Doos (PT 11)
    if (tickPlayerThread1) {
      audioPlay(0);
    }
    break;
  case -2: 
  case -1: 
    arduinoPort.write(2); // Case 2 Prullenbak (PT 10)
    if (tickPlayerThread2) {
      audioPlay(1);
    }
    break;
  case 0: 
    arduinoPort.write(4); // Case 4 Televisie (RF A)
    if (tickPlayerThread3) {
      audioPlay(2);
    }
    break;
  case 1: 
  case 2: 
    arduinoPort.write(6); // Case 6 Blender (RF B)
    if (tickPlayerThread4) {
      audioPlay(3);
    }
    break;
  case 3: 
  case 4: 
    arduinoPort.write(8); // Case 8 Platenspeler (RF C)
    if (tickPlayerThread5) {
      audioPlay(4);
    }
    break;
  }
}

/* Draw skeleton functie
 ================================================== */
void drawSkeleton(int userId) {
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
  case 3:
    player4.play();
    tickPlayerThread4 = false;

    if (millis() - time >= player4.length()) {
      player4.rewind();
      tickPlayerThread4 = true;
    }
    break;
  case 4:
    player5.play();
    tickPlayerThread5 = false;

    if (millis() - time >= player5.length()) {
      player5.rewind();
      tickPlayerThread5 = true;
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

