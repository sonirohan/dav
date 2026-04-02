# Digital Audio Visualizer (DAV) - UCLA IEEE 2025-26
## **_Contributors:_** David Farag, Rohan Soni (UCLA '28)

This repository contains the hardware implementation files for DAV, specifically developed for the Basys3 FPGA. Currently, the codebase focuses on foundational signal processing and display controller modules required for the final capstone project.

---

## Project Components

### 1. VGA Controller (Lab 3)
A custom Video Graphics Array (VGA) driver designed to interface with a **640x480** resolution display at a **60Hz** refresh rate.

* **Pixel Tracking:** Implements horizontal (`hc`) and vertical (`vc`) counters to track the pixel currently being drawn. 
* **Sync Generation:** Drives `HSYNC` and `VSYNC` signals to synchronize the monitor, pulling them low only during blanking periods. 
* **Color Logic:** Outputs 12-bit RGB values. It translates 8-bit input colors via left-shifting to match the output specification. 
* **Double Buffering:** Includes a ping-pong RAM implementation to store pixels and prevent screen tearing by ensuring no buffer is read from and written to simultaneously. 

### 2. Fast Fourier Transform - FFT (Lab 4)
A hardware-accelerated **4-point FFT** module used to transform time-domain audio samples into frequency-domain data.

* **Butterfly Unit:** The core building block that performs complex arithmetic ($A + BW$ and $A - BW$).
* **Twiddle Factors:** Pre-calculated complex constants ($W_n^k$) stored in two’s complement form and scaled by $2^{15}$ to maintain precision in signed integer math. 
* **FSM Architecture:** Uses a Finite State Machine to manage the stages of calculation (Stage 1 and Stage 2), allowing for butterfly unit reuse to optimize FPGA space. 
* **Configurable Precision:** Supports both **32-bit** (16-bit real/imaginary) and **16-bit** (8-bit real/imaginary) complex number representations through parameters.

---

## Future Work (Capstone)
The modules in this repository serve as the basic building blocks for the upcoming **Digital Audio Visualizer Capstone**.

The final project will integrate:
1.  **Audio Input:** Real-time sampling of audio signals.
2.  **FFT Processing:** Utilizing the butterfly units to analyze frequency spectrums. 
3.  **Advanced Graphics:** A graphics driver that processes FFT outputs to create dynamic visual effects on the VGA display.

--- 

## Setup and Testing
* **Clock Speed:** The VGA module requires a **25 MHz** clock signal, generated via a clock divider in the top-level module. 
* **Verification:** A Python script is utilized to validate the fixed-point complex arithmetic of the butterfly units against theoretical results.
* **Deployment:** Designed for synthesis on FPGA hardware using standard constraints and pin planning.
