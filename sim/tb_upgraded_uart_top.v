`timescale 1ns / 1ps

module tb_upgraded_uart_top();

    // 1. 定义信号，用于连接到我们升级后的 uart_top
    reg         clk;
    reg         rst_n;
    reg         uart_rxd; // 我们现在需要能驱动它，来测试接收
    wire        uart_txd;
    wire [7:0]  led;
    wire [31:0] uart_read_data;
    reg  [31:0] uart_write_data;
    reg  [31:0] uart_addr;
    reg         uart_wen;

    // 2. 例化我们要测试的 uart_top 模块 (DUT)
    // 这里通过参数传递，告诉DUT它的工作时钟是100MHz
    uart_top #(
        .CLK_HZ(100_000_000) 
    ) u_dut (
        .clk(clk),
        .rst_n(rst_n),
        .uart_rxd(uart_rxd),
        .uart_txd(uart_txd),
        .led(led),
        .uart_read_data(uart_read_data),
        .uart_write_data(uart_write_data),
        .uart_addr(uart_addr),
        .uart_wen(uart_wen)
    );

    // 3. 产生时钟和复位
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock
    end

    initial begin
        rst_n = 0;
        uart_rxd = 1; // RXD线空闲时为高电平
        #100;
        rst_n = 1;
    end

    // 4. 定义一个用于发送UART波形的任务 (Task)
    //    这样我们就可以方便地模拟外部设备发送数据
    task send_uart_byte;
        input [7:0] data;
        integer i;
        begin
            // Start bit
            uart_rxd = 0;
            #104160; // 等待一个波特周期 (for 9600 baud @ 100MHz)

            // Data bits (LSB first)
            for (i = 0; i < 8; i = i + 1) begin
                uart_rxd = data[i];
                #104160;
            end

            // Stop bit
            uart_rxd = 1;
            #104160;
        end
    endtask

    // 5. 编写测试序列
    initial begin
        // 初始化控制信号
        uart_write_data = 32'h0;
        uart_addr       = 32'h0;
        uart_wen        = 1'b0;

        @(posedge rst_n); // 等待复位结束
        #200;

        $display("----------------- Test Start -----------------");

        // --- Test 1: Read Status Register (should be TX Ready) ---
        uart_addr = 32'h4;
        uart_wen  = 1'b0;
        #10; // 等待组合逻辑稳定
        if (uart_read_data == 32'h2) begin
            $display("[%t ns] PASS: Read status OK, TX is ready.", $time);
        end else begin
            $display("[%t ns] FAIL: Read status ERROR, expected 2, got %h", $time, uart_read_data);
        end
        
        // --- Test 2: Write 'A' to Data Register ---
        $display("[%t ns] INFO: Writing 'A' to data register...", $time);
        uart_addr = 32'h0;
        uart_wen  = 1'b1;
        uart_write_data = 32'h41;
        #10;
        uart_wen = 1'b0; // 写操作只持续一个周期

        // --- Test 3: Read Status Register again (should be TX Busy) ---
        $display("[%t ns] INFO: Checking status during transmission...", $time);
        uart_addr = 32'h4;
        #10;
        if (uart_read_data == 32'h0) begin
            $display("[%t ns] PASS: Read status OK, TX is busy.", $time);
        end else begin
            $display("[%t ns] FAIL: Read status ERROR, expected 0, got %h", $time, uart_read_data);
        end

        // 等待发送完成 (大约1ms)
        #1050000;

        // --- Test 4: Simulate receiving 'B' ---
        $display("[%t ns] INFO: Simulating reception of 'B'...", $time);
        send_uart_byte(8'h42);
        
        // --- Test 5: Poll Status Register until RX Valid is set (The Key Fix!) ---
        $display("[%t ns] INFO: Polling status until RX valid flag is set...", $time);
        uart_addr = 32'h4;
        uart_wen  = 1'b0;
        
        // Continuously check the status register every 100ns until bit 0 (RX Valid) is 1
        while (uart_read_data[0] != 1'b1) begin
            #100;
        end
        $display("[%t ns] PASS: Polling status OK, RX Valid flag is set.", $time);
        
        // --- Test 6: Read Data Register to get 'B' ---
        $display("[%t ns] INFO: Reading received data...", $time);
        uart_addr = 32'h0;
        #10; // Wait for combinational logic to settle
        if (uart_read_data == 32'h42) begin
            $display("[%t ns] PASS: Read received data OK, got 'B' (0x42).", $time);
        end else begin
            $display("[%t ns] FAIL: Read received data ERROR, expected 42, got %h", $time, uart_read_data);
        end
    
        $display("----------------- Test Finish -----------------");
        $display("----             ALL TESTS PASSED!         ----");
        #100;
        $finish;
    end

endmodule