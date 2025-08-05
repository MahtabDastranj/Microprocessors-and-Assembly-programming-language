#include <LedControl.h>
#include <LiquidCrystal.h>
#include <avr/interrupt.h>

/* pin assignments */
#define DIN_PIN     12      // MAX7219 DIN
#define CLK_PIN     11      // MAX7219 CLK
#define CS_PIN      10      // MAX7219 LOAD / CS
#define BUZZER_PIN   3      // active buzzer
#define BTN_PIN      2      // pause / resume push-button

/* LCD (RS,E,D4,D5,D6,D7) */
LiquidCrystal lcd(9, 8, 7, 6, 5, 4);

/* LED matrices via MAX7219 */
const uint8_t NUM_MTX = 2;
const uint8_t COLS_TOT = 8 * NUM_MTX;
LedControl lc(DIN_PIN, CLK_PIN, CS_PIN, NUM_MTX);

/* ECG waveform (0 = R-peak) */
const uint8_t ecgPQRST[] = {
  4,4,4,4,4, 3,2,3,4,
  4,5,6,2,0,2,
  5,6,4,4,4,4,
  3,2,3,4,4, 4,4,4,4
};
const uint16_t SIGNAL_LEN = sizeof(ecgPQRST);

/* runtime variables */
uint8_t  frame[COLS_TOT];
uint16_t ecgIndex    = 0;
bool     running     = true;

uint8_t  beatCounter = 0;
uint16_t bpm         = 0;
unsigned long lastBpmMs = 0;

/* push-button debounce */
bool lastBtnState      = HIGH;
unsigned long lastDebounce = 0;
const unsigned long DEBOUNCE_MS = 50;

/* Timer-1 flag  */
volatile bool refreshNeeded = false;

/* Timer-1 ISR: sets refresh flag every 100 ms */
ISR(TIMER1_COMPA_vect) { refreshNeeded = true; }

/* configure Timer-1 in CTC @ 10 Hz */
void startTimer(uint16_t ocrVal = 6249)           // 6249 → 10 Hz
{
  cli();
  TCCR1A = 0;
  TCCR1B = 0;
  TCNT1  = 0;
  OCR1A  = ocrVal;
  TCCR1B |= (1 << WGM12);                         // CTC mode
  TCCR1B |= (1 << CS12);                          // prescaler 256
  TIMSK1 |= (1 << OCIE1A);                        // enable ISR
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

  pinMode(BTN_PIN, INPUT_PULLUP);                 // internal pull-up
  startTimer();                                   // start 10 Hz interrupt
}

/* loop */
void loop()
{
  /* debounce push-button */
  bool reading = digitalRead(BTN_PIN);
  if (reading != lastBtnState) {
    lastDebounce = millis();
    lastBtnState = reading;
  }
  if (reading == LOW && (millis() - lastDebounce) > DEBOUNCE_MS) {
    running = !running;                           // toggle on press
    while (digitalRead(BTN_PIN) == LOW);          // wait for release
  }

  /* ---- refresh when ISR sets the flag ---- */
  if (running && refreshNeeded) {
    refreshNeeded = false;
    updateFrame();
    drawFrame();
  }
}

/* update ECG frame & BPM */
void updateFrame()
{
  static bool lastWasR = false;

  /* shift left */
  for (uint8_t i = 0; i < COLS_TOT - 1; ++i) frame[i] = frame[i + 1];

  /* new sample */
  uint8_t y = ecgPQRST[ecgIndex++];
  frame[COLS_TOT - 1] = y;

  /* beep on R-peak */
  if (y == 0 && !lastWasR) {
    tone(BUZZER_PIN, 1500, 60);
    ++beatCounter;
    lastWasR = true;
  } else if (y != 0) lastWasR = false;

  /* loop signal */
  if (ecgIndex >= SIGNAL_LEN) ecgIndex = 0;

  /* BPM every 10 s */
  unsigned long now = millis();
  if (now - lastBpmMs >= 10000) {
    bpm = beatCounter * 6;
    beatCounter = 0;
    lastBpmMs = now;
    lcd.setCursor(0, 1);
    lcd.print("BPM: ");
    lcd.print(bpm);
    lcd.print("   ");
  }
}

/* draw on both 8×8 matrices */
void drawFrame()
{
  for (uint8_t m = 0; m < NUM_MTX; ++m) lc.clearDisplay(m);

  for (uint8_t c = 0; c < 8; ++c) {
    lc.setLed(0, frame[c]     , c, true);         // first matrix
    lc.setLed(1, frame[c + 8] , c, true);         // second matrix
  }
}
