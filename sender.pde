import processing.serial.*;

// Arduino Firmata library – https://github.com/firmata/processing/releases/tag/latest
import cc.arduino.*;

Arduino arduino;
PImage img;
color sourceColor;
int canvasHeight;
int canvasWidth;
color currentPixelColor;
int laserPin = 3;
int time;
int wait = 100;
int pixelIndex;
float currentPixel;
boolean imageProcessed;
boolean programStarted = false;

XML xml;

void setup() {
  setupCanvas(true);
  frameRate(20);
  time = millis();
  pixelIndex = 0;

  println(Arduino.list());
  arduino = new Arduino(this, Arduino.list()[7], 57600);
  arduino.pinMode(laserPin, Arduino.OUTPUT);
}

String getLastImgUrl() {
  /* Flickr API key (eg. 41025812e2f179a425925e6ae134cc8b) */
  String apikey = '';
  String flickrUrl = "https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=" + apikey + "&min_upload_date=" + time;
  xml = loadXML(flickrUrl);
  XML[] children = xml.getChildren("photos/photo");

  String farmId = children[0].getString("farm");
  String serverId = children[0].getString("server");
  String id = children[0].getString("id");
  String secret = children[0].getString("secret");

  String result = "https://farm" + farmId + ".staticflickr.com/" + serverId + "/" + id + "_" + secret + "_t.jpg";
  return result;
}

PImage getLastImg() {
  PImage img = loadImage(getLastImgUrl());
  return img;
}

void setupCanvas(boolean start) {
  canvasWidth = 64;
  if (start) {
	img = loadImage("baseline.png");
  } else {
	img = getLastImg();
  }

  //img.resize(canvasWidth, 0);
  canvasHeight = img.height;

  size(canvasWidth, canvasHeight);
  imageProcessed = false;
}

void keyPressed() {
  if (key == 's') {
	programStarted = true;
  }
}

void sendMightyLaser() {
  // Actually do thing
  currentPixel = red(pixels[pixelIndex]);

  if (currentPixel == 0) {
	arduino.digitalWrite(laserPin, Arduino.HIGH);
  } else {
	arduino.digitalWrite(laserPin, Arduino.LOW);
  }

  //println(pixelIndex + ": " + currentPixel);

  time = millis();
  pixelIndex++;
}

void draw() {
  // background(0);

  if (imageProcessed == false) {
	image(img, 0, 0);
	filter(THRESHOLD);
	loadPixels();
	imageProcessed = true;
  }

  if (programStarted) {
	if (pixelIndex < pixels.length) {
	  sendMightyLaser();
	} else {
	  setupCanvas(false);
	  pixelIndex = 0;
	  sendMightyLaser();
	}
  }
}
