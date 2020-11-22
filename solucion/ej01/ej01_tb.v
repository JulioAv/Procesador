module counter_tb ();

    reg clk, reset, enabled, load;
    reg [11:0] loadData;
    wire[11:0] outValue;

    counter U1(.clk(clk), .reset(reset), .enabled(enabled), .load(load), .loadData(loadData), .outValue(outValue));

    initial begin
        $display("reset\tenabled\tload\tloadData\t\toutValue");
        $monitor("%b\t%b\t%b\t%b\t\t%b",reset, enabled, load, loadData, outValue);
        clk = 0; reset = 0; enabled = 0; load = 0; loadData = 12'b1100_0011_0101;
        #1 reset = 1;
        #1 reset = 0;
    end
    
    initial begin
        #8 enabled = 1;
        #(52-4) enabled = 0;
        #25 enabled = 1;
        #44 enabled = 0;
    end
    
    initial begin
        #52 load = 1;
        #12 loadData = 12'b1111_0000_1111;
        #12 load = 0;
    end
    
    initial
        #150 $finish;
    
    always
        #5 clk = ~clk;
    
    initial begin
        $dumpfile("ej01_tb.vcd");
        $dumpvars(0, counter_tb);
    end
    
endmodule
