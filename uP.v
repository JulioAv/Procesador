module PC (input wire clock, enabled1, load, reset, input wire [11:0]D1, output reg [11:0]Q1);
always @(posedge clock or posedge reset) begin

  if (reset)
    Q1<=0;
  else if (load)
    Q1<=D1;
  else if (enabled1)
    Q1<=Q1+1'b1;
  end

endmodule

module ROM (input wire [11:0]M, output [7:0]O );
assign O = m[M];
reg[7:0] m[0:4095];

initial begin
  $readmemh("ROM.list", m);

end

endmodule

module Fetch (input wire [7:0]D2, input wire enabled2, clock, reset, output reg [3:0]op, ins);
reg [7:0]Q2;
always @(posedge clock or posedge enabled2 or posedge reset) begin
  if (reset)
    Q2<=0;
  else if (enabled2)
    Q2<=D2;

    assign ins[0] = Q2[4]; assign ins[1] = Q2[5]; assign ins[2] = Q2[6]; assign ins[3] = Q2[7];
    assign op[0] = Q2[0]; assign op[1] = Q2[1]; assign op[2] = Q2[2]; assign op[3] = Q2[3];
  end




endmodule

module Decode (input wire [6:0]D, output reg [12:0]Q);

   always @(*) begin

  casex (D)
    7'bxxxxxx0: Q=13'b1000000001000;
    7'b00001x1: Q=13'b0100000001000;
    7'b00000x1: Q=13'b1000000001000;
    7'b00011x1: Q=13'b1000000001000;
    7'b00010x1: Q=13'b0100000001000;
    7'b0010xx1: Q=13'b0001001000010;
    7'b0011xx1: Q=13'b1001001100000;
    7'b0100xx1: Q=13'b0011010000010;
    7'b0101xx1: Q=13'b0011010000100;
    7'b0110xx1: Q=13'b1011010100000;
    7'b0111xx1: Q=13'b1000000111000;
    7'b1000x11: Q=13'b0100000001000;
    7'b1000x01: Q=13'b1000000001000;
    7'b1001x11: Q=13'b1000000001000;
    7'b1001x01: Q=13'b0100000001000;
    7'b1010xx1: Q=13'b0011011000010;
    7'b1011xx1: Q=13'b1011011100000;
    7'b1100xx1: Q=13'b0100000001000;
    7'b1101xx1: Q=13'b0000000001001;
    7'b1110xx1: Q=13'b0011100000010;
    7'b1111xx1: Q=13'b1011100100000;
    default     Q=13'b0000000000000;
  endcase
end

endmodule

module ALU (input wire [3:0]A, B, input wire [2:0]F, output reg [3:0]Y, output reg FC, FZ);
  always @(A, B, F) begin
    case (F)
      3'b000: Y= A;
      3'b001: Y= A - B;
      3'b010: Y= B;
      3'b011: Y= A + B;
      3'b100: Y= {1'b0, ~(A & B)};
      default: Y= 5'b10101;
    endcase

    assign FC = Y[4];
    assign FZ = ~(Y[3] | Y[2] | Y[1] | Y[0]);
    end
endmodule

module Bus(input wire [3:0]D, input wire B, output wire [3:0]Q);
  assign Q = B ? D : 4'bz;
endmodule

module Accu(input wire [3:0]D1, input wire enabled3, clock, reset, output reg [3:0]Q1);
always @(posedge clock or posedge enabled3 or posedge reset) begin

  if (reset)
    Q1<=0;
  else if (enabled3)
    Q1<=D1;
  end
endmodule

module Phase(input wire clock, reset, output reg Q);
always @(posedge clock or posedge reset) begin
if (reset)
  Q<=0;
else
    Q<=~Q;

end
endmodule


module Out(input wire [3:0]D, input wire clock, enabled, reset, output reg [3:0]Q);
always @(posedge clock or posedge reset or posedge enabled) begin
if (reset)
  Q<=0;
else if (enabled)
  Q<=D;
end
endmodule

module RAM(
	input wire cs, we, input wire [11:0] dir, inout [3:0] data);
	reg [3:0] dataO;
	reg [3:0] mem [0:4095];

	assign data = (cs & !we)? dataO: 4'bz;

	always @ (dir or data or cs or we)
	begin
		if ( cs && we) begin
			mem[dir] = data;
		end
	end

	always @ (dir or cs or we)
	begin
		if (cs && !we) begin
			dataO = mem[dir];
		end
	end

endmodule

module Flgs(input wire clock, reset, enabled, input wire [1:0]D, output reg [1:0]Q);
always @(posedge clock or posedge reset or posedge enabled) begin
if (reset)
  Q<=0;
else if (enabled)
  Q<=D;
end
endmodule

module uP(input wire clock, reset, input wire [3:0]pushbuttons, output wire phase, c_flag, z_flag,
          output wire [3:0]instr, oprnd, accu, data_bus, FF_out, output wire [7:0] program_byte,
          output wire [11:0]PC, address_RAM);

wire[3:0] O;
wire[6:0] decode_in;
wire[12:0] decode_out;
wire C, ZERO;

assign decode_in = {instr, c_flag, z_flag, phase};
assign address_RAM={oprnd, program_byte};

PC PC1(clock, decode_out[12], decode_out[11], reset, address_RAM, PC);
ROM ROM1(PC, program_byte);
Fetch Fetch1(program_byte, ~phase, clock, reset, oprnd, instr);
Decode Decode1(decode_in, decode_out);
Bus bus_1(oprnd, decode_out[1], data_bus);
ALU ALU6(accu, data_bus, decode_out[8:6], O, C, ZERO);
Accu ACCU7(O, decode_out[10], clock, reset, accu);
Bus bus_2(O,  decode_out[3], data_bus);
Phase PHase9(clock, reset, phase);
Out Out0(data_bus, clock, decode_out[0], reset, FF_out);
Bus in(pushbuttons, decode_out[2], data_bus);
RAM ram1(decode_out[5], decode_out[4], address_RAM, data_bus);
Flgs f1(clock, reset, decode_out[9], {C, ZERO}, {c_flag, z_flag});


endmodule
