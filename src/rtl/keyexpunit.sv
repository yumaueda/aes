module keyexpunit #(
    parameter WORD      = 32,
    parameter NB        = 4,
    parameter NK        = 4,
    parameter ITERMODNK = 0,
    parameter ITERDIVNK = 0
) (
    input  wire            clk, rst, i_valid,
    input  wire [WORD-1:0] i_wi_1,
    input  wire [WORD-1:0] i_wi_nk,
    output wire [WORD-1:0] o_wi
);

    wire [WORD-1:0] interkey1;
    reg  [WORD-1:0] interkey2;

    generate if (ITERMODNK == 0) begin
        wire [WORD-1:0] rotword = {i_wi_1[23:0], i_wi_1[31:24]}, subword;
        wire [WORD-1:0] rcon    = ITERDIVNK ==  1 ? 32'h0100_0000 :
                                  ITERDIVNK ==  2 ? 32'h0200_0000 :
                                  ITERDIVNK ==  3 ? 32'h0400_0000 :
                                  ITERDIVNK ==  4 ? 32'h0800_0000 :
                                  ITERDIVNK ==  5 ? 32'h1000_0000 :
                                  ITERDIVNK ==  6 ? 32'h2000_0000 :
                                  ITERDIVNK ==  7 ? 32'h4000_0000 :
                                  ITERDIVNK ==  8 ? 32'h8000_0000 :
                                  ITERDIVNK ==  9 ? 32'h1b00_0000 :
                                  ITERDIVNK == 10 ? 32'h3600_0000 : 'x;

        assign interkey1 = subword ^ rcon;

        genvar i;
        for (i = 0; i < WORD; i += 8) begin
            sbox sbox_n (
                .i_premap(rotword[32-(1+i):32-(8+i)]),
                .o_postmap(subword[32-(1+i):32-(8+i)]));
        end
    end
    else if (NK == 8 && ITERMODNK == 4) begin
        genvar i;
        for (i = 0; i < WORD; i += 8) begin
            sbox sbox_n (
                .i_premap(i_wi_1[32-(1+i):32-(8+i)]),
                .o_postmap(interkey1[32-(1+i):32-(8+i)]));
        end
    end
    else begin
        assign interkey1 = i_wi_1;
    end
    endgenerate

    assign o_wi = interkey2 ^ i_wi_nk;

    always @(posedge clk) begin
        interkey2 <= interkey1;
    end

endmodule
