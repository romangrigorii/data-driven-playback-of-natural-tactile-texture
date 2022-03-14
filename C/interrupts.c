#include <xc.h>          // Load the proper header for the processor
#include "constants.h"
#include "interrupts.h"
#include "control.h"
#include "NU32.h"
#include "helpers.h"
#include <math.h>
#include <stdio.h>
#include "dsp.h"

void digital_init(){

  TRISBbits.TRISB4 = 0;  // CNVST pin
  TRISBbits.TRISB10 = 0; // ADC spi
  TRISBbits.TRISB11 = 0; // DAC spi
  TRISBbits.TRISB12 = 0; // LED1
  TRISBbits.TRISB13 = 0; // LED2

  TRISBbits.TRISB0 = 0;  // CH pin
  TRISBbits.TRISB1 = 0;  // CH pin
  TRISBbits.TRISB2 = 0;  // CH pin
  TRISBbits.TRISB3 = 0;  // CH pin

  TRISBbits.TRISB5 = 0;  // CH pin
  TRISBbits.TRISB6 = 0;  // CH pin
  TRISBbits.TRISB7 = 0;  // CH pin
  TRISBbits.TRISB8 = 0;  // CH pin

  TRISDbits.TRISD3 = 0;
  TRISDbits.TRISD4 = 0;
}

void SPI_com_init(){
  // setting up communication with friction control chip_write
  CS1 = 1;
  SPI3CON = 0;
  SPI3BRG = 10; // communication at 640kHz
  //SPI3BUF;
  SPI3BUF;
  SPI3STATbits.SPIROV = 0;
  SPI3CONbits.MODE32 = 1;
  SPI3CONbits.MODE16 = 0;
  SPI3CONbits.MSTEN = 1;
  SPI3CONbits.CKE = 1;
  SPI3CONbits.CKP = 0; // 0 and 1 work
  SPI3CONbits.SMP = 0; // 0 and 1 work
  SPI3CONbits.ON = 1;

  // setting up communiction with DAC
  CS2 = 1;
  SPI4CON = 0;
  SPI4BRG = 10;
  //SPI4BUF;
  SPI4BUF;
  SPI4STATbits.SPIROV = 0;
  SPI4CONbits.MODE32 = 0;
  SPI4CONbits.MODE16 = 1;
  SPI4CONbits.MSTEN = 1;
  SPI4CONbits.CKE = 1;
  SPI4CONbits.CKP = 1;
  SPI4CONbits.ON = 1;
}

void chip_write_data(int d_sig){
  CS2 = 0;
  SPI4BUF = d_sig;
  while(!SPI4STATbits.SPIRBF){
  }
  SPI4BUF;
  CS2 = 1;
}

int twocompconv(int s){
  if (s>=8192){
    s = s - 8192;
  } else {
    s = s + 8191;
  }
  return s;
}

void chip_read_data(){
  CNVST = 0;
  wait(2);
  CNVST = 1;
  wait(5);
  CS1 = 0;
  SPI3BUF = 0;
  while(!SPI3STATbits.SPIRBF){
  }
  sig = SPI3BUF;
  CS1 = 1;
  sig1 = (double) twocompconv((sig>>4) & 0x3FFF);
  sig2 = (double) twocompconv((sig>>18) & 0x3FFF);
}

