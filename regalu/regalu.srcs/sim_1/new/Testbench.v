`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/30 17:54:02
// Design Name: 
// Module Name: Testbench
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


module Testbench;

    // 输入信号
    reg [31:0] A, B;
    reg [3:0] ALU_Control;
    reg clk, reset;
    reg [4:0] rs1, rs2, rd;
    reg [31:0] writeData;
    reg regWrite;

    // 输出信号
    wire [31:0] ALU_Result;
    wire Zero, Overflow;
    wire [31:0] readData1, readData2;

    // 实例化ALU模块
    ALU alu_instance (
        .A(A),
        .B(B),
        .ALU_Control(ALU_Control),
        .ALU_Result(ALU_Result),
        .Zero(Zero),
        .Overflow(Overflow)
    );

    // 实例化寄存器堆
    RegisterFile regfile_instance (
        .clk(clk),
        .reset(reset),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .writeData(writeData),
        .regWrite(regWrite),
        .readData1(readData1),
        .readData2(readData2)
    );

    // 时钟产生器
    always begin
        #5 clk = ~clk;  // 时钟周期5个时间单位
    end

    initial begin
        // 初始化信号
        clk = 0;
        reset = 1;
        rs1 = 5'b00001;  // 假设寄存器1
        rs2 = 5'b00010;  // 假设寄存器2
        rd = 5'b00011;  // 目标寄存器
        writeData = 32'd100;  // 写入数据
        regWrite = 1;

        // 重置信号
        #10 reset = 0;
        #10 reset = 1;

        // 测试ALU和寄存器堆
        A = 32'd10; B = 32'd5; ALU_Control = 4'b0000; // ADD
        #10;
        $display("ADD: A + B = %d, Zero = %b, Overflow = %b", ALU_Result, Zero, Overflow);

        A = 32'd10; B = 32'd5; ALU_Control = 4'b0001; // SUB
        #10;
        $display("SUB: A - B = %d, Zero = %b, Overflow = %b", ALU_Result, Zero, Overflow);

        // 测试寄存器堆写入
        #10 regWrite = 1;  // 启用寄存器写操作
        #10 rs1 = 5'b00001; rs2 = 5'b00010;  // 读取寄存器1和寄存器2
        #10 $display("Read Register 1: %d, Read Register 2: %d", readData1, readData2);

        // 测试ALU立即数操作
        A = 32'd20; B = 32'd5; ALU_Control = 4'b1011; // ADDI
        #10;
        $display("ADDI: A + Imm = %d, Zero = %b", ALU_Result, Zero);
        
        $finish;
    end

endmodule

