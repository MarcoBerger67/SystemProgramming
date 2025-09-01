`timescale 1ns / 1ps

module uart_top (
    input               clk,
    input               rst_n,
    input   wire        uart_rxd,
    output  wire        uart_txd,
    output  wire [7:0]  led,

    output  [31:0]      uart_read_data,
    input   [31:0]      uart_write_data,
    input   [31:0]      uart_addr,
    input               uart_wen
);

    parameter CLK_HZ = 50_000_000; 
    parameter BIT_RATE = 9600;
    parameter PAYLOAD_BITS = 8;

    wire [PAYLOAD_BITS-1:0]  core_rx_data;
    wire                     core_rx_valid;
    wire                     core_tx_busy;
    
    localparam ADDR_DATA_REG   = 32'h0;
    localparam ADDR_STATUS_REG = 32'h4;

    wire is_accessing_data_reg   = (uart_addr[11:0] == ADDR_DATA_REG[11:0]);
    wire is_accessing_status_reg = (uart_addr[11:0] == ADDR_STATUS_REG[11:0]);

    wire core_tx_en = uart_wen && is_accessing_data_reg && !core_tx_busy;
    wire [PAYLOAD_BITS-1:0] core_tx_data = uart_write_data[PAYLOAD_BITS-1:0];
    
    wire rx_data_read_clear = !uart_wen && is_accessing_data_reg;

    reg [31:0] read_data_selection;
    always @(*) begin
        if (is_accessing_data_reg) read_data_selection = {24'b0, core_rx_data};
        else if (is_accessing_status_reg) read_data_selection = {30'b0, ~core_tx_busy, core_rx_valid};
        else read_data_selection = 32'h0;
    end
    
    assign uart_read_data = (!uart_wen) ? read_data_selection : 32'h0;

    reg [PAYLOAD_BITS-1:0] led_reg;
    assign led = led_reg;
    
    always @(posedge clk) begin
        if(!rst_n) led_reg <= 8'hF0;
        else if(core_rx_valid) led_reg <= core_rx_data;
        else if(core_tx_en) led_reg <= core_tx_data;
    end

    uart_rx #(
        .BIT_RATE(BIT_RATE), .PAYLOAD_BITS(PAYLOAD_BITS), .CLK_HZ(CLK_HZ)
    ) i_uart_rx(
        .clk(clk),
        .rst_n(rst_n),
        .rx_data_read(rx_data_read_clear),
        .uart_rxd(uart_rxd),
        .uart_rx_en(1'b1),
        .uart_rx_break(),
        .uart_rx_valid(core_rx_valid),
        .uart_rx_data(core_rx_data)
    );

    uart_tx #(
        .BIT_RATE(BIT_RATE), .PAYLOAD_BITS(PAYLOAD_BITS), .CLK_HZ(CLK_HZ)
    ) i_uart_tx(
        .clk(clk),
        .rst_n(rst_n),
        .uart_txd(uart_txd),
        .uart_tx_en(core_tx_en),
        .uart_tx_busy(core_tx_busy),
        .uart_tx_data(core_tx_data) 
    );

endmodule