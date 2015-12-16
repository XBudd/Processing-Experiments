/* --------------------------------------------------------------------------
 * Baed on SimpleOpenNI User3d Test & SimpleOpenNI Hands3d Test by Max Rheiner
 * --------------------------------------------------------------------------
 * Processing Wrapper for the OpenNI/Kinect 2 library
 * http://code.google.com/p/simple-openni
 * --------------------------------------------------------------------------
 * prog: Colin Budd - www.xbudd.com
 * date:  10/23/2015 
 * ----------------------------------------------------------------------------
 */

import SimpleOpenNI.*;
import ddf.minim.spi.*;
import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;
import geomerative.*;
import org.apache.batik.svggen.font.table.*;
import org.apache.batik.svggen.font.*;

SimpleOpenNI context;
float        zoomF =0.3f;
float        rotX = radians(180);  // by default rotate the whole scene 180deg around the x-axis, 
// the data from openni comes upside down
float        rotY = radians(0);
boolean      autoCalib=true;

PVector      bodyDepth = new PVector();
PVector      bodyCenter = new PVector();
PVector      bodyDir = new PVector();
PVector      com = new PVector();                                   
PVector      com2d = new PVector();                                   
color[]       userClr = new color[] { 
  color(255, 0, 0), 
  color(0, 255, 0), 
  color(0, 0, 255), 
  color(255, 255, 0), 
  color(255, 0, 255), 
  color(0, 255, 255)
};
//Geometry
RShape arc1;
RPoint[][] pointPaths;
boolean ignoringStyles = false;

Minim minim;
AudioOutput out;
int closestValue;
int closestX;
int closestY;
int closestZ;


void setup()
{
  size(1024, 768, P3D); 
  minim = new Minim(this);
  out = minim.getLineOut();

  context = new SimpleOpenNI(this);
  if (context.isInit() == false)
  {
    println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
    exit();
    return;
  }

  // disable mirror
  context.setMirror(true);

  // enable depthMap generation 
  context.enableDepth();

  // enable skeleton generation for all joints
  context.enableUser();

  stroke(255, 255, 255);
  smooth();  
  perspective(radians(45), 
  float(width)/float(height), 
  10, 150000);
  
  //load shape geometry for Arc
  RG.init(this);
  ignoringStyles = !ignoringStyles; //show color
  RG.ignoreStyles(ignoringStyles);
  RG.setPolygonizer(RG.ADAPTATIVE);
  //Note: have to have the layers JUST be paths, cant be any further info
  arc1 = RG.loadShape("curve.svg");
  arc1.centerIn(g, 1, 1, 1);
  pointPaths = arc1.getPointsInPaths();
 
  
}

void draw()
{
  // update the cam
  context.update();

  background(0, 0, 0);


  // set closestVal
  closestValue = 8000;

  // set the scene pos
  translate(width/2, height/2, 0);
  rotateX(rotX);
  rotateY(rotY);
  scale(zoomF);

  int[]   depthMap = context.depthMap();
  int[]   userMap = context.userMap();
  int     steps   = 3;  // to speed up the drawing, draw every third point
  int     index;
  PVector realWorldPoint;

  translate(0, 0, -1000);  // set the rotation center of the scene 1000 infront of the camera

  // draw the pointcloud
  beginShape(POINTS);

  for (int y=0; y < context.depthHeight (); y+=steps)
  {
    for (int x=0; x < context.depthWidth (); x+=steps)
    {
      index = x + y * context.depthWidth();
      if (depthMap[index] > 0)
      { 
        // draw the projected point
        //realWorldPoint = context.depthMapRealWorld()[index]; //unhide and move thing below out of else statement to show all dots
        if (userMap[index] == 0) {
          stroke(100);
        } else {
          realWorldPoint = context.depthMapRealWorld()[index]; // Draws the dots on screen!
          stroke(userClr[ (userMap[index] - 1) % userClr.length ]);        

          point(realWorldPoint.x, realWorldPoint.y, realWorldPoint.z); //move outside of else if want to display all dots
        }
      }
    }
  } 
  endShape(); 

  // draw the skeleton if it's available
  int[] userList = context.getUsers();
  for (int i=0; i<userList.length; i++)
  {
    if (context.isTrackingSkeleton(userList[i]))
      drawSkeleton(userList[i]);

    // draw the center of mass
    if (context.getCoM(userList[i], com))
    {
      stroke(100, 255, 0);
      strokeWeight(1);
      beginShape(LINES);
      vertex(com.x - 15, com.y, com.z);
      vertex(com.x + 15, com.y, com.z);

      vertex(com.x, com.y - 15, com.z);
      vertex(com.x, com.y + 15, com.z);

      vertex(com.x, com.y, com.z - 15);
      vertex(com.x, com.y, com.z + 15);
      endShape();

      fill(0, 255, 100);
      text(Integer.toString(userList[i]), com.x, com.y, com.z);
    }
  }    

  // draw the kinect cam
 // context.drawCamFrustum();
  
  
  // make those music bars
  rectMode(CENTER);
  noStroke();
  fill(255, 0, 0, 50 );
  rect(-280, 0, 40, 280);
  fill(255, 128, 0, 50);
  rect(-200, 0, 40, 480);
  fill(255, 255, 0, 50);
  rect(-120, 0, 40, 580);
  fill(0, 255, 0, 50);
  rect(-40, 0, 40, 640);
  fill(0, 255, 255, 50);
  rect(40, 0, 40, 640);
  fill(0, 0, 255, 50);
  rect(120, 0, 40, 580);
  fill(128, 0, 255, 50);
  rect(200, 0, 40, 480);
  fill(255, 0, 255, 50);
  rect(280, 0, 40, 280);
  
  //draw arc
  fill(255,0,0,50);
  noStroke();
  arc1.draw();
  
  //Create ball if player is active
  for (int i=0; i<userList.length; i++)
  {
    if (context.isTrackingSkeleton(userList[i]))
      playBall(userList[i]);
  }
}


