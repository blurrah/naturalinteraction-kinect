/*
 * Arduino code voor het besturen van de RF Transmitter
 * en de Servo's op commando van de Kinect.
 * Werkt door middel van een seriele connectie met
 * Processing.
 * xoxox Boris & Jasper
 */
#include <RCSwitch.h>
#include <Servo.h>

// Frequentie const's
#define freqA1 "F0FFF0FFFF0F"
#define freqA0 "F0FFF0FFFFF0"
#define freqB1 "F0FFFF0FFF0F"
#define freqB0 "F0FFFF0FFFF0"
#define freqC1 "F0FFFFF0FF0F"
#define freqC0 "F0FFFFF0FFF0"
#define freqD1 "F0FFFFFF0F0F" // Alles aan
#define freqD0 "F0FFFFFF0FF0" // Alles uit


// Seriele shit
int serialVal;

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
RCSwitch rcSwitch = RCSwitch();

Servo servoA;
Servo servoB;

void setup() {
  Serial.begin(9600);

  servoA.attach(11);
  servoB.attach(10);

  rcSwitch.enableTransmit(6);
  rcSwitch.setPulseLength(318);
  rcSwitch.setProtocol(1);
  rcSwitch.setRepeatTransmit(6);

}

void sendSignalToRC(int x, boolean y) {
  switch(x){
  case 1:
    if(y) {
      rcSwitch.sendTriState(freqA1);
    } 
    else {
      rcSwitch.sendTriState(freqA0); 
    }
    break;
  case 2:
    if(y) {
      rcSwitch.sendTriState(freqB1);  
    } 
    else {
      rcSwitch.sendTriState(freqB1);
    }

    break;
  case 3:
    if(y) {
      rcSwitch.sendTriState(freqC1); 
    } 
    else {
      rcSwitch.sendTriState(freqC0);
    }
    break;
  default:
    break;
  }
}


void loop() {
  if(Serial.available()) {
    serialVal = Serial.read();
    Serial.print("I received: ");
    Serial.println(serialVal, DEC);
  }

  switch(serialVal) {
  case -1:
    break;
  case 0:
    // Servo A HIGH
    servoA.write(90);
    break;
  case 1:
    // Servo A LOW
    servoA.write(0);
    break;
  case 2:
    // Servo B HIGH
    servoB.write(90);
    break;
  case 3:
    // Servo B LOW
    servoB.write(0);
    break;
  case 4:
    // RF A HIGH
    sendSignalToRC(1, true);
    break;
  case 5:
    // RF A LOW
    sendSignalToRC(1, false);
    break;
  case 6:
    // RF B HIGH
    sendSignalToRC(2, true);
    break;
  case 7:
    // RF B LOW
    sendSignalToRC(2, false);
    break;
  case 8:
    // RF C HIGH
    sendSignalToRC(3, true);
    break;
  case 9:
    // RF C LOW
    sendSignalToRC(3, false);
    break;
  default:
    break; 
  }

}










