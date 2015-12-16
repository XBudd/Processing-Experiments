/* Colin Budd
 * September 30, 2015
 * Cornell University
 * Based on: https://forum.processing.org/one/topic/help-needed-with-multiple-keywords-in-a-string-filtering-twitter-feeds.html
 */
 
String[] good= { "good", "wonderfull", "great" };
String[] bad = { "bad", "down", "shit" };
ArrayList <String> words = new ArrayList <String> ();
 
void setup() {
  size(400, 400);
  words.add("good");
  words.add("great");
  words.add("shit");
  words.add("bad");
  background(0);
  textAlign (CENTER);
  fill(255);
  textSize(20);
  text("today we feel:", width/2, height/2-100);
  smooth();
}
 
void draw() {
  int i = (frameCount % words.size());
  String word = words.get(i);
 
  if (compareWordToArray(word, good)) {
    fill(0, 255, 0);
    textSize(random(10, 50));
    text(word, random(width), random(height));
  }
 
  if (compareWordToArray(word, bad)) {
    fill(255, 0, 0);
    textSize(random(10, 50));
    text(word, random(width), random(height));
  }
}
 
boolean compareWordToArray(String word, String[] wordArray) {
  for (int i=0; i<wordArray.length; i++) {
    if (word.equals(wordArray[i])) return true;
  }
  return false;
}