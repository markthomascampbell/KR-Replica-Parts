#include "SoftwareSerial.h"
#include <Adafruit_NeoPixel.h>
// Board: Arduino Nano    Processor: ATMega32P (Old Bootloader)
#define LED_PIN 5                                                   // pin NeoPixels are connected to
#define BRIGHTNESS 50                                               // LED Brightness (0-255)
// Uncomment 4 lines below if transmission is a 3 speed
  //const int LED_COUNT = 6;                                        // Number of NeoPixels
  //const int hallArray [] = {2,3,4,5,6,7};                         // Pins used by each hall sensor
  //const int gearArray [] = {0,1,2,3,4,5};                         // 0=Park, 1=Reverse, 2=Neutral, 3=Drive, 4=2, 5=1
  //const String gearNames [] = { "Park", "Reverse", "Neutral", "Drive", "Second", "First" };
// Uncomment 4 lines below if transmission is a 4 speed
  const int LED_COUNT = 3;                                          // Number of NeoPixels
  const int hallArray [] = {2,3,4,5,6,7,8};                         // Pins used by each hall sensor
  const int gearArray [] = {0,1,2,3,4,5,6};                         // 0=Park, 1=Reverse, 2=Neutral, 3=Drive, 4=3, 5=2, 6=1
  const String gearNames [] = { "Park", "Reverse", "Neutral", "Drive", "Third", "Second", "First" };
const int count = 10;                                               // a debouncer for hall sensors
const int arraySize = sizeof(hallArray)/sizeof(hallArray[0]);       // Size of arrays
int isOn[arraySize] ;                                               // Array to keep track of whether a given position is lit
uint8_t c = 0;                                                      // counter variable to go from 0 to value of count
uint32_t White = ( 0, 0, 0, 255);                                   // the color white
uint32_t Black = ( 0, 0, 0, 0);                                     // the color black
Adafruit_NeoPixel strip(LED_COUNT, LED_PIN, NEO_GRBW + NEO_KHZ800); // Declare our NeoPixel strip object

void setup() {
  strip.begin();                                                    // Init NeoPixel strip
  strip.show();                                                     // Turn OFF all pixels ASAP
  strip.setBrightness(BRIGHTNESS);                                  // Set brightness level of LEDs
  for (int sensor = 0; sensor < arraySize; sensor++) { pinMode (sensor, INPUT); 
    Serial.print(F("Initializing pin ")); Serial.println(sensor); }         // init hall sensors
  Serial.begin(9600);
  Serial.println(F("starting up..."));
}

void loop() {
  for (int i = 0; i < arraySize; i++) {
    Serial.print(F("int i (")); Serial.print(i); Serial.print(F(") is pin #")); Serial.print(hallArray[i]); 
    Serial.print(F(", value is ")); Serial.print(digitalRead(hallArray[i]));
    Serial.print(F("    c is ")); Serial.print(c);
    if (digitalRead(hallArray[i] == HIGH && c < 10)) { Serial.println(F("Boo")); c++; delay(1);
    } else if (digitalRead(hallArray[i]) == HIGH && c == 10 && isOn[i] == 0) { 
        strip.setPixelColor(gearArray[i], White); strip.show(); 
        Serial.print(F("Turning on ")); Serial.println(gearNames[i]);
        isOn[i] = 1;
    } else if (digitalRead(hallArray[i]) == LOW && c > 0) { Serial.println(F("Bee")); c--; delay(1);
    } else if (digitalRead(hallArray[i]) == LOW && c == 0 && isOn[i] == 1) { 
        strip.setPixelColor(gearArray[i], Black); strip.show(); 
        Serial.print(F("Turning off ")); Serial.println(gearNames[i]);
        isOn[i] = 0;
    }
  }
}
