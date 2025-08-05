#include <LedControl.h>
#include <LiquidCrystal.h>
#include <Keypad.h>

// PIN ASSIGNMENTS 
#define DIN_PIN     12
#define CLK_PIN     11
#define CS_PIN      10
#define BUZZER_PIN  3

LiquidCrystal lcd(9, 8, 7, 6, 5, 4);

//Keypad 4x3 setup
const byte ROWS = 4;
const byte COLS = 3;
char keys[ROWS][COLS] = {
  {'1','2','3'},
  {'4','5','6'},
  {'7','8','9'},
  {'*','0','#'}
};

byte rowPins[ROWS] = {A0, A1, A2, A3};  // R1–R4
byte colPins[COLS] = {A4, A5, 2};       // C1-C3

Keypad keypad = Keypad(makeKeymap(keys), rowPins, colPins, ROWS, COLS);

//ECG Settings
const uint8_t NUM_DISPLAYS   = 2;
const uint8_t DISPLAY_COLS   = 8 * NUM_DISPLAYS;
const uint8_t DEFAULT_HEIGHT = 4;
const uint8_t BRIGHTNESS     = 8;

LedControl lc(DIN_PIN, CLK_PIN, CS_PIN, NUM_DISPLAYS);

// ECG waveform (0 = R-peak)
const uint8_t ecgPQRST[] = {
  4,4,4,4,4,
  3,2,3,4,
  4,5,6,
  2,0,2,
  5,6,4,
  4,4,4,
  3,2,3,4,4,
  4,4,4,4
};
const uint16_t SIGNAL_LEN = sizeof(ecgPQRST) / sizeof(ecgPQRST[0]);

uint8_t frame[DISPLAY_COLS];
uint16_t ecgIndex = 0;
bool running = true;

unsigned long lastBpmTime = 0;
uint8_t beatCount = 0;
uint16_t bpm = 0;

int speedDelay = 60;  // scroll speed, adjustable

void setup() {
  lcd.begin(16, 2);
  lcd.print("ECG Scroller");
  lcd.setCursor(0, 1);
  lcd.print("BPM: --");

  for (uint8_t i = 0; i < NUM_DISPLAYS; i++) {
    lc.shutdown(i, false);
    lc.setIntensity(i, BRIGHTNESS);
    lc.clearDisplay(i);
  }

  for (uint8_t i = 0; i < DISPLAY_COLS; i++) {
    frame[i] = DEFAULT_HEIGHT;
  }

  pinMode(BUZZER_PIN, OUTPUT);
  digitalWrite(BUZZER_PIN, LOW);
}

void loop() {
  char key = keypad.getKey();
  if (key) {
    if (key == '1') {
      running = !running;  // Pause / Resume
    } else if (key == '2') {
      ecgIndex = 0;
      beatCount = 0;
      bpm = 0;
      lastBpmTime = millis();
      lcd.setCursor(0, 1);
      lcd.print("BPM: --   ");
    } else if (key == '3') {
      speedDelay = constrain(speedDelay - 10, 20, 200);  // faster
    } else if (key == '4') {
      speedDelay = constrain(speedDelay + 10, 20, 200);  // slower
    }
  }

  if (running) {
    updateFrame();
  }

  drawFrame();
  delay(speedDelay);
}

void updateFrame() {
  static bool lastWasR = false;
  for (uint8_t i = 0; i < DISPLAY_COLS - 1; i++) {
    frame[i] = frame[i + 1];
  }
  uint8_t newVal = ecgPQRST[ecgIndex++];
  frame[DISPLAY_COLS - 1] = newVal;
  if (newVal == 0 && !lastWasR) {
    tone(BUZZER_PIN, 1500, 60);
    beatCount++;
    lastWasR = true;
  } else if (newVal != 0) {
    lastWasR = false;
  }
  if (ecgIndex >= SIGNAL_LEN) ecgIndex = 0;
  unsigned long now = millis();
  if (now - lastBpmTime >= 10000) {
    bpm = beatCount * 6;
    beatCount = 0;
    lastBpmTime = now;

    lcd.setCursor(0, 1);
    lcd.print("BPM: ");
    lcd.print(bpm);
    lcd.print("   ");
  }
}

void drawFrame() {
  for (uint8_t d = 0; d < NUM_DISPLAYS; d++) {
    lc.clearDisplay(d);
  }

  for (uint8_t col = 0; col < 8; col++) {
    lc.setLed(0, frame[col], col, true);
    lc.setLed(1, frame[col + 8], col, true);
  }
}
