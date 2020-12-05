module round #(
    parameter WORD  = 32,
    parameter NB    = 4,
    parameter FINAL = 0
) (
    input  wire               clk, rst,
    input  wire               i_valid,
    input  wire [WORD*NB-1:0] i_block,
    input  wire [WORD*NB-1:0] i_roundkey,
    output wire               o_valid,
    output wire [WORD*NB-1:0] o_block
);

    wire               sub_valid_shift, shift_valid_regormix, regormix_valid_add;
    wire [WORD*NB-1:0] sub_block_shift, shift_block_regormix, regormix_block_add;

    // Each register has the value n clocks ago
    reg  [WORD-1:0]    wi_0_staged1, wi_0_staged2, wi_0_staged3;
    reg  [WORD-1:0]    wi_1_staged1, wi_1_staged2;
    reg  [WORD-1:0]    wi_2_staged1;

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
        .o_valid(shift_valid_regormix),
        .o_block(shift_block_regormix)
    );

    generate if (FINAL == 0) begin
        mixcolumns #(
            .WORD(WORD),
            .NB(NB)
        ) mix (
            .*,
            .i_valid(shift_valid_regormix),
            .i_block(shift_block_regormix),
            .o_valid(regormix_valid_add),
            .o_block(regormix_block_add)
        );
    end
    else begin
        // FINAL == 1
        // Wait for two cycles until the key expansion is complete
        reg               shift_valid_staged1, shift_valid_staged2;
        reg [WORD*NB-1:0] shift_block_staged1, shift_block_staged2;

        always @(posedge clk) begin
            shift_valid_staged1 <= shift_valid_regormix;
            shift_valid_staged2 <= shift_valid_staged1;
            shift_block_staged1 <= shift_block_regormix;
            shift_block_staged2 <= shift_block_staged1;
        end
    end
    endgenerate

    addroundkey #(
        .WORD(WORD),
        .NB(NB)
    ) add (
        .*,
        .i_valid(regormix_valid_add),
        .i_block(regormix_block_add),
        .i_roundkey({wi_0_staged3, wi_1_staged2, wi_2_staged1, i_roundkey[31:0]})
    );

    always @(posedge clk) begin
        wi_0_staged1 <= i_roundkey[127:96];
        wi_0_staged2 <= wi_0_staged1;
        wi_0_staged3 <= wi_0_staged2;

        wi_1_staged1 <= i_roundkey[95:64];
        wi_1_staged2 <= wi_1_staged1;

        wi_2_staged1 <= i_roundkey[63:32];
    end

endmodule
