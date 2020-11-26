module SUBBYTES #(
    parameter WORD = 32,
    parameter NB   = 4
) (
    input  wire               clk, rst, i_valid,
    input  wire [WORD*NB-1:0] i_block,
    output reg                o_valid,
    output reg  [WORD*NB-1:0] o_block
);

    wire [WORD*NB-1:0] postmap;

    generate
        genvar i;
        for (i = 0; i < WORD*NB; i = i + 8) begin
            SBOX sbox (.i_premap(i_block[i+7:i]), .o_postmap(postmap[i+7:i]));
        end
    endgenerate

    always @(posedge clk) begin
        if (!rst) begin
            o_valid <= '0;
            o_block <= '0;
        end
        else begin
            o_valid <= i_valid;
            o_block <= postmap;
        end
    end

endmodule
