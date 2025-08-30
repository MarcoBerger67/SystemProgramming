`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/30 17:53:38
// Design Name: 
// Module Name: HazardUnit
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


module HazardUnit (
    input [4:0] ID_rs1,      // ID阶段的rs1
    input [4:0] ID_rs2,      // ID阶段的rs2
    input [4:0] EX_rd,       // EX阶段的目标寄存器
    input EX_regWrite,       // EX阶段的寄存器写使能
    output reg hazard        // 是否发生数据冒险
);

always @(*) begin
    if (EX_regWrite && ((ID_rs1 == EX_rd) || (ID_rs2 == EX_rd))) begin
        hazard = 1;  // 数据冒险
    end else begin
        hazard = 0;  // 没有数据冒险
    end
end

endmodule