void playBall(int userId) {
  
  fill(userClr[ (userId-1) % userClr.length ]);
  ellipse(closestX, closestY, 20, 20);
  
  PVector      jointPosR = new PVector();
  PVector      jointPosL = new PVector();
  float rightHand = context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_HAND, jointPosR);
  float leftHand = context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_HAND, jointPosL);
  float distanceScalar = (1024/jointPosR.z); //this is the key to scaling for distance accuracy of hand on Z axis
  //println("jointPosR.x of " + userId + " is: " + jointPosR.x);

  closestX = (int)(jointPosR.x*distanceScalar);
  closestY = (int)(jointPosR.y*distanceScalar);
  closestZ = (int)jointPosR.z;

  //make shape hoverable/clickable
   RPoint p = new RPoint(closestX, closestY);
   for(int i=0;i<arc1.countChildren();i++){
    if(arc1.children[i].contains(p)){
       RG.ignoreStyles(true);
      
       fill(0,100,255,250);
       noStroke();
       arc1.children[i].draw();
       RG.ignoreStyles(ignoringStyles);
    }
  }
  //make music
    if (closestX < -240 && closestX > -280 && closestY < 140 && closestY > -140) {
      out.playNote ("C4");
      fill(255, 0, 0, 100 );
      rect(-280, 0, 40, 280);
    }

    if (closestX < -160 && closestX > -200 && closestY < 240 && closestY > -240) {
      out.playNote ("D4");
      fill(255, 128, 0, 100);
      rect(-200, 0, 40, 480);
    }

    if (closestX < -80 && closestX > -120 && closestY < 290 && closestY > -290) {
      out.playNote ("E4");
       fill(255, 255, 0, 100);
      rect(-120, 0, 40, 580);
    }

    if (closestX < 0 && closestX > -40 && closestY < 320 && closestY > -320) {
      out.playNote ("F4");
      fill(0, 255, 0, 100);
      rect(-40, 0, 40, 640);
    }

    if (closestX < 80 && closestX > 40 && closestY < 320 && closestY > -320) {
      out.playNote ("G4");
      fill(0, 255, 255, 100);
    rect(40, 0, 40, 640);
    }

    if (closestX < 160 && closestX > 120 && closestY < 290 && closestY > -290) {
      out.playNote ("A4");
      fill(0, 0, 255, 100);
      rect(120, 0, 40, 580);
    }

    if (closestX < 240 && closestX > 200 && closestY < 240 && closestY > -240) {
      out.playNote ("B4");
      fill(128, 0, 255, 100);
  rect(200, 0, 40, 480);
    }

    if (closestX < 320 && closestX > 280 && closestY < 140 && closestY > -140) {
      out.playNote ("C5");
      fill(255, 0, 255, 100);
    rect(280, 0, 40, 280);
    }
  
}
// draw the skeleton with the selected joints
void drawSkeleton(int userId)
{
  strokeWeight(3);

  // to get the 3d joint data
  drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);

  drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
  drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
  drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);

  drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);

  drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);

  drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
  drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
  drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);

  drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
  drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
  drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);  

  // draw body direction
  getBodyDirection(userId, bodyCenter, bodyDir);

  bodyDir.mult(200);  // 200mm length
  bodyDir.add(bodyCenter);

  stroke(255, 200, 200);
  line(bodyCenter.x, bodyCenter.y, bodyCenter.z, 
  bodyDir.x, bodyDir.y, bodyDir.z);

  strokeWeight(1);
}
//--------ARC--------

