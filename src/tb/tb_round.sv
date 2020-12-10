`default_nettype none
`timescale       1ns / 1ps
`include         "param.svh"

interface round_if # (
    parameter WORD = 32,
    parameter NB   = 4,
) (
    input logic clk, rst
)

    logic               i_valid;
    logic [WORD*NB-1:0] i_block;
    logic [WORD*NB-1:0] i_roundkey;
    logic               o_valid;
    logic [WORD*NB-1:0] o_block;

endinterface

`ifndef VERILATOR
program round_test (
);
endprogram
`endif

module tb_round;

    localparam CYCLE = 10;

    localparam WORD  = `WORD,
    localparam NB    = `NB,
    localparam FINAL = 0

    round #(
        .WORD(WORD),
        .NB(NB),
        .FINAL(FINAL)
    ) dut (
    );

    initial begin
    end

endmodule
