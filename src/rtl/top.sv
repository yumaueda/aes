`default_nettype             none
`timescale                   1ns / 1ps
`include                     "param.svh"

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
     It would go back to 0x00000000_00000000_00000000_00000000
     if we increment the counter by one when WRAP == true.
     -------------------------------------------------------------------*/
) (
    input  wire                 clk, rst,
    input  wire                 i_keyexp_en,
    input  wire [NK*WORD-1:0]   i_key,
    input  wire [1:0]           i_mode,
    input  wire [WORD*NB-1:0]   i_nonce,
    input  wire [7:0]           i_noncesize,
    input  wire                 i_axi4s_tvalid,
    input  wire                 o_axi4s_tready,
    input  wire [WORD*NB-1:0]   i_axi4s_tdata,
    input  wire                 i_axi4s_tlast,
    input  wire [WORD*NB/8-1:0] i_axi4s_tstrb,
    output wire                 o_axi4s_tvalid,
    input  wire                 i_axi4s_tready,
    output wire [WORD*NB-1:0]   o_axi4s_tdata,
    output wire                 o_axi4s_tlast,
    output wire [WORD*NB/8-1:0] o_axi4s_tstrb
);

endmodule
