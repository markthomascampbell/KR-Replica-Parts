#include <FastLED.h>                    // Library that controls the LEDs
#include <SPI.h>                        // Library for SPI devices like the rotary encoder
//#include <Adafruit_VS1053.h>            // Library for the Music Maker
//#include <SD.h>                         // Library to enable the SD card
//#include <EEPROM.h>                     // Library to read/write to Arduino internal EEPROM
// https://forum.arduino.cc/t/cylon-larsen-scanner-fastled-sequence/660006/7
// https://create.arduino.cc/projecthub/electropeak/pir-motion-sensor-how-to-use-pirs-w-arduino-raspberry-pi-18d7fa
// https://docs.arduino.cc/built-in-examples/digital/Debounce
// https://www.arduino.cc/reference/en/language/variables/data-types/string/functions/equals/
//# Raspberry Pi Pico settings
//# https://github.com/earlephilhower/arduino-pico/releases/download/global/package_rp2040_index.json
// These are the pins used for the music maker shield
//#define SHIELD_RESET -1                 // VS1053 reset pin (unused!)
//const uint8_t SHIELD_CS = 7;            // VS1053 chip select pin (output)
//const uint8_t SHIELD_DCS = 6;           // VS1053 Data/command select pin (output)
//const uint8_t CARDCS = 4;               // VS1053 Card chip select pin
//const uint8_t DREQ = 3;                 // Data request Int pin, see http://arduino.cc/en/Reference/attachInterrupt
//const uint8_t SHIELD_MOSI = 11;         // Master Out, Slave In
//const uint8_t SHIELD_MISO = 12;         // Master In, Slave Out
//const uint8_t SHIELD_SCK = 13;          // Serial Clock pin
//### Rotary Encoder pins
const uint8_t RE1_CLK = 18;             // Rotary Encoder's CLK pin, each click in either direction, output cycles HIGH then LOW
const uint8_t RE1_DT = 22;              // Rotary Encoder's DT pin, same as CLK, but lags by 90 deg phase shift, determines rot. dir.
const uint8_t RE1_SW = 19;              // Rotary Encoder's SW pin, push button built into dial that goes LOW when pushed
//### Pins, physical defs
const uint8_t dataPin = 2;              // Data pin on Arduino for LED Strip, default 2
const uint8_t mdataPin = 15;            // Data pin on Arduino for LED Strip, default 3
const uint8_t ledPin = 25;              // the number of the LED pin, 25 on the Pico
const uint8_t pwrPin = 8;               // Pin for the Power button
const uint8_t pirPin = 24;              // Output pin of PIR/motion sensor
//### Default Settings
const uint8_t volMin = 255;             // Minimum volume setting; 0-255, lower is louder
const uint8_t volMax = 0;               // Maximum volume setting; 0-255, higher is softer
const uint8_t numLEDs = 20;              // How many leds in your strip?  Default 8
const uint8_t numArrays = 2;            // Number of LEDs on different pins
const uint8_t tail = 7;                 // Darkens LEDs by n/256th of value, higher = faster, 4-7 is good
const uint8_t tailSpeed = 3;            // How frequently fadetoblackby runs in (milliseconds), higher = slower, 3 is default
const int angleStart = -1;              // -1 or 6 to start from left or from right
const int soulAngleStart = 6;           // Inverse of angleStart for use in SoulSurvivor mode
const uint8_t brightDefault = 255;      // LED Brightness default
const uint8_t rbSpeedDefault = 10;      // Higher is faster.  Rainbow mode default color change speed
const uint8_t rbSpeedMax = 30;          // Upper limit set for color change speed
const uint8_t rbSpeedMin = 1;           // Lower limit set for color change speed
const uint16_t scanSpeedDefault = 120;  // Lower is faster.  Usable range 40-500, Default 120
const uint16_t scanSpeedMax = 20;       // Upper speed limit set for scan speed
const uint16_t scanSpeedMin = 600;      // Lower speed limit set for scan speed
//#define Red CRGB::Red; #define Orange CRGB::Orange; #define Yellow CRGB::Yellow; #define Green CRGB::Green; #define Blue CRGB::Blue
//#define Purple CRGB::Purple; #define White CRGB::White; #define Black CRGB::Black; #define Gold CRGB::Gold;
CHSV Red = CHSV(0, 255, 255); CHSV Orange = CHSV(32, 255, 255); CHSV Yellow = CHSV(64, 255, 255); CHSV KARR = CHSV(35, 255, 255);
CHSV KARRVB = CHSV(78, 255, 255); CHSV Green = CHSV(96, 255, 255); CHSV Aqua = CHSV(128, 255, 255); 
CHSV Blue = CHSV(160, 255, 255); CHSV Purple = CHSV(192, 255, 255); CHSV Pink = CHSV(224, 255, 255); 
CHSV Black = CHSV(0, 255, 0); CHSV Gold = CHSV(48, 255, 255); CHSV White = CHSV(0, 0, 255);
//#define White CRGB::White 
//CRGB USA[] = { CRGB::Red, CRGB::White, CRGB::Blue }; // call with USA[i++] to loop through
CHSV color = Red;
//CRGB color = Red;                       // http://fastled.io/docs/3.1/pixeltypes_8h_source.html line 590 for list
CRGBArray<numLEDs> leds[numArrays];
//#define color CHSV(0, 255, 255)
//String color = "CRGB::Red";
bool allOn = true;                      // Starts all on
bool scannerOn = false;                 // Lights run while scannerOn = true, and should be false if allOn = true
bool soulOn = false;                    // Enables Soul Survivor mode when enabled
bool policeOn = false;                  // Flashing red and blue lights when enabled *USE WITH CAUTION!*
bool mmPresent = false;                 // Indicates presence of Music Maker, set to false until proven true
bool motionOn = false;                   // Enable or disable the motion sensor
bool playSound = true;                  // When enabled, play sound
bool rainbowOn = false;                 // Enables constantly rotating color wheel 
bool turnOff = !allOn;                  // When enabled, function proceeds to shut down
bool USAOn = false;
bool verb = true;                       // Verbosity true/false
char * soundFile = "scan01.mp3";        // Default scanner sound file
int angle = angleStart;                 // set angle to the starting position
int soulAngle = soulAngleStart;         // set the 2nd angle to the starting position
int angleStartPos;                      // Setting start/end position for scanner
int buttonState;                        // the current reading from the input pin
int fxcycle = 0;                        // counter for the number of scan sounds in a row
int lastButtonState = LOW;              // the previous reading from the input pin
int ledState = HIGH;                    // the current state of the onboard LED
int rbSpeed = rbSpeedDefault;           // Rainbow mode color change speed
int RE1_stateCLK;                       // the state of the CLK pin on RE1
int RE1_lastStateCLK;                   // the previous state of the RE1 CLK pin, used to track rotation
int RE1_stateSW;                        // the state of the pushbutton switch on RE1
uint16_t scanSpeed = scanSpeedDefault;  // Lower is faster.  Usable range 40-500, Default 100
uint8_t usac = 0;                       // USA array counter
uint8_t randNum;                        // random number generator variable
uint8_t pirStat = 0;                    // the state of the PIR sensor
uint8_t vol = 20;                       // Volume for the music maker 0-255, lower is louder!
uint8_t hue = 0;                        // LED hue
uint8_t sat = 255;                      // LED saturation
uint8_t bright = brightDefault;         // LED Brightness - 40 indoors, 84 night, 255 full
String cname = "Red";                   // "pretty" name to announce color in serial
String motionStatus;                    // Human readable status of motion detect for serial output
String scanStatus;                      // Human readable status of scanner for serial output
String soundStatus;                     // Human readable status of sound for serial output
//unsigned long lastDT = 0;               // lastDebounceTime - the last time the output pin was toggled
unsigned long dtDelay = 75;             // the debounce time; increase if output flickers
unsigned long lastButtonPress = 0;      // the last time in millis that the button was pressed
unsigned long motionDelay = 50;         // a delay in millis to smooth out the motion sensor
unsigned long motionDelayOff = 10000;   // time in millis from the last detected motion before turning off scanner
unsigned long lastMotion = 0;           // reference variable to mark the last time motion was detected

