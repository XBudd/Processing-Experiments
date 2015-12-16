import ddf.minim.spi.*;
import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;
import SimpleOpenNI.*;

// declare SimpleOpenNI object
SimpleOpenNI context;
float        zoomF =0.5f;
float        rotX = radians(180);  // by default rotate the hole scene 180deg around the x-axis, 
// the data from openni comes upside down
float        rotY = radians(0);
PShape       pointCloud;
int          steps = 2;

//Mimim Stuff
Minim minim;
AudioPlayer jingle;
FFT fft; 
AudioInput in;
float[] angle;
float[] mX, mY;

// Angle for rotation
float a = 0;


// PImage to hold incoming imagery
PImage cam;
int r(int a) {
  return int(random(a));
}
void setup() {
  // same as Kinect dimensions
  size(640, 480, P3D);
  frameRate(60);
  background(0);
  // initialize SimpleOpenNI object
  context = new SimpleOpenNI(this);
  context.enableRGB();
  context.enableDepth();
  // mirror the image to be more intuitive
  context.setMirror(true);
  context.alternativeViewPointDepthToImage();
  context.setDepthColorSyncEnabled(true);
  stroke(255, 255, 255);
  smooth();
  perspective(radians(45), 
  float(width)/float(height), 
  10, 150000);


  // minim
  minim = new Minim(this);
  in = minim.getLineIn(Minim.STEREO, 2048, 192000.0);
  fft = new FFT(in.bufferSize(), in.sampleRate());
  mX = new float[fft.specSize()];
  mY = new float[fft.specSize()];
  angle = new float[fft.specSize()];
}
void goBig() {

  translate(width/2, height/2, 0);
  rotateX(rotX);
  rotateY(rotY);
  scale(zoomF);

  PImage  rgbImage = context.rgbImage();
  int[]   depthMap = context.depthMap();
  int     steps   = 4;  // to speed up the drawing, draw every third point [typically at 4]
  int     index;
  PVector realWorldPoint;
  color   pixelColor;

  strokeWeight((float)steps); // how disperesed points are (usually "steps/2")

  translate(0, 0, -1000);  // set the rotation center of the scene 1000 infront of the camera

  PVector[] realWorldMap = context.depthMapRealWorld();
  beginShape(POINTS);
  for (int y=0; y < context.depthHeight (); y+=steps)
  {
    for (int x=0; x < context.depthWidth (); x+=steps)
    {
      index = x + y * context.depthWidth();
      if (depthMap[index] > 0)
      { 
        // get the color of the point
        pixelColor = rgbImage.pixels[index];
        stroke(pixelColor);

        // draw the projected point
        realWorldPoint = realWorldMap[index];
        vertex(realWorldPoint.x, realWorldPoint.y, realWorldPoint.z);  // make realworld z negative, in the 3d drawing coordsystem +z points in the direction of the eye
      }
    }
  } 
  endShape();
  /*
  // draw the kinect cam
   strokeWeight(1);
   context.drawCamFrustum();
   */
}

void draw() {

  fft.forward(in.mix);
  // update the SimpleOpenNI object
  context.update();
 
  // put the image into a PImage
  cam = context.rgbImage();
 
  // display the image
  image(cam, 0, 0);
  loadPixels();
  for (int y = 0; y<height; y+=1 ) {
    for (int x = 0; x<width; x+=1) {
      int loc = x + y*cam.width;
      float r = red (cam.pixels[loc]);
      float g = green (cam.pixels[loc]);
      float b = blue (cam.pixels[loc]);
      float av = ((r+g+b)/3.0);
      //HOW DO I MAKE THE 3D STAY IN FRONT?!
      pushMatrix();
      translate(x, y);
      stroke(r, g, b);
      if (r > 100 && r < 255) {
        //magic time
        line(
        (av-200)*fft.getBand(x)/20+fft.getFreq(x)/200, 
        fft.getBand(x)/20+fft.getFreq(x)/20, 
        (av-255)*fft.getBand(x)/20+fft.getFreq(x)*2, 
        fft.getBand(x)+fft.getFreq(x)/200, -9000, -9000); //change these values to alter the length. The closer to 0 the longer the lines. 
        // you can also try different shapes or even bezier curves instead of line();
      }
      popMatrix();
    }
  }
  println("done");

  context.update();
  goBig();
}

