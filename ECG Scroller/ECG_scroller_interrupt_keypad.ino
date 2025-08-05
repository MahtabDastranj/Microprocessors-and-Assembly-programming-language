#include <LedControl.h>
#include <LiquidCrystal.h>
#include <Keypad.h>
#include <avr/interrupt.h>

/*  pin map  */
#define DIN_PIN     12      // MAX7219 DIN
#define CLK_PIN     11      // MAX7219 CLK
#define CS_PIN      10      // MAX7219 CS / LOAD
#define BUZZER_PIN   3      // active buzzer
#define BTN_PIN      2      // pause / resume push-button

/* LCD (RS,E,D4,D5,D6,D7)  */
LiquidCrystal lcd(9, 8, 7, 6, 5, 4);

/* keypad 4 × 3 */
const byte ROWS = 4, COLS = 3;
char keys[ROWS][COLS] = {
  { '1','2','3' },
  { '4','5','6' },
  { '7','8','9' },
  { '*','0','#' }
};
byte rowPins[ROWS] = { A0, A1, A2, A3 };
byte colPins[COLS] = { A4, A5, 4 };
Keypad keypad = Keypad(makeKeymap(keys), rowPins, colPins, ROWS, COLS);

/*  MAX7219 / LED matrices */
const uint8_t NUM_MTX   = 2;
const uint8_t COLS_TOT  = 8 * NUM_MTX;
LedControl lc(DIN_PIN, CLK_PIN, CS_PIN, NUM_MTX);

/*  ECG waveform (0 = R-peak) */
const uint8_t ecgPQRST[] = {
  4,4,4,4,4, 3,2,3,4,
  4,5,6,2,0,2,
  5,6,4,4,4,4,
  3,2,3,4,4, 4,4,4,4
};
const uint16_t SIGNAL_LEN = sizeof(ecgPQRST);

/* runtime state  */
uint8_t  frame[COLS_TOT];
uint16_t ecgIndex      = 0;
bool     running       = true;
uint8_t  beatCounter   = 0;
uint16_t bpm           = 0;
unsigned long lastBpm  = 0;

/* push-button debounce */
bool lastBtnState      = HIGH;
unsigned long lastDebounce = 0;
const unsigned long DEBOUNCE_MS = 50;

/* refresh timer */
volatile bool refreshNeeded = false;
uint8_t  scrollHz = 10;                // start at 10 Hz
const uint8_t MIN_HZ = 2;
const uint8_t MAX_HZ = 20;

/* Timer-1 ISR: sets refresh flag */
ISR(TIMER1_COMPA_vect) { refreshNeeded = true; }

/* configure Timer-1 for given refresh rate (Hz) */
void setTimerHz(uint8_t hz)
{
  cli();
  OCR1A  = (F_CPU / 256UL / hz) - 1;   // prescaler 256
  TCCR1A = 0;
  TCCR1B = (1 << WGM12) | (1 << CS12); // CTC, presc 256
  TIMSK1 = (1 << OCIE1A);
  sei();
}

/* setup */
void setup()
{
  lcd.begin(16, 2);
  lcd.print("ECG Scroller");
  lcd.setCursor(0, 1);
  lcd.print("BPM: --");

  for (uint8_t i = 0; i < NUM_MTX; ++i) {
    lc.shutdown(i, false);
    lc.setIntensity(i, 8);
    lc.clearDisplay(i);
  }
  for (uint8_t i = 0; i < COLS_TOT; ++i) frame[i] = 4;

  pinMode(BUZZER_PIN, OUTPUT);
  digitalWrite(BUZZER_PIN, LOW);

  pinMode(BTN_PIN, INPUT_PULLUP);      // external push-button
  setTimerHz(scrollHz);                // start timer
}

/* main loop */
void loop()
{
  /* push-button on D2: pause / resume */
  bool rd = digitalRead(BTN_PIN);
  if (rd != lastBtnState) { lastDebounce = millis(); lastBtnState = rd; }
  if (rd == LOW && (millis() - lastDebounce) > DEBOUNCE_MS) {
    running = !running;
    while (digitalRead(BTN_PIN) == LOW);          // wait release
  }

  /* keypad control */
  char k = keypad.getKey();
  if (k) {
    if (k == '1') running = !running;             // toggle
    else if (k == '2') {                          // reset
      ecgIndex = beatCounter = bpm = 0;
      lastBpm = millis();
      lcd.setCursor(0,1); lcd.print("BPM: --   ");
    }
    else if (k == '3') {                          // faster (+2 Hz)
      if (scrollHz < MAX_HZ) { scrollHz += 2; setTimerHz(scrollHz); }
    }
    else if (k == '4') {                          // slower (−2 Hz)
      if (scrollHz > MIN_HZ) { scrollHz -= 2; setTimerHz(scrollHz); }
    }
  }

  /* update display when ISR flag set */
  if (running && refreshNeeded) {
    refreshNeeded = false;
    updateFrame();
    drawFrame();
  }
}

/* update frame & BPM calculation */
void updateFrame()
{
  static bool lastWasR = false;

  for (uint8_t i = 0; i < COLS_TOT - 1; ++i) frame[i] = frame[i + 1];

  uint8_t y = ecgPQRST[ecgIndex++];
  frame[COLS_TOT - 1] = y;

  if (y == 0 && !lastWasR) { tone(BUZZER_PIN, 1500, 60); ++beatCounter; lastWasR = true; }
  else if (y != 0) lastWasR = false;

  if (ecgIndex >= SIGNAL_LEN) ecgIndex = 0;

  unsigned long now = millis();
  if (now - lastBpm >= 10000) {
    bpm = beatCounter * 6;
    beatCounter = 0;
    lastBpm = now;
    lcd.setCursor(0, 1);
    lcd.print("BPM: ");
    lcd.print(bpm);
    lcd.print("   ");
  }
}

/* draw current frame on both matrices */
void drawFrame()
{
  for (uint8_t m = 0; m < NUM_MTX; ++m) lc.clearDisplay(m);
  for (uint8_t c = 0; c < 8; ++c) {
    lc.setLed(0, frame[c]      , c, true);
    lc.setLed(1, frame[c + 8U] , c, true);
  }
}
