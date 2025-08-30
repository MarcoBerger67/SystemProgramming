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

    // 1. �����źţ��������ӵ����ǵ�UARTģ��
    reg         clk;
    reg         rstn;
    reg         tx_start;
    reg [7:0]   tx_data_in;
    wire        tx_busy;
    wire        uart_tx_pin;

    // 2. ���� (Instantiate) ����Ҫ���Ե�ģ�飬����������
    uart_core u_dut (
        .clk(clk),
        .rstn(rstn),
        .tx_start(tx_start),
        .tx_data_in(tx_data_in),
        .tx_busy(tx_busy),
        .uart_tx_pin(uart_tx_pin)
    );

    // 3. ����ʱ���ź� (100MHz, ����10ns)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // 4. ��д�������� (Test Sequence)
    initial begin
        // ��ʼ��
        rstn = 0;
        tx_start = 0;
        tx_data_in = 8'h00;
        #100;

        rstn = 1;
        #200;

        // --- ��ʼ�´�������� ---
        $display("[%t ns] Testbench: ����UART�����ַ� 'A' (ASCII: 0x41)", $time);

        // **���ؼ��޸������**
        // ������ʱ��������֮ǰ׼�����ź�
        @(posedge clk); // �ȴ���һ��ʱ�������� (305ns)
        tx_data_in = 8'h41;
        tx_start = 1;

        // �ٵȴ�һ��ʱ�������أ�ȷ��start�źű���������һ������
        @(posedge clk); // (315ns)
        tx_start = 0;
        // **���޸Ľ�����**

        $display("[%t ns] Testbench: ���������ѷ������ȴ��������...", $time);

        #200000;

        $display("[%t ns] Testbench: �������.", $time);
        $finish;
    end

endmodule
