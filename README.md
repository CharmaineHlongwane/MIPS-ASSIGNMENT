# MIPS-ASSIGNMENT
# Image Processing

## Introduction
This is a simple image processing programs written in MIPS assembly language. Reads an input image in PPM format, processes it, and generates an output image. (increasing brightness and  greyscalling)

## Prerequisites
Before running this program, ensure that you have the following:
  - QtSPIM- MIPS simulator for running MIPS assembly programs.

## Usage

1. Open QtSPIM and load the MIPS assembly code provided in the repository.
2. Before running the program, make sure to update the file paths in the code:
   - Update "in_file" to the path of your input image.
   - Update "out_file" to the desired path for the output image.
3. Run the program in QtSPIM. This will execute the image processing on the input image and generate an output image.
4. After running the program, you can find the output image at the path specified in `output_filename`.

## Important Notes
- Ensure that the input image is in PPM (Portable Pixmap) format.
- The program calculates and displays average pixel values before and after processing.
- You may need to adjust memory space and buffer sizes based on your input image's dimensions and requirements.

Happy image processing!

