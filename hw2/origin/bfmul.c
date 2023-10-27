# include<stdio.h>

float fp32_to_bf16(float x)                 
{
    float y = x;
    int *p = (int *) &y;
    unsigned int exp = *p & 0x7F800000;
    unsigned int man = *p & 0x007FFFFF;
    if (exp == 0 && man == 0) /* zero */
        return x;
    if (exp == 0x7F800000 /* Fill this! */) /* infinity or NaN */
        return x;

    /* Normalized number */
    /* round to nearest */
    float r = x;
    int *pr = (int *) &r;
    *pr &= 0xFF800000;  /* r has the same exp as x */
    r /= 0x100 /* Fill this! */;
    y = x + r;

    *p &= 0xFFFF0000;

    return y;
}

int main(){
    float x = 50.266666412353515625; //0x42491111 
    x = fp32_to_bf16(x);
    printf("%f\n", x);
    
    float xx = -73.53333282470703125; //0xc2931111 
    xx = fp32_to_bf16(xx);
    printf("%f\n", xx);
    
    printf("%f\n", x*xx);
}
