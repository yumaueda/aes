# AES

Fully pipelined AES module written in SystemVerilog.

## Status

WIP.

## Interfaces

| Name                 | I/O | DESC                                |
| -------------------- | --- | ----------------------------------- |
| clk                  | I   | Main clock                          |
| rst                  | I   | Negative reset                      |
| i_keyexp_en          | I   | Key expansion enable                |
| i_key[NK\*WORD-1:0]  | I   | Cipher key                          |
| i_mode[1:0]          | I   | ENC/DEC, ECB/CTR                    |
| i_nonce[127:0]       | I   | Nonce                               |
| i_nonce_size[7:0]    | I   | Size of nonce [0, 128)              |
| i_axi4s_tvalid       | I   | Master ready                        |
| o_axi4s_tready       | O   | Slave ready                         |
| i_axi4s_tdata[127:0] | I   | Input data                          |
| i_axi4s_tlast        | I   | EOD                                 |
| i_axi4s_tstrb[15:0]  | I   | Byte enable for the last block      |
| o_axi4s_tvalid       | O   | Master ready                        |
| i_axi4s_tready       | I   | Slave ready                         |
| o_axi4s_tdata[127:0] | O   | Output data                         |
| o_axi4s_tlast        | O   | EOD                                 |
| o_axi4s_tstrb[15:0]  | O   | Byte enable for the last block      |

## Implementation results on FPGA

### Xilinx

| FPGA        | Tool          | LUTs | FFs | FMax |
| ----------- | ------------- | ---- | --- | ---- |
| Kintex-7    | Vivado 2019.2 | ???  | ??? | ???  |
| Artix-7 35T | Vivado 2019.2 | ???  | ??? | ???  |

### Lattice

???