void interrupt_init(){
  // setting up external interrupts for encoder
  // pin D8 set up as interrupt on rising edge
  INTCONbits.INT1EP = 1;
  IPC1bits.INT1IP = 1;
  IPC1bits.INT1IS = 0;
  IFS0bits.INT1IF = 0;
  IEC0bits.INT1IE = 1;
  // pin D9 set up as interrupt on rising edge
  INTCONbits.INT2EP = 1;
  IPC2bits.INT2IP = 1;
  IPC2bits.INT2IS = 0;
  IFS0bits.INT2IF = 0;
  IEC0bits.INT2IE = 1;
  // pin D10 set up as interrupt on falling edge
  INTCONbits.INT3EP = 0;
  IPC3bits.INT3IP = 6;
  IPC3bits.INT3IS = 0;
  IFS0bits.INT3IF = 0;
  IEC0bits.INT3IE = 1;
  // // pin D11 set up as interrupt on falling edge
  // INTCONbits.INT4EP = 1;
  // IPC4bits.INT4IP = 6;
  // IPC4bits.INT4IS = 0;
  // IFS0bits.INT4IF = 0;
  // IEC0bits.INT4IE = 1;

  // initialize friction control interrupt

  PR4 =  7982; // freq = 80,000,000/(1+3199) = 10kHz
  PR4 = 15970;
  TMR4 = 0;
  T4CONbits.TCKPS = 0; // = 1
  T4CONbits.ON = 1;
  IPC4bits.T4IP = 4;
  IPC4bits.T4IS = 0;
  IFS0bits.T4IF = 0;
  IEC0bits.T4IE = 1;

  // PR5 =  6249; // freq = 80,000,000/(1+3199) = 10kHz
  // TMR5 = 0;
  // T5CONbits.TCKPS = 6; // = 1
  // T5CONbits.ON = 1;
  // IPC5bits.T5IP = 4;
  // IPC5bits.T5IS = 0;
  // IFS0bits.T5IF = 0;
  // IEC0bits.T5IE = 1;
}

void find_avg(){
  if (avc<avn){
    sig1s = sig1s + sig1;
    sig2s = sig2s + sig2;
    avc++;
    if (avc==avn){
      avc++;
      sig1av = sig1s/((long double) avn);
      sig2av = sig2s/((long double) avn);
      sig1s = 0.0;
      sig2s = 0.0;
    }
  }
}

void sample_lat_des(){ // readings are in N
  chip_read_data();
  lat = (sig1 - sig1av)/adcbits*VtoFlat*20.0; // N
  des = (sig2 - sig2av)/adcbits*0.2; // *20.0/100.0 5V = 50mN
  alat = absd(lat);
}

void output_compute(){
  chip_out = (int) ((5.0 + controller())/10.0*dacbits);
  if (chip_out > dacbits){
    chip_out = (int) dacbits;
  }
  if (chip_out < 0){
    chip_out = 0;
  }
}

void __ISR(_TIMER_4_VECTOR,IPL4SOFT) Timer4ISR(void){
  // friction sample, filter, and feedback routine
  t += .0002;

  // find_avg(); // remove DC offset
  // sample_lat_des(); // sample lat data
  // output_compute(); // compute the output of FM
  // chip_write_data(chip_out); // write signal

  if(mot++==99){
      move_slide(possel,velsel); // move the slider
      mot = 0;
    }

  step_motor_move(des_pos); // move the stepper motor

  IFS0bits.T4IF = 0;
}


void __ISR(_EXTERNAL_1_VECTOR, IPL1SOFT) Ext1ISR(void) {
if (t1 == 0){
  enc_val+= (PORTDbits.RD9 == 1) - (PORTDbits.RD9 == 0);
  t2 = 0;
}
t1 = 1;

  // if (PORTDbits.RD9 == 0){
  //   enc_val-=1;
  // }
  // else{
  //   enc_val+=1;
  // }
  IFS0bits.INT1IF = 0;
}

void __ISR(_EXTERNAL_2_VECTOR, IPL1SOFT) Ext2ISR(void) {
  if (t2 == 0){
    enc_val+= (PORTDbits.RD8 == 0) - (PORTDbits.RD8 == 1);
    t1 = 0;
  }
  t2 = 1;
  //
  // if (PORTDbits.RD8 == 0){
  //   enc_val+=1;
  // }
  // else{
  //   enc_val-=1;
  // }
  IFS0bits.INT2IF = 0;
}

void __ISR(_EXTERNAL_3_VECTOR, IPL6SOFT) Ext3ISR(void) {
  butt = 1;
  IFS0bits.INT3IF = 0;
}
