module testbench ();

    reg [11:0] address;
    wire [7:0] data;
    
    ROM U1(.address(address), .data(data));
    
    initial begin
        $display("Address:\tData:");
        $monitor("%b\t%b",address, data);
        address = 12'h000;
        #1 address = 12'h001;
        #1 address = 12'h002;
        #1 address = 12'h00A;
        #1 address = 12'h00B;
        #1 address = 12'h00C;
        #1 address = 12'h123;
        #1 address = 12'h124;
        #1 address = 12'h125;
        #1 address = 12'hFFF;
        $finish;
    end

endmodule