//Adafruit_VS1053_FilePlayer musicPlayer = Adafruit_VS1053_FilePlayer(SHIELD_RESET, SHIELD_CS, SHIELD_DCS, DREQ, CARDCS);



void interfaces() {
  if (motionOn) motion();
  if(Serial.available()){
    String cmd = Serial.readStringUntil('\n');
    if(cmd.equals("status") || cmd.equals("s")){ 
      if(scannerOn == true) {scanStatus = "active";} else {scanStatus = "not active";}
      if(mmPresent == true) {soundStatus = "active";} else {soundStatus = "not active";}
      if(motionOn == true) {motionStatus = "active";} else {motionStatus = "not active";}
      Serial.println(F("*************************"));
      Serial.print(F("Scanner ")); Serial.println(scanStatus);
      Serial.print(F("Sound is ")); Serial.println(soundStatus);
      Serial.print(F("Motion detect is ")); Serial.println(motionStatus);
      Serial.print(F("  Color: ")); Serial.println(cname);
      Serial.print(F("  Brightness: ")); Serial.println(bright);
      Serial.print(F("  Speed: ")); Serial.println(scanSpeed);
      Serial.println(F("*************************"));
    }
    //if(cmd.equals("ls") || cmd.equals("dir")) { printDirectory(SD.open("/"), 1); }
    if(cmd.equals("all on") || cmd.equals("a") || cmd.equals("3")) { allOn = true; }
    if(cmd.equals("on") || cmd.equals("1")){ turnOff = false; motionOn = false; soulOn = false; soulAngle = -1; turnOnOff(); }
    if(cmd.equals("off") || cmd.equals("0")){ policeOn = false; turnOff = true; turnOnOff(); }
    if(cmd.equals("soul") || cmd.equals("2")){ policeOn = false; soulOn = true; }
    //if(cmd.equals("usa") || cmd.equals("4")){ cname = "USA"; colorCh(USA); }
    if(cmd.equals("police on") || cmd.equals("p") || cmd.equals("9")) { policeOn = true; }
    if(cmd.equals("bright max") || cmd.equals("B")) { brightness(255); }
    if(cmd.equals("bright night") || cmd.equals("b")) { brightness(84); }
    if(cmd.equals("bright min") || cmd.equals("i")) { brightness(40); }
    if(cmd.equals("color rainbow") || cmd.equals("7")) { cname = "Rainbow"; hue = 0; colorCh(Red); }
    if(cmd.equals("color red")) { cname = "Red"; colorCh(Red); }
    if(cmd.equals("color orange")) { cname = "Orange"; colorCh(Orange); }
    if(cmd.equals("color yellow")) { cname = "Yellow"; colorCh(Yellow); }
    if(cmd.equals("color KARR")) { cname = "KARR"; colorCh(KARR); }
    if(cmd.equals("color KARRVB")) { cname = "KARRVB"; colorCh(KARRVB); }
    if(cmd.equals("color gold")) { cname = "Gold"; colorCh(Gold); }
    if(cmd.equals("color green")) { cname = "Green"; colorCh(Green); }
    if(cmd.equals("color aqua")) { cname = "Aqua"; colorCh(Aqua); }
    if(cmd.equals("color blue")) { cname = "Blue"; colorCh(Blue); }
    if(cmd.equals("color purple")) { cname = "Purple"; colorCh(Purple); }
    if(cmd.equals("color pink")) { cname = "Pink"; colorCh(Pink); }
    if(cmd.equals("color white")) { cname = "White"; colorCh(White); }
    if(cmd.equals("*")) { rbSpeedUpDown(true); }
    if(cmd.equals("/")) { rbSpeedUpDown(false); }
    if(cmd.equals("+")) { speedUpDown(true); }
    if(cmd.equals("-")) { speedUpDown(false); }
    /*if(cmd.equals("sound") || cmd.equals("f")) { soundfx(soundFile); }
    if(cmd.equals("sound kimberly") || cmd.equals("kim")) { soundfx("kimberly.mp3"); }
    if(cmd.equals("sound wonderful") || cmd.equals("wonderful")) { soundfx("wonderfl.mp3"); }
    if(cmd.equals("sound cordial") || cmd.equals("cordial")) { soundfx("cordial.mp3"); }
    if(cmd.equals("sound pilot") || cmd.equals("pilot")) { soundfx("scanplt.mp3"); }
    if(cmd.equals("sound karr") || cmd.equals("karr")) { soundfx("scankarr.mp3"); }
    if(cmd.equals("sound knerd") || cmd.equals("knerd")) { soundfx("scannerd.mp3"); }
    if(cmd.equals("V")) { volUpDown(true); }
    if(cmd.equals("v")) { volUpDown(false); } */
    if(cmd.equals("motion on") || cmd.equals("5")) { Serial.println(F("Turning on motion sensing")); motionOn = true; }
    if(cmd.equals("motion off")) { Serial.println(F("Turning off motion sensing")); motionOn = false; }
    if(cmd.equals("default speed") || cmd.equals("d")) { 
      scanSpeed = scanSpeedDefault; 
      Serial.print(F("Setting speed to default: ")); Serial.println(scanSpeed);
    }
    if(cmd.equals("verbose")) { Serial.println(F("Turning on verbosity")); verb = true; }
    if(cmd.equals("silent")) { Serial.println(F("Turning off verbosity")); verb = false; }
    if(cmd.equals("help") || cmd.equals("h") || cmd.equals("?")){
      Serial.println(F("Commands:")); Serial.println(F("  0 / Off - Off")); Serial.println(F("  1 / On - On"));
      Serial.println(F("  + - Increase Scan Speed")); Serial.println(F("  - - Decrease Scan Speed"));
      Serial.println(F("  a / all on - All On")); Serial.println(F("  B / bright max - Max Brightness"));
      Serial.println(F("  b / bright min - 1/3 Brightness")); Serial.println(F("  i / indoor Brightness"));
      Serial.println(F("  d / default speed - Default Scan Speed")); 
      Serial.println(F("  f / sound - activate scanner sound")); Serial.println(F("  h / help - help menu"));
    }
  }
  
 /*int pwrReading = digitalRead(pwrPin);
  if (pwrReading != lastButtonState) { lastDT = millis(); }
  if ((millis() - lastDT) > dtDelay) {
    if (pwrReading != buttonState) {
      buttonState = pwrReading;
      if (buttonState = HIGH) {
        ledState = !ledState;
        digitalWrite(ledPin, ledState);
        turnOff = !turnOff;   //toggle turnOff state when button pressed 
        Serial.print("Button pressed, LED state is ");
        Serial.print(ledState);
        Serial.print(" and turnOff state is ");
        Serial.println(turnOff);
      }
    }
  }
  if (turnOff == false) {scannerOn = true; angle = angleStart; digitalWrite(ledPin, ledState);}
  lastButtonState = pwrReading; */
}


