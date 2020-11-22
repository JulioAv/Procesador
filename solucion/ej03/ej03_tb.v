module ALU_tb();

    reg [2:0] F;
    reg [3:0] A, B;
    wire [3:0] res;

    ALU U1(.F(F), .A(A), .B(B), .res(res));

    initial begin
        $display("A:\tB:\tF:\t\tres:");
        $monitor("%b\t%b\t%b\t\t%b",A,B,F,res);
        
        $display("--- A < B ---");
           A = 4'b0010; B = 4'b0011; F = 3'b000;
        #1 A = 4'b0010; B = 4'b0011; F = 3'b001;
        #1 A = 4'b0010; B = 4'b0011; F = 3'b010;
        #1 A = 4'b0010; B = 4'b0011; F = 3'b100;
        #1 A = 4'b0010; B = 4'b0011; F = 3'b101;
        #1 A = 4'b0010; B = 4'b0011; F = 3'b110;
        #1 A = 4'b0010; B = 4'b0011; F = 3'b111;
        
        #1 $display("--- A > B ---");
        #1 B = 4'b0010; A = 4'b1100; F = 3'b000;
        #1 B = 4'b0010; A = 4'b1100; F = 3'b001;
        #1 B = 4'b0010; A = 4'b1100; F = 3'b010;
        #1 B = 4'b0010; A = 4'b1100; F = 3'b100;
        #1 B = 4'b0010; A = 4'b1100; F = 3'b101;
        #1 B = 4'b0010; A = 4'b1100; F = 3'b110;
        #1 B = 4'b0010; A = 4'b1100; F = 3'b111;
        
        #1 $display("--- A = B ---");
        #1 B = 4'b0011; A = 4'b0011; F = 3'b000;
        #1 B = 4'b0011; A = 4'b0011; F = 3'b001;
        #1 B = 4'b0011; A = 4'b0011; F = 3'b010;
        #1 B = 4'b0011; A = 4'b0011; F = 3'b100;
        #1 B = 4'b0011; A = 4'b0011; F = 3'b101;
        #1 B = 4'b0011; A = 4'b0011; F = 3'b110;
        #1 B = 4'b0011; A = 4'b0011; F = 3'b111;
    end
    
    initial
        #100 $finish;

    initial begin
        $dumpfile("ej03_tb.vcd");
        $dumpvars(0, ALU_tb);
    end

endmodule
