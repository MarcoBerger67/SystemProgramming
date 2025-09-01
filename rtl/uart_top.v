`timescale 1ns/1ps
// 
// Module: uart_top (Upgraded Version by [yy] 8.31 17£º11)
// Notes:
// - This module keeps the original interface for seamless integration.
// - It now implements register mapping for data and status access.
// - It properly utilizes the uart_addr input.
//
module uart_top (
    // This interface is IDENTICAL to your team lead's original uart_top.v
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

    // --- Parameters (kept from the original files) ---
    // IMPORTANT: Let's use 50MHz as it's a more common clock for FPGA peripherals.
    // The top.v should provide a 50MHz clock to this 'clk' input.
    parameter CLK_HZ = 50_000_000; 
    parameter BIT_RATE = 9600;
    parameter PAYLOAD_BITS = 8;

    // --- Internal wires connecting this wrapper to the RX/TX cores ---
    wire [PAYLOAD_BITS-1:0]  core_rx_data;
    wire                     core_rx_valid;
    wire                     core_tx_busy;
    
    // -----------------------------------------------------------------
    // 1. Address Decoding Logic (This is the main upgrade!)
    //    We now use the 'uart_addr' to decide what the CPU wants to do.
    // -----------------------------------------------------------------
    // Define our register addresses (we only care about the lower bits)
    localparam ADDR_DATA_REG   = 32'h0;
    localparam ADDR_STATUS_REG = 32'h4;

    wire is_accessing_data_reg   = (uart_addr[11:0] == ADDR_DATA_REG[11:0]);
    wire is_accessing_status_reg = (uart_addr[11:0] == ADDR_STATUS_REG[11:0]);

    // -----------------------------------------------------------------
    // 2. Write Logic (Controlling the TX core)
    // -----------------------------------------------------------------
    // The CPU wants to send data if it's a write operation (wen=1),
    // the address is the data register, and the transmitter is not busy.
    wire core_tx_en = uart_wen && is_accessing_data_reg && !core_tx_busy;
    wire [PAYLOAD_BITS-1:0] core_tx_data = uart_write_data[PAYLOAD_BITS-1:0];
    
    // The rx_valid flag should be cleared after the CPU reads the data register.
    wire rx_data_read_clear = !uart_wen && is_accessing_data_reg;

    // -----------------------------------------------------------------
    // 3. Read Logic (Providing data back to the CPU)
    // -----------------------------------------------------------------
    // This is combinational logic, providing an immediate response,
    // just like in the original design.
    reg [31:0] read_data_selection;
    always @(*) begin
        if (is_accessing_data_reg) begin
            // If CPU reads the data register, provide the last received byte.
            read_data_selection = {24'b0, core_rx_data};
        end else if (is_accessing_status_reg) begin
            // If CPU reads the status register, provide the status.
            // Bit 1: TX is ready (not busy)
            // Bit 0: RX has valid data
            read_data_selection = {30'b0, ~core_tx_busy, core_rx_valid};
        end else begin
            read_data_selection = 32'h0;
        end
    end
    
    // The final read data is only driven if the CPU is NOT writing.
    assign uart_read_data = (!uart_wen) ? read_data_selection : 32'h0;

    // -----------------------------------------------------------------
    // 4. LED Logic (Kept from original, slightly improved)
    // -----------------------------------------------------------------
    reg [PAYLOAD_BITS-1:0] led_reg;
    assign led = led_reg;
    
    always @(posedge clk) begin
        if(!rst_n) begin
            led_reg <= 8'hF0;
        end else if(core_rx_valid) begin // When new data arrives
            led_reg <= core_rx_data;
        end else if(core_tx_en) begin    // When a new character is sent
            led_reg <= core_tx_data;
        end
    end

    // ------------------------------------------------------------------------- 
    // 5. Instantiate the original RX and TX cores (No changes needed here)
    // ------------------------------------------------------------------------- 
    uart_rx #(
        .BIT_RATE(BIT_RATE),
        .PAYLOAD_BITS(PAYLOAD_BITS),
        .CLK_HZ  (CLK_HZ)
    ) i_uart_rx(
        .clk          (clk),
        .rst_n       (rst_n),
        .clk(clk), .rst_n(rst_n), .uart_txd(uart_txd), .uart_tx_en(core_tx_en),
        .uart_rxd     (uart_rxd),
        .uart_rx_en   (1'b1),
        .uart_rx_break(),
        .uart_rx_valid(core_rx_valid),
        .uart_rx_data (core_rx_data)
    );

    uart_tx #(
        .BIT_RATE(BIT_RATE), .PAYLOAD_BITS(PAYLOAD_BITS), .CLK_HZ(CLK_HZ)
    ) i_uart_tx(
        .clk(clk), .resetn(rst_n), .uart_txd(uart_txd), .uart_tx_en(core_tx_en),
        .uart_tx_busy(core_tx_busy), .uart_tx_data(core_tx_data) 
    );

endmodule