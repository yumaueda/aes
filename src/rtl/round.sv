module round #(
    parameter WORD = 32,
    parameter NB   = 4
) (
    input  wire               clk, rst, i_valid,
    input  wire [WORD*NB-1:0] i_block, i_roundkey,
    output wire               o_valid,
    output wire [WORD*NB-1:0] o_block
);

    wire               sub_valid_shift, shift_valid_mix, mix_valid_add;
    wire [WORD*NB-1:0] sub_block_shift, shift_block_mix, mix_block_add;

    subbytes #(
        .WORD(WORD),
        .NB(NB)
    ) sub (
        .*,
        .o_valid(sub_valid_shift),
        .o_block(sub_block_shift)
    );

    shiftrows #(
        .WORD(WORD),
        .NB(NB)
    ) shift (
        .i_valid(sub_valid_shift),
        .i_block(sub_block_shift),
        .o_valid(shift_valid_mix),
        .o_block(shift_block_mix)
    );

    mixcolumns #(
        .WORD(WORD),
        .NB(NB)
    ) mix (
        .*,
        .i_valid(shift_valid_mix),
        .i_block(shift_block_mix),
        .o_valid(mix_valid_add),
        .o_block(mix_block_add)
    );

    addroundkey #(
        .WORD(WORD),
        .NB(NB)
    ) add (
        .*,
        .i_valid(mix_valid_add),
        .i_block(mix_block_add)
    );

endmodule
