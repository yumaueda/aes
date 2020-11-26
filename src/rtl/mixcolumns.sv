module POLYMULT #(
    parameter x = 2
) (
    input  wire [7:0] i_poly,
    output wire [7:0] o_poly
);

    wire [8:0] preshift, postshift, reduced;

    assign preshift  = {1'b0, i_poly};
    assign postshift = x == 2 ? preshift << 1 : x == 3 ? (preshift << 1) ^ preshift : 'x;
    assign reduced   = postshift[8] ? (postshift ^ 9'b100011011) : postshift;
    assign o_poly    = reduced[7:0];

endmodule

module MAPCOLUMN (
    input  wire        clk, rst,
    input  wire [31:0] i_column,
    output reg  [31:0] o_column
);

    wire [7:0] s0x02, s1x02, s2x02, s3x02;
    wire [7:0] s0x03, s1x03, s2x03, s3x03;
    wire [7:0] s0postmap, s1postmap, s2postmap, s3postmap;

    POLYMULT #(.x(2)) polymultx2_s0 (.i_poly(i_column[31:24]), .o_poly(s0x02));
    POLYMULT #(.x(2)) polymultx2_s1 (.i_poly(i_column[23:16]), .o_poly(s1x02));
    POLYMULT #(.x(2)) polymultx2_s2 (.i_poly(i_column[15:8]),  .o_poly(s2x02));
    POLYMULT #(.x(2)) polymultx2_s3 (.i_poly(i_column[7:0]),   .o_poly(s3x02));
    POLYMULT #(.x(3)) polymultx3_s0 (.i_poly(i_column[31:24]), .o_poly(s0x03));
    POLYMULT #(.x(3)) polymultx3_s1 (.i_poly(i_column[23:16]), .o_poly(s1x03));
    POLYMULT #(.x(3)) polymultx3_s2 (.i_poly(i_column[15:8]),  .o_poly(s2x03));
    POLYMULT #(.x(3)) polymultx3_s3 (.i_poly(i_column[7:0]),   .o_poly(s3x03));

    assign s0postmap = s0x02 ^ s1x03 ^ i_column[15:8] ^ i_column[7:0];
    assign s1postmap = i_column[31:24] ^ s1x02 ^ s2x03 ^ i_column[7:0];
    assign s2postmap = i_column[31:24] ^ i_column[23:16] ^ s2x02 ^ s3x03;
    assign s3postmap = s0x03 ^ i_column[23:16] ^ i_column[15:8] ^ s3x02;

    always @(posedge clk) begin
        if (!rst) begin
            o_column <= '0;
        end
        else begin
            o_column <= {s0postmap, s1postmap, s2postmap, s3postmap};
        end
    end

endmodule

module MIXCOLUMNS #(
    parameter WORD = 32,
    parameter NB   = 4
) (
    input  wire               clk, rst, i_valid,
    input  wire [WORD*NB-1:0] i_block,
    input  wire [3:0]         i_round,
    output reg                o_valid,
    output wire [WORD*NB-1:0] o_block
);

    wire [WORD*NB-1:0] postmap;

    generate
        genvar i;
        for (i = 0; i < NB; i = i + 1) begin
            MAPCOLUMN mapcolumn_n (
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