void updateEncoder() { //https://lastminuteengineers.com/rotary-encoder-arduino-tutorial/amp/
  RE1_stateSW = digitalRead(RE1_SW);
  if (RE1_stateSW == LOW) {
    if (millis() - lastButtonPress > dtDelay ) {
      if (turnOff == false) { turnOff = true; } else if (turnOff == true) { turnOff = false; }
      turnOnOff();
    }
    lastButtonPress = millis();
  }
  RE1_stateCLK = digitalRead(RE1_CLK);          // Read the current state of RE1_CLK
  // If last & current state of CLK are different, then pulse occurred, react to only 1 state change to avoid double count
  //if (RE1_stateCLK != RE1_lastStateCLK && RE1_stateCLK == 1) {
  if (RE1_stateCLK != RE1_lastStateCLK) {
    if (digitalRead(RE1_DT) != RE1_stateCLK) {  // If DT state is different than CLK, then encoder is rotating CCW
      speedUpDown(true);
    } else {  // Encoder is rotating CW
      speedUpDown(false);
    }
  }
}


/*void printDirectory(File dir, int numTabs) {
  if (mmPresent == true) {
    while(true) {
      File entry = dir.openNextFile();
      if (! entry) { break; }
      for (uint8_t i=0; i<numTabs; i++) { Serial.print('\t'); }
      Serial.print(entry.name());
      if (entry.isDirectory()) { Serial.println("/"); printDirectory(entry, numTabs+1);
      } else { Serial.print("\t\t"); Serial.println(entry.size(), DEC); }
      entry.close();
    } 
  } else { Serial.println(F("Can't display directory, SD Reader not present!")); }
}*/


