`timescale 1ns/1ps

module tb_top;

    // 时钟
    reg clk = 0;
    always #5 clk = ~clk; // 100 MHz

    // --- ALU 接口 ---
    reg  [31:0] alu_a, alu_b;
    reg  [3:0]  alu_op;
    wire [31:0] alu_result;

    alu u_alu(
        .alu_data1_i(alu_a),
        .alu_data2_i(alu_b),
        .alu_op_i(alu_op),
        .alu_result_o(alu_result)
    );

    // --- GEN_REG 接口 ---
    reg        reg_clk, reg_reset, reg_wen;
    reg  [4:0] reg_raddr1, reg_raddr2, reg_waddr;
    reg  [31:0] reg_wdata;
    wire [31:0] reg_rdata1, reg_rdata2;

    gen_regs u_reg(
        .clk(reg_clk),
        .reset(reg_reset),
        .wen(reg_wen),
        .regRAddr1(reg_raddr1),
        .regRAddr2(reg_raddr2),
        .regWAddr(reg_waddr),
        .regWData(reg_wdata),
        .regRData1(reg_rdata1),
        .regRData2(reg_rdata2)
    );

    integer pass_count, total_count;

    initial begin
        pass_count = 0;
        total_count = 0;

        // 复位寄存器堆
        reg_reset = 1; reg_clk = 0;
        #10;
        reg_reset = 0;

        // ---------------- ALU 测试 ----------------
        $display("=== ALU TESTS ===");

        alu_test(32'h2, 32'h20, `ALU_OP_ADD, 32'h22);
        alu_test(32'h20, 32'h10, `ALU_OP_SUB, 32'h10);
        alu_test(32'haaaa5555, 32'hffff0000, `ALU_OP_AND, 32'haaaa0000);
        alu_test(32'haaaa5555, 32'hffff0000, `ALU_OP_OR, 32'hffff5555);
        alu_test(32'h12345678, 32'h87654321, `ALU_OP_XOR, 32'h95511559);
        alu_test(32'h1, 32'h2, `ALU_OP_SLL, 32'h4);
        alu_test(32'h80000000, 32'h1, `ALU_OP_SRL, 32'h40000000);
        alu_test(32'h80000000, 32'h1, `ALU_OP_SRA, 32'hc0000000);
        alu_test(32'h5, 32'ha, `ALU_OP_SLT, 32'h1);
        alu_test(32'hfffffffe, 32'h1, `ALU_OP_SLTU, 32'h0);
        alu_test(32'h12345678, 32'h12345678, `ALU_OP_EQ, 32'h1);
        alu_test(32'h12345678, 32'h87654321, `ALU_OP_NEQ, 32'h1);
        alu_test(32'h2, 32'h2, `ALU_OP_GE, 32'h1);
        alu_test(32'h2, 32'h2, `ALU_OP_GEU, 32'h1);

        $display("ALU TESTS PASSED %0d / %0d", pass_count, total_count);

        // ---------------- GEN_REG 测试 ----------------
        $display("\n=== GEN_REG TESTS ===");

        reg_write(5'd1, 32'h12345678);
        reg_read(5'd1, 5'd0, 32'h12345678, 32'h0);

        reg_write(5'd2, 32'hdeadbeef);
        reg_read(5'd1, 5'd2, 32'h12345678, 32'hdeadbeef);

        // 尝试写 x0，应该保持为 0
        reg_write(5'd0, 32'hffffffff);
        reg_read(5'd0, 5'd0, 32'h0, 32'h0);

        $display("GEN_REG TESTS PASSED %0d / %0d", pass_count - total_count, total_count);

        $display("\n=== TOP-LEVEL TESTS FINISHED ===");
        $stop;
    end

    // ---------------- ALU 测试任务 ----------------
    task alu_test;
        input [31:0] a, b;
        input [3:0] op;
        input [31:0] expect;
        begin
            total_count = total_count + 1;
            alu_a = a;
            alu_b = b;
            alu_op = op;
            #10;
            if (alu_result === expect)
                begin
                    $display("PASS: ALU op=%04b a=%08h b=%08h result=%08h", op, a, b, alu_result);
                    pass_count = pass_count + 1;
                end
            else
                $display("FAIL: ALU op=%04b a=%08h b=%08h result=%08h (expected %08h)", op, a, b, alu_result, expect);
        end
    endtask

    // ---------------- GEN_REG 写任务 ----------------
    task reg_write;
        input [4:0] addr;
        input [31:0] data;
        begin
            reg_waddr = addr;
            reg_wdata = data;
            reg_wen   = 1;
            #10 reg_clk = 1; #10 reg_clk = 0; // 上升沿写
            reg_wen   = 0;
        end
    endtask

    // ---------------- GEN_REG 读任务 ----------------
    task reg_read;
        input [4:0] addr1, addr2;
        input [31:0] expect1, expect2;
        begin
            reg_raddr1 = addr1;
            reg_raddr2 = addr2;
            #1; // small delay for combinational read
            if (reg_rdata1 === expect1 && reg_rdata2 === expect2)
                begin
                    $display("PASS: Read x%0d=%08h x%0d=%08h", addr1, reg_rdata1, addr2, reg_rdata2);
                    pass_count = pass_count + 1;
                end
            else
                $display("FAIL: Read x%0d=%08h x%0d=%08h (expected %08h %08h)", addr1, reg_rdata1, addr2, reg_rdata2, expect1, expect2);
        end
    endtask

endmodule
