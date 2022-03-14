#include "dsp.h"
#include "interrupts.h"
// 
// double rfilter(int order, double *b, double *a, double *s, double *sf){
//   switch (order){
//     case 1:
//       return (b[0]*s[0] + b[1]*s[1] - a[0]*sf[0]);
//     break;
//     case 2:
//       return (b[0]*s[0] + b[1]*s[1] + b[2]*s[2] - a[0]*sf[0] - a[1]*sf[1]);
//     break;
//   }
// }
