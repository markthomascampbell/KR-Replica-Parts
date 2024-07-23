//Board: Arduino MBed OS RP2040 Boards -> Raspberry Pi Pico

// Library Includes
//#include <Adafruit_NeoPixel.h>
#include <FastLED.h>

//#define debug
// Definition variables

// Audio settings
const int audioPin = 26;                                                                  // Audio input pin
int audioValue = 0;                                                                       // PWM value read from ADC on audioPin
int prevAudioValue = 0;                                                                   // Previous audioValue reading to use as comp in increasing or decreasing VU lights

// LED Settings
/*
const int sideLeftPin = 3;                                                                // Pin the side lights are on
const int sideRightPin = 18;                                                              // Pin the side lights are on
const int vuLeftPin = 12;                                                                 // Pin the vu left column are on
const int vuCenterPin = 14;                                                               // Pin the vu center column are on
const int vuRightPin = 15;                                                                // Pin the vu right column are on
const int napPin = 2;                                                                     // Pin Normal/Auto/Pursuit lights are on
const int ctdnPin = 13;
*/
vuPin = 12;
lightPin = 3;
const int sideLeftNum = 4;                                                                // Light count of the lights to either side of the VU
const int sideRightNum = 4;                                                               // Light count of the lights to either side of the VU
const int vuCenterNum = 16;                                                               // The center column of the vu Voicebox light count
const int vuSideNum = 16;
const int vuLeftNum = vuSideNum;                                                          // The left column of the vu Voicebox light count
const int vuRightNum = vuSideNum;                                                         // The right column of the vu Voicebox light count
const int vuMiddle = vuCenterNum / 2;
const int napNum = 9;
const int ctdnNum = 12;
    //CHSV Hues:  TopSides=(38,255,100), BotSides=(0,255,100), 
    //            vuKITT=(0,255,100)/vuKARR=(78,255,100), auto=(38,255,100), normal=(64,255,100), 
    //            PursuitWhite=(), PursuitPurple=(170,150,100), PursuitRed=(0,255,100)
    //CHSV Red = CHSV(0, 255, 255); CHSV Orange = CHSV(32, 255, 255); CHSV Yellow = CHSV(64, 255, 255);
    //CHSV KARRVB = CHSV(78, 255, 255); CHSV Green = CHSV(96, 255, 255); CHSV Aqua = CHSV(128, 255, 255); 
    //CHSV Blue = CHSV(160, 255, 255); CHSV Purple = CHSV(192, 255, 255); CHSV Pink = CHSV(224, 255, 255); 
    //CHSV Black = CHSV(0, 255, 0); CHSV Gold = CHSV(48, 255, 255); CHSV White = CHSV(0, 0, 255);
uint32_t sideHue[sideLeftNum] = { 38, 38, 0, 0 };                                         // Hue array for Side LEDs
uint32_t sideSat[sideLeftNum] = { 255, 255, 255, 255 };                                   // Sat array for Side LEDs
uint32_t napHue[napNum] = { 38, 38, 38, 64, 64, 64, 0, 0, 0 };                            // Hue array for N/A/P LEDs
uint32_t napSat[napNum] = { 255, 255, 255, 255, 255, 255, 255, 255, 255 };                // Sat array for N/A/P LEDs
uint32_t ctdnHue[ctdnNum] = { 0, 0, 0, 32, 32, 32, 64, 64, 64, 64, 64, 64 };              // Hue array for N/A/P LEDs
uint32_t ctdnSat[ctdnNum] = { 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255 };  // Sat array for N/A/P LEDs
int vuHue = 0;                                                                            // Hue for the bargraph LEDs
int vuSat = 255;                                                                          // Saturation for the bargraph LEDs
String vuMode = "KITT";
CRGBArray<ctdnNum> ctdnLEDs;                                                              // Defining the 
CRGBArray<napNum> napLEDs;                                                                // Defining the 
CRGBArray<sideLeftNum> sideLeftLEDs;                                                      // 
CRGBArray<sideRightNum> sideRightLEDs;                                                    // 
CRGBArray<vuLeftNum> vuLeftLEDs;                                                          // 
CRGBArray<vuCenterNum> vuCenterLEDs;                                                      // 
CRGBArray<vuRightNum> vuRightLEDs;                                                        // 
int hue = 170;
int sat = 150;
int bright = 40;                                                                          // 40 is dimmest without color compromise, 100 normal
int brightDefault = 40;                                                                   // 40 is dimmest without color compromise, 100 normal
int brightness = 0;                                                                       // Varliable for different brightness settings in VU bargraph

