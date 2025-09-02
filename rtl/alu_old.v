`timescale 1ns/1ps
// ALU_OP {instr[30], func3}
`define ALU_OP_ADD      4'b0000
`define ALU_OP_SUB      4'b1000
`define ALU_OP_SLL      4'b0001
`define ALU_OP_SLT      4'b0010
`define ALU_OP_SLTU     4'b0011
`define ALU_OP_XOR      4'b0100
`define ALU_OP_SRL      4'b0101
`define ALU_OP_SRA      4'b1101
`define ALU_OP_OR       4'b0110
`define ALU_OP_AND      4'b0111

`define ALU_OP_EQ       4'b1001
`define ALU_OP_NEQ      4'b1010
`define ALU_OP_GE       4'b1100
`define ALU_OP_GEU      4'b1011

`define ALU_OP_XXX      4'b1111


`define BEQ_FUNCT3      3'b000
`define BNE_FUNCT3      3'b001
`define BLT_FUNCT3      3'b100
`define BGE_FUNCT3      3'b101
`define BLTU_FUNCT3     3'b110
`define BGEU_FUNCT3     3'b111

`define OPCODE_LUI             7'b01_101_11
`define OPCODE_AUIPC           7'b00_101_11
`define OPCODE_JAL             7'b11_011_11
`define OPCODE_JALR            7'b11_001_11
`define OPCODE_BRANCH          7'b11_000_11
`define OPCODE_LOAD            7'b00_000_11
`define OPCODE_STORE           7'b01_000_11
`define OPCODE_ALUI            7'b00_100_11
`define OPCODE_ALUR            7'b01_100_11
`define OPCODE_FENCE           7'b00_011_11
`define OPCODE_SYSTEM          7'b11_100_11


module alu (
  input  [31:0] alu_data1_i,
  input  [31:0] alu_data2_i,
  input  [ 3:0] alu_op_i,
  output [31:0] alu_result_o
);

  reg  [31:0] result;
  
  wire [31:0] sum    = alu_data1_i + ((alu_op_i[3] | alu_op_i[1]) ? -alu_data2_i : alu_data2_i);
  wire        neq    = |sum;
  wire        cmp    = (alu_data1_i[31] == alu_data2_i[31]) ? sum[31]
                     : alu_op_i[0] ? alu_data2_i[31] : alu_data1_i[31];
  wire [ 4:0] shamt  = alu_data2_i[4:0];
  wire [31:0] shin   = alu_op_i[2] ? alu_data1_i : reverse(alu_data1_i);
  wire [32:0] shift  = {alu_op_i[3] & shin[31], shin};
  wire [32:0] shiftt = ($signed(shift) >>> shamt);
  wire [31:0] shiftr = shiftt[31:0];
  wire [31:0] shiftl = reverse(shiftr);

  always @(*) begin
    case(alu_op_i)
      `ALU_OP_ADD:    result <= sum;
      `ALU_OP_SUB:    result <= sum;
      `ALU_OP_SLL:    result <= shiftl;
      `ALU_OP_SLT:    result <= cmp;
      `ALU_OP_SLTU:   result <= cmp;
      `ALU_OP_XOR:    result <= (alu_data1_i ^ alu_data2_i);
      `ALU_OP_SRL:    result <= shiftr;
      `ALU_OP_SRA:    result <= shiftr;
      `ALU_OP_OR:     result <= (alu_data1_i | alu_data2_i);
      `ALU_OP_AND:    result <= (alu_data1_i & alu_data2_i);

      `ALU_OP_EQ:     result <= {31'b0, ~neq};
      `ALU_OP_NEQ:    result <= {31'b0, neq};
      `ALU_OP_GE:     result <= {31'b0, ~cmp};
      `ALU_OP_GEU:    result <= {31'b0, ~cmp};
      default:        begin 
                      result <= 32'b0; 
                      //$display("*** alu error ! ***%x", alu_op_i); 
        end
    endcase
  end

  function [31:0] reverse;
    input [31:0] in;
    integer i;
    for(i=0; i<32; i=i+1) begin
      reverse[i] = in[31-i];
    end
  endfunction  

  assign alu_result_o = result;

endmodule