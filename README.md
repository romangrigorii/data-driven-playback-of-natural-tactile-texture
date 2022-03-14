# data-driven-playback-of-natural-tactile-texture

This repository contains all of the code used in writing an IEEE publication
titled "Data-driven playback of natural tactile texture via broadband friction
modulation" which can be found here:

DOI: 10.1109/TOH.2021.3130091

IEEE link: https://ieeexplore.ieee.org/document/9625707

This repo contains the embedded C code used to program PIC32 microcontroller.
Microcontroller was responsible for:

1) linear stage motion with velocity feedback
2) driving of servo motor for loading of tribometer stage
3) temperature controller for heating a tactile substrate

The repo also contains experimental protocol for gathering psychophysical data
from subjects, extract a number of statistic metrics from the data, and generate
the graphics that are included in the paper.
