/*
* Colin Budd
 * September 30, 2015
 * Cornell University
 */

import twitter4j.*;
import twitter4j.api.*;
import twitter4j.auth.*;
import twitter4j.conf.*;
import twitter4j.json.*;
import twitter4j.management.*;
import twitter4j.util.*;
import twitter4j.util.function.*;

import processing.net.*;
import java.util.Date;
import twitter4j.Status;
import twitter4j.Twitter;
import twitter4j.TwitterFactory;
import twitter4j.auth.AccessToken;
import twitter4j.conf.*;
import java.util.*; 
import twitter4j.*;
import java.util.ArrayList;
import java.util.Arrays; 

import java.io.IOException;

//ArrayLists for all words from tweets and fragments
ArrayList<String> words = new ArrayList<String>();
ArrayList<String> wordBits = new ArrayList<String>();
//Lists to check for words
String[] good= { "pretty", "best", "better",  "fantastic", "fabulous", "wins", "win", 
  "looking forward", "beautiful", "on point", "on spec", "nice", "big red", "good", "friend", 
  "friends", "bigred", "%23"+"breakfast", "friends", "excited", "exciting", "wonderful", "peaceful", 
  "fantastic", "gorgous", "loved", "perfect", "awesome", "love", "<3",  "amazing", "beautiful",
  "weekend", "happy", "great", "run", "shots", "sex", "fun", "better", "interesting", "healthy",
  "party", "night", "ample", "amazed", "rainbow", "well", "won", "congrats", "congratulations", "dating", "outside", 
  "incredible", "pumped", "excited", "can't wait", "surreal", "win", "winning", "blessed", "gobigred", "cool", "great",
  "god", "God", "great", "loved", "home", "loving", "loved", "congrats", "Congrats", "congratulations", "hopeful", "groovy", "cool", "favorite", "warm", "treat",
  "miricale", "dope", "sexy", "perfect", "fantastic", "lucky", "sweet", "sunny", "winner", "running", "yum", "fest", "bff",
  "delicous", "dream", "won", "kiss", "hug", "engaged", "wedding", "Saturday", "Friday", "mixer", "social", "joy", "joyful", "realax", "realaxed", "peace", "peaceful", "wonderful", "helping", "high",
  "super", "stoked", "gorgeous", "loving", "helpful", "neat", "excited", "pretty", "hot", "cool", "looking forward", "hope", "unwind",
  "praying", "pray", "sex", "unbelievable", "jolly", "thank", "thanks", "thankful", "Thank", "cool",  "ran", "free", "babe", "cutie", "cute", "bliss", "heaven", "respect", "community",
  "look forward", "Sun", "can't wait", "play", "Netflix", "tv", "netflix", "chill", "hanging", "concert", "survived", "attractive",
"clean", "fresh", "safe", "creative", "playing", "family", "baby", "sun", "shine", "team", "wondering", "thinking", "reading", "start",
"beginning", "romantic", "lovely", "best", "congrats", "golden", "prime", "festive", "playful",  "enjoyed"};

