#include <SoftwareSerial.h>
#include <Adafruit_MCP23008.h>
#include <Wire.h>

const int BUTTON_PIN = 12;
const int RGB_RED_PIN = A2;
const int RGB_GREEN_PIN = A0;
const int RGB_BLUE_PIN = A1;

const int COLUMN_PINS [] = {0, 1, 2, 3, 4, 5, 6, 7};
const int ROW_PINS [] = {9, 7, 8, 6, 5, 4, 3, 2};

byte buttonState = LOW;
int color = 0;
boolean buttonPressed = false;
boolean error = false;

Adafruit_MCP23008 mcp;
SoftwareSerial BT(10, 11); // RX, TX

void setup() {
  
  Serial.begin(9600);
  BT.begin(9600);
  Wire.begin();
  mcp.begin(); 

  BT.flush();
  
  mcp.pinMode(0, OUTPUT);
  mcp.pinMode(1, OUTPUT);
  mcp.pinMode(2, OUTPUT);
  mcp.pinMode(3, OUTPUT);
  mcp.pinMode(4, OUTPUT);
  mcp.pinMode(5, OUTPUT);
  mcp.pinMode(6, OUTPUT);
  mcp.pinMode(7, OUTPUT);

  pinMode(RGB_RED_PIN, OUTPUT);
  pinMode(RGB_GREEN_PIN, OUTPUT);
  pinMode(RGB_BLUE_PIN, OUTPUT); 
   
  pinMode(2, INPUT_PULLUP);
  pinMode(3, INPUT_PULLUP);
  pinMode(4, INPUT_PULLUP);
  pinMode(5, INPUT_PULLUP);
  pinMode(6, INPUT_PULLUP);
  pinMode(7, INPUT_PULLUP);
  pinMode(8, INPUT_PULLUP);
  pinMode(9, INPUT_PULLUP);
  
  pinMode(BUTTON_PIN, INPUT_PULLUP);
  
  setColor(0, 255, 0);

}

void loop() {

  buttonState = digitalRead(BUTTON_PIN);

  if (BT.available() > 0) {
    byte data = BT.read();

    switch (data) {
      case 0:
        setColor(0, 255, 0);
        buttonPressed = false;
        error = false;
        break;
      case 1:
        setColor(255, 0, 0);
        buttonPressed = false;
        error = true;
        break;
      case 2: 
        buttonState = HIGH;
        buttonPressed = false;
        break;
      default: 
        setColor(0, 255, 0);
    }
  }

  if (buttonState == HIGH && !buttonPressed) {
    buttonPressed = true;

    if (!error) {
      setColor(0,0,0);
      delay(100);
      setColor(0, 255, 0);
      delay(100);
      setColor(0,0,0);
      delay(100);
      setColor(0, 255, 0);
    } else {
      setColor(0,0,0);
      delay(100);
      setColor(255, 0, 0);
      delay(100);
      setColor(0,0,0);
      delay(100);
      setColor(255, 0, 0);
    }
    
    for (int i = 0; i < 8; i++) {
      mcp.digitalWrite(i, HIGH);
    }
    
    byte board [8][8] = {};
    
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        
        mcp.digitalWrite(COLUMN_PINS[i], LOW);
        board[i][j] = !digitalRead(ROW_PINS[j]);
        mcp.digitalWrite(COLUMN_PINS[i], HIGH);
      }
    }
    

    uint8_t result[8] = {0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0};
    for (int i = 0; i < 8; i++) {
       for (int j = 0; j < 8; j++) {
          if (board[i][j] == 1)
              result[i] |= 1UL << 7-j;
       }
    }

    BT.write(result, 8);
        
  }
}

void setColor(int red, int green, int blue) {
  
  #ifdef COMMON_ANODE
    red = 255 - red;
    green = 255 - green;
    blue = 255 - blue;
  #endif
  
  analogWrite(RGB_RED_PIN, red);
  analogWrite(RGB_GREEN_PIN, green);
  analogWrite(RGB_BLUE_PIN, blue);  
}
