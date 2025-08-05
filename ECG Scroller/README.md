
# 🫀 ECG Scroller with MAX7219 and Buzzer – Arduino Project

This project simulates an ECG (electrocardiogram) waveform using an LED matrix display driven by the MAX7219 module. It includes features such as:

- Adjustable scroll speed via keypad input  
- Buzzer pulse synchronized with the R-peak of the ECG  
- Real-time heart rate (BPM) display on a 16×2 LCD  
- Debounced keypad control for smooth user interaction  

Ideal for educational purposes, biomedical demos, or Arduino-based signal simulations.

---

## 🚀 Features

- 💡 **LED Matrix Scrolling**: Displays an ECG waveform across 4 chained 8×8 matrices.
- 🎵 **Audible Pulse**: Buzzer beeps on each R-peak to mimic heartbeat sounds.
- ⏱️ **Scroll Speed Control**: Use a 4×4 matrix keypad to speed up or slow down scrolling.
- 📟 **BPM Display**: LCD shows beats per minute calculated from pulse timing.
- 🔄 **Timer1-Based Scrolling**: Uses hardware timer interrupt for consistent display updates.
- 🧪 **Proteus Simulation**: Includes `.DSN` Proteus file for virtual circuit testing.

---

## 🔧 Hardware Requirements

- Arduino Uno (or compatible board)  
- 4× MAX7219 8×8 LED matrix modules  
- 4×4 matrix keypad  
- 16×2 LCD with I2C backpack  
- Passive buzzer  
- Jumper wires & breadboard

---

## 🗂️ File Structure

- `ECG_Scroller.ino` – Main Arduino sketch  
- `ECG_Scroller.dsn` – Proteus simulation file  
- `Proteus_Output.bmp` – Snapshot of the simulated output  
- `ECG_Scroller.LYT` – Proteus layout configuration (if present)  
- Libraries:
  - `LedControl.h` for MAX7219
  - `Keypad.h` for keypad input
  - `LiquidCrystal_I2C.h` for I2C LCD control

---

## 🔌 Wiring Overview

| Component       | Arduino Pin     |
|----------------|------------------|
| MAX7219 DIN    | 12               |
| MAX7219 CLK    | 11               |
| MAX7219 CS     | 10               |
| Buzzer         | 9                |
| Keypad (4x4)   | 2, 3, 4, 5, 6, 7, 8, A0 |
| LCD SDA/SCL    | A4 (SDA), A5 (SCL) |

> Make sure to power the MAX7219 with 5V and GND. Connect all modules properly to avoid flickering or noise.

---

## 🛠️ Installation & Upload

1. Install the following libraries via Arduino Library Manager:
   - **LedControl**
   - **Keypad**
   - **LiquidCrystal_I2C**
2. Open `ECG_Scroller.ino` in the Arduino IDE.
3. Select the correct board and COM port.
4. Upload the sketch.

---

## 🎮 How to Use

- **Start:** ECG waveform scrolls immediately after power-up.
- **Adjust Speed:** Use keypad numbers to change scroll speed (lower = faster).
- **Heartbeat Sound:** Buzzer emits a pulse at each detected peak.
- **View BPM:** Live heart rate shown on the LCD.

---

## 🧪 Proteus Simulation

If you do not have hardware available, open `ECG_Scroller.dsn` in Proteus to simulate the complete ECG Scroller circuit.  
You can visualize the matrix output and test the keypad and buzzer responses virtually.

> Note: Proteus 8.9 or later is recommended for compatibility.

---

## 📷 Preview

*(Add a photo or GIF of the setup in action here)*

---

## 📄 License

This project is open-source and distributed under the MIT License.  
Feel free to modify and use it in your own applications.
