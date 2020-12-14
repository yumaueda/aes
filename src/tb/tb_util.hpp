#include <verilated.h>
#include <verilated_vcd_c.h>

template <typename Top>
static inline void tick(Top *top, VerilatedVcdC *tfp)
{
    top->eval();
    tfp->dump(++main_time);
}

bool test_state
(unsigned int output_state[], unsigned int expected_state[], ssize_t len);
