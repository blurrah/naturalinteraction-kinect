#include <RCSwitch.h>

const String freqA1 = "F0FFF0FFFF0F";
const String freqA0 = "F0FFF0FFFFF0";
const String freqB1 = "F0FFFF0FFF0F";
const String freqB0 = "F0FFFF0FFFF0";
const String freqC1 = "F0FFFFF0FF0F";
const String freqC0 = "F0FFFFF0FFF0";
const String freqD1 = "F0FFFFFF0F0F"; // Alles aan
const String freqD0 = "F0FFFFFF0FF0"; // Alles uit

boolean x;
boolean y;

RCSwitch mySwitch = RCSwitch();

void setup() {

  Serial.begin(9600);
  
  mySwitch.enableTransmit(10);
  mySwitch.setPulseLength(318);
  mySwitch.setProtocol(1);
  mySwitch.setRepeatTransmit(10);
  
}

void loop() {
  sendSignalTo(1, true);
  delay(1000);
  sendSignalTo(1, false);
  delay(1000);
  sendSignalTo(2, true);
  delay(1000);
  sendSignalTo(2, false);
  delay(1000);
  sendSignalTo(3, true);
  delay(1000);
  sendSignalTo(3, false);
  delay(1000);
}

/*
    Send signal function.
*/
void sendSignalTo(int x, boolean y){
  switch (x) {
  case 1:
    if(y){
      mySwitch.sendTriState("F0FFF0FFFF0F");
      Serial.println("Adapter A on.");
      delay(20);
    }else{
      mySwitch.sendTriState("F0FFF0FFFFF0");
      Serial.println("Adapter A off.");
      delay(20);
    }
    break;
  case 2:
    if(y){
      mySwitch.sendTriState("F0FFFF0FFF0F");
      Serial.println("Adapter B on.");
      delay(20);
    }else{
      mySwitch.sendTriState("F0FFFF0FFFF0");
      Serial.println("Adapter B off.");
      delay(20);
    }
    break;
  case 3:
    if(y){
      mySwitch.sendTriState("F0FFFFF0FF0F");
      Serial.println("Adapter C on.");
      delay(20);
    }else{
      mySwitch.sendTriState("F0FFFFF0FFF0");
      Serial.println("Adapter C off.");
      delay(20);
    }
    break;
  } 
  delay(1);
};