// Basic settings
int dropDelay = 5;                                                                        // Hold time before dropping the LEDs
float dropFactor = .92;                                                                   // Value for dropping the LEDs
int drop, dropTime;                                                                       //
float sensitivityFactor;
int sensitivityValue = 600;                                                              // 0 - 255, initial value
int maxSensitivity = 2 * 255;                                                             // let the 'volume' go up to 200%!
int minValue = 10;                                                                        // min analog input value
int maxValue = 350;                                                                       // max analog input value (0-1023 equals 0-5V)
int maxDisplaySegments = (vuCenterNum / 2) - 1;                                           //
int vuCenterValue = 0;                                                                    //
int vuSideValue = 0;                                                                      //
int prevVuCenterValue = 0;                                                                //
int prevVuSideValue = 0;                                                                  //


void interfaces() {
  if(Serial.available()){
    String cmd = Serial.readStringUntil('\n');
    if(cmd.equals("kitt")){ vuMode = "KITT"; vuHue = 0; }
    if(cmd.equals("karr")){ vuMode = "KARR"; vuHue = 78; }
  }
}


void startupSequence() {
  delay(1000);
  for (int i=0; i < (sideLeftNum); i++) { 
    for (int a=1; a < 4; a++) { ctdnLEDs[i*3+a] = CHSV(ctdnHue[i*3+a], ctdnSat[i*3+a], bright); }
    sideLeftLEDs[i] = CHSV(sideHue[i], sideSat[i], bright);
    sideRightLEDs[i] = CHSV(sideHue[i], sideSat[i], bright);
    FastLED.show();
    delay(500);
  }
  delay(1000);
  for ( int i=3; i < 6; i++) { napLEDs[i] = CHSV(napHue[i], napSat[i], bright); }
  FastLED.show();
}


void setSensitivityFactor() {
  //sensitivityValue_div_numOfSegments = sensitivityValue / numOfSegments;
  sensitivityFactor = ((float) sensitivityValue / 255 * (float) maxSensitivity / 255);
  //sensitivityFactor = 1.5;
}


void readValues() {
  audioValue = analogRead(audioPin);// * 3;
  //if ((audioValue > 40) && (audioValue < 200)); { audioValue = audioValue * 3; }
  if ((audioValue > 10) && (audioValue < 50)) { audioValue = audioValue * 4; }
  else if ((audioValue >= 50) && (audioValue < 100)) { audioValue = audioValue * 3; }
  else if ((audioValue >= 100) && (audioValue < 200)) { audioValue = audioValue * 2; }
  if (audioValue < prevAudioValue) {
    dropTime++;
    if (dropTime > dropDelay) {
      audioValue = prevAudioValue * dropFactor;
      dropTime = 0;
    }
    else
      audioValue = prevAudioValue;
  }
  vuCenterValue = map(audioValue * sensitivityFactor, minValue, maxValue, 0, maxDisplaySegments);
  //if (vuCenterValue > maxDisplaySegments) {vuCenterValue = maxDisplaySegments;}
  if (vuCenterValue < 4) { vuSideValue = 0;}
  else { vuSideValue = vuCenterValue - 4; }
  #if defined debug
    Serial.print("audioValue = "); Serial.print(audioValue);
    Serial.print("  sensitivityFactor = "); Serial.print(sensitivityFactor);
    Serial.print("  vuCenterValue = "); Serial.print(vuCenterValue);
    Serial.print("  vuSideValue = "); Serial.println(vuSideValue);
  #endif

  //sensitivityValue = analogRead(sensitivityPin);
  //sensitivityValue = map(sensitivityValue, 0, 1023, 0, 255);
  //setSensitivityFactor();
  //delay(5);
}


