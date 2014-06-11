/*
 * Arduino code voor het besturen van de RF Transmitter
 * en de Servo's op commando van de Kinect.
 * Werkt door middel van een seriele connectie met
 * Processing.
 * xoxox Boris & Jasper
 */
#include <Servo.h>



// Seriele shit
char val;

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

// DEFINE'S
#define ServoAHigh 0
#define ServoALow 1
#define ServoBHigh 2
#define ServoBLow 3
#define rfAHigh 4
#define rfALow 5
#define rfBHigh 6
#define rfBLow 7
#define rfCHigh 8
#define rfCLow 9

// Objecten aanroepen

Servo servoA;
Servo servoB;

void setup() {
  Serial.begin(9600);

  servoA.attach(11);
  servoB.attach(10);

  

}



void loop() {
  if(Serial.available()) {
   val = Serial.read();
  Serial.println(val); 
  }
  
  switch(val) {
  case -1:
    break;
  case 'A':
    // Servo A HIGH
    servoA.write(90);
    disableAllBut(0);
    break;
  case 1:
    // Servo A LOW
    servoA.write(0);
    break;
  case 'B':
    // Servo B HIGH
    servoB.write(90);
    disableAllBut(2);
    break;
  case 3:
    // Servo B LOW
    servoB.write(0);
    break;
  
  default:
    break; 
  }
  

  

}

void disableAllBut(int Nono) {
  switch(Nono) {
  case 0:
    // Als ServoA aangaat
    servoB.write(0);
    break;
  case 2:
    servoA.write(0);
    break;
  case 4:
    servoA.write(0);
    servoB.write(0);
    break;
  case 6:
    servoA.write(0);
    servoB.write(0);
    break;
  case 8:
    servoA.write(0);
    servoB.write(0);
    break;
  default:
    break;
  } 
}
