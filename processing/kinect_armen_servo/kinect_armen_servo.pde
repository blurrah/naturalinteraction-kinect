import SimpleOpenNI.*;

import processing.serial.*;

import cc.arduino.*;

Arduino arduino1;

SimpleOpenNI  context;
color[]       userClr = new color[]{ color(255,0,0,63),
                                     color(0,255,0,63),
                                     color(0,0,255,63),
                                     color(255,255,0,63),
                                     color(255,0,255,63),
                                     color(0,255,255,63)
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
  
  // Initiate text function
  drawText(userId,SimpleOpenNI.SKEL_RIGHT_ELBOW,SimpleOpenNI.SKEL_RIGHT_HAND,SimpleOpenNI.SKEL_TORSO);
  drawText(userId,SimpleOpenNI.SKEL_LEFT_ELBOW,SimpleOpenNI.SKEL_LEFT_HAND,SimpleOpenNI.SKEL_TORSO);
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
  //println("onVisibleUser - userId: " + userId);
}

// -----------------------------------------------------------------
// Control Servo

void controlServo(int userId, int jointType1, int jointType2, int jointType3) {
 PVector jointPos1 = new PVector();
 PVector jointPos2 = new PVector();
 PVector jointPos3 = new PVector();
 float text;
 
 text = context.getJointPositionSkeleton(userId, jointType1, jointPos1);
 text = context.getJointPositionSkeleton(userId, jointType2, jointPos2);
 //text = context.getJointPositionSkeleton(userId, jointType3, jointPos3);
 
 int Y1 = parseInt(jointPos1.y);
 int Y2 = parseInt(jointPos2.y);
 int X1 = parseInt(jointPos1.x);
 int X2 = parseInt(jointPos3.x);
 
 int xDiff = X1 - X2;
 int yDiff = Y1 - Y2;
 
 /* OUDE CODE
 if(Y1 > Y2) {
   arduino.servoWrite(11, 90);
   arduino.servoWrite(10, 90);
 } else if (Y1 < Y2) {
   arduino.servoWrite(11, 0);
   arduino.servoWrite(10, 0);
 }

*/ 
 

 if(X1 > X2) {
    if(Y1 > Y2) {
      arduino1.servoWrite(11, 20); 
    } else if (Y1 < Y2) {
       arduino1.servoWrite(11, 90);
    }
    arduino1.servoWrite(10, 0);
 } else if (X1 < X2) {
   if(Y1 > Y2) {
      arduino1.servoWrite(10, 20);
    } else if (Y1 < Y2) {
    arduino1.servoWrite(10, 90);
    }
    arduino1.servoWrite(11, 0);
 }
}

// -----------------------------------------------------------------
// Draw text and evaluate arm position

void drawText(int userId,int jointType1,int jointType2,int jointCenter)
{
  PVector jointPos1 = new PVector();
  PVector jointPos2 = new PVector();
  PVector jointPos0 = new PVector();
  float text;
  
  text = context.getJointPositionSkeleton(userId,jointType1,jointPos1); // userId vervangen door 1
  text = context.getJointPositionSkeleton(userId,jointType2,jointPos2); // userId vervangen door 1
  text = context.getJointPositionSkeleton(userId,jointCenter,jointPos0); // userId vervangen door 1
  
  int X1 = parseInt(jointPos1.x);
  int Y1 = parseInt(jointPos1.y);
  int Z1 = parseInt(jointPos1.z);
  
  int X2 = parseInt(jointPos2.x);
  int Y2 = parseInt(jointPos2.y);
  int Z2 = parseInt(jointPos2.z);
  
  int X0 = parseInt(jointPos0.x);
  int Y0 = parseInt(jointPos0.y);
  int Z0 = parseInt(jointPos0.z);
  
  int xDiff = X1 - X2;
  int yDiff = Y1 - Y2;
  int zDiff = Z1 - Z2;
  
  textSize(12);
  fill(255);
  
  if(X1 > X0){
    textAlign(LEFT);
    text("X: " + xDiff, 10, 15);
    text("Y: " + yDiff, 10, 30);
    text("Z: " + zDiff, 10, 45);
  } else if (X1 < X0){
    textAlign(RIGHT);
    text("X: " + xDiff, 630, 15);
    text("Y: " + yDiff, 630, 30);
    text("Z: " + zDiff, 630, 45);
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
