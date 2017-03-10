import processing.serial.*;

// Arduino Firmata library – https://github.com/firmata/processing/releases/tag/latest
import cc.arduino.*;

import oscP5.*;
import netP5.*;

Arduino arduino;
int pixelSize = 20;
int rows = 51 ; // 48 = full screen
int columns = 64;
color sourceColor;
int canvasHeight;

int analogPin = 0;
int pinNum = 1;
float val;
boolean didReceiveBeam;
int counter = 0;
boolean[][] storedPixels = new boolean[rows][columns];
int currentColumn = 0;

int laserThresholdValue = 900;
boolean programStarted = false;

OscP5 osc;
NetAddress addr;
int port = 1337;

void productionSetup() {
  frame.removeNotify();
  frame.setUndecorated(true);
  frame.addNotify();
  //super.init();
  frame.setLocation(0, 0);
}

void setup() {
  size(columns * pixelSize, rows * pixelSize, OPENGL);
  //productionSetup();
  frameRate(20);

  println(Arduino.list());
  arduino = new Arduino(this, Arduino.list()[2], 57600);

  osc  = new OscP5(this, port);
  addr = new NetAddress("127.0.0.1", port);

  for (int r = 0; r < rows; r++) {
    for (int p = 0; p < columns; p++) {
      storedPixels[r][p] = false;
    }
  }

  noStroke();
}

boolean beamReceived() {
  boolean received = false;
  for (int i = 0; i < pinNum; i++) {
    int val = arduino.analogRead(i);
    if (val > laserThresholdValue) {
      received = true;
    }
  }

  return received;
}


void drawPixels(){
  for (int r = 0; r < rows; r++) {
    for (int p = 0; p < columns; p++) {
      if(storedPixels[r][p] == true){
        fill(0);
        rect(p * pixelSize, r * pixelSize, pixelSize, pixelSize);
      }
    }
  }
  fill(255, 0, 0);
  rect(currentColumn * pixelSize, (rows - 1) * pixelSize, pixelSize, pixelSize);
}

void writeOrNot(){
  // here I come
  if (didReceiveBeam){
    storedPixels[rows - 1][currentColumn] = true;
  }
}

void runProgram() {
  if (currentColumn < columns) {
    writeOrNot();
    currentColumn++;
  }

  else {
    OscMessage msg = new OscMessage("/test");

    for (int i = 0; i < columns; i++) {
        int val;
        if (storedPixels[0][i]) { val = 1; }
        else { val = 0; }
        msg.add(val);
    }
    osc.send(msg, addr);

    for (int row = 0; row < rows; row++){
      if (row < rows - 1){
        arrayCopy(storedPixels[row + 1], storedPixels[row]);
      }

      else if (row == rows - 1){
        for (int i = 0; i < columns; i++){
          storedPixels[row][i] = false;
        }
      }
    }

    currentColumn = 0;
    writeOrNot();
    currentColumn++;
  }
}

void draw() {
  background(255);

  if (beamReceived()) {
    didReceiveBeam = true;
    counter++;
  }
  else {
    didReceiveBeam = false;
  }

  if (programStarted) {
    runProgram();
  }

  else if (didReceiveBeam) {
    programStarted = true;
    runProgram();
  }

  // Finally
  drawPixels();
}
