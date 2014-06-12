import ddf.minim.*;

Minim minim;

AudioPlayer player;

void setup() {
 minim = new Minim(this);
 player = minim.loadfile("billieholiday.mp3"); 
}

void draw() {
  player.play();
  println(player.getVolume());
}