void vuKITT() {
  for (int i=vuMiddle; i < vuCenterValue - 1; i++) {                                          //## For all lit LEDs in Center Bargraph ##
    if (vuCenterValue - i == 3) { brightness = bright-(bright/4); }                       // If 3 lights from the end of lit LEDs, set brightness to 75%
    else if (vuCenterValue - i == 2) { brightness = bright-(bright/2); }                  // If 2 lights from the end of lit LEDs, set brightness to 50%
    else if (vuCenterValue - i == 1) { brightness = bright-((bright/4)*3); }              // If 1 light from the end of lit LEDs, set brightness to 25%
    else { brightness = bright; }                                                         // Otherwise set to default brightness
    vuCenterLEDs[i] = CHSV(vuHue, vuSat, brightness);                                     // Set LED on bottom half to defined brightness level
    vuCenterLEDs[(vuMiddle-(i-vuMiddle+1))] = CHSV(vuHue, vuSat, brightness);             // Do the same for top half
  }
  for (int i=prevVuCenterValue; i >= vuCenterValue + 1; i--) {                                //## For all unlit LEDs in Center Bargraph ##
    vuCenterLEDs[i] = CHSV(vuHue, vuSat, 0);                                              // Set unlit LEDs on bottom half to 0 brightness
    vuCenterLEDs[(vuMiddle-(i-vuMiddle))] = CHSV(vuHue, vuSat, 0);                        // Do the same for top half
  }
  for (int i=vuMiddle; i < vuSideValue - 1; i++) {                                            //## For all lit LEDs in Left & Right Side Bargraphs ##
    if (vuSideValue - i == 3) { brightness = bright-(bright/4); }                         // If 3 lights from the end of lit LEDs, set brightness to 75%
    else if (vuSideValue - i == 2) { brightness = bright-(bright/2); }                    // If 2 lights from the end of lit LEDs, set brightness to 50%
    else if (vuSideValue - i == 1) { brightness = bright-((bright/4)*3); }                // If 1 light from the end of lit LEDs, set brightness to 25%
    else { brightness = bright; }                                                         // Otherwise set to default brightness
    vuLeftLEDs[i] = CHSV(vuHue, vuSat, brightness);                                       // Left side: Set LED to full brightness for bottom half
    vuLeftLEDs[(vuMiddle-(i-vuMiddle +1))] = CHSV(vuHue, vuSat, brightness);              // Left side: Do the same for top half
    vuRightLEDs[i] = CHSV(vuHue, vuSat, brightness);                                      // Right side: Set LED to full brightness for bottom half
    vuRightLEDs[(vuMiddle-(i-vuMiddle+1))] = CHSV(vuHue, vuSat, brightness);              // Right side: Do the same for top half
  }
  for (int i=prevVuSideValue; i >= vuSideValue + 1; i--) {                                    //## For all unlit LEDs in Left & Right Side Bargraphs ##
    vuLeftLEDs[i] = CHSV(vuHue, vuSat, 0);                                                // Left side: Set unlit LEDs on bottom half to 0 brightness 
    vuLeftLEDs[(vuMiddle-(i-vuMiddle))] = CHSV(vuHue, vuSat, 0);                          // Left side: Do the same for top half
    vuRightLEDs[i] = CHSV(vuHue, vuSat, 0);                                               // Right side: Set unlit LEDs on bottom half to 0 brightness 
    vuRightLEDs[(vuMiddle-(i-vuMiddle))] = CHSV(vuHue, vuSat, 0);                         // Right side: Do the same for top half
  }
}