String[] bad = { "kill", "hell", "help", "stupid", "harsh", "crash", "crashes", "bored", "loser", "wrecked", "miss", "lonely", "sad", "fuck", "broke", "lonely", "alone", "emotional",
  "depressed", "damn", "problems", "bad", "down", "end", "shit", "hate", "rain", "raining", "miss you", "fight", "fighting", "hate", 
  "missing you", "miss her", "dead", "RIP", "rainy", "rainyday", "kill me", "prelims", "fab", "gay", "sad", "gun", "drunk", "garbage",
  "violent", "fail", "failed", "quit", "broke", "drunk", "denial", "killed", "no", "worst", "can't", "fat", "obese", "fail", "quit", 
  "sick", "fuck", "fucker", "dipshit", "worst", "wrong", "hateful", "drowning", "tired", "depressing", "failed", "terrible", "borken",
  "depressed", "moody", "dreary", "ugly", "#vomit", "vomit", "puke", "%23vomit", "deadline", "poor", "stuck", "study", "broken", "sucks", 
  "sick", "hurts", "hurt", "dick", "pussy", "fag", "geed", "painful", "pain", "awful", "die", "ass", "studying", "disgusting", "quitting", "failing", "disaster", "sucked",
  "disgusted", "sorry", "late", "rape", "raped", "hospital", "studied", "vomit", "poison", "ill", "don't", "no", "awful", "failed", 
  "lost", "mad", "over", "rough", "denial", "whore", "slut", "bitch", "cunt", "pussy", "problem!", "loser", "tinder", "lonely", "fucked", "sad", "violent",
 "horrible", "horrid", "hard", "hurt", "#studying", "fear", "fearing", "afraid", "worrying", "worry", "lame", "dumb", "test", "prelims",
 "prelim", "exam", "exams", "lies", "lied", "cancer", "false", "annoying", "annoyed", "yourproblem", "rains", "snow", "snows", "winter", 
 "cold", "sinking", "working", "work", "deadline", "prelim", "worried", "ruin", "ruining", "sober", "afraid", "work", "no sleep", 
 "#working", "end", "bad habits", "disobedience"};
  
String[] locationPop = {"Garrett", "Garett", "#newyork", "nyc", "#nyc", "global", "Elizabeth", "Ezra", "Ithaca", "Cornell", "NYC", "Olin", "Slope", "library", "mann", "uris", "lab", 
  "New York", "Cornell", "%23Cornell", "cornell", "%23cornell", "#Cornell", "CTB", "campus", "west", "college town", "#BigRed"};
StringList goodFound = new StringList();
StringList badFound = new StringList();

String msg, medias, y, x;
String[] imgUrl = new String[2000];
String[] profImg = new String[2000];
PImage webImg, profImages;

int interval = 5000; // 
int time;


void setup() {
  //Set the size of the stage, and the background to black.
  size(1420, 780);
  background(0);
  smooth();
  frameRate(20);
  time = millis();

  //Credentials
  ConfigurationBuilder cb = new ConfigurationBuilder();
  cb.setDebugEnabled(true);
  cb.setOAuthConsumerKey("***");
  cb.setOAuthConsumerSecret("***");
  cb.setOAuthAccessToken("***");
  cb.setOAuthAccessTokenSecret("***");
  TwitterFactory tf = new TwitterFactory(cb.build());
  Twitter twitter = tf.getInstance();
  //Make the twitter object and prepare the query
  Query query = new Query("%23Cornell");
  query.count(40000);

  //Try making the query request.
  try {

    QueryResult result = twitter.search(query);
    ArrayList tweets = (ArrayList) result.getTweets();

    for (int i = 0; i < tweets.size(); i++) {
      int x=i;
      Status t = (Status)tweets.get(i);
      User u=(User) t.getUser();
      String user = u.getName();
      String userPic = u.getProfileImageURL();
      msg = t.getText();
      Date d = t.getCreatedAt();
      GeoLocation loc = t.getGeoLocation();
      String userLoc = u.getLocation();
      String location = userLoc;
      if (loc == null) {
        location = userLoc;
      } else {
        location = ""+loc;
      }

      //println("Tweet by " + user + " at " + d + ": " + msg);
      profImg[i] = (userPic);

      // Find Images
      MediaEntity[] medias = new MediaEntity[1000];
      medias = t.getMediaEntities();

      for (MediaEntity mediaEntity : medias) {
        if (mediaEntity.getMediaURL().contains("jpg") || mediaEntity.getMediaURL().contains("png") || mediaEntity.getMediaURL().contains("gif") || mediaEntity.getMediaURL().contains("jpeg")) {
          imgUrl[x] = (mediaEntity.getMediaURL());
        }
        System.out.println(mediaEntity.getType() + " "+ i + ": " + mediaEntity.getMediaURL());
      }

      //Break the tweet into words
      String[] input = msg.split(" ");
      for (int j = 0; j < input.length; j++) {
        //Put each word into the words ArrayList

        //println(input[j]);
        wordBits.add(input[j]); //Use for single words
        words.add(msg);
        words.add(location);
        words.add(" ");
      }
    }
  }
  catch (TwitterException te) {
    println("Couldn't connect: " + te);
  };

  println("Number of tweets: " + words.size());
}

