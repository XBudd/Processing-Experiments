/**
 * Based on "Getting Started with Capture" Example and aferriss' 
 * Pixel Sorting code here: http://forum.processing.org/one/topic/pixel-sorting.html
 * 
 * Colin Budd
 * September 22, 2015
 * Cornell University
 */

import processing.video.*;

int numPixels;
int[] backgroundPixels;
Capture video;

void setup() {
  size(1280, 720, P2D);
  background(0);
  String[] cameras = Capture.list();

  if (cameras == null) {
    println("Failed to retrieve the list of available cameras, will try the default...");
    video = new Capture(this, 1280, 720);
  } if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(cameras[i]);
    }

    // The camera can be initialized directly using an element
    // from the array returned by list():
    video = new Capture(this, cameras[0]);
   
    // Start capturing the images from the camera
    video.start();
  }
}

void draw() {
  if (video.available() == true) {
    video.read();
  
    video.loadPixels();
    
    for (int y = 0; y<height; y+=1 ) {
      for (int x = 0; x<width; x+=1) {
        int loc = x + y*video.width;
        float r = red (video.pixels[loc]);
        float g = green (video.pixels[loc]);
        float b = blue (video.pixels[loc]);
        float av = ((r+g+b)/3.0);
  
      pushMatrix();
      translate(x,y);
        stroke(r,g,b);
        if (r > 100 && r < 255) {
          line(0,0,(av-255)/3,0); //change these values to alter the length. The closer to 0 the longer the lines. 
         // you can also try different shapes or even bezier curves instead of line();
        }
      popMatrix(); 
     }
   }
 }
}