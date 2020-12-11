`default_nettype none
`timescale       1ns / 1ps
`include         "param.svh"

program round_test (
);
endprogram

module tb_round (
    input  i_valid,
    input  i_block,
    input  i_roundkey,
    input  o_valid,
    output o_block
);

    localparam WORD  = `WORD;
    localparam NB    = `NB;
    localparam FINAL = 0;

    logic               clk, rst;
    logic               i_valid;
    logic [WORD*NB-1:0] i_block;
    logic [WORD*NB-1:0] i_roundkey;
    logic               o_valid;
    logic [WORD*NB-1:0] o_block;

    default clocking master @(posedge clk);
        default input #1 output #0;
        input  rst;
        input  i_valid;
        input  i_block;
        input  i_roundkey;
        output o_valid;
        output o_block;
    endclocking : master

    round #(
        .WORD(WORD),
        .NB(NB),
        .FINAL(FINAL)
    ) dut (
        .*
    );

    initial begin
        ##5 $finish();
    end

    always #(10/2) clk = ~clk;

    initial begin
        rst = '0;
        #4;
        rst = '1;
    end

endmodule
