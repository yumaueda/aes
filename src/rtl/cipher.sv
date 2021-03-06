module cipher #(
    parameter WORD = 32,
    parameter NB   = 4,
    parameter NK   = 4,
    parameter NR   = 10,
    parameter ECB  = 0,                       // unimplemented
    parameter CTR  = 0,                       // unimplemented
    parameter WRAP = 0                        // see description below
    /*-------------------------------------------------------------------
     true: see the entire block as a counter. wrap around on entire block
     false: wrap around only on counter.

     i.e.
     
     Suppose nonce/counter == 0xffffffff_ffffffff_ffffffff_ffffffff.
     It would go back to 0x00000000_00000000_00000000_00000000
     if we increment the counter by one when WRAP == true.
     -------------------------------------------------------------------*/
) (
    input  wire                 clk, rst,
    input  wire                 i_keyexp_en,
    input  wire [WORD*NK-1:0]   i_key,
    input  wire                 i_valid,
    input  wire                 i_mode,       // true: CTR, false: ECB
    input  wire [WORD*NB-1:0]   i_block,      // tdata: plaintext
    input  wire [WORD*NB-1:0]   i_nonce,      // nonce: for CTR mode.
    input  wire [7:0]           i_nonce_size, // [0, 128)
    input  wire                 i_last,       // also for counter reset
    input  wire [WORD*NB/8-1:0] i_strb,       // tstrb: for CTR mode. must be '1 when i_last == 0
    output wire                 o_valid,
    output wire                 o_last,
    output wire [WORD*NB/8-1:0] o_strb,
    output wire [WORD*NB-1:0]   o_block
);
    localparam TC = NR*4+1;

    typedef enum logic {ENC_ECB, ENC_CTR} mode_t;
    mode_t               mode = i_mode;

    reg  [WORD*NB-1:0]   counter;

    wire [WORD-1:0]      expanded_w [NB*(NR+1)-1:0];

    reg  [WORD*NB-1:0]   block_staged [TC-1:0];
    reg                  last_staged  [TC-1:0];
    reg  [WORD*NB/8-1:0] strb_staged  [TC-1:0];

    wire [WORD*NB-1:0]   block_post_in;
    wire [WORD*NB-1:0]   block_pre_out;

    wire [NR-1:0]        valid_interround;
    wire [WORD*NB-1:0]   block_interround [NR-1:0];

    keyexp #(
        .WORD(WORD),
        .NB(NB),
        .NK(NK),
        .NR(NR)
    ) keyexp_0 (
        .*,  // clk, rst, i_key
        .i_valid(i_keyexp_en),
        .o_w(expanded_w)
    );

    addroundkey #(
        .WORD(WORD),
        .NB(NB)
    ) add_0 (
        .*,  // clk, rst, i_valid
        .i_block(block_post_in),
        .i_roundkey({expanded_w[0], expanded_w[1], expanded_w[2], expanded_w[3]}),
        .o_valid(valid_interround[0]),
        .o_block(block_interround[0])
    );

    genvar i;
    generate
        for (i = 0; i < NR-1; i += 1) begin
            round #(
                .WORD(WORD),
                .NB(NB),
                .FINAL(0)
            ) round_n (
                .*,  // clk, rst
                .i_valid(valid_interround[i]),
                .i_block(block_interround[i]),
                .i_roundkey({
                        expanded_w[(i+1)*4+0],
                        expanded_w[(i+1)*4+1],
                        expanded_w[(i+1)*4+2],
                        expanded_w[(i+1)*4+3]}),
                .o_valid(valid_interround[i+1]),
                .o_block(block_interround[i+1])
            );
        end

        round #(
            .WORD(WORD),
            .NB(NB),
            .FINAL(1)
        ) round_n (
            .*,  // clk, rst, o_valid,
            .i_valid(valid_interround[NR-1]),
            .i_block(block_interround[NR-1]),
            .i_roundkey({
                    expanded_w[NB*(NR+1)-4],
                    expanded_w[NB*(NR+1)-3],
                    expanded_w[NB*(NR+1)-2],
                    expanded_w[NB*(NR+1)-1]}),
            .o_block(block_pre_out)
        );

        for (i = 0; i < TC-1; i += 1) begin
            always @(posedge clk) begin
                block_staged[i+1] <= block_staged[i];
                last_staged[i+1]  <= last_staged[i];
                strb_staged[i+1]  <= strb_staged[i];
            end
        end
    endgenerate

    always @(posedge clk) begin
        block_staged[0] <= i_block;
        last_staged[0]  <= i_last;
        strb_staged[0]  <= i_strb;
    end

    generate if (WRAP == 0) begin
        always @(posedge clk) begin
            if (!rst) begin
                counter <= '0;
            end
            else if (i_valid) begin
                if (!i_last) begin
                    if (counter != 2**(128-i_nonce_size)-1) begin
                        counter <= counter + 1;
                    end
                    else begin
                        counter <= '0;
                    end
                end
                else begin
                    counter <= '0;
                end
            end
        end
    end
    else begin  // WRAP == 1
        always @(posedge clk) begin
            if (!rst) begin
                counter <= '0;
            end
            else if (i_valid) begin
                if (!i_last) begin
                    counter <= counter + 1;
                end
                else begin
                    counter <= '0;
                end
            end
        end
    end

    //if (ECB == 1) begin
    always_comb begin
        if (mode == ENC_ECB) begin
            o_block = block_pre_out;
        end
    end
    //end

    if (CTR == 1) begin
        for (i = 0; i < WORD*NB/8; i += 1) begin
            always_comb begin
                if (mode == ENC_CTR) begin
                    o_block[WORD*NB-i*8-1:WORD*NB-(i+1)*8] = strb_staged[(NR+1)*4-1][WORD*NB/8-1-i] == 1'b1 ?
                        block_pre_out[WORD*NB-i*8-1:WORD*NB-(i+1)*8] ^ block_staged[(NR+1)*4-1][WORD*NB-i*8-1:WORD*NB-(i+1)*8] :
                        block_pre_out[WORD*NB-i*8-1:WORD*NB-(i+1)*8];
                end
            end
        end
    end

    endgenerate

    assign block_post_in = mode == ENC_ECB ? i_block : i_nonce + counter;
    assign o_last        = last_staged[TC-1];
    assign o_strb        = strb_staged[TC-1];

endmodule
