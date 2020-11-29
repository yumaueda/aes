module mixcolumns #(
    parameter WORD = 32,
    parameter NB   = 4
) (
    input  wire               clk, rst, i_valid,
    input  wire [WORD*NB-1:0] i_block,
    output reg                o_valid,
    output wire [WORD*NB-1:0] o_block
);

    wire [WORD*NB-1:0] postmap;

    generate
        genvar i;
        for (i = 0; i < NB; i = i + 1) begin
            mapcolumn mapcolumn_n (
                .*,
                .i_column(i_block[WORD*(NB-i)-1:WORD*(NB-i-1)]),
                .o_column(postmap[WORD*(NB-i)-1:WORD*(NB-i-1)])
            );
        end
    endgenerate

    assign o_block = postmap;

    always @(posedge clk) begin
        if (!rst) begin
            o_valid      <= '0;
        end
        else begin
            o_valid      <= i_valid;
        end
    end

endmodule
