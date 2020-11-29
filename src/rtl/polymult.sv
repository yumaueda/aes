module polymult #(
    parameter x = 2
) (
    input  wire [7:0] i_poly,
    output wire [7:0] o_poly
);

    wire [8:0] preshift, postshift;
    wire [7:0] reduced;

    assign preshift  = {1'b0, i_poly};
    assign postshift = x == 2 ? preshift << 1 : x == 3 ? (preshift << 1) ^ preshift : 'x;
    assign reduced   = postshift[8] ? (postshift[7:0] ^ 8'b00011011) : postshift[7:0];
    assign o_poly    = reduced;

endmodule
