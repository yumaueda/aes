module mapcolumn (
    input  wire        clk, rst,
    input  wire [31:0] i_column,
    output reg  [31:0] o_column
);

    wire [7:0] s0x02, s1x02, s2x02, s3x02;
    wire [7:0] s0x03, s1x03, s2x03, s3x03;
    wire [7:0] s0postmap, s1postmap, s2postmap, s3postmap;

    polymult #(.x(2)) polymultx2_s0 (.i_poly(i_column[31:24]), .o_poly(s0x02));
    polymult #(.x(2)) polymultx2_s1 (.i_poly(i_column[23:16]), .o_poly(s1x02));
    polymult #(.x(2)) polymultx2_s2 (.i_poly(i_column[15:8]),  .o_poly(s2x02));
    polymult #(.x(2)) polymultx2_s3 (.i_poly(i_column[7:0]),   .o_poly(s3x02));
    polymult #(.x(3)) polymultx3_s0 (.i_poly(i_column[31:24]), .o_poly(s0x03));
    polymult #(.x(3)) polymultx3_s1 (.i_poly(i_column[23:16]), .o_poly(s1x03));
    polymult #(.x(3)) polymultx3_s2 (.i_poly(i_column[15:8]),  .o_poly(s2x03));
    polymult #(.x(3)) polymultx3_s3 (.i_poly(i_column[7:0]),   .o_poly(s3x03));

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
