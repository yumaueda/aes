module keyexp #(
    parameter WORD = 32,
    parameter NB = 4,
    parameter NK = 4,
    parameter NR = 10
) (
    input  wire               clk, rst,
    input  wire               i_valid,
    input  wire [WORD*NK-1:0] i_key,
    output wire [WORD-1:0]    o_w [NB*(NR+1)-1:0]
);

    reg  [WORD*NK-1:0]    key;
    wire [NB*(NR+1)-NK:0] keu_valid;
    wire [WORD-1:0]       keu_wi_1  [NB*(NR+1)-NK:0];
    wire [WORD-1:0]       keu_wi_nk [NB*(NR+1)-NK-1:0];
    reg  [WORD-1:0]       w_staged1 [NB*(NR+1)-2*NK-1:0];
    reg  [WORD-1:0]       w_staged2 [NB*(NR+1)-2*NK-1:0];
    reg  [WORD-1:0]       w_staged3 [NB*(NR+1)-2*NK-1:0];

    generate if (NK == 4) begin
        reg [WORD-1:0] key_w2_staged1;
        reg [WORD-1:0] key_w1_staged1;
        reg [WORD-1:0] key_w0_staged1;

        reg [WORD-1:0] key_w1_staged2;
        reg [WORD-1:0] key_w0_staged2;

        reg [WORD-1:0] key_w0_staged3;

        always @(posedge clk) begin
            if (!rst) begin
                key_w2_staged1 <= '0;
                key_w1_staged1 <= '0;
                key_w0_staged1 <= '0;
            end
            else if (i_valid) begin
                key_w2_staged1 <= i_key[95:64];
                key_w1_staged1 <= i_key[63:32];
                key_w0_staged1 <= i_key[31:0];
            end

            key_w1_staged2 <= key_w1_staged1;
            key_w0_staged2 <= key_w0_staged1;

            key_w0_staged3 <= key_w0_staged2;
        end

        assign keu_wi_nk[1] = key_w2_staged1;
        assign keu_wi_nk[2] = key_w1_staged2;
        assign keu_wi_nk[3] = key_w0_staged3;
    end
    else if (NK == 6) begin
        reg [WORD-1:0] key_w4_staged1;
        reg [WORD-1:0] key_w3_staged1;
        reg [WORD-1:0] key_w2_staged1;
        reg [WORD-1:0] key_w1_staged1;
        reg [WORD-1:0] key_w0_staged1;

        reg [WORD-1:0] key_w3_staged2;
        reg [WORD-1:0] key_w2_staged2;
        reg [WORD-1:0] key_w1_staged2;
        reg [WORD-1:0] key_w0_staged2;

        reg [WORD-1:0] key_w2_staged3;
        reg [WORD-1:0] key_w1_staged3;
        reg [WORD-1:0] key_w0_staged3;

        reg [WORD-1:0] key_w1_staged4;
        reg [WORD-1:0] key_w0_staged4;

        reg [WORD-1:0] key_w0_staged5;

        always @(posedge clk) begin
            if (!rst) begin
                key_w4_staged1 <= '0;
                key_w3_staged1 <= '0;
                key_w2_staged1 <= '0;
                key_w1_staged1 <= '0;
                key_w0_staged1 <= '0;
            end
            else if (i_valid) begin
                key_w4_staged1 <= i_key[159:128];
                key_w3_staged1 <= i_key[127:96];
                key_w2_staged1 <= i_key[95:64];
                key_w1_staged1 <= i_key[63:32];
                key_w0_staged1 <= i_key[31:0];
            end

            key_w3_staged2 <= key_w3_staged1;
            key_w2_staged2 <= key_w2_staged1;
            key_w1_staged2 <= key_w1_staged1;
            key_w0_staged2 <= key_w0_staged1;

            key_w2_staged3 <= key_w2_staged2;
            key_w1_staged3 <= key_w1_staged2;
            key_w0_staged3 <= key_w0_staged2;

            key_w1_staged4 <= key_w1_staged3;
            key_w0_staged4 <= key_w0_staged3;

            key_w0_staged5 <= key_w0_staged4;
        end

        assign keu_wi_nk[1] = key_w4_staged1;
        assign keu_wi_nk[2] = key_w3_staged2;
        assign keu_wi_nk[3] = key_w2_staged3;
        assign keu_wi_nk[4] = key_w1_staged4;
        assign keu_wi_nk[5] = key_w0_staged5;
    end
    else begin  // NK == 8
        reg [WORD-1:0] key_w6_staged1;
        reg [WORD-1:0] key_w5_staged1;
        reg [WORD-1:0] key_w4_staged1;
        reg [WORD-1:0] key_w3_staged1;
        reg [WORD-1:0] key_w2_staged1;
        reg [WORD-1:0] key_w1_staged1;
        reg [WORD-1:0] key_w0_staged1;

        reg [WORD-1:0] key_w5_staged2;
        reg [WORD-1:0] key_w4_staged2;
        reg [WORD-1:0] key_w3_staged2;
        reg [WORD-1:0] key_w2_staged2;
        reg [WORD-1:0] key_w1_staged2;
        reg [WORD-1:0] key_w0_staged2;

        reg [WORD-1:0] key_w4_staged3;
        reg [WORD-1:0] key_w3_staged3;
        reg [WORD-1:0] key_w2_staged3;
        reg [WORD-1:0] key_w1_staged3;
        reg [WORD-1:0] key_w0_staged3;

        reg [WORD-1:0] key_w3_staged4;
        reg [WORD-1:0] key_w2_staged4;
        reg [WORD-1:0] key_w1_staged4;
        reg [WORD-1:0] key_w0_staged4;

        reg [WORD-1:0] key_w2_staged5;
        reg [WORD-1:0] key_w1_staged5;
        reg [WORD-1:0] key_w0_staged5;

        reg [WORD-1:0] key_w1_staged6;
        reg [WORD-1:0] key_w0_staged6;

        reg [WORD-1:0] key_w0_staged7;

        always @(posedge clk) begin
            if (!rst) begin
                key_w6_staged1 <= '0;
                key_w5_staged1 <= '0;
                key_w4_staged1 <= '0;
                key_w3_staged1 <= '0;
                key_w2_staged1 <= '0;
                key_w1_staged1 <= '0;
                key_w0_staged1 <= '0;
            end
            else if (i_valid) begin
                key_w6_staged1 <= i_key[223:192];
                key_w5_staged1 <= i_key[191:160];
                key_w4_staged1 <= i_key[159:128];
                key_w3_staged1 <= i_key[127:96];
                key_w2_staged1 <= i_key[95:64];
                key_w1_staged1 <= i_key[63:32];
                key_w0_staged1 <= i_key[31:0];
            end
            key_w5_staged2 <= key_w5_staged1;
            key_w4_staged2 <= key_w4_staged1;
            key_w3_staged2 <= key_w3_staged1;
            key_w2_staged2 <= key_w2_staged1;
            key_w1_staged2 <= key_w1_staged1;
            key_w0_staged2 <= key_w0_staged1;

            key_w4_staged3 <= key_w4_staged2;
            key_w3_staged3 <= key_w3_staged2;
            key_w2_staged3 <= key_w2_staged2;
            key_w1_staged3 <= key_w1_staged2;
            key_w0_staged3 <= key_w0_staged2;

            key_w3_staged4 <= key_w3_staged3;
            key_w2_staged4 <= key_w2_staged3;
            key_w1_staged4 <= key_w1_staged3;
            key_w0_staged4 <= key_w0_staged3;

            key_w2_staged5 <= key_w2_staged4;
            key_w1_staged5 <= key_w1_staged4;
            key_w0_staged5 <= key_w0_staged4;

            key_w1_staged6 <= key_w1_staged5;
            key_w0_staged6 <= key_w0_staged5;

            key_w0_staged7 <= key_w0_staged6;
        end

        assign keu_wi_nk[1] = key_w6_staged1;
        assign keu_wi_nk[2] = key_w5_staged2;
        assign keu_wi_nk[3] = key_w4_staged3;
        assign keu_wi_nk[4] = key_w3_staged4;
        assign keu_wi_nk[5] = key_w2_staged5;
        assign keu_wi_nk[6] = key_w1_staged6;
        assign keu_wi_nk[7] = key_w0_staged7;
    end
    endgenerate

    always_latch begin
        if (!rst) begin
            key = '0;
        end
        else if (i_valid) begin
            key = i_key;
        end
    end

    generate
        genvar i;

        for (i = 0; i < NK; i += 1) begin
            assign o_w[i] = key[WORD*(NK-i)-1:WORD*(NK-i-1)];
        end

        for (i = NK; i < NB*(NR+1)-NK; i += 1) begin
            always @(posedge clk) begin
                if (!rst) begin
                    w_staged1[i-NK] <= '0;
                    w_staged2[i-NK] <= '0;
                    w_staged3[i-NK] <= '0;
                end
                else begin
                    w_staged1[i-NK] <= o_w[i];
                    w_staged2[i-NK] <= w_staged1[i-NK];
                    w_staged3[i-NK] <= w_staged2[i-NK];
                end
            end

            assign keu_wi_nk[i] = w_staged3[i-NK];
        end

        for (i = NK; i < NB*(NR+1); i += 1) begin
            keyexpunit #(
                .WORD(WORD),
                .NB(NB),
                .NK(NK),
                .ITERMODNK(i%NK),
                .ITERDIVNK(i/NK)
            ) keu_n (
                .*,
                .i_valid(keu_valid[i-NK]),
                .i_wi_1(keu_wi_1[i-NK]),
                .i_wi_nk(keu_wi_nk[i-NK]),
                .o_valid(keu_valid[i-NK+1]),
                .o_wi(keu_wi_1[i-NK+1])
            );

            assign o_w[i] = keu_wi_1[i-NK+1];
        end
    endgenerate

    assign keu_valid[0] = i_valid;
    assign keu_wi_1[0]  = i_key[WORD-1:0];
    assign keu_wi_nk[0] = i_key[WORD*NK-1:WORD*(NK-1)];

endmodule
