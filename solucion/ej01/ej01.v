module counter (input clk, reset, enabled, load, input [11:0] loadData, output reg [11:0] outValue);

    always @ (posedge clk, posedge reset, loadData) begin
        if (reset)
            outValue = 12'b0;
        else if (load)
            outValue = loadData;
        else if (enabled)
            outValue = outValue + 1;
    end

endmodule
