`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/29 16:15:05
// Design Name: 
// Module Name: uart_core
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


module uart_core (
    input wire clk,         // ϵͳʱ�� (���Ǽ�����100MHz)
    input wire rstn,       // ��λ�ź� (�͵�ƽ��Ч)

    // ����CPU�ļ򵥿��ƽӿ�
    input wire        tx_start,     // �����ʼ���ͣ� (һ��ʱ�����ڵĸ�����)
    input wire [7:0]  tx_data_in, // Ҫ���͵�8λ����
    output wire       tx_busy,      // ״̬������æ�������������

    // ����������
    output wire       uart_tx_pin   // �������ӵ�FPGA�ⲿ�ķ�����
);

    // -----------------------------------------------------------------
    // 1. ������������ (Baud Rate Generator)
    // Ŀ�꣺����һ��Ƶ��Ϊ 9600 Hz �Ľ����źţ����ڿ���ÿһλ�ķ��ͽ���
    // ���㣺ϵͳʱ�� / ������ = ����������
    //      100,000,000 Hz / 9600 Hz = 10416.66...  ����ȡ 10416
    // -----------------------------------------------------------------
    parameter BAUD_RATE_COUNTER = 10416;
    reg [$clog2(BAUD_RATE_COUNTER)-1:0] baud_counter;
    wire baud_tick; // ������������ʱ������źŻ�����һ��ʱ������

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            baud_counter <= 0;
        end else begin
            if (baud_counter == BAUD_RATE_COUNTER - 1) begin
                baud_counter <= 0;
            end else begin
                baud_counter <= baud_counter + 1;
            end
        end
    end
    assign baud_tick = (baud_counter == BAUD_RATE_COUNTER - 1);

    // -----------------------------------------------------------------
    // 2. ����״̬�� (Transmit Finite State Machine)
    // ְ�𣺸��ݽ����źţ�����������������
    // ���̣����� -> ����ʼλ -> ��8������λ -> ��ֹͣλ -> �ص�����
    // -----------------------------------------------------------------
    parameter STATE_IDLE = 2'b00;
    parameter STATE_START = 2'b01;
    parameter STATE_DATA = 2'b10;
    parameter STATE_STOP = 2'b11;

    reg [1:0]   state_reg;        // �洢��ǰ״̬
    reg [2:0]   bit_counter_reg;  // ��¼���ڷ��͵ڼ�λ���� (0-7)
    reg [7:0]   tx_data_reg;      // ����Ҫ���͵�����

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            state_reg <= STATE_IDLE;
            bit_counter_reg <= 0;
        end else begin
            case (state_reg)
                STATE_IDLE: begin
                    if (tx_start) begin
                        tx_data_reg <= tx_data_in; // ��������
                        state_reg <= STATE_START;  // ������һ��״̬
                    end
                end
                STATE_START: begin
                    if (baud_tick) begin // �ȴ���һ������
                        state_reg <= STATE_DATA;
                        bit_counter_reg <= 0;
                    end
                end
                STATE_DATA: begin
                    if (baud_tick) begin // ÿ��һ�����ģ�����һλ
                        if (bit_counter_reg == 3'd7) begin // 8λ��������
                            state_reg <= STATE_STOP;
                        end else begin
                            bit_counter_reg <= bit_counter_reg + 1;
                        end
                    end
                end
                STATE_STOP: begin
                    if (baud_tick) begin // �ȴ����һ������
                        state_reg <= STATE_IDLE;
                    end
                end
                default: state_reg <= STATE_IDLE;
            endcase
        end
    end

    // ���ݵ�ǰ״̬����������źŵ�ֵ
    assign uart_tx_pin = (state_reg == STATE_START) ? 1'b0 :          // ����ʼλʱ������͵�ƽ
                         (state_reg == STATE_DATA)  ? tx_data_reg[bit_counter_reg] : // ������λʱ�������Ӧλ
                         1'b1;                                     // �������(IDLE, STOP)������ߵ�ƽ

    assign tx_busy = (state_reg != STATE_IDLE); // ֻҪ������IDLE״̬���ͱ�ʾ��æ

endmodule
