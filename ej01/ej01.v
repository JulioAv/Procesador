/*

Este ejercicio está implementado completo en 1 sólo archivo .v

Los 3 primeros módulos que componen el ejercicios son (casi) los mismos de los ejercicios
de los laboratorios anteriores.

El último módulo implementa los primeros 3 y luego los conecta con 'wires'.

*/

module counter (input clk, reset, enabled, load, input [11:0] loadData, output reg [11:0] outValue);

    always @ (posedge clk, posedge reset) begin
        if (reset)
            outValue <= 12'b0;
        else if (load)
            outValue <= loadData;
        else if (enabled)
            outValue <= outValue + 1;
    end

endmodule

module ROM (input [11:0] address, output [7:0] data);

    reg [7:0] memory [0:4096];
    
    initial
        $readmemb("memory.list", memory);
    
    assign data = memory[address];

endmodule

module FF_D (input clk, reset, enabled, input [7:0] D, output reg [7:0] Q);

    always @ (posedge clk, posedge reset)
        if (reset)
            Q <= 8'b0000;
        else if (enabled)
            Q <= D;
    
endmodule

module ej01(input clk, reset, enCounter, enFetch, load,
            input [11:0] counter12bit,
            output [3:0] instr, oprnd,
            output [7:0] program_byte);
    
    
    wire [11:0] PC;
    
    // puertos de 'counter' -> input clk, reset, enabled, load, input [11:0] loadData, output reg [11:0] outValue
    counter U1(.clk(clk), .reset(reset), .enabled(enCounter), .load(load), .loadData(counter12bit), .outValue(PC));
    // puertos de 'ROM' -> input [11:0] address, output [7:0] data
    ROM U2 (PC, program_byte);
    // puertos de 'FF_D' -> input clk, reset, enabled, input [7:0] D, output reg [7:0] Q
    FF_D U3 (clk, reset, enFetch, program_byte, {instr, oprnd});
    
endmodule
