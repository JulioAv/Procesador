module ALU (input [2:0] F, input [3:0] A, B, output [3:0] res);

    reg [4:0] tempRes;
    
    always @ (F, A, B) begin
        tempRes = 5'b0;
        case (F)
            3'b000: tempRes = A & B;
            3'b001: tempRes = A | B;
            3'b010: tempRes = A + B;
            3'b011: tempRes = 5'b0;
            3'b100: tempRes = A & ~B;
            3'b101: tempRes = A | ~B;
            3'b110: tempRes = A - B;
            3'b111: begin tempRes = A - B; tempRes = tempRes >> 4; end
            default: tempRes = 5'b00000;
        endcase
    end

    assign res = tempRes;

endmodule
