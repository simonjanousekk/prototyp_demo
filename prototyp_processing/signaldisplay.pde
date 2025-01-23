

class SignalDisplay {

  SineWave sinePlayer, sineGame;
  float baseIncrement = 0.05;
  PVector bandConstrain = new PVector(0.1, 0.6); // min max
  PVector ampConstrain = new PVector(30, screenSize / 2 - screen1Border); // min max

  float interference = 0;
  boolean sineGameSet = false;


  SignalDisplay() {
    //randomizeSineGame();
    requestPotValues();


    sinePlayer = new SineWave(primary, primaryLight);
    sineGame = new SineWave(white, gray);
  }

  void update() {
    if (!sineGameSet && sinePlayer.desAmp != 0 && sinePlayer.desBand != 0) { // this is fucking piss but i cannot solve for delay that arduino midi brings.
      sineGame.desAmp = sinePlayer.desAmp;
      sineGame.desBand = sinePlayer.desBand;
      sineGameSet = true;
    }

    sinePlayer.update();
    sineGame.update();

    float ampTolerance = 5;
    float bandTolerance =.03;

    float pAmp = sinePlayer.amp;
    float pBand = sinePlayer.band;
    float gAmp = sineGame.amp;
    float gBand = sineGame.band;

    if (isCloseEnough(pAmp, gAmp, ampTolerance) && isCloseEnough(pBand, gBand, bandTolerance)) {
      //sinePlayer.col = white;
      sinePlayer.isRight = true;
      interference = 0;
    } else {
      sinePlayer.isRight = false;

      // Calculate normalized difference
      float ampDiff = max(0, abs(pAmp - gAmp) - ampTolerance) / (ampConstrain.y - ampConstrain.x);
      float bandDiff = max(0, abs(pBand - gBand) - bandTolerance) / (bandConstrain.y - bandConstrain.x);

      // Combine differences, capped at 1
      interference = min(ampDiff + bandDiff, 1);
    }
  }

  void randomizeSineGame() {
    sineGame.desBand = random(bandConstrain.x, bandConstrain.y);
    sineGame.desAmp = random(ampConstrain.x, ampConstrain.y);
  }

  void display() {

    push();
    translate(screen1Center.x, screen1Center.y);
    fill(0);
    rectMode(CENTER);
    rect(0, 0, screenSize, screenSize);


    stroke(gray);
    line(0, -screenSize / 2, 0, screenSize / 2);
    line( -screenSize / 2, 0, screenSize / 2, 0);


    int step = screenSize / 20;
    int stepLineL = 5;
    for (int i = -screenHalf + step; i <= screenHalf - step; i += step) {
      line( -stepLineL, i, stepLineL, i);
      line(i, -stepLineL, i, stepLineL);
      for (int j = -screenHalf + step; j <= screenHalf - step; j += step) {
        point(i, j);
      }
    }




    sineGame.display();

    sinePlayer.display();

    pop();
  }
}



class SineWave {
  PVector origin = new PVector(screen1Center.x, screen1Center.y);
  PVector pos;
  color col, col2;
  float ang = 0;
  float band, amp;
  float desBand, desAmp;
  int strokeWeight = 2;
  boolean isRight = false;

  SineWave(int c, int c2) {
    this(c, c2, 0, 0);
  }

  SineWave(int c, int c2, float a, float b) {
    col = c;
    col2 = c2;
    band = b;
    amp = a;
  }

  void update() {
    ang += signalDisplay.baseIncrement;
    pos = new PVector(0, map(sin(ang), -1, 1, -amp, amp));

    band += (desBand - band) *.1;
    amp += (desAmp - amp) *.1;
  }


  void display() {
    stroke(isRight ? col : col2);
    strokeWeight(1);
    line( -screenSize / 2, amp, screenSize / 2, amp);
    line( -screenSize / 2, -amp, screenSize / 2, -amp);

    fill(col);
    noStroke();
    circle(pos.x, pos.y, 5);


    noFill();
    strokeWeight(isRight ? 4 : 2);
    stroke(col);

    beginShape();
    float a = ang;
    for (int i = 0; i < screenSize / 2 + 20; i += 10) {
      curveVertex(i, map(sin(a), -1, 1, -amp, amp));
      a += band;
    }
    endShape();

    beginShape();
    float b = ang;
    for (float i = 0; i > - screenSize / 2 - 20; i -= 10) {
      curveVertex(i, map(sin(b), -1, 1, -amp, amp));
      b -= band;
    }
    endShape();



    //for (float i = 0; i < TWO_PI; i += 0.01) {
    //  circle(i*10, map(sin(i), -1, 1, -screenHalf-screen1Border, screenHalf-screen1Border), 2);
    //}
  }
}
