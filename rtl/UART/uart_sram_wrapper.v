`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/29 16:19:35
// Design Name: 
// Module Name: uart_sram_wrapper
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


module uart_sram_wrapper (
    input wire clk,
    input wire rstn,
    input wire        data_sram_en,
    input wire [3:0]  data_sram_wen,
    input wire [31:0] data_sram_addr,
    input wire [31:0] data_sram_wdata,
    // ���޸ĵ� 1��: ������� wire ��Ϊ reg����Ϊ����Ҫ�洢ֵ
    output reg [31:0] data_sram_rdata, 
    output wire uart_tx_pin
);

    localparam ADDR_DATA_REG   = 32'h0000_0000;
    localparam ADDR_STATUS_REG = 32'h0000_0004;

    wire cpu_access_data_reg   = (data_sram_addr[11:0] == ADDR_DATA_REG[11:0]);
    wire cpu_access_status_reg = (data_sram_addr[11:0] == ADDR_STATUS_REG[11:0]);

    wire        core_tx_start;
    wire [7:0]  core_tx_data_in;
    wire        core_tx_busy;

    uart_core u_core (
        .clk(clk), .rstn(rstn),
        .tx_start(core_tx_start), .tx_data_in(core_tx_data_in),
        .tx_busy(core_tx_busy), .uart_tx_pin(uart_tx_pin)
    );

    assign core_tx_start   = data_sram_en && (|data_sram_wen) && cpu_access_data_reg;
    assign core_tx_data_in = data_sram_wdata[7:0];

    // --- ���߼� (��ȫ��д) ---
    // ����Ĵ�����������"�Ƿ����ڽ���һ�ζ�״̬����"
    reg is_reading_status_reg;
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            is_reading_status_reg <= 1'b0;
        end else begin
            // ����������ĵ��ģ������״̬����
            if (data_sram_en && (data_sram_wen == 4'b0) && cpu_access_status_reg) begin
                is_reading_status_reg <= 1'b1;
            end else begin
                is_reading_status_reg <= 1'b0;
            end
        end
    end

    // ���޸ĵ� 2��: ʹ�� always �������� rdata��ʵ����ȷ��1���ӳ�
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            data_sram_rdata <= 32'h0;
        end else if (is_reading_status_reg) begin // �����һ���Ƕ�״̬...
            // ...��ô��һ�ľͰ�״̬���������ȥ
            data_sram_rdata <= {31'b0, ~core_tx_busy}; 
        end else begin
            data_sram_rdata <= 32'h0; // ����ʱ����������Ϊ0
        end
    end

endmodule