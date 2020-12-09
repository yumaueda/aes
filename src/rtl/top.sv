`default_nettype             none
`timescale                   1ns / 1ps

`define          WORD        32
`define          NB          4   // number of data words

`define          NK4             // 128 bit key mode
/*--------------------------------------------------
`define          NK6             // 196 bit key mode
`define          NK8             // 256 bit key mode
 --------------------------------------------------*/

`define          ENC_ONLY
/*-----------------------
`define          DEC_ONLY
`define          ENC_AND_DEC
 -----------------------*/
/*-----------------------
`define          ECB_ONLY
`define          CTR_ONLY
 -----------------------*/
`define          ECB_AND_CTR
`define          WRAP        0

// Don't edit this part
`ifdef           NK4
`define          NK          4
`define          NR          10
`elsif           NK6
`define          NK          6
`define          NR          12
`elsif           NK8
`define          NK          8
`define          NR          14
`endif

`ifdef           ENC_ONLY
`define          ENC         1
`define          DEC         0
`elsif           DEC_ONLY
`define          ENC         0
`define          DEC         1
`elsif           ENC_AND_DEC
`define          ENC         1
`define          DEC         1
`endif

`ifdef           ECB_ONLY
`define          ECB         1
`define          CTR         0
`elsif           CTR_ONLY
`define          ECB         0
`define          CTR         1
`elsif           ECB_AND_CTR
`define          ECB         1
`define          CTR         1
`endif
// end

module top #(
    parameter WORD = `WORD,   // word size in bits
    parameter NB   = `NB,     // number of data words
    parameter NK   = `NK,     // keylength / wordsize
    parameter NR   = `NR,     // number of rounds
    parameter ENC  = `ENC,
    parameter DEC  = `DEC,
    parameter ECB  = `ECB,
    parameter CTR  = `CTR,
    parameter WRAP = `WRAP    // see description below
    /*-------------------------------------------------------------------
     true: see the entire block as a counter. wrap around on entire block
     false: wrap around only on counter.

     i.e.
     
     Suppose nonce/counter == 0xffffffff_ffffffff_ffffffff_ffffffff.
     We would go back to 0x00000000_00000000_00000000_00000000
     if we increment the counter by one when WRAP == true.
     -------------------------------------------------------------------*/
) (

);

endmodule
