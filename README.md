
# Erosion of Binary Images using RISC-V Assembly

## Project Overview
This project implements the erosion of binary images using RISC-V assembly language in the RARS simulator. The algorithm processes binary images represented as 16x16 matrices, applying a 3x3 sliding window for erosion. The display output is mapped to a graphical interface provided by RARS, with each pixel rendered in either green or black, depending on its binary value.

## Objectives
* Practice RISC-V assembly programming using RARS.
* Implement a binary image erosion algorithm.
* Display both the original and eroded images on the RARS graphical interface.
  
## Key Features
* **Binary Image Representation:** Two binary matrices (`mat1` and `mat2`) of 16x16 elements are created. `mat1` holds the original image, while `mat2` stores the eroded image.
* **3x3 Sliding Window Erosion:** The algorithm applies a 3x3 window to the matrix, checking if all elements in the window are `1`. If so, the central pixel in the destination matrix (`mat2`) is set to `1`; otherwise, it is set to `0`.
* **Edge Handling:** The outermost rows and columns (0th and 15th) are cleared to `0` in the destination matrix.
* **Display Output:** The images are displayed using RARS' memory-mapped graphic output, where each pixel is represented by a 32-bit word. Green pixels (`0x0000FF00`) represent `1` values, while black pixels (`0x00000000`) represent `0` values.

## Functions
* `bin_im`: Displays the binary matrix (`mat1` or `mat2`) on the RARS graphical display.
* `erode_window`: Applies the 3x3 sliding window erosion algorithm on mat1 and stores the result in `mat2`.
* `clrln`: Clears a specific line in the matrix.
* `lrcln`: Clears a specific column in the matrix.
* `clrdsp`: Clears the graphical display.
* `cpymat`: Copies the contents of one matrix to another.

## How the Code Works
1. Initial Setup:
* `mat1` holds the initial binary image data.
* `mat2` is the destination matrix initialized to `0` (reserved for the eroded image).
2. Matrix Display:
* The image in `mat1` is rendered on the display using the `bin_im` function.
3. Matrix Erosion:
* A sliding window moves across `mat1` from position (1,1) to (14,14). If all pixels in the 3x3 window are `1`, the corresponding pixel in `mat2` is set to `1`. Otherwise, it's set to `0`.
4. Clearing Display:
* The `clrdsp` function is called to clear the display before rendering the next image.
5. Display Eroded Image:
* The eroded image in `mat2` is displayed using the `bin_im` function.

## Prerequisites
* **RARS Simulator:** Download and install [RARS](https://github.com/TheThirdOne/rars) to run the RISC-V assembly code.

##Running the Program
1. Open the RARS simulator and load the assembly file.
2. Run the program and observe the original binary image (`mat1`) displayed on the graphical interface.
3. Enter any character to continue, and the eroded binary image (`mat2`) will be displayed.