void draw() {
  //Draw a faint black rectangle over what is currently on the stage so it fades over time.
  fill(0, 12);
  rect(0, 0, width, height);

  int i = ((frameCount % words.size()));
  String word = words.get(i);
  word = word.replaceAll("[^A-Za-z0-9()\\[\\]]", "");

  int a = (frameCount % wordBits.size());
  String wordPop = wordBits.get(a);
  //////////////Word Filter//////////////
  try {

    for (int j = 0; j < wordPop.length(); j++) {
      if (compareWordToArray(wordPop, good)) {
        fill(0, 255, 0);
        if (wordBits.get(i).length() > 0) {
          text(wordBits.get(i), random(width), random(height));
          goodFound.append(wordBits.get(i));
        }
      }

      if (compareWordToArray(wordPop, bad)) {
        fill(255, 0, 0);
        if (wordBits.get(i).length() > 0) {
          text(wordBits.get(i), random(width), random(height));
          badFound.append(wordBits.get(i));
        }
      }

      if (compareWordToArray(wordPop, locationPop)) {
        fill(255);
        if (wordBits.get(i).length() > 0) {
          text(wordBits.get(i), random(width), random(height));
        }
      }
    }
    int rand = (int) random(0, goodFound.size());
    int rand1 = (int) random(0, badFound.size());
    int rand2 = (int) random(0, badFound.size());
    if (goodFound.get(rand).length() > 0) {
      fill(0, 255, 0);
      text(goodFound.get(rand), random(width), random(height));
    }
    if (badFound.get(rand1).length() > 0) {
      fill(255, 0, 0);
      text(badFound.get(rand1), random(width), random(height));
    }

    if (badFound.get(rand2).length() > 0) {
      fill(255, 0, 0);
      text(badFound.get(rand2), random(width), random(height));
    }
  } 

  catch (IndexOutOfBoundsException b) {
    println("Out of bounds, player");
  }

  // End Word Filter
  int k = 0;
  String[] imgList = new String[2000];
  for (int j = 0; j < imgUrl.length; j++) {
    if (imgUrl[j] != null) {
      imgList[k] = imgUrl[j];
      k++;
    }
  }
  int p = (int) random(0, 100);
  if (millis() - time > interval) {
    if (imgList[p] != null) {
      webImg = loadImage(imgList[p]);
      image(webImg, random(width/2), random(height/2));

      time = millis();
    }
  }

  int randImg = (int) random(0, 100);
  try{
  if (profImg[randImg] != null) {
    profImages = loadImage(profImg[randImg]);
    image(profImages, random(width), random(height));
  }
  } catch (NullPointerException x){
  }

  //Put it somewhere random on the stage, with a random size and colour
  fill(255);//,random(50,150));
  textAlign(CENTER);
  textSize(random(10, 30));
  try {
    if (words.get(i).length() == 0) {
      //println("problem! " + words.get(i) + " has " + words.get(i).length() + " chars");
      text(words.get(i+1), random(width), random(height));
    } else {
      text(words.get(i), random(width), random(height));
    }
  } 
  catch (IllegalArgumentException e) {
    println("Zero length string dude");
  }
  /*
  fill(0);
   rect(0, height-50, width, height);
   
   int txtX = width;
   int txtY = height/2;
   fill(255);
   textSize(20);
   if (txtX < 0) {
   text(wordBits.get(i), txtX + textWidth(wordBits.get(i)) + 50, txtY);
   }
   
   if (txtX <= -textWidth(wordBits.get(i))){
   txtX = txtX + (int)textWidth(wordBits.get(i)) + 50;
   }
   
   text(wordBits.get(i), txtX, txtY);
   txtX--;
   */
}

//Class for Comparison
boolean compareWordToArray(String word, String[] wordArray) {
  for (int i=0; i<wordArray.length; i++) {
    //println(word); //Problem - "word" is a full block of text! must split up before processing!
    if (word.equals(wordArray[i])) return true;
  }
  return false;
}