void motion() {
  pirStat = digitalRead(pirPin);
  if (pirStat == HIGH && millis() - lastMotion > motionDelay) {
    Serial.println(F("Motion detected"));
    turnOff = false; soulOn = false; soulAngle = -1; turnOnOff();
    lastMotion = millis();
  } else if (pirStat == LOW && millis() - lastMotion > motionDelayOff) {
    policeOn = false; turnOff = true; turnOnOff();
  }
}


/*void soundfx(char * file) {
  if (mmPresent == true) {
    //if (scannerOn == true) {
      if (! musicPlayer.playingMusic) {
        char path[strlen(1)+strlen(file)+2]; strcpy(path, "/"); strcat(path, file);
        if (musicPlayer.startPlayingFile(path)) { Serial.print(F("Started playing "));
        } else { Serial.print(F("Could not open file ")); }
        Serial.println(file);
      } else { Serial.println(F("Sound is actively playing!")); }
    //} else { Serial.println(F("Can't play sound, scanner not active!")); }
  } else { Serial.println(F("Can't play, Sound not initialized!")); }
}


void volSet(uint8_t volVal) {
  if (volVal >=volMax && volVal <=volMin) { vol = volVal; }
  Serial.print(F("Setting volume to: ")); Serial.println(vol);
  musicPlayer.setVolume(vol,vol);
}


void volUpDown(bool volCh) {
  if (volCh == true && vol >=volMax) { vol = (vol-1); }
  else if (volCh == false && vol <=volMin) { vol = (vol+1); }
  Serial.print(F("Setting volume to: ")); Serial.println(vol);
  musicPlayer.setVolume(vol,vol);
}*/


