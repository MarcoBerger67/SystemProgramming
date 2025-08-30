`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/29 16:20:56
// Design Name: 
// Module Name: tb_uart_core
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


module tb_uart_core();

    // 1. 定义信号，用于连接到我们的UART模块
    reg         clk;
    reg         rstn;
    reg         tx_start;
    reg [7:0]   tx_data_in;
    wire        tx_busy;
    wire        uart_tx_pin;

    // 2. 例化 (Instantiate) 我们要测试的模块，并把线连上
    uart_core u_dut (
        .clk(clk),
        .rstn(rstn),
        .tx_start(tx_start),
        .tx_data_in(tx_data_in),
        .tx_busy(tx_busy),
        .uart_tx_pin(uart_tx_pin)
    );

    // 3. 产生时钟信号 (100MHz, 周期10ns)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // 4. 编写测试流程 (Test Sequence)
    initial begin
        // 初始化
        rstn = 0;
        tx_start = 0;
        tx_data_in = 8'h00;
        #100;

        rstn = 1;
        #200;

        // --- 开始下达测试命令 ---
        $display("[%t ns] Testbench: 命令UART发送字符 'A' (ASCII: 0x41)", $time);

        // **【关键修改在这里】**
        // 我们在时钟上升沿之前准备好信号
        @(posedge clk); // 等待下一个时钟上升沿 (305ns)
        tx_data_in = 8'h41;
        tx_start = 1;

        // 再等待一个时钟上升沿，确保start信号保持了整整一个周期
        @(posedge clk); // (315ns)
        tx_start = 0;
        // **【修改结束】**

        $display("[%t ns] Testbench: 发送命令已发出，等待发送完成...", $time);

        #200000;

        $display("[%t ns] Testbench: 仿真结束.", $time);
        $finish;
    end

endmodule
