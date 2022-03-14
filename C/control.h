#ifndef control
#define control

double controller();
double compute_sig();
void speed_select(int);
void compute_P();
void stepper_motor_step(int);
void step_motor_move(int);
void move_slide(int, int);

// message related things
char message[100], option;

// friction control specific paramters

int controldist[] = {2500,27500,31250,37750,62750,65250}, render_flag = 0, texture_c = 0, texture_cm = 0, effect_on = 0, feedback_enable = 0, texture_count_max = 7500, texture_flag = 0;
double Pval = 3000.0, texture_mean = 0.0, lat_start = 0.0, texture_vals[7500], lat_s = 0, tex = 0.0;
int Pvalflag, recordP = 0;
int i; // generic variable

#endif