void vuKARR() {
  for (int i=vuMiddle; i < vuCenterValue - 1; i++) {                                          //## For all lit LEDs in Center Bargraph ##
    if (vuCenterValue - i == 3) { brightness = bright-(bright/4); }                       // If 3 lights from the end of lit LEDs, set brightness to 75%
    else if (vuCenterValue - i == 2) { brightness = bright-(bright/2); }                  // If 2 lights from the end of lit LEDs, set brightness to 50%
    else if (vuCenterValue - i == 1) { brightness = bright-((bright/4)*3); }              // If 1 light from the end of lit LEDs, set brightness to 25%
    else { brightness = bright; }                                                         // Otherwise set to default brightness
    vuCenterLEDs[i] = CHSV(vuHue, vuSat, brightness);                                     // Set LED on bottom half to defined brightness level
    vuCenterLEDs[(vuMiddle-(i-vuMiddle+1))] = CHSV(vuHue, vuSat, brightness);             // Do the same for top half
  }
  for (int i=prevVuCenterValue; i >= vuCenterValue + 1; i--) {                                //## For all unlit LEDs in Center Bargraph ##
    vuCenterLEDs[i] = CHSV(vuHue, vuSat, 0);                                              // Set unlit LEDs on bottom half to 0 brightness
    vuCenterLEDs[(vuMiddle-(i-vuMiddle))] = CHSV(vuHue, vuSat, 0);                        // Do the same for top half
  }
  for (int i=vuMiddle; i < vuSideValue - 1; i++) {                                            //## For all lit LEDs in Left & Right Side Bargraphs ##
    if (vuSideValue - i == 3) { brightness = bright-(bright/4); }                         // If 3 lights from the end of lit LEDs, set brightness to 75%
    else if (vuSideValue - i == 2) { brightness = bright-(bright/2); }                    // If 2 lights from the end of lit LEDs, set brightness to 50%
    else if (vuSideValue - i == 1) { brightness = bright-((bright/4)*3); }                // If 1 light from the end of lit LEDs, set brightness to 25%
    else { brightness = bright; }                                                         // Otherwise set to default brightness
    vuLeftLEDs[i - vuMiddle+1] = CHSV(vuHue, vuSat, brightness);                                       // Left side: Set LED to full brightness for bottom half
    //vuLeftLEDs[(vuMiddle-(i-vuMiddle +1))] = CHSV(vuHue, vuSat, brightness);              // Left side: Do the same for top half
    vuRightLEDs[i - vuMiddle+1] = CHSV(vuHue, vuSat, brightness);                                      // Right side: Set LED to full brightness for bottom half
    //vuRightLEDs[(vuMiddle-(i-vuMiddle+1))] = CHSV(vuHue, vuSat, brightness);              // Right side: Do the same for top half
  }
  for (int i=prevVuSideValue; i >= vuSideValue + 1; i--) {                                    //## For all unlit LEDs in Left & Right Side Bargraphs ##
    vuLeftLEDs[i - vuMiddle] = CHSV(vuHue, vuSat, 0);                                                // Left side: Set unlit LEDs on bottom half to 0 brightness 
    //vuLeftLEDs[(vuMiddle-(i-vuMiddle))] = CHSV(vuHue, vuSat, 0);                          // Left side: Do the same for top half
    vuRightLEDs[i - vuMiddle] = CHSV(vuHue, vuSat, 0);                                               // Right side: Set unlit LEDs on bottom half to 0 brightness 
    //vuRightLEDs[(vuMiddle-(i-vuMiddle))] = CHSV(vuHue, vuSat, 0);                         // Right side: Do the same for top half
  }
}


void drawValues() {
  //if(vuMode.equals("KITT")){ vuKITT(); }
  //if(vuMode.equals("KARR")){ vuKARR(); }
  vuKITT();
  //vuKARR();
  FastLED.show();
}


void storePrevValues() {
  prevAudioValue = audioValue;
  prevVuCenterValue = vuCenterValue;
  prevVuSideValue = vuSideValue;
}


void setup() {
  Serial.begin(115200);                         // Start a serial interface
  pinMode(audioPin, INPUT);                     // Define the audio port
  // Define LED Strips
  FastLED.addLeds<WS2812,ctdnPin,GRB>(ctdnLEDs,ctdnNum).setCorrection( TypicalSMD5050 );
  FastLED.addLeds<WS2812,napPin,GRB>(napLEDs,napNum).setCorrection( TypicalSMD5050 );
  FastLED.addLeds<WS2812,sideLeftPin,GRB>(sideLeftLEDs,sideLeftNum).setCorrection( TypicalSMD5050 );
  FastLED.addLeds<WS2812,sideRightPin,GRB>(sideRightLEDs,sideRightNum).setCorrection( TypicalSMD5050 );
  FastLED.addLeds<SK6812,vuLeftPin,GRB>(vuLeftLEDs,vuLeftNum).setCorrection( TypicalSMD5050 );
  FastLED.addLeds<SK6812,vuCenterPin,GRB>(vuCenterLEDs,vuCenterNum).setCorrection( TypicalSMD5050 );
  FastLED.addLeds<SK6812,vuRightPin,GRB>(vuRightLEDs,vuRightNum).setCorrection( TypicalSMD5050 ); 
  
  /*FastLED.addLeds<WS2811,vuLeftPin,GRB>(vuLeftLEDs,vuLeftNum).setCorrection( TypicalSMD5050 );
  FastLED.addLeds<WS2812,vuCenterPin,GRB>(vuCenterLEDs,vuCenterNum).setCorrection( TypicalSMD5050 );
  FastLED.addLeds<SK6812,vuRightPin,GRB>(vuRightLEDs,vuRightNum).setCorrection( TypicalSMD5050 ); */
  startupSequence();                            // Do the countdown sequence
  setSensitivityFactor();
}

void loop() {
  //interfaces();                                 // Interfaces with devices
  readValues();                                 // Read the audio port's analog value
  drawValues();                                 // Light up the VU LEDs based on the reading
  storePrevValues();                            // Save current values for next cycle
}
