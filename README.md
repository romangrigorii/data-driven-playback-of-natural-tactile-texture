# data-driven-playback-of-natural-tactile-texture
"We used broadband electroadhesion to reproduce the friction force profile measured as a finger slid across a textured surface. In doing so, we were also able to reproduce with high fidelity the skin vibrations characteristic of that texture; however, we found that this did not reproduce the original perception. To begin, the reproduction felt weak. In order to maximize perceptual similarity between a real texture and its friction force playback, the vibratory magnitude of the latter must be scaled up on average ~3X for fine texture and ~5X for coarse texture samples. This additional gain appears to correlate with perceived texture roughness. Additionally, even with optimal scaling and high fidelity playback, subjects could identify which of two reproductions corresponds to a real texture with only 72% accuracy, as compared to 95% accuracy when using real texture alternatives. We conclude that while tribometry and vibrometry data can be useful for texture classification, they appear to contribute only partially to texture perception. We propose that spatially distributed excitation of skin within the fingerpad may play an additional key role, and may thus be able to contribute to high fidelity texture reproduction."

This repository contains all of the code used in writing an IEEE publication
titled "Data-driven playback of natural tactile texture via broadband friction
modulation" which can be found here:

DOI: 10.1109/TOH.2021.3130091

IEEE link: https://ieeexplore.ieee.org/document/9625707

/C contains the embedded C code used to program PIC32 microcontroller.
Microcontroller was responsible for:

1) communication with DAC/ADC
2) linear stage motion driven by brushless DC motor with velocity feedback
3) driving of servo motor for loading of tribometer stage
4) temperature control for heating a tactile substrate to a nominal
temperature of the human body

/matlab contains experimental protocol for gathering psychophysical data
from subjects, extract a number of statistic metrics from the data, and generate
the graphics that are included in the paper.
