#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vround.h"

#define TRACE_LEVEL            99
#define VCD_NAME               "round.vcd"
#define SIM_TIME               60

#define MASTER_CLK_HALF        (10/2)          // 100MHz

#define FIPS_CIPHER_START3     0x193de3be
#define FIPS_CIPHER_START2     0xa0f4e22b
#define FIPS_CIPHER_START1     0x9ac68d2a
#define FIPS_CIPHER_START0     0xe9f84808

#define FIPS_CIPHER_ROUND_KEY3 0xa0fafe17
#define FIPS_CIPHER_ROUND_KEY2 0x88542cb1
#define FIPS_CIPHER_ROUND_KEY1 0x23a33939
#define FIPS_CIPHER_ROUND_KEY0 0x2a6c7605
/*---------------------------------------
#define FIPS_CIPHER_AFT_SUB3   0xd42711ae
#define FIPS_CIPHER_AFT_SUB2   0xe0bf98f1
#define FIPS_CIPHER_AFT_SUB1   0xb8b45de5
#define FIPS_CIPHER_AFT_SUB0   0x1e415230

#define FIPS_CIPHER_AFT_SHIFT3 0xd4bf5d30
#define FIPS_CIPHER_AFT_SHIFT2 0xe0b452ae
#define FIPS_CIPHER_AFT_SHIFT1 0xb84111f1
#define FIPS_CIPHER_AFT_SHIFT0 0x1e2798e5

#define FIPS_CIPHER_AFT_MIX3   0x046681e5
#define FIPS_CIPHER_AFT_MIX2   0xe0cb199a
#define FIPS_CIPHER_AFT_MIX1   0x48f8d37a
#define FIPS_CIPHER_AFT_MIX0   0x2806264c

#define FIPS_CIPHER_AFT_ADD3   0xa49c7ff2
#define FIPS_CIPHER_AFT_ADD2   0x689f352b
#define FIPS_CIPHER_AFT_ADD1   0x6b5bea43
#define FIPS_CIPHER_AFT_ADD0   0x026a5049
 ---------------------------------------*/

vluint64_t main_time = 0;

double sc_time_stamp(void) {
    return main_time;
}

int main(int argc, char **argv)
{
    Verilated::commandArgs(argc, argv);
    Verilated::traceEverOn(true);

    Vround *top = new Vround;
    VerilatedVcdC *tfp = new VerilatedVcdC;

    top->trace(tfp, TRACE_LEVEL);
    tfp->open(VCD_NAME);

    top->clk = 1;
    top->rst = 0;
    top->i_valid = 1;
    top->i_block[0] = FIPS_CIPHER_START0;
    top->i_block[1] = FIPS_CIPHER_START1;
    top->i_block[2] = FIPS_CIPHER_START2;
    top->i_block[3] = FIPS_CIPHER_START3;
    top->i_roundkey[0] = FIPS_CIPHER_ROUND_KEY0;
    top->i_roundkey[1] = FIPS_CIPHER_ROUND_KEY1;
    top->i_roundkey[2] = FIPS_CIPHER_ROUND_KEY2;
    top->i_roundkey[3] = FIPS_CIPHER_ROUND_KEY3;

    while (sc_time_stamp() < SIM_TIME) {
        if (main_time % MASTER_CLK_HALF == 0) {
            top->clk = top->clk ? 0 : 1;
            if (top->clk && !top->rst)
                top->rst = ~top->rst;
        }
        top->eval();
        tfp->dump(++main_time);
    }

    tfp->close();
    top->final();
    delete top;

    return 0;
}
