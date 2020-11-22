module testbench();
    
    reg clk, reset, enCounter, enFetch, load;
    reg [11:0] counter12bit;
    wire [3:0] instr, oprnd;
    wire [7:0] program_byte;
    
    // Puertos del ej01 input clk, reset, enCounter, enFetch, load, input [11:0] counter12bit, output [3:0] instr, oprnd, output [7:0] program_byte
    ej01 U1 (clk, reset, enCounter, enFetch, load, counter12bit, instr, oprnd, program_byte);
    
    always
        #5 clk = ~clk;
    
    initial
        #100 $finish;
        
    initial begin
        $display("");
        $monitor("",);
        clk = 0; reset = 0; enCounter = 0; enFetch = 0; load = 0; counter12bit = 12'h000;
        #2 reset = 1;
        #1 reset = 0;
        
        // Primera prueba será verificar el contador + ROM
        // Esto es sencillamente ver que con cada flanco de reloj se vea un
        // nuevo dato en program_byte. No se agrega un delay de intención.
        // Ya que enFetch = 0 la salida debe ser 4'b0000 todo el tiempo
        enCounter = 1;
        
        // La siguiente prueba es hacer el 'load' del contador.
        // Saltamos a la localidad 0x123.
        // El enCounter lo dejamos a propósito en 1 para verificar que el load
        // tenga preferencia sobre el conteo. Se espera tener el valor de la
        // localidad de memoria 0x123 en el program_byte
        #20
        counter12bit = 12'h123;
        load = 1;
        
        // Se deshabilita el load y se permite el conteo de un par de localidades
        // de memoria.
        // NOTA: En este punto me percaté que las únicas señales que deben
        // estar en la lista de sensibilidad del contador son clk y reset.
        // Si se agrega el bit de load o de los 12 bits de entrada produce resultados
        // que podrían causar conflictos con el procesador. En este momento no
        // he hecho pruebas con el procesador, pero es algo importante que tener
        // en cuenta.
        #10
        load = 0;
        counter12bit = 12'h00A;
        
        // Se deshabilita el conteo y se habilita el Fetch
        // En este momento en instr y oprnd deberían estar los mismos valores
        // que en el program_byte. El program_byte ya no cambia porque el conteo
        // se apagó.
        #10
        enCounter = 0;
        enFetch = 1;
    
    end
        
    initial begin
        $dumpfile("ej01_tb.vcd");
        $dumpvars(0, testbench);
    end
    
endmodule
