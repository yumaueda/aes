#include <stdbool.h>
#include <stdio.h>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vkeyexp.h"

#define TRACE_LEVEL                 99
#define MASTER_CLK_HALF             (10/2)      // 100MHz
#define SIM_TIME_128                410

// Expansion of a 128-bit Cipher Key
#define FIPS_KEYEXP_128_CIPHER_KEY3 0x2b7e1516
#define FIPS_KEYEXP_128_CIPHER_KEY2 0x28aed2a6
#define FIPS_KEYEXP_128_CIPHER_KEY1 0xabf71588
#define FIPS_KEYEXP_128_CIPHER_KEY0 0x09cf4f3c

static unsigned int fips_keyexp_128_w[44] = {
    FIPS_KEYEXP_128_CIPHER_KEY3, FIPS_KEYEXP_128_CIPHER_KEY2,
    FIPS_KEYEXP_128_CIPHER_KEY1, FIPS_KEYEXP_128_CIPHER_KEY0,
    0xa0fafe17, 0x88542cb1, 0x23a33939, 0x2a6c7605,
    0xf2c295f2, 0x7a96b943, 0x5935807a, 0x7359f67f,
    0x3d80477d, 0x4716fe3e, 0x1e237e44, 0x6d7a883b,
    0xef44a541, 0xa8525b7f, 0xb671253b, 0xdb0bad00,
    0xd4d1c6f8, 0x7c839d87, 0xcaf2b8bc, 0x11f915bc,
    0x6d88a37a, 0x110b3efd, 0xdbf98641, 0xca0093fd,
    0x4e54f70e, 0x5f5fc9f3, 0x84a64fb2, 0x4ea6dc4f,
    0xead27321, 0xb58dbad2, 0x312bf560, 0x7f8d292f,
    0xac7766f3, 0x19fadc21, 0x28d12941, 0x575c006e,
    0xd014f9a8, 0xc9ee2589, 0xe13f0cc8, 0xb6630ca6
};

vluint64_t main_time = 0;

double sc_time_stamp(void) {
    return main_time;
}

static bool test(Vkeyexp* top, unsigned int arr_w[], size_t len)
{
    bool pass = true;
    size_t passcount = 0;

    for (size_t i = 0; i < len; i++) {
        if (top->o_w[i] == arr_w[i]) {
            passcount++;
            printf("\x1b[32m");
        } else {
            pass = false;
            printf("\x1b[31m");
        }
        printf("\r%zu/%zu\x1b[0m: \t"
                "Checking if the output of the module matches the expected one...",
                passcount,
                len);
    }
    printf("\n");

    for (size_t i = 0; i < len; i++) {
        if (top->o_w[i] == arr_w[i])
            printf("\tw[%zu]:\t%#08x\t"
                    "arr_w[%zu]:\t%#08x\t\n", i, top->o_w[i], i, arr_w[i]);
        else
            printf("\tw[%zu]:\t\x1b[1;31m%#08x\x1b[0m\t"
                    "arr_w[%zu]:\t%#08x\t\n", i, top->o_w[i], i, arr_w[i]);
    }

    printf("\x1b[0mResult: \x1b[1m");
    if (pass)
        printf("\x1b[32m" "\tPassed\n");
    else
        printf("\x1b[31m" "\t%zu/%zu failed\n", len-passcount, len);
    printf("\x1b[0m");

    return pass;
}

int main(int argc, char **argv)
{
    // TODO: Use FST instead of VCD
    Verilated::commandArgs(argc, argv);
    Verilated::traceEverOn(true);

    // Expansion of a 128-bit Cipher Key
    Vkeyexp *top = new Vkeyexp;
    VerilatedVcdC *tfp = new VerilatedVcdC;

    int i;
    bool r;
    size_t len = sizeof(fips_keyexp_128_w)/sizeof(fips_keyexp_128_w[0]);

    top->trace(tfp, TRACE_LEVEL);
    tfp->open("sim_keyexp_128.vcd");

    printf("--- Verilator testbench for the keyexp module (128-bit Cipher Key) ---\n");
    printf("Cipher Key:\t{%#08x, %#08x, %#08x, %#08x}\n",
            FIPS_KEYEXP_128_CIPHER_KEY0,
            FIPS_KEYEXP_128_CIPHER_KEY1,
            FIPS_KEYEXP_128_CIPHER_KEY2,
            FIPS_KEYEXP_128_CIPHER_KEY3);

    top->clk = 1;
    top->rst = 0;
    top->i_valid = 0;
    top->i_key[0] = 0;
    top->i_key[1] = 0;
    top->i_key[2] = 0;
    top->i_key[3] = 0;

    while (sc_time_stamp() < SIM_TIME_128) {
        if (main_time % MASTER_CLK_HALF == 0) {
            top->clk = top->clk ? 0 : 1;
        }
        if (main_time >= 4) top->rst = 1;
        if (main_time >= 14) {
            top->i_valid = 1;
            top->i_key[0] = FIPS_KEYEXP_128_CIPHER_KEY0;
            top->i_key[1] = FIPS_KEYEXP_128_CIPHER_KEY1;
            top->i_key[2] = FIPS_KEYEXP_128_CIPHER_KEY2;
            top->i_key[3] = FIPS_KEYEXP_128_CIPHER_KEY3;
        }
        if (main_time >= 16) {
            top->i_valid = 0;
            for (i = 0; i < 4; i++)
                top->i_key[i] = 0;
        }
        top->eval();
        tfp->dump(++main_time);
    }

    r = test(top, fips_keyexp_128_w, len);

    tfp->close();
    top->final();
    delete top;

    if (r) return 0;
    else   return 1;
}
