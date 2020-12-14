#include <cassert>

bool test_state
(unsigned int output_state[], unsigned int expected_state[], ssize_t len)
{
    assert(len == 4);

    bool pass = true;
    ssize_t passcount = 0;

    for (size_t i = 0; i < len; i++) {
        if (output_state[i] == expected_state[i]) {
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
        if (output_state[i] == expected_state[i])
            printf("\toutput_state[%zu]:\t%#08x\t"
                    "expected_state[%zu]:\t%#08x\n", i, output_state[i], i, expected_state[i]);
        else
            printf("\toutput_state[%zu]:\t\x1b[1;31m%#08x\x1b[0m\t"
                    "expected_state[%zu]:\t%#08x\n", i, output_state[i], i, expected_state[i]);
    }

    printf("\x1b[0mResult: \x1b[1m");
    if (pass)
        printf("\x1b[32m" "\tPassed\n");
    else
        printf("\x1b[31m" "\t%zu/%zu failed\n", len-passcount, len);
    printf("\x1b[0m");

    return pass;
}
