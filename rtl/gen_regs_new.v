`timescale 1ns/1ps
module gen_regs_new (
    input  clk,
    input  reset,
    input  wen,
    input  [4:0] regRAddr1,
    input  [4:0] regRAddr2,
    input  [4:0] regWAddr,
    input  [31:0] regWData,
    output [31:0] regRData1,
    output [31:0] regRData2
);

    integer ii;
    reg [31:0] regs[31:0];

    // 写寄存器
    always @(posedge clk or posedge reset) begin
        if(reset) begin
            for(ii=0; ii<32; ii=ii+1)
                regs[ii] <= 32'b0;
        end
        else if(wen & (|regWAddr))   // x0 不可写
            regs[regWAddr] <= regWData;
    end

    // 读寄存器，支持写回前递，x0 永远为0
    assign regRData1 = (regRAddr1 == 5'b0) ? 32'b0 :
                       (wen & (regWAddr == regRAddr1)) ? regWData : regs[regRAddr1];
    assign regRData2 = (regRAddr2 == 5'b0) ? 32'b0 :
                       (wen & (regWAddr == regRAddr2)) ? regWData : regs[regRAddr2];

endmodule
