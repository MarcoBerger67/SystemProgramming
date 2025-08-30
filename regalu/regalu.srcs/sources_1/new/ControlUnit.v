`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/30 17:53:20
// Design Name: 
// Module Name: ControlUnit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ControlUnit (
    input [6:0] opcode,        // 操作码（7位）
    input [2:0] funct3,        // funct3字段
    input funct7,              // funct7字段
    output reg [3:0] ALU_Control,  // ALU操作控制信号
    output reg regWrite,       // 寄存器写使能
    output reg memRead,        // 内存读使能
    output reg memWrite,       // 内存写使能
    output reg branch,         // 分支使能
    output reg jump,           // 跳转使能
    output reg ALUSrc,         // ALU的第二个操作数是否为立即数
    output reg memToReg        // 数据是否来自内存（用于LW指令）
);

always @(*) begin
    // 默认信号
    ALU_Control = 4'b0000;   // 默认操作
    regWrite = 0;
    memRead = 0;
    memWrite = 0;
    branch = 0;
    jump = 0;
    ALUSrc = 0;
    memToReg = 0;

    case (opcode)
        7'b0110011: begin  // R-type: ADD, SUB, AND, OR, XOR
            regWrite = 1;
            case (funct3)
                3'b000: ALU_Control = (funct7 == 1'b0) ? 4'b0000 : 4'b0001;  // ADD / SUB
                3'b100: ALU_Control = 4'b0010;  // AND
                3'b110: ALU_Control = 4'b0011;  // OR
                3'b111: ALU_Control = 4'b0100;  // XOR
                default: ALU_Control = 4'b0000;  // 默认ADD
            endcase
        end
        7'b0010011: begin  // I-type: ADDI, ANDI, ORI, etc.
            regWrite = 1;
            ALUSrc = 1;  // 使用立即数
            case (funct3)
                3'b000: ALU_Control = 4'b1011;  // ADDI
                3'b100: ALU_Control = 4'b1100;  // ANDI
                3'b110: ALU_Control = 4'b1101;  // ORI
                default: ALU_Control = 4'b1011;  // 默认ADD
            endcase
        end
        7'b0000011: begin  // Load (LW)
            regWrite = 1;
            memRead = 1;
            ALUSrc = 1;
            memToReg = 1;  // 数据来自内存
            ALU_Control = 4'b1011;  // ADDI
        end
        7'b0100011: begin  // Store (SW)
            memWrite = 1;
            ALUSrc = 1;
            ALU_Control = 4'b1011;  // ADDI
        end
        7'b1100011: begin  // Branch (BEQ, BNE, BLT)
            case (funct3)
                3'b000: ALU_Control = 4'b1000;  // BEQ
                3'b001: ALU_Control = 4'b1001;  // BNE
                3'b100: ALU_Control = 4'b1010;  // BLT
                default: ALU_Control = 4'b1000;
            endcase
            branch = 1;
        end
        7'b1101111: begin  // Jump (JAL)
            jump = 1;
            regWrite = 1;
            ALU_Control = 4'b0000;  // JAL不需要ALU操作
        end
        7'b0110111: begin  // LUI (Load Upper Immediate)
            regWrite = 1;
            ALU_Control = 4'b1111;  // LUI是立即数操作
            ALUSrc = 1;
        end
        default: begin
            ALU_Control = 4'b0000;  // 默认操作
        end
    endcase
end

endmodule

