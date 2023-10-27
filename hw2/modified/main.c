#include <stdint.h>
#include <stdio.h>
#include <string.h>

extern uint64_t get_cycles();
extern uint64_t get_instret();

/*
 * Taken from the Sparkle-suite which is a collection of lightweight symmetric
 * cryptographic algorithms currently in the final round of the NIST
 * standardization effort.
 * See https://sparkle-lwc.github.io/
 */
extern int fp32_to_bf16(int a, int b);

int main(void)
{
    int a = 0x42491111;
    int b = 0xc2931111;
    int ans = 0;
    /* measure cycles */
    uint64_t instret = get_instret();
    uint64_t oldcount = get_cycles();
    ans = fp32_to_bf16(a, b);
    uint64_t cyclecount = get_cycles() - oldcount;

    printf("multiplication answer: 0x%x\n", ans);
    printf("cycle count: %u\n", (unsigned int) cyclecount);
    printf("instret: %x\n", (unsigned) (instret & 0xffffffff));
    return 0;
}