void turnOnOff() {
    if (turnOff == false) {
      if (scannerOn == false) { scannerOn = true; angle = angleStart; digitalWrite(ledPin, HIGH);}
      if (scannerOn == true) digitalWrite(ledPin, HIGH);
    }
    if (turnOff) {policeOn = false; digitalWrite(ledPin, LOW); }
}


void brightness(int b) {
  bright = b; FastLED.setBrightness(bright);
  Serial.print(F("Setting brightness to: ")); Serial.println(bright);
}


//void colorChRGB(CRGB colorRGB) { CRGB color = colorRGB; Serial.print(F("Changing color to: ")); Serial.println(cname); }


void colorCh(CHSV colour) {
  //if ( colour == "USA") { USAOn = true; } else { USAOn = false; }
  if ( cname == "Rainbow" ) { rainbowOn = true; } else { rainbowOn = false; }
  color = colour;
  Serial.print(F("Changing color to: ")); Serial.println(cname);
}


void rbSpeedUpDown(bool vert) {
  if (vert == true && rbSpeed <=rbSpeedMax) { rbSpeed = (rbSpeed+1); }
  if (vert == false && rbSpeed >=rbSpeedMin) { rbSpeed = (rbSpeed-1); }
  Serial.print(F("Setting Rainbow change speed to: ")); Serial.println(rbSpeed);
}


