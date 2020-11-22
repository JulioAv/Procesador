module ROM (input [11:0] address, output [7:0] data);

    reg [7:0] memory [0:4096];
    
    initial
        $readmemb("memory.list", memory);
    
    assign data = memory[address];

endmodule
