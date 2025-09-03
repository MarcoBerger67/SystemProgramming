`timescale 1ns/1ps

module tb_cpu_alu_reg;

  reg clk;
  reg reset;

  // CPU memory interface
  wire [31:0] imem_addr;
  wire        imem_valid;
  reg  [31:0] imem_instr;
  wire [31:0] dmem_addr;
  wire        dmem_valid;
  reg  [31:0] dmem_readData;
  wire [31:0] dmem_writeData;
  wire        dmem_memRead;
  wire        dmem_memWrite;
  wire [1:0]  dmem_maskMode;
  wire        dmem_sext;
  wire [31:0] dmem_readBack;

  // Instantiate your CPU (with new ALU and RegFile)
  cpu uut (
    .clk(clk),
    .reset(reset),
    .imem_addr(imem_addr),
    .imem_valid(imem_valid),
    .imem_good(1'b1),
    .imem_instr(imem_instr),
    .dmem_addr(dmem_addr),
    .dmem_valid(dmem_valid),
    .dmem_good(1'b1),
    .dmem_writeData(dmem_writeData),
    .dmem_memRead(dmem_memRead),
    .dmem_memWrite(dmem_memWrite),
    .dmem_maskMode(dmem_maskMode),
    .dmem_sext(dmem_sext),
    .dmem_readData(dmem_readData),
    .dmem_readBack(dmem_readBack)
  );

  // Clock
  initial clk = 0;
  always #5 clk = ~clk; // 100 MHz

  // Test program memory (simple instructions)
  reg [31:0] program [0:15];

  integer i;

  initial begin
    reset = 1;
    imem_instr = 32'b0;
    dmem_readData = 32'b0;

    // Initialize test program
    // Example: ADDI x1, x0, 10
    //          ADDI x2, x0, 20
    //          ADD x3, x1, x2
    program[0] = 32'h00A00093; // ADDI x1, x0, 10
    program[1] = 32'h01400113; // ADDI x2, x0, 20
    program[2] = 32'h002081B3; // ADD x3, x1, x2
    program[3] = 32'h00310133; // ADD x2, x2, x3
    program[4] = 32'h00000013; // NOP
    program[5] = 32'h00000013; // NOP

    #20;
    reset = 0;

    // Run simulation for some cycles
    for(i=0; i<20; i=i+1) begin
      @(posedge clk);
      imem_instr = program[i];
      // Print PC and simulated ALU/Registers
      $display("Time %0t | PC: %0h | Instr: %0h", $time, uut.pc, imem_instr);
      $display("x1=%0d x2=%0d x3=%0d", uut.u_gen_regs.regs[1], uut.u_gen_regs.regs[2], uut.u_gen_regs.regs[3]);
      $display("ALU out=%0d", uut.u_alu.alu_result_o);
      $display("-------------------------------");
    end

    $display("Simulation finished.");
    $finish;
  end

endmodule
