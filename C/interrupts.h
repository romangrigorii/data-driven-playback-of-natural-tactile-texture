#ifndef interrupts
#define interrupts

#define CNVST LATBbits.LATB4
#define CS1 LATBbits.LATB10
#define CS2 LATBbits.LATB11
#define LED2 LATBbits.LATB12
#define LED1 LATBbits.LATB13

#define P1 LATBbits.LATB0
#define P2 LATBbits.LATB1
#define P3 LATBbits.LATB2
#define P4 LATBbits.LATB3

#define V1 LATBbits.LATB5
#define V2 LATBbits.LATB6
#define DIR LATBbits.LATB7
#define MON LATBbits.LATB8



void chip_read_data();
void chip_write_data(int);
int twocompconv(int);
void pin_init();
void SPI_com_init();
void interrupt_init();
void sample_lat_nor();
void sample_lat_des();
void output_compute();
void find_avg();

// signal processing related initialization
int sig, chip_out = 0, avc = 0, avn = 1000, val = 0, stepmotspeed = 6, stepmotit = 0, mot_pos = 0, des_pos = 0, stepper_val = 0;
int posnow = 0;
int rt, ff, ti = 0, butt = 0;
double sig1, sig2, sig1s = 0.0, sig2s = 0.0, sig1av = 0.0, sig2av = 0.0, t = 0.0;
double alat, alatf, nor, norf, lat, latf, des;
int mot = 0, led_flag = 1;

int t1 = 0, t2 = 0;

// sensor constants
double VtoFlat = .444444, VtoFnor = -.134;

// chip communication related initialization
double adcbits = 16833, dacbits = 65535;

// motor and encoder related initialization
int enc_val = 0, velsel = 0, possel = 0, complete_flag = 1;

#endif
