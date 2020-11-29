module addroundkey #(
    parameter WORD = 32,
    parameter NB   = 4
) (
    input  wire               clk, rst, i_valid,
    input  wire [WORD*NB-1:0] i_block, i_roundkey,
    output reg                o_valid,
    output reg  [WORD*NB-1:0] o_block
);

always @(posedge clk) begin
    if (!rst) begin
        o_valid <= '0;
        o_block <= '0;
    end
    else begin
        o_valid <= i_valid;
        o_block <= i_block ^ i_roundkey;
    end
end

endmodule
