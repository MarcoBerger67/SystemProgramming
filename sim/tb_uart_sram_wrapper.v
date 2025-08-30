`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/30 21:09:14
// Design Name: 
// Module Name: tb_uart_sram_wrapper
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


module tb_uart_sram_wrapper();

    reg         clk;
    reg         rstn;
    reg         data_sram_en;
    reg  [3:0]  data_sram_wen;
    reg  [31:0] data_sram_addr;
    reg  [31:0] data_sram_wdata;
    wire [31:0] data_sram_rdata;
    wire        uart_tx_pin;

    uart_sram_wrapper u_dut (
        .clk(clk), .rstn(rstn),
        .data_sram_en(data_sram_en), .data_sram_wen(data_sram_wen),
        .data_sram_addr(data_sram_addr), .data_sram_wdata(data_sram_wdata),
        .data_sram_rdata(data_sram_rdata), .uart_tx_pin(uart_tx_pin)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rstn = 0; #100; rstn = 1;
    end

    // 【最终修正版】测试流程
    initial begin
        data_sram_en   = 0;
        data_sram_wen  = 4'b0;
        data_sram_addr = 32'h0;
        data_sram_wdata = 32'h0;

        @(posedge rstn);
        #100;

        $display("[%t ns] Testbench: 开始测试流程...", $time);

        // --- 步骤 A: 发出一次读状态请求 ---
        $display("[%t ns] Testbench: 发出读状态请求...", $time);
        @(posedge clk);
        data_sram_en   <= 1;
        data_sram_wen  <= 4'b0;
        data_sram_addr <= 32'h1faf0004;

        // --- 步骤 B: 在下一个周期，撤销请求并准备检查数据 ---
        // 这一拍，wrapper正在锁存我们的请求
        @(posedge clk);
        data_sram_en   <= 0;

        // --- 步骤 C: 再下一个周期，检查返回的数据 ---
        // 这一拍，wrapper应该已经把数据放到了rdata上
        @(posedge clk);
        if (data_sram_rdata[0] == 1'b1) begin
            $display("[%t ns] Testbench: 成功读到UART空闲状态！准备发送数据。", $time);
        end else begin
            $display("[%t ns] Testbench: 错误！未能读到UART空闲状态。", $time);
            $finish;
        end

        // --- 步骤 D: 发送字符 'A' (0x41) ---
        @(posedge clk);
        $display("[%t ns] Testbench: 向数据寄存器写入字符 'A'...", $time);
        data_sram_en   <= 1;
        data_sram_wen  <= 4'b0001;
        data_sram_addr <= 32'h1faf0000;
        data_sram_wdata <= 32'h00000041;
        
        @(posedge clk);
        data_sram_en   <= 0;
        data_sram_wen  <= 4'b0;
        $display("[%t ns] Testbench: 写入命令已发出。", $time);

        #200000;
        $display("[%t ns] Testbench: 仿真结束。", $time);
        $finish;
    end

endmodule