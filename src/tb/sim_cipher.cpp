#include <stdbool.h>
#include <stdio.h>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vcipher.h"

#define TRACE_LEVEL                 99
#define MASTER_CLK                  10
#define MASTER_CLK_HALF             (MASTER_CLK/2)  // 100MHz
#define SIM_TIME_AES_128            ((MASTER_CLK*4)*10+MASTER_CLK)

vluint64_t main_time = 0;

double sc_time_stamp(void) {
    return main_time;
}

static unsigned int fips_vector_output_128[4] = {
    0x69c4e0d8,
    0x6a7b0430,
    0xd8cdb780,
    0x70b4c55a
};

static unsigned int fips_vector_input_128[4] = {
    0xccddeeff,
    0x8899aabb,
    0x44556677,
    0x00112233
};

static unsigned int fips_vector_key_128[4] = {
    0x0c0d0e0f,
    0x08090a0b,
    0x04050607,
    0x00010203
};

template <typename Top> static void tick(Top *top, VerilatedVcdC *tfp)
{
    top->eval();
    tfp->dump(++main_time);
}

// size of an unsigned int array of state must be 4
static void print_state(unsigned int state[], const char *msg)
{
    printf("%s:\t{%#08x, %#08x, %#08x, %#08x}\n",
            msg,
            state[3],
            state[2],
            state[1],
            state[0]);
}

static void print_cipher_key(unsigned int key[], ssize_t len)
{
    printf("Cipher Key:\t{");
    for (ssize_t i = 0; i < len; i++) {
        if (i != len-1)
            printf("%#08x, ", key[len-1-i]);
        else
            printf("%#08x", key[len-1-i]);
    }
    printf("}\n");
}

int main(int argc, char **argv)
{
    int i = 0;

    // TODO: Use FST instead of VCD
    Verilated::commandArgs(argc, argv);
    Verilated::traceEverOn(true);

    // 
    Vcipher *top = new Vcipher;
    VerilatedVcdC *tfp = new VerilatedVcdC;

    top->trace(tfp, TRACE_LEVEL);
    tfp->open("sim_cipher_aes128.vcd");

    printf("--- Verilator testbench for the cipher module (AES-128) ---\n");
    print_cipher_key(
            fips_vector_key_128,
            sizeof(fips_vector_key_128)/sizeof(fips_vector_key_128[0]));
    print_state(fips_vector_input_128, "Input State");

    top->clk = 1;
    top->rst = 0;
    top->i_keyexp_en = 1;
    for (i = 0; i < 4; i++)
        top->i_key[i] = fips_vector_key_128[i];
    top->i_valid = 1;
    top->i_mode = 1;
    for (i = 0; i < 4; i++) {
        top->i_block[i] = fips_vector_input_128[i];
        top->i_nonce[i] = 0;
    }
    top->i_nonce_size = 0;
    top->i_last = 1;
    top->i_strb = 0xFFFF;

    while (sc_time_stamp() < SIM_TIME_AES_128) {
        if (main_time % MASTER_CLK_HALF == 0) {
            top->clk = top->clk ? 0 : 1;
            if (top->clk && !top->rst) {
                top->rst = 1;
            } else if (top->clk && top->i_valid) {
                top->i_keyexp_en = 0;
                top->i_valid = 0;
            }
        }
        tick(top, tfp);
    }

    tfp->close();
    top->final();
    delete top;

    return 0;
}
