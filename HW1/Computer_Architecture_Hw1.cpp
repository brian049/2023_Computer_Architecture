#include<stdio.h>
#include<iostream>
using namespace std;

float fp32_to_bf16(float x)                 
{
    float y = x;
    int *p = (int *) &y;
    unsigned int exp = *p & 0x7F800000;
    unsigned int man = *p & 0x007FFFFF;

    if (exp == 0 && man == 0) /* zero */
        return x;
    if (exp == 0x7F800000) /* infinity or NaN */
        return x;

    /* Normalized number */
    /* round to nearest */
    float r = x;
    int *pr = (int *) &r;
    *pr &= 0xFF800000;  /* r has the same exp as x */
    r /= 0x100;
    y = x + r;

    *p &= 0xFFFF0000;

    cout << y << endl;
    return y;
}

int main(){
    // Three test cases
    float x[3] = {0.000000, 1.200000,5.630000};
    float y[3] = {1.200000, 5.630000,2.312500};
    for(int i=0; i<3; i++){
        x[i] = fp32_to_bf16(x[i]);
        y[i] = fp32_to_bf16(y[i]);
    }
    for(int i=0; i<3; i++){
        cout << x[i]*y[i] << endl;
    }
}