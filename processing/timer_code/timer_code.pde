// binnen de controlServo functie
boolean tickPlayerThread1;
boolean tickPlayerThread2;
boolean tickPlayerThread3;

// global variable
int time;

// Dit moet in de setup functie
time = millis();


// in de if's moet er een nieuwe if

if(tickPlayerThread1) {
  
}

if(tickPlayerThread2) {
  
}

if(tickPlayerThread3) {
  
}

void audioPlay(int player) {
  int wait[];
  
  switch(player) {
    
  case "0":
  // misschien een parseInt
   player1.play();
   tickPlayerThread1 = false;
   wait[0] = player1.length();
   if (millis() - time >= wait[0]) {
    player1.rewind();
    tickPlayerThread1 = true;
   }
  break;
  case "1":
  player2.play();
  tickPlayerThread2 = false;
  wait[1] = player2.length();
  if(millis() - time >= wait[1]) {
   player2.rewind();
   tickPlayerThread2 = true;
  }
  break;
  case "2":
  player3.play();
  tickPlayerThread3 = false;
  wait[2] = player3.length();
  if(millis() - time >= wait[2]) {
    player3.rewind();
    tickPlayerThread3 = true;
  }
  break;
  };
  
}

void delayIt(int ms) {
  
}
