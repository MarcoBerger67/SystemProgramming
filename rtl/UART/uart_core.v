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
    input wire clk,         // 系统时钟 (我们假设是100MHz)
    input wire rstn,       // 复位信号 (低电平有效)

    // 来自CPU的简单控制接口
    input wire        tx_start,     // 命令：开始发送！ (一个时钟周期的高脉冲)
    input wire [7:0]  tx_data_in, // 要发送的8位数据
    output wire       tx_busy,      // 状态：我正忙，别给我新任务

    // 物理发送引脚
    output wire       uart_tx_pin   // 最终连接到FPGA外部的发送线
);

    // -----------------------------------------------------------------
    // 1. 波特率生成器 (Baud Rate Generator)
    // 目标：产生一个频率为 9600 Hz 的节拍信号，用于控制每一位的发送节奏
    // 计算：系统时钟 / 波特率 = 计数器周期
    //      100,000,000 Hz / 9600 Hz = 10416.66...  我们取 10416
    // -----------------------------------------------------------------
    parameter BAUD_RATE_COUNTER = 10416;
    reg [$clog2(BAUD_RATE_COUNTER)-1:0] baud_counter;
    wire baud_tick; // 当计数器数满时，这个信号会拉高一个时钟周期

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
    // 2. 发送状态机 (Transmit Finite State Machine)
    // 职责：根据节拍信号，控制整个发送流程
    // 流程：空闲 -> 发起始位 -> 发8个数据位 -> 发停止位 -> 回到空闲
    // -----------------------------------------------------------------
    parameter STATE_IDLE = 2'b00;
    parameter STATE_START = 2'b01;
    parameter STATE_DATA = 2'b10;
    parameter STATE_STOP = 2'b11;

    reg [1:0]   state_reg;        // 存储当前状态
    reg [2:0]   bit_counter_reg;  // 记录正在发送第几位数据 (0-7)
    reg [7:0]   tx_data_reg;      // 锁存要发送的数据

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            state_reg <= STATE_IDLE;
            bit_counter_reg <= 0;
        end else begin
            case (state_reg)
                STATE_IDLE: begin
                    if (tx_start) begin
                        tx_data_reg <= tx_data_in; // 锁存数据
                        state_reg <= STATE_START;  // 进入下一个状态
                    end
                end
                STATE_START: begin
                    if (baud_tick) begin // 等待第一个节拍
                        state_reg <= STATE_DATA;
                        bit_counter_reg <= 0;
                    end
                end
                STATE_DATA: begin
                    if (baud_tick) begin // 每来一个节拍，发送一位
                        if (bit_counter_reg == 3'd7) begin // 8位都发完了
                            state_reg <= STATE_STOP;
                        end else begin
                            bit_counter_reg <= bit_counter_reg + 1;
                        end
                    end
                end
                STATE_STOP: begin
                    if (baud_tick) begin // 等待最后一个节拍
                        state_reg <= STATE_IDLE;
                    end
                end
                default: state_reg <= STATE_IDLE;
            endcase
        end
    end

    // 根据当前状态，决定输出信号的值
    assign uart_tx_pin = (state_reg == STATE_START) ? 1'b0 :          // 发起始位时，输出低电平
                         (state_reg == STATE_DATA)  ? tx_data_reg[bit_counter_reg] : // 发数据位时，输出对应位
                         1'b1;                                     // 其他情况(IDLE, STOP)，输出高电平

    assign tx_busy = (state_reg != STATE_IDLE); // 只要不处于IDLE状态，就表示正忙

endmodule
