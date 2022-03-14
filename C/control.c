#include <xc.h>          // Load the proper header for the processor
#include "constants.h"
#include "interrupts.h"
#include "control.h"
#include "NU32.h"
#include <math.h>
#include "helpers.h"
#include "dsp.h"

double compute_cont(){
  cont = 0.0;
  for (i=0;i<6;i++){
    S[i] = sin(2*pi*t*F[i]);
    C[i] = cos(2*pi*t*F[i]);

    ERRN[i][0][1] = ERRN[i][0][0];
    ERRN[i][0][0] = S[i]*err;
    ERRN[i][1][1] = ERRN[i][1][0];
    ERRN[i][1][0] = C[i]*err;

    CONT[i][0][0] = ERRN[i][0][0]*controlb[i][0] + ERRN[i][0][1]*controlb[i][1] - CONT[i][0][0]*controla[i];
    CONT[i][1][0] = ERRN[i][1][0]*controlb[i][0] + ERRN[i][1][1]*controlb[i][1] - CONT[i][1][0]*controla[i];

    cont += A[i]*(CONT[i][0][0]*S[i] + CONT[i][1][0]*C[i]); //HPC[i];
  }

  return cont;
}

double controller(){

  alatf = ldlgb[0]*alat+ ldlgb[1]*alato - alatf*ldlga[0];
  alato = alat;
  err = des - alatf;

  if (feedback_enable == 1){
    return compute_cont();
  } else {
    return des*A[0];
  }
}

void speed_select(int speed){ // select speed of the motor
  switch (speed){
    case 0:
    V1 = 0;
    V2 = 0;
    break;
    case 1:
    V1 = 1;
    V2 = 0;
    break;
    case 2:
    V1 = 0;
    V2 = 1;
    break;
    case 3:
    V1 = 1;
    V2 = 1;
    break;
  }
}

void stepper_motor_step(int dir){
  switch(stepper_val){
    case 0:
    P1 = 0;
    P2 = 0;
    P3 = 0;
    P4 = 1;
    break;
    case 1:
    P1 = 0;
    P2 = 0;
    P3 = 1;
    P4 = 1;
    break;
    case 2:
    P1 = 0;
    P2 = 0;
    P3 = 1;
    P4 = 0;
    break;
    case 3:
    P1 = 0;
    P2 = 1;
    P3 = 1;
    P4 = 0;
    break;
    case 4:
    P1 = 0;
    P2 = 1;
    P3 = 0;
    P4 = 0;
    break;
    case 5:
    P1 = 1;
    P2 = 1;
    P3 = 0;
    P4 = 0;
    break;
    case 6:
    P1 = 1;
    P2 = 0;
    P3 = 0;
    P4 = 0;
    break;
    case 7:
    P1 = 1;
    P2 = 0;
    P3 = 0;
    P4 = 1;
    break;
  }

  if (dir == 0){
    if((stepper_val++)==8){
      stepper_val = 0;
    }
    mot_pos--;
  }
  else{
    if((stepper_val--)==-1){
      stepper_val = 7;
    }
    mot_pos++;
  }
}

void step_motor_move(int dpos){
  if (mot_pos<dpos){
    if (stepmotit++==stepmotspeed){
      stepper_motor_step(1);
      stepmotit = 0;
    }
  }
  if (mot_pos>dpos){
    if (stepmotit++==stepmotspeed){
      stepper_motor_step(0);
      stepmotit = 0;
    }
  }
}

void move_slide(int pf, int v){
  if (complete_flag == 0){
    if (pf<enc_val){
      DIR = 0;
    } else {
      DIR = 1;
    }
    complete_flag = 1;
    speed_select(v);
  }
  if (complete_flag == 1){
    if (DIR == 0){

      if (enc_val<50000){
        led_flag = 1;
      } else {
        led_flag = 0;
      }

      if (enc_val<30000){
        led_flag = 2;
      }

      if (led_flag == 0){
        LED1 = 0;
        LED2 = 1;
      }

      if (led_flag == 1){
        LED1 = 0;
        LED2 = 0;
      }

      if (led_flag == 2){
        LED1 = 1;
        LED2 = 0;
      }

      if (enc_val<=pf){
        speed_select(0);
        complete_flag = 2;
        led_flag = 0;
        LED1 = 1;
        LED2 = 1;
      }

    } else {
      if (enc_val>=pf){
        speed_select(0);
        complete_flag = 2;
      }
    }
  }
}
