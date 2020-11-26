`define WORD 4
`define NB   4   // number of data words

`define NK4      // 128 bit key mode
/*
`define NK6      // 196 bit key mode
`define NK8      // 256 bit key mode
 */

`ifdef  NK4
`define NK   4
`define NR   10
`elsif  NK6
`define NK   6
`define NR   12
`elsif  NK8
`define NK   8
`define NR   14
`endif