void speedUpDown(bool vert) {
  if (vert == true && scanSpeed >=scanSpeedMax) { scanSpeed = scanSpeed-(scanSpeed/10); }
  if (vert == false && scanSpeed <=scanSpeedMin) { scanSpeed = scanSpeed+(scanSpeed/10); }
  Serial.print(F("Setting speed to: ")); Serial.println(scanSpeed);
}


void allOnScan() {
  scannerOn = false; turnOff = false;
  randNum = random(0,2); 
  Serial.print(F("Starting all on mode ")); Serial.print(randNum); Serial.println(F("..."));
  digitalWrite(ledPin, HIGH); 
  if ( randNum == 1) { for (int i =0; i < (numLEDs); i++) { leds[0][i] = color; leds[1][i] = color; }
  } else {
    // Turn on even lights
    for (int i =0; i < (numLEDs); i++) {if ((i % 2) == 0) { leds[0][i] = color; leds[1][i] = color; }}
    FastLED.show(); delay(55);
    // Turn on odd lights
    for (int i =0; i < (numLEDs); i++) {if ((i % 2) == 1) { leds[0][i] = color; leds[1][i] = color;}}
  } FastLED.show(); delay(400);
  allOn = false; scannerOn = true;
  Serial.println(F("All on complete, starting scanner"));
}


void scan() {
  if (rainbowOn) { hue = hue + rbSpeed; };
  //if (USAOn) { if (usac == 2) { usac = 0; }; color = USA[usac++]; Serial.print(F("usac: ")); Serial.println(usac);}
  if (soulOn) { soulAngle = soulAngle + 1; if (soulAngle >= ((numLEDs *2)-2)) soulAngle = 0; }
  angle = angle + 1;
  if (angle >= ((numLEDs *2)-2)) angle = 0;
  if (angle == angleStartPos) { 
    /*if (playSound == true) { 
      soundfx(soundFile);
      fxcycle++;
      if (fxcycle >= 1) { playSound = false; fxcycle = 0; }
    }*/
    if (verb) { 
      Serial.print(F("Scanning... Color: ")); Serial.print(cname); 
      if (rainbowOn) { Serial.print(F(", Hue: ")); Serial.print(hue); Serial.print(F(", Rate: ")); Serial.print(rbSpeed); }
      Serial.print(F(", Bright: ")); Serial.print(bright); 
      Serial.print(F(", Speed: ")); Serial.println(scanSpeed); 
    }
  }
  if (turnOff == true && angle == angleStartPos) {
    Serial.println(F("Turning scanner off..."));
    scannerOn = false; angle = angleStart;
  }
}


void soulSurvivorScan() {
  soulAngle = soulAngle + 1;
  if (soulAngle >= ((numLEDs *2)-2)) soulAngle = 0;
  if (turnOff && soulAngle == 0) soulOn = false;
}


void policeScan() {
  Serial.print(F("Starting Police mode")); Serial.println(F("..."));
  const uint8_t strobeDelay = 55;
  for (int abc =0; abc < 3; abc++) {
    for (int t =0; t < 6; t++) {
      for (int i =0; i < (numLEDs); i++) {if ((i % 2) == 0) { leds[0][i] = Red; leds[1][i] = Red; }}
      FastLED.show(); delay(strobeDelay);
      for (int i =0; i < (numLEDs); i++) {if ((i % 2) == 0) { leds[0][i] = Black; leds[1][i] = Black; }}
      FastLED.show(); delay(strobeDelay);
    }
    for (int t =0; t < 6; t++) {
      for (int i =0; i < (numLEDs); i++) {if ((i % 2) == 1) { leds[0][i] = Blue; leds[1][i] = Blue;}}
      FastLED.show(); delay(strobeDelay);
      for (int i =0; i < (numLEDs); i++) {if ((i % 2) == 1) { leds[0][i] = Black; leds[1][i] = Black;}}
      FastLED.show(); delay(strobeDelay);
    }
  }
  policeOn = false;
}


