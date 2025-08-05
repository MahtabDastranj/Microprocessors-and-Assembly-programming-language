#include <LedControl.h>
#include <LiquidCrystal.h>

// PIN ASSIGNMENTS 
#define DIN_PIN     12
#define CLK_PIN     11
#define CS_PIN      10
#define PAUSE_BTN   2
#define BUZZER_PIN  3

LiquidCrystal lcd(9, 8, 7, 6, 5, 4);

const uint8_t NUM_DISPLAYS   = 2;
const uint8_t DISPLAY_COLS   = 8 * NUM_DISPLAYS;
const uint8_t DEFAULT_HEIGHT = 4;
const uint8_t BRIGHTNESS     = 8;
const uint16_t SCROLL_DELAY  = 60;

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

// STATE VARIABLES 
uint8_t  frame[DISPLAY_COLS];
uint16_t ecgIndex = 0;
bool running = true;

unsigned long lastButtonCheck = 0;
bool lastPauseButtonState = HIGH;

unsigned long lastBpmTime = 0;
uint8_t beatCount = 0;
uint16_t bpm = 0;

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

  for (uint8_t i = 0; i < DISPLAY_COLS; i++) frame[i] = DEFAULT_HEIGHT;

  pinMode(PAUSE_BTN, INPUT_PULLUP); // ← استفاده از pull-up داخلی
  pinMode(BUZZER_PIN, OUTPUT);
  digitalWrite(BUZZER_PIN, LOW);
}

void loop() {
  // Check pause button (debounced)
  if (millis() - lastButtonCheck > 50) {
    bool currentPauseButtonState = digitalRead(PAUSE_BTN);
    if (currentPauseButtonState == LOW && lastPauseButtonState == HIGH) {
      running = !running;
    }
    lastPauseButtonState = currentPauseButtonState;
    lastButtonCheck = millis();
  }

  if (running) {
    updateFrame();
  }

  drawFrame();
  delay(SCROLL_DELAY);
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
