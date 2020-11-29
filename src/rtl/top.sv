`default_nettype none
`timeunit        1ns
`timeprecision   1ps

`define          WORD 32
`define          NB   4   // number of data words

`define          NK4      // 128 bit key mode
/*-----------------------------------------------
`define          NK6      // 196 bit key mode
`define          NK8      // 256 bit key mode
 -----------------------------------------------*/

`ifdef           NK4
`define          NK   4
`define          NR   10
`elsif           NK6
`define          NK   6
`define          NR   12
`elsif           NK8
`define          NK   8
`define          NR   14
`endif

module top #(
    parameter WORD = `WORD,   // word size in bits
    parameter NB   = `NB,    // number of data words
    parameter NK   = `NK,  // keylength / wordsize
    parameter NR   = `NR   // number of rounds
) (

);

endmodule
