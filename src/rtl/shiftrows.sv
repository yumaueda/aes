module SHIFTROWS #(
    parameter WORD = 32,
    parameter NB   = 4
) (
    input  wire               i_valid,
    input  wire [WORD*NB-1:0] i_block,
    output wire               o_valid,
    output wire [WORD*NB-1:0] o_block
);

    assign o_valid = i_valid;

    // 1st row (s_{00}->s_{00}, s_{01}->s_{01}, s_{02}->s_{02}, s_{03}->s_{03})
    assign o_block[127:120] = i_block[127:120];
    assign o_block[95:88]   = i_block[95:88];
    assign o_block[63:56]   = i_block[63:56];
    assign o_block[31:24]   = i_block[31:24];

    // 2nd row (s_{10}->s_{11}, s_{11}->s_{12}, s_{12}->s_{13}, s_{13}->s_{10})
    assign o_block[119:112] = i_block[87:80];
    assign o_block[87:80]   = i_block[55:48];
    assign o_block[55:48]   = i_block[23:16];
    assign o_block[23:16]   = i_block[119:112];

    // 3rd row (s_{20}->s_{22}, s_{21}->s_{23}, s_{22}->s_{20}, s_{23}->s_{21})
    assign o_block[111:104] = i_block[47:40];
    assign o_block[79:72]   = i_block[15:8];
    assign o_block[47:40]   = i_block[111:104];
    assign o_block[15:8]    = i_block[79:72];

    // 4th row (s_{30}->s_{33}, s_{31}->s_{30}, s_{32}->s_{31}, s_{33}->s_{32})
    assign o_block[103:96]  = i_block[7:0];
    assign o_block[71:64]   = i_block[103:96];
    assign o_block[39:32]   = i_block[71:64];
    assign o_block[7:0]     = i_block[39:32];

endmodule
