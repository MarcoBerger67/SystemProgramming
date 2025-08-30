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

    // �����������桿��������
    initial begin
        data_sram_en   = 0;
        data_sram_wen  = 4'b0;
        data_sram_addr = 32'h0;
        data_sram_wdata = 32'h0;

        @(posedge rstn);
        #100;

        $display("[%t ns] Testbench: ��ʼ��������...", $time);

        // --- ���� A: ����һ�ζ�״̬���� ---
        $display("[%t ns] Testbench: ������״̬����...", $time);
        @(posedge clk);
        data_sram_en   <= 1;
        data_sram_wen  <= 4'b0;
        data_sram_addr <= 32'h1faf0004;

        // --- ���� B: ����һ�����ڣ���������׼��������� ---
        // ��һ�ģ�wrapper�����������ǵ�����
        @(posedge clk);
        data_sram_en   <= 0;

        // --- ���� C: ����һ�����ڣ���鷵�ص����� ---
        // ��һ�ģ�wrapperӦ���Ѿ������ݷŵ���rdata��
        @(posedge clk);
        if (data_sram_rdata[0] == 1'b1) begin
            $display("[%t ns] Testbench: �ɹ�����UART����״̬��׼���������ݡ�", $time);
        end else begin
            $display("[%t ns] Testbench: ����δ�ܶ���UART����״̬��", $time);
            $finish;
        end

        // --- ���� D: �����ַ� 'A' (0x41) ---
        @(posedge clk);
        $display("[%t ns] Testbench: �����ݼĴ���д���ַ� 'A'...", $time);
        data_sram_en   <= 1;
        data_sram_wen  <= 4'b0001;
        data_sram_addr <= 32'h1faf0000;
        data_sram_wdata <= 32'h00000041;
        
        @(posedge clk);
        data_sram_en   <= 0;
        data_sram_wen  <= 4'b0;
        $display("[%t ns] Testbench: д�������ѷ�����", $time);

        #200000;
        $display("[%t ns] Testbench: ���������", $time);
        $finish;
    end

endmodule