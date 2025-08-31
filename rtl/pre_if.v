`timescale 1ns/1ps
`include "defines.v"

module pre_if (
    input [31:0] instr,
    input [31:0] pc,

    output [31:0] pre_pc
);

endmodule
    wire is_jal = (instr[6:0] == `OPCODE_JAL) ;     //æ— æ¡ä»¶è·³è½¬æŒ‡ä»¤çš„æ“ä½œç ?
    
    //Båž‹æŒ‡ä»¤çš„ç«‹å³æ•°æ‹¼æŽ?
    wire [31:0] bimm  = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
    //Jåž‹æŒ‡ä»¤çš„ç«‹å³æ•°æ‹¼æŽ?
    wire [31:0] jimm  = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};

    //æŒ‡ä»¤åœ°å€çš„åç§»é‡
    wire [31:0] adder = is_jal ? jimm : (is_bxx & bimm[31]) ? bimm : 4;
    assign pre_pc = pc + adder;

endmodule