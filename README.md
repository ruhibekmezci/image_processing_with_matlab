# Real-Time Coin Counter with MATLAB

This project uses MATLAB and the Image Processing Toolbox to perform real-time coin counting and summation via a webcam.

The key feature of this script is its **robust, calibration-based detection system**, which avoids the common pitfalls of hard-coded pixel values.

## The Problem with "Magic Numbers"

A simple approach to this problem is to hard-code the pixel radius of each coin. This is extremely fragile. If the camera's distance, zoom, or resolution changes, the entire system breaks.

This project solves that problem.

## The Solution: Ratio-Based Calibration

This script uses a dynamic, ratio-based approach. Instead of measuring absolute pixel sizes, it measures *relative* sizes based on a reference coin.

### How It Works

1.  **Calibration:**
    * On startup, the script asks you to place a single 1 TL coin in the camera's view.
    * It measures this coin's radius in pixels and saves it as the `r_referans_1TL`. This value becomes the "scale" for the current session.

2.  **Relative Identification:**
    * The script knows the *actual physical diameter ratios* of all Turkish coins (e.g., a 50 Kr coin is ~91.2% the size of a 1 TL coin).
    * When it detects a new coin, it calculates its ratio relative to the `r_referans_1TL`.
    * This ratio is compared against the known physical ratios to make a positive identification, regardless of camera distance or resolution.

## Features

* **Real-time detection** via any system webcam.
* **Robust calibration logic** resilient to changes in camera distance and zoom.
* **Gaussian filtering** (`imgaussfilt`) to reduce noise from metallic reflections and improve circle detection.
* **Dynamic search parameters:** The `imfindcircles` search range is set dynamically based on the calibration step.
* **Live summation** of all detected coins, displayed on-screen.

## Requirements

* **MATLAB**
* **MATLAB Image Processing Toolbox**
* **A webcam** connected to your computer.

## Usage

1.  Run the `matlab_code.m` script.
2.  A pop-up window will ask you to calibrate. Place **only one 1 TL coin** in view and press "OK".
3.  Once calibrated, a new window will open. You can now place multiple coins in the frame.
4.  The script will identify each coin and display the total sum in the center of the screen.
5.  To stop the program, simply close the video preview window.

## Limitations

* **Overlapping Coins:** This algorithm relies on `imfindcircles`. If coins are touching or overlapping, they will likely be ignored or misidentified. For best results, coins must be separated.