//void surveillanceMode() {

void setup() {
  if (angleStart == -1) {angleStartPos = 1;} else if (angleStart == 6) {angleStartPos = 6;}
  Serial.begin(9600);
  // https://fastled.io/docs/3.1/group___color_enums.html
  FastLED.addLeds<WS2812,dataPin,RGB>(leds[0],numLEDs).setCorrection( TypicalPixelString ); 
  FastLED.addLeds<WS2812,mdataPin,GRB>(leds[1],numLEDs).setCorrection( TypicalSMD5050 );
  brightness(bright);
  pinMode(pwrPin, INPUT);
  pinMode(pirPin, INPUT);
  pinMode(ledPin, OUTPUT); digitalWrite(ledPin, ledState);
  
  //******* Rotary Encoder initialization
  pinMode(RE1_CLK,INPUT_PULLUP); attachInterrupt(5, updateEncoder, CHANGE); // Rotary Encoder 1 CLK
  //pinMode(RE1_DT,INPUT); attachInterrupt(4, updateEncoder, CHANGE);       // Rotary Encoder 1 DT
  pinMode(RE1_SW,INPUT_PULLUP); attachInterrupt(4, updateEncoder, CHANGE);  // Rotary Encoder 1 SW
  RE1_lastStateCLK = digitalRead(RE1_CLK);
  if (verb) { Serial.println(F("Starting up...")); }
  
  /*//******* Music Maker initialization
  Serial.println(F("Adafruit VS1053 Library Loading"));
  if (musicPlayer.begin()) { 
    Serial.println(F("VS1053 found"));
    if (! musicPlayer.useInterrupt(VS1053_FILEPLAYER_PIN_INT)) {Serial.println(F("DREQ pin is not an interrupt"));}
    if (SD.begin(CARDCS)) {
      mmPresent = true;
      printDirectory(SD.open("/"), 0);
      musicPlayer.setVolume(vol,vol);
    } else { Serial.println(F("SD failed or not present")); }
  } else { Serial.println(F("VS1053 not found, check pins")); }*/
}


void loop() {
  if (allOn) { allOnScan(); }
  if (policeOn) { policeScan(); }
  EVERY_N_MILLISECONDS(100) { interfaces(); }
  EVERY_N_MILLISECONDS_I(scanSpeedTimer, 0) {
    if (scannerOn) { scanSpeedTimer.setPeriod(scanSpeed); scan();   //patternsList[gCurrentPatternNumber]();
    } else if (soulOn) { scanSpeedTimer.setPeriod(scanSpeed); soulSurvivorScan(); }
  }
  EVERY_N_MILLISECONDS(tailSpeed) {
    uint8_t leadDot = angle < (numLEDs - 1) ? angle : (numLEDs - 1) - (angle - (numLEDs - 1));
    uint8_t leadDot2 = soulAngle < (numLEDs - 1) ? soulAngle : (numLEDs - 1) - (soulAngle - (numLEDs - 1));
    if (rainbowOn) { for (int a=0; a < (numArrays); a++) { leds[a][leadDot] = CHSV(hue, sat, bright); }
    } else if (soulOn) { for (int a=0; a < (numArrays); a++) { leds[a][leadDot] = color; leds[a][leadDot2] = color; }
    } else { for (int a=0; a < (numArrays); a++) { leds[a][leadDot] = color; }; }
    for (int a=0; a < (numArrays); a++) { fadeToBlackBy(leds[a], numLEDs, tail); } //ARR, strip len, fade by n/256s
    FastLED.show();
  }
}


//}
