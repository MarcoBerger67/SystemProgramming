`timescale 1ns/1ps
module tb_console;

    // 鏃堕挓鍜屽浣�
    reg clk = 0;
    reg reset = 1;

    // ---------- ALU 淇″彿 ----------
    reg  [31:0] alu_a, alu_b;
    reg  [3:0]  alu_op;
    wire [31:0] alu_out;

    alu_new u_alu (
        .alu_data1_i(alu_a),
        .alu_data2_i(alu_b),
        .alu_op_i(alu_op),
        .alu_result_o(alu_out)
    );

    // ---------- 瀵勫瓨鍣ㄥ爢淇″彿 ----------
    reg         wen;
    reg  [4:0]  reg_waddr, reg_raddr1, reg_raddr2;
    reg  [31:0] reg_wdata;
    wire [31:0] reg_rdata1, reg_rdata2;

    gen_regs_new u_regs (
        .clk(clk),
        .reset(reset),
        .wen(wen),
        .regRAddr1(reg_raddr1),
        .regRAddr2(reg_raddr2),
        .regWAddr(reg_waddr),
        .regWData(reg_wdata),
        .regRData1(reg_rdata1),
        .regRData2(reg_rdata2)
    );

    // 鏃堕挓鐢熸垚
    always #5 clk = ~clk;  // 100MHz

    // 浠跨湡浠诲姟
    integer i;
    initial begin
        $display("=== Console Testbench Start ===");

        // 澶嶄綅瀵勫瓨鍣ㄥ爢
        reset = 1; wen = 0;
        #20;
        reset = 0;

        // ---------------- ALU 娴嬭瘯 ----------------
        $display("--- ALU Tests ---");
        alu_test(32'd2, 32'd3, 4'b0000); // ADD
        alu_test(32'd10, 32'd4, 4'b1000); // SUB
        alu_test(32'hFFFF0000, 32'hAAAA5555, 4'b0111); // AND
        alu_test(32'hFFFF0000, 32'hAAAA5555, 4'b0110); // OR

        // ---------------- 瀵勫瓨鍣ㄥ爢娴嬭瘯 ----------------
        $display("--- Register Tests ---");
        reg_write(5'd1, 32'h12345678);
        reg_write(5'd2, 32'hDEADBEEF);

        reg_read(5'd1, 5'd2);
        reg_write(5'd0, 32'hFFFFFFFF); // 鍐� x0 娴嬭瘯
        reg_read(5'd0, 5'd1);

        $display("=== Console Testbench Finished ===");
        $stop;
    end

    // ---------- ALU 娴嬭瘯浠诲姟 ----------
    task alu_test(input [31:0] a, b, input [3:0] op);
    begin
        alu_a = a;
        alu_b = b;
        alu_op = op;
        #10;
        $display("ALU op=%b a=%h b=%h => result=%h", op, a, b, alu_out);
    end
    endtask

    // ---------- 瀵勫瓨鍣ㄥ啓浠诲姟 ----------
    task reg_write(input [4:0] addr, input [31:0] data);
    begin
        reg_waddr = addr;
        reg_wdata = data;
        wen = 1;
        #10;
        wen = 0;
        #1;
        $display("Write Reg x%0d = %h", addr, data);
    end
    endtask

    // ---------- 瀵勫瓨鍣ㄨ浠诲姟 ----------
    task reg_read(input [4:0] addr1, addr2);
    begin
        reg_raddr1 = addr1;
        reg_raddr2 = addr2;
        #1;
        $display("Read Reg x%0d = %h, x%0d = %h", addr1, reg_rdata1, addr2, reg_rdata2);
    end
    endtask

endmodule