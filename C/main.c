#include <xc.h>          // Load the proper header for the processor
#include "constants.h"
#include "interrupts.h"
#include "control.h"
#include "NU32.h"
#include "helpers.h"
#include <math.h>
#include <stdio.h>
#include "dsp.h"

int main(void) {
  __builtin_disable_interrupts();
  NU32_Startup();
  digital_init();
  interrupt_init();
  SPI_com_init();
  avc = 0;
  CNVST = 1;
  MON = 0; // motor off
  DIR = 1; // direction - right
  V1 = 0; // velocity 0
  V2 = 0; // velocity 0
  LED1 = 1;
  LED2 = 1;

  __builtin_enable_interrupts();
  NU32_ReadUART3(message,100);
  sprintf(message,"%s\n\r","CONNECTED");
  NU32_WriteUART3(message);

  while (1){
    NU32_ReadUART3(message,100);
    sscanf(message,"%c",&option);
    sprintf(message,"%c\r\n", option);
    NU32_WriteUART3(message);
    switch (option){
      case 'c':
      LED1 = LED2;
      LED2 = !LED2;
      break;
      case 'b': // sends out the button value
      sprintf(message,"%d\n\r",butt);
      NU32_WriteUART3(message);
      break;
      case 'a': // sends out the button value
      butt = 0;
      break;
      case 'g': // enables/disables closed loop feedback
      feedback_enable = !feedback_enable;
      sprintf(message,"%d\n\r",feedback_enable);
      NU32_WriteUART3(message);
      break;
      case 'm': // motor on/off
      MON = !MON;
      break;
      case 'p': // read encoder value
      sprintf(message,"%d\n\r",enc_val);
      NU32_WriteUART3(message);
      break;
      case 'r': // resets encoder values
      enc_val = 0;
      break;
      case 'v': // send new desired position/velcoity to the driver
      NU32_ReadUART3(message,100);
      sscanf(message,"%d",&possel);
      NU32_ReadUART3(message,100);
      sscanf(message,"%d",&velsel);
      sprintf(message,"%d\t%d\n\r",possel,velsel);
      NU32_WriteUART3(message);
      move_slide(possel,velsel);
      posnow = enc_val;
      complete_flag = 0;
      break;
      case 'l': // sets stepper motor position
      NU32_ReadUART3(message,100);
      sscanf(message,"%d",&des_pos);
      break;
      case 't': // gives current readings of lateral force
      sprintf(message,"%lf\r\n", lat);
      NU32_WriteUART3(message);
      break;
      case 'z': // zeros the force and encoder readings
      avc = 0;
      enc_val = 0;
      break;
    }
  }
}
