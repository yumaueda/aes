#include <stdbool.h>
#include <stdio.h>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vround.h"

#define TRACE_LEVEL                 99
#define MASTER_CLK_HALF             (10/2)          // 100MHz
#define SIM_TIME                    50

// Cipher
#define FIPS_CIPHER_START3          0x193de3be
#define FIPS_CIPHER_START2          0xa0f4e22b
#define FIPS_CIPHER_START1          0x9ac68d2a
#define FIPS_CIPHER_START0          0xe9f84808

#define FIPS_CIPHER_ROUND_KEY3      0xa0fafe17
#define FIPS_CIPHER_ROUND_KEY2      0x88542cb1
#define FIPS_CIPHER_ROUND_KEY1      0x23a33939
#define FIPS_CIPHER_ROUND_KEY0      0x2a6c7605
/*--------------------------------------------
#define FIPS_CIPHER_AFT_SUB3        0xd42711ae
#define FIPS_CIPHER_AFT_SUB2        0xe0bf98f1
#define FIPS_CIPHER_AFT_SUB1        0xb8b45de5
#define FIPS_CIPHER_AFT_SUB0        0x1e415230

#define FIPS_CIPHER_AFT_SHIFT3      0xd4bf5d30
#define FIPS_CIPHER_AFT_SHIFT2      0xe0b452ae
#define FIPS_CIPHER_AFT_SHIFT1      0xb84111f1
#define FIPS_CIPHER_AFT_SHIFT0      0x1e2798e5

#define FIPS_CIPHER_AFT_MIX3        0x046681e5
#define FIPS_CIPHER_AFT_MIX2        0xe0cb199a
#define FIPS_CIPHER_AFT_MIX1        0x48f8d37a
#define FIPS_CIPHER_AFT_MIX0        0x2806264c
 --------------------------------------------*/

#define FIPS_CIPHER_AFT_ADD3        0xa49c7ff2
#define FIPS_CIPHER_AFT_ADD2        0x689f352b
#define FIPS_CIPHER_AFT_ADD1        0x6b5bea43
#define FIPS_CIPHER_AFT_ADD0        0x026a5049

vluint64_t main_time = 0;

int main(int argc, char **argv)
{
    // TODO: Use FST instead of VCD
    Verilated::commandArgs(argc, argv);
    Verilated::traceEverOn(true);

    // Round
    Vround *top = new Vround;
    VerilatedVcdC *tfp = new VerilatedVcdC;
    bool pass = false;

    top->trace(tfp, TRACE_LEVEL);
    tfp->open("sim_round.vcd");

    printf("--- Verilator testbench for the round module ---\n");
    printf("Input State:\t{%#08x, %#08x, %#08x, %#08x}\n",
            FIPS_CIPHER_START3,
            FIPS_CIPHER_START2,
            FIPS_CIPHER_START1,
            FIPS_CIPHER_START0);
    printf("Round Key:\t{%#08x, %#08x, %#08x, %#08x}\n",
            FIPS_CIPHER_ROUND_KEY3,
            FIPS_CIPHER_ROUND_KEY2,
            FIPS_CIPHER_ROUND_KEY1,
            FIPS_CIPHER_ROUND_KEY0);

    top->clk = 1;
    top->rst = 0;
    top->i_valid = 0;
    top->i_block[0] = 0;
    top->i_block[1] = 0;
    top->i_block[2] = 0;
    top->i_block[3] = 0;
    top->i_roundkey[0] = 0;
    top->i_roundkey[1] = 0;
    top->i_roundkey[2] = 0;
    top->i_roundkey[3] = 0;

    while (main_time < SIM_TIME) {
        if (main_time % MASTER_CLK_HALF == 0) {
            top->clk = top->clk ? 0 : 1;
        }
        if (main_time >= 4) top->rst = 1;
        if (main_time >= 14) {
            top->i_valid = 1;
            top->i_block[0] = FIPS_CIPHER_START0;
            top->i_block[1] = FIPS_CIPHER_START1;
            top->i_block[2] = FIPS_CIPHER_START2;
            top->i_block[3] = FIPS_CIPHER_START3;
            top->i_roundkey[0] = FIPS_CIPHER_ROUND_KEY0;
            top->i_roundkey[1] = FIPS_CIPHER_ROUND_KEY1;
            top->i_roundkey[2] = FIPS_CIPHER_ROUND_KEY2;
            top->i_roundkey[3] = FIPS_CIPHER_ROUND_KEY3;
        }
        if (main_time >= 16)
            top->i_valid = 0;
        top->eval();
        tfp->dump(++main_time);
    }

    printf("Output State:\t{%#08x, %#08x, %#08x, %#08x}\n",
            top->o_block[3],
            top->o_block[2],
            top->o_block[1],
            top->o_block[0]);

    printf("Expected State:\t{%#08x, %#08x, %#08x, %#08x}\n",
            FIPS_CIPHER_AFT_ADD3,
            FIPS_CIPHER_AFT_ADD2,
            FIPS_CIPHER_AFT_ADD1,
            FIPS_CIPHER_AFT_ADD0);

    pass = top->o_block[0] == FIPS_CIPHER_AFT_ADD0 &&
           top->o_block[1] == FIPS_CIPHER_AFT_ADD1 &&
           top->o_block[2] == FIPS_CIPHER_AFT_ADD2 &&
           top->o_block[3] == FIPS_CIPHER_AFT_ADD3;

    tfp->close();
    top->final();
    delete top;

    printf("Result: \x1b[1m");
    if (pass) {
        printf("\x1b[32m" "\tpassed\n\x1b[0m");
        return 0;
    } else {
        printf("\x1b[31m" "\tfailed\n\x1b[0m");
        return 1;
    }

    return 0;
}