//learned this from rely 11 of https://processing.org/discourse/beta/num_1212093888.html
class PArc2D {
 java.awt.geom.Arc2D arc2D;
 PArc2D(float x, float y, float w, float a, float e) {
   // x, y : center
   // w : width
   // a : direction (point at)
   // e : extent angle
   arc2D = new java.awt.geom.Arc2D.Float(x-w/2, y-w/2, w, w, degrees(-a-e), degrees(e*2), java.awt.geom.Arc2D.PIE);
 }
 void setXY(float x, float y) {
   arc2D.setArcByCenter((double)x, (double)y, arc2D.getWidth()/2, arc2D.getAngleStart(), arc2D.getAngleExtent(), java.awt.geom.Arc2D.PIE);
 }
 void turn(float ra) {
   arc2D.setAngleStart(arc2D.getAngleStart() - degrees(ra));
 }
 void display() {
   float x = (float)arc2D.getX();
   float y = (float)arc2D.getY();
   float w = (float)arc2D.getWidth();
   float as = -radians((float)arc2D.getAngleStart());
   float ae = radians((float)arc2D.getAngleExtent());
   arc(x + w/2, y + w/2, w, w, as - ae, as);
 }
 boolean contains(float x, float y) {
   return arc2D.contains(x, y);
 }
}
//--------END ARC--------

void drawLimb(int userId, int jointType1, int jointType2)
{
  PVector jointPos1 = new PVector();
  PVector jointPos2 = new PVector();
  float  confidence;

  // draw the joint position
  confidence = context.getJointPositionSkeleton(userId, jointType1, jointPos1);
  confidence = context.getJointPositionSkeleton(userId, jointType2, jointPos2);

  stroke(255, 0, 0, confidence * 200 + 55);
  line(jointPos1.x, jointPos1.y, jointPos1.z, 
  jointPos2.x, jointPos2.y, jointPos2.z);

  drawJointOrientation(userId, jointType1, jointPos1, 50);
}

void drawJointOrientation(int userId, int jointType, PVector pos, float length)
{
  // draw the joint orientation  
  PMatrix3D  orientation = new PMatrix3D();
  float confidence = context.getJointOrientationSkeleton(userId, jointType, orientation);
  if (confidence < 0.001f) 
    // nothing to draw, orientation data is useless
    return;

  pushMatrix();
  translate(pos.x, pos.y, pos.z);

  // set the local coordsys
  applyMatrix(orientation);

  // coordsys lines are 100mm long
  // x - r
  stroke(255, 0, 0, confidence * 200 + 55);
  line(0, 0, 0, 
  length, 0, 0);
  // y - g
  stroke(0, 255, 0, confidence * 200 + 55);
  line(0, 0, 0, 
  0, length, 0);
  // z - b    
  stroke(0, 0, 255, confidence * 200 + 55);
  line(0, 0, 0, 
  0, 0, length);
  popMatrix();
}
// -----------------------------------------------------------------
// Music Class
void makeMusic() {
}



// -----------------------------------------------------------------
// SimpleOpenNI user events

void onNewUser(SimpleOpenNI curContext, int userId)
{
  println("onNewUser - userId: " + userId);
  println("\tstart tracking skeleton");

  context.startTrackingSkeleton(userId);
}

void onLostUser(SimpleOpenNI curContext, int userId)
{
  println("onLostUser - userId: " + userId);
}

void onVisibleUser(SimpleOpenNI curContext, int userId)
{
  //println("onVisibleUser - userId: " + userId);
}


// -----------------------------------------------------------------
// Keyboard events

void keyPressed()
{
  switch(key)
  {
  case ' ':
    context.setMirror(!context.mirror());
    break;
  }

  switch(keyCode)
  {
  case LEFT:
    rotY += 0.1f;
    break;
  case RIGHT:
    // zoom out
    rotY -= 0.1f;
    break;
  case UP:
    if (keyEvent.isShiftDown())
      zoomF += 0.01f;
    else
      rotX += 0.1f;
    break;
  case DOWN:
    if (keyEvent.isShiftDown())
    {
      zoomF -= 0.01f;
      if (zoomF < 0.01)
        zoomF = 0.01;
    } else
      rotX -= 0.1f;
    break;
  }
}

void getBodyDirection(int userId, PVector centerPoint, PVector dir)
{
  PVector jointL = new PVector();
  PVector jointH = new PVector();
  PVector jointR = new PVector();
  float  confidence;

  // draw the joint position
  confidence = context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, jointL);
  confidence = context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_HEAD, jointH);
  confidence = context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, jointR);

  // take the neck as the center point
  confidence = context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_NECK, centerPoint);

  /*  // manually calc the centerPoint
   PVector shoulderDist = PVector.sub(jointL,jointR);
   centerPoint.set(PVector.mult(shoulderDist,.5));
   centerPoint.add(jointR);
   */

  PVector up = PVector.sub(jointH, centerPoint);
  PVector left = PVector.sub(jointR, centerPoint);

  dir.set(up.cross(left));
  dir.normalize();
}

