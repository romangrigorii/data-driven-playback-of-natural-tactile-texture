#include <xc.h>          // Load the proper header for the processor
#include "constants.h"
#include "interrupts.h"
#include "control.h"
#include "NU32.h"
#include <math.h>
#include "dsp.h"
#include "helpers.h"

void wait(t){ // = 8 cycles + t cycles
  int ii;
  for (ii=0;ii<t;ii++){
  }
}

double absd(double val){
  if (val>=0.0){
    return val;
  } else {
    return -val;
  }
}
