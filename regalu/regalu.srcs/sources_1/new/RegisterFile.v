`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/30 17:53:01
// Design Name: 
// Module Name: RegisterFile
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


module RegisterFile (
    input clk,                  // 时钟信号
    input reset,                // 重置信号
    input [4:0] rs1,            // 源寄存器1
    input [4:0] rs2,            // 源寄存器2
    input [4:0] rd,             // 目标寄存器
    input [31:0] writeData,     // 写入数据
    input regWrite,             // 写使能信号
    output [31:0] readData1,    // 读取寄存器1的数据
    output [31:0] readData2     // 读取寄存器2的数据
);

    // 定义32个32位寄存器
    reg [31:0] registers [31:0];

    // 初始化寄存器
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            registers[0] <= 32'b0;  // 寄存器0固定为零
            registers[1] <= 32'b0;
            // 其他寄存器初始化为零
        end
        else if (regWrite && rd != 0) begin
            registers[rd] <= writeData;  // 写入数据
        end
    end

    // 读取数据
    assign readData1 = (rs1 == 5'b0) ? 32'b0 : registers[rs1];
    assign readData2 = (rs2 == 5'b0) ? 32'b0 : registers[rs2];

endmodule

