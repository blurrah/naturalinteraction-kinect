/* Import scripts
 ================================================== */
import SimpleOpenNI.*;
import processing.serial.*;
import cc.arduino.*;
import ddf.minim.*;

/* Definitie componenten
 ================================================== */
SimpleOpenNI context;
Arduino arduino1;
Arduino arduino2;
Minim minim;
AudioPlayer player1;
AudioPlayer player2;
AudioPlayer player3;
AudioPlayer player4;
AudioPlayer player5;
AudioPlayer player6;

/* Variabelen
 ================================================== */
boolean tickPlayerThread1 = true;
boolean tickPlayerThread2 = true;
boolean tickPlayerThread3 = true;
boolean tickPlayerThread4 = true;
boolean tickPlayerThread5 = true;
boolean tickPlayerThread6 = true;

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
int lastTime;
int[] zValue = new int[6];

int value1 = 30;
int value2 = 90;
int value3 = 150;
int value4 = 200;
int value5 = 300;

byte[] out = {
  byte(value1), byte(value2), byte(value3), byte(value4), byte(value5)
  };
  /*
out[0] = byte(value1);
   out[1] = byte(value2);
   out[2] = byte(value3);
   out[3] = byte(value4);
   out[4] = byte(value5);
   
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
    lastTime = millis();

    // Arduino configuration
    arduino1 = new Arduino(this, "/dev/tty.usbmodemfd131", 57600);
    arduino2 = new Arduino(this, "/dev/tty.usbmodemfd141", 57600);

    arduino1.pinMode(11, Arduino.SERVO);
    arduino1.pinMode(10, Arduino.SERVO);
    arduino2.pinMode(9, Arduino.SERVO);
    arduino2.pinMode(6, Arduino.SERVO);

    // Audio configuration
    minim = new Minim(this);
    player1 = minim.loadFile("doos_longbeep.wav"); // Case 0 Houten Doos
    player2 = minim.loadFile("doos_morse.wav"); // Case 2 Prullenbak
    player3 = minim.loadFile("doos_radiobeep.wav"); // Case Doos onder houten doos
    player4 = minim.loadFile("uiteinde_rewind.mp3"); // Case 6 Uiteinde
    player5 = minim.loadFile("doos_longbeep.wav"); // Case 8 Eerste doos
    player6 = minim.loadFile("billieholiday.mp3");

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
  if(tickPlayerThread6) {
    audioPlay(5);
  }
  
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
      int MIN = MAX_INT; 

      if (zValue[i]<MIN && zValue[i] != 0.0) { 
        MIN=zValue[i]; 
        if (com2d.x >= 0 && com2d.x <= 640) { 
          sendHValue(int(com2d.x));
        }
      }
    }
  }
}

/* Send horizontal value function
 ================================================== */
void sendHValue(int x) {

  x = round(x / 100);
  text(x, com2d.x, com2d.y + 25);

  textSize(14);
  switch(x) {
  case 6:
  case 5:
    // arduinoPort.write('E'); // Case Eerste doos
    text("PLATENSPELER", com2d.x, 450);
    if (tickPlayerThread5) {
      audioPlay(4);
    }
    break;
  case 4: 
    //arduinoPort.write('B'); // Case 2 Prullenbak (PT 10)
    arduino1.servoWrite(10, 90);
    arduino1.servoWrite(11, 0);
    arduino2.servoWrite(9, 0);
    arduino2.servoWrite(6, 0);
    text("PRULLENBAK", com2d.x, 450);
    if (tickPlayerThread2) {
      audioPlay(1);
    }
    break;
  case 3: 
    //arduinoPort.write('A'); // Case 0 Houten Doos (PT 11)
    arduino1.servoWrite(11, 90);
    arduino1.servoWrite(10, 0);
    arduino2.servoWrite(9, 0);
    arduino2.servoWrite(6, 0);
    text("DOOS", com2d.x, 450);
    if (tickPlayerThread1) {
      audioPlay(0);
    }
    break;
  case 2: 
    // arduinoPort.write('C'); // Case 4 Doos onder houten doos (RF A)
    arduino1.servoWrite(11, 0);
    arduino1.servoWrite(10, 0);
    arduino2.servoWrite(9, 90);
    arduino2.servoWrite(6, 0);
    text("TELEVISIE", com2d.x, 450);
    if (tickPlayerThread3) {
      audioPlay(2);
    }
    break; 
  case 1:
  case 0:
    // arduinoPort.write('D'); // Case 6 Uiteinde (RF B)
    arduino1.servoWrite(11, 0);
    arduino1.servoWrite(10, 0);
    arduino2.servoWrite(9, 0);
    arduino2.servoWrite(6, 90);
    text("BLENDER", com2d.x, 450);
    if (tickPlayerThread4) {
      audioPlay(3);
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
    println(player1.getVolume());
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
    case 5:
      player6.play();
      tickPlayerThread6 = false;
      
      if(millis() - time >= player6.length()) {
       player6.rewind();
       tickPlayerThread6 = true; 
      }
     break;
  };
}

/* SimpleOpenNI events
 ================================================== */
void onNewUser(SimpleOpenNI curContext, int userId) {
  //println("onNewUser - userId: " + userId);
  //println("\tstart tracking skeleton");
  curContext.startTrackingSkeleton(userId);
  if(tickPlayerThread6) {
    audioPlay(5);
  }
}

void onLostUser(SimpleOpenNI curContext, int userId) {
  //println("onLostUser - userId: " + userId);
}

void onVisibleUser(SimpleOpenNI curContext, int userId) {
  //println("onVisibleUser - userId: " + userId);
  if(tickPlayerThread6) {
    audioPlay(5);
  }
}

