/*

Para este ejercicio decidí agregar la salida del Accu para poder verificar el 
valor almacenado.

No era necesario para el laboratorio, pero resultó ser muy útil para verificar
la funcionalidad de la ALU.

Una recomendación para hacer estas verificaciones es abrir el programa
GTKWave por aparte y cargar el archivo .vcd del testbench. Hay una opción
que permite hacer un re-load de las gráficas. Esto evita que tengan que arrastrar
las señales cada vez que corran su programa.

El testbench completo está diseñado para usar GTKWave. No hay nada en $monitor

*/

module testbench();
    
    reg clk, reset, buffIn, buffOut, enAccu;
    reg [2:0] F;
    reg [3:0] busInput;
    wire C, Z;
    wire [3:0] busOutput, accu;
    
    ej02 U1 (clk, reset, buffIn, buffOut, enAccu, F, busInput, C, Z, busOutput, accu);
    
    always
        #5 clk = ~clk;
    
    initial
        #200 $finish;
    
    initial begin
        clk = 0; reset = 0; buffIn = 0; buffOut = 0; enAccu = 0; F = 3'b000; busInput = 4'b0000;
        #2 reset = 1;
        #1 reset = 0;
        
        // Almacenar algo en el Accu
        #1
        buffIn = 1;
        buffOut = 1;
        enAccu = 1;
        F = 3'b010;
        busInput = 4'b1010;
        
        // Cambiar la ALU a sumar +1 a cualquier cosa que esté en el Accu
        #10
        busInput = 4'b0001;
        F = 3'b011;
        
        // Deshabilitar el buffer de salidas
        #10
        buffOut = 0;
        
        // Re-habilitar el buffer de salida y deshabilitar el buffer de entrada
        // La ALU sigue sumando por lo que la salida debería ser Accu + 4'bz
        // Esto entrega 4'bxxxx en la salida porque la suma no se puede hacer
        #8
        buffOut = 1;
        #2
        buffIn = 0;
        
        // Cambiar la ALU a dejar pasar el accu. En este momento el Accu debería
        // tener un valor 4'bxxxx.
        #10
        F = 3'b000;
        
        // Guardar el valor 4'b0001 en el Accu y luego cambiar la ALU para dejar
        // pasar el valor del Accu a la salida
        #10
        buffIn = 1;
        F = 3'b010;
        #5
        F = 3'b000;
        
        // Cambiar la ALU para hacer CMPx y restar
        // La resta es 1-1 por lo que la bandera de Z debe levantarse
        // Cuando pasa a F la bandera de C debe levantarse también cuando
        // sea 0 - 1 (A < B)
        #5
        F = 3'b001;
        
        // Para probar Z de forma más extensa podemos dejar pasar 4'b0000 a la ALU
        #30
        busInput = 4'b0000;
        F = 3'b010;
        
        // Cambio a dejar pasar el Accu. Z debe seguir encendido.
        #10
        F = 3'b000;
        
        // Apagar enAccu, dejar pasar B y cambiar el valor de entrada
        #10
        enAccu = 0;
        busInput = 4'b0101;
        F = 3'b010;
        
        // Encender enAccu para almacenar el dato
        #10
        enAccu = 1;
        
        // Por último verificar NANDx. Debe ser ~(0101 & 0101)
        #10
        busInput = 4'b0101;
        F = 3'b100;
        
        // Apagar todas las señales y verificar el valor almacenado en el Accu
        // que debería ser 4'b1010.
        #10
        buffIn = 0;
        buffOut = 1;
        enAccu = 0;
        F = 3'b000;
        
    end
    
    
    initial begin
        $dumpfile("ej02_tb.vcd");
        $dumpvars(0, testbench);
    end

endmodule
