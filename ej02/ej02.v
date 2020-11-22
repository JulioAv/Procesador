//`include "ALU.v"
//`include "buffer.v"
//`include "FF_D.v"

module ej02 (input clk, reset, enBuff1, enBuff2, enAccu,
             input [2:0] F,
             input [3:0] busInput,
             output C,Z,
             output [3:0] busOutput, accu);
    
    wire [3:0] data_bus, aluResult;
    
    // puertos de buffer -> input enabled, input [3:0] A, output [3:0] Y
    buffer U1(enBuff1, busInput, data_bus);
    buffer U2(enBuff2, aluResult, busOutput);
    
    // puertos de ALU -> input [3:0] A, B, input [2:0] F, output C, Z, output [3:0] S
    ALU U3(.A(accu), .B(data_bus), .F(F), .C(C), .Z(Z), .S(aluResult));
    
    // puertos de FF_D -> input clk, reset, enabled, input [3:0] D, output reg [3:0] Q
    FF_D U4(clk, reset, enAccu, aluResult, accu);
    
endmodule
