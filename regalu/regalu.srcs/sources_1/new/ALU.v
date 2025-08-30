`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/30 17:52:41
// Design Name: 
// Module Name: ALU
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


module ALU (
    input [31:0] A,            // 操作数A
    input [31:0] B,            // 操作数B
    input [3:0] ALU_Control,   // 控制信号
    output reg [31:0] ALU_Result, // 运算结果
    output reg Zero,           // 零标志
    output reg Overflow        // 溢出标志
);

// ALU操作控制
always @(*) begin
    Overflow = 0; // 默认无溢出

    case (ALU_Control)
        4'b0000: ALU_Result = A + B;           // ADD
        4'b0001: ALU_Result = A - B;           // SUB
        4'b0010: ALU_Result = A & B;           // AND
        4'b0011: ALU_Result = A | B;           // OR
        4'b0100: ALU_Result = A ^ B;           // XOR
        4'b0101: ALU_Result = A << B[4:0];     // SLL (Shift Left Logical)
        4'b0110: ALU_Result = A >> B[4:0];     // SRL (Shift Right Logical)
        4'b0111: ALU_Result = $signed(A) >>> B[4:0]; // SRA (Shift Right Arithmetic)
        4'b1000: ALU_Result = (A == B) ? 1 : 0; // BEQ (Branch Equal)
        4'b1001: ALU_Result = (A != B) ? 1 : 0; // BNE (Branch Not Equal)
        4'b1010: ALU_Result = (A < B) ? 1 : 0;  // BLT (Branch Less Than)
        4'b1011: ALU_Result = A + B;            // ADDI (Immediate ADD)
        4'b1100: ALU_Result = A & B;            // ANDI (Immediate AND)
        4'b1101: ALU_Result = A | B;            // ORI (Immediate OR)
        4'b1110: ALU_Result = A << B[4:0];      // SLLI (Immediate Shift Left)
        4'b1111: ALU_Result = A >> B[4:0];      // SRLI (Immediate Shift Right)
        default: ALU_Result = 32'b0;            // 默认值
    endcase

    // 设置零标志
    Zero = (ALU_Result == 32'b0);
    
    // 溢出检测：仅对加法和减法进行溢出检测
    if (ALU_Control == 4'b0000) begin  // ADD
        if ((A[31] == B[31]) && (ALU_Result[31] != A[31])) begin
            Overflow = 1;
        end
    end
    if (ALU_Control == 4'b0001) begin  // SUB
        if ((A[31] != B[31]) && (ALU_Result[31] != A[31])) begin
            Overflow = 1;
        end
    end
end

endmodule

