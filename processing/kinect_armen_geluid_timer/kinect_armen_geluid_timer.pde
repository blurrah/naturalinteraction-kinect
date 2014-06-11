import SimpleOpenNI.*;
import processing.serial.*;
import cc.arduino.*;
import ddf.minim.*;

Arduino arduino1;
Minim minim;
AudioPlayer player1;
AudioPlayer player2;
AudioPlayer player3;

// time functie
int time;

 // Timer
 boolean tickPlayerThread1 = true;
 boolean tickPlayerThread2 = true;
 boolean tickPlayerThread3 = true;


SimpleOpenNI  context;
color[]       userClr = new color[]{ color(73,10,61),
                                     color(189,21,80),
                                     color(233,127,2),
                                     color(248,202,0),
                                     color(138,155,15)
                                   };
PVector com = new PVector();                                   
PVector com2d = new PVector();                                   

// -----------------------------------------------------------------
// Setup function

void setup()
{
  
  println(Arduino.list());
  arduino1 = new Arduino(this, "/dev/tty.usbmodem1411", 57600);
  size(640,480);
  
  // Audio Baudio
  minim = new Minim(this);
  player1 = minim.loadFile("box2.mp3");
  player2 = minim.loadFile("box3.mp3");
  player3 = minim.loadFile("box4.mp3");
  
  // Timer
  time = millis();
  
  context = new SimpleOpenNI(this);
  if(context.isInit() == false)
  {
     println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
     exit();
     return;  
  }
  
  // enable depthMap generation 
  context.enableDepth();
   
  // enable skeleton generation for all joints
  context.enableUser();
 
  background(200,0,0);

  stroke(0,0,255);
  strokeWeight(3);
  smooth(); 
 
 arduino1.pinMode(11, Arduino.SERVO); 
 arduino1.pinMode(10, Arduino.SERVO);
 arduino1.pinMode(6, Arduino.SERVO);
}

// -----------------------------------------------------------------
// Draw function

void draw()
{
  // update the cam
  context.update();
  
  // draw depthImageMap
  //image(context.depthImage(),0,0);
  image(context.userImage(),0,0);
  
  // draw the skeleton if it's available
  int[] userList = context.getUsers();
  for(int i=0;i<userList.length;i++)
  {
    if(context.isTrackingSkeleton(userList[i]))
    {
      stroke(userClr[ (userList[i] - 1) % userClr.length ] );
      drawSkeleton(userList[i]);
    }      
      
    // draw the center of mass
    if(context.getCoM(userList[i],com))
    {
      context.convertRealWorldToProjective(com,com2d);
      stroke(100,255,0);
      strokeWeight(1);
      beginShape(LINES);
        vertex(com2d.x,com2d.y - 5);
        vertex(com2d.x,com2d.y + 5);

        vertex(com2d.x - 5,com2d.y);
        vertex(com2d.x + 5,com2d.y);
      endShape();
      
      fill(0,255,100);
      text(Integer.toString(userList[i]),com2d.x,com2d.y);
    }
  }    
}

// draw the skeleton with the selected joints
void drawSkeleton(int userId)
{
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
  
  //controlServo(userId, SimpleOpenNI.SKEL_RIGHT_HAND, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  controlServo(userId, SimpleOpenNI.SKEL_LEFT_HAND, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_SHOULDER);
}

// -----------------------------------------------------------------
// SimpleOpenNI events

void onNewUser(SimpleOpenNI curContext, int userId)
{
  println("onNewUser - userId: " + userId);
  println("\tstart tracking skeleton");
  
  curContext.startTrackingSkeleton(userId);
}

void onLostUser(SimpleOpenNI curContext, int userId)
{
  println("onLostUser - userId: " + userId);
}

void onVisibleUser(SimpleOpenNI curContext, int userId)
{
  println("onVisibleUser - userId: " + userId);
}

// -----------------------------------------------------------------
// Control Servo

void controlServo(int userId, int jointType1, int jointType2, int jointType3) {
 PVector jointPos1 = new PVector();
 PVector jointPos2 = new PVector();
 PVector jointPos3 = new PVector();
 float text;
 
 text = context.getJointPositionSkeleton(userId, jointType1, jointPos1); // userId naar 1
 text = context.getJointPositionSkeleton(userId, jointType2, jointPos2);
 text = context.getJointPositionSkeleton(userId, jointType3, jointPos3);
 
 int Y1 = parseInt(jointPos1.y);
 int Y2 = parseInt(jointPos2.y);
 int Y3 = parseInt(jointPos3.y);
 int X1 = parseInt(jointPos1.x);
 int X2 = parseInt(jointPos3.x);
 int X3 = parseInt(jointPos3.y);
 
 int xDiff = X1 - X3;
 int yDiff = Y1 - Y3;
 
 text("< User: " + userId, 15, X3 - 15);
 text("     X: " + xDiff, 15, X3);
 text("     Y: " + yDiff, 15, X3 + 15);
 

  if(xDiff >= 250) {
    arduino1.servoWrite(11, 90); // Links
    arduino1.servoWrite(6, 0); // Midden
    arduino1.servoWrite(10, 0); // Rechts
    
    audioPlay(0);
    /*if(yDiff >= 100) {
      arduino1.servoWrite(11, 0); 
    } else if (yDiff < 100) {
      arduino1.servoWrite(11, 90);
      arduino1.servoWrite(10, 0);
      arduino1.servoWrite(6, 0);
      if(tickPlayerThread1){
        audioPlay(0);
      }
    }*/
  } else if (xDiff > -500 && xDiff < 250) {
    arduino1.servoWrite(11, 0); // Links
    arduino1.servoWrite(6, 90); // Midden
    arduino1.servoWrite(10, 0); // Rechts
    
    audioPlay(1);
    /*if(yDiff >= 100) {
      arduino1.servoWrite(6, 0);
    } else if (yDiff < 100) {
      arduino1.servoWrite(6, 90);
      arduino1.servoWrite(11, 0);
      arduino1.servoWrite(10, 0);
      if(tickPlayerThread2) {
        audioPlay(1);
      }
    }*/
  } else if (xDiff <= -500) {
    arduino1.servoWrite(11, 0); // Links
    arduino1.servoWrite(6, 0); // Midden
    arduino1.servoWrite(10, 90); // Rechts
    
    audioPlay(2);
    /*if(yDiff >= 200) {
      arduino1.servoWrite(10, 0);
    } else if (yDiff < 100) {
      arduino1.servoWrite(10, 90);
      arduino1.servoWrite(11, 0);
      arduino1.servoWrite(6, 0);
      if(tickPlayerThread3) {
        audioPlay(2);
      }
    }*/
  }
}

// -----------------------------------------------------------------
// Keypresses

void keyPressed()
{
  switch(key)
  {
  case ' ':
    context.setMirror(!context.mirror());
    break;
  }
}  

// ------------------------------------------------------------------
// Delay Timer
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
  
    if(millis() - time >= player2.length()) {
       player2.rewind();
       tickPlayerThread2 = true;
    }
  break;
  case 2:
  player3.play();
  tickPlayerThread3 = false;
  
    if(millis() - time >= player3.length()) {
      player3.rewind();
      tickPlayerThread3 = true;
    }
  break;
  };
}
