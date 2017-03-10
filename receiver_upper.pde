import oscP5.*;
import netP5.*;


int pixelSize = 20;
int rows = 51 ; // 48 = full screen
int columns = 64;
color sourceColor;
int canvasHeight;

int counter = 0;
boolean[][] storedPixels = new boolean[rows][columns];

OscP5 osc;
NetAddress addr;
int port = 1337;



void setup() {
  size(columns * pixelSize, rows * pixelSize);
  frameRate(5);
  
  osc  = new OscP5(this, port);
  addr = new NetAddress("127.0.0.1", port);
  
  
  for (int r = 0; r < rows; r++) {
    for (int p = 0; p < columns; p++) {
      storedPixels[r][p] = false;
    }
  }
  
  noStroke();
}


void drawPixels(){
  for (int r = 0; r < rows; r++) {
    for (int p = 0; p < columns; p++) {
      if (storedPixels[r][p] == true) {
        fill(0);
        rect(p * pixelSize, r * pixelSize, pixelSize, pixelSize);
      }
    }
  }
}

void oscEvent(OscMessage msg)
{
    boolean[] tempArray = new boolean[columns];
    
    for (int i = 0; i < columns; i++) {
        tempArray[i] = boolean(msg.get(i).intValue());
    }
    
    addLine(tempArray);
}



void addLine(boolean[] lastLine) {
  for (int row = 0; row < rows; row++) {
    if (row < rows - 1){
      arrayCopy(storedPixels[row + 1], storedPixels[row]);
    }
    
    else {
      storedPixels[row] = lastLine;
    }
  }
}

void draw() {
  background(255);
  
  // Finally
  drawPixels();
}
