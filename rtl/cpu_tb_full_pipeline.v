`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/02 13:41:14
// Design Name: 
// Module Name: cpu_tb_full_pipeline
// Project Name: 
// Target Devices: 
// Tool Versions:`timescale 1ns/1ps

module cpu_tb_full_pipeline;

    reg clk;
    reg rst;

    // ALU signals
    reg  [31:0] alu_in1, alu_in2;
    reg  [3:0]  alu_op;
    wire [31:0] alu_out;

    // Register signals
    reg         wen;
    reg  [4:0]  reg_waddr;
    reg  [31:0] reg_wdata;
    wire [31:0] reg_rdata1, reg_rdata2;

    // 实例化 ALU
    alu u_alu (
        .alu_data1_i(alu_in1),
        .alu_data2_i(alu_in2),
        .alu_op_i(alu_op),
        .alu_result_o(alu_out)
    );

    // 实例化寄存器堆
    gen_regs u_regs (
        .clk(clk),
        .reset(rst),
        .wen(wen),
        .regRAddr1(reg_raddr1),
        .regRAddr2(reg_raddr2),
        .regWAddr(reg_waddr),
        .regWData(reg_wdata),
        .regRData1(reg_rdata1),
        .regRData2(reg_rdata2)
    );

    reg [4:0] reg_raddr1, reg_raddr2;

    // 时钟
    initial clk = 0;
    always #5 clk = ~clk; // 10ns 时钟周期

    initial begin
        rst = 1; wen = 0; alu_in1 = 0; alu_in2 = 0; alu_op = 0; reg_waddr = 0; reg_wdata = 0;
        reg_raddr1 = 5'b00001; reg_raddr2 = 5'b00010;
        #20 rst = 0;

        $display("===== 开始全寄存器和指令验证 =====");

        // 多条指令连续执行，写入不同寄存器
        test_pipeline("ADD", 5, 3, 4'b0000, 5'b00001);
        test_pipeline("SUB", 10, 4, 4'b1000, 5'b00010);
        test_pipeline("AND", 7, 3, 4'b0111, 5'b00011);
        test_pipeline("OR" , 5, 2, 4'b0110, 5'b00100);
        test_pipeline("XOR", 5, 2, 4'b0100, 5'b00101);
        test_pipeline("SLL", 2, 1, 4'b0001, 5'b00110);
        test_pipeline("SRL", 4, 1, 4'b0101, 5'b00111);
        test_pipeline("SRA", -8, 2, 4'b1101, 5'b01000);
        test_pipeline("SLT", 3, 5, 4'b0010, 5'b01001);
        test_pipeline("SLTU", 3, 5, 4'b0011, 5'b01010);
        test_pipeline("EQ", 3, 3, 4'b1001, 5'b01011);
        test_pipeline("NEQ", 3, 4, 4'b1010, 5'b01100);
        test_pipeline("GE", 5, 2, 4'b1100, 5'b01101);
        test_pipeline("GEU", 5, 2, 4'b1011, 5'b01110);

        // x0 永远不可写
        alu_in1 = 7; alu_in2 = 5; alu_op = 4'b0000; #10;
        wen = 1; reg_waddr = 5'b00000; reg_wdata = alu_out; #10;
        wen = 0;
        $display("尝试写 x0: 寄存器 x0=%0d (应为0)", u_regs.regs[0]);

        $display("===== 全部验证完成 =====");
        $finish;
    end

    // 任务：执行一条指令并写回寄存器
    task test_pipeline(
        input [8*10:1] name,
        input [31:0] in1,
        input [31:0] in2,
        input [3:0] op,
        input [4:0] waddr
    );
    begin
        alu_in1 = in1; alu_in2 = in2; alu_op = op; #10;
        wen = 1; reg_waddr = waddr; reg_wdata = alu_out; #10;
        wen = 0;
        $display("指令: %s | ALU_in1=%0d, ALU_in2=%0d, ALU_op=%b, ALU_out=%0d, 写寄存器 x%0d=%0d",
            name, in1, in2, op, alu_out, waddr, u_regs.regs[waddr]);
    end
    endtask

endmodule
 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module cpu_tb_full_pipeline(

    );
endmodule
