module PC (input wire clock, reset, enabled, load, input wire [11:0]D, output reg [11:0]Q);
always @(posedge clock or posedge reset) begin

  if (reset)
    Q<=0;
  else if (load)
    Q<=D;
  else if (enabled)
    Q<=Q+12'b1;
  end

endmodule

module ROM (input wire [11:0]M, output [7:0]O );
assign O = m[M];
reg[7:0] m[0:4095];

initial begin
  $readmemh("ROM.list", m);

end

endmodule

module FFD4 (input wire clock, reset, enabled, input wire [3:0]D, output wire [3:0]Q);

FFD1 M3 (clock, reset, enabled, D[0], Q[0]);
FFD1 M4 (clock, reset, enabled, D[1], Q[1]);
FFD1 M5 (clock, reset, enabled, D[2], Q[2]);
FFD1 M7 (clock, reset, enabled, D[3], Q[3]);

endmodule

module FFD1 (input wire clock, reset, enabled, D, output reg Q);
always @(posedge clock or posedge reset) begin

  if (reset)
    Q<=0;
  else if (enabled)
    Q<=D;
  end
endmodule

module Fetch (input wire clock, reset, enabled, input wire [7:0]D, output wire[3:0]op, ins);
FFD4 m1(clock, reset, enabled, D[7:4], op[3:0]);
FFD4 m9(clock, reset, enabled, D[3:0], ins[3:0]);
endmodule

module Decode (input wire [6:0]D, output reg [12:0]Q);

   always @(*) begin

  casez (D)
    7'b??????0: Q=13'b1000000001000;
    7'b00001?1: Q=13'b0100000001000;
    7'b00000?1: Q=13'b1000000001000;
    7'b00011?1: Q=13'b1000000001000;
    7'b00010?1: Q=13'b0100000001000;
    7'b0010??1: Q=13'b0001001000010;
    7'b0011??1: Q=13'b1001001100000;
    7'b0100??1: Q=13'b0011010000010;
    7'b0101??1: Q=13'b0011010000100;
    7'b0110??1: Q=13'b1011010100000;
    7'b0111??1: Q=13'b1000000111000;
    7'b1000?11: Q=13'b0100000001000;
    7'b1000?01: Q=13'b1000000001000;
    7'b1001?11: Q=13'b1000000001000;
    7'b1001?01: Q=13'b0100000001000;
    7'b1010??1: Q=13'b0011011000010;
    7'b1011??1: Q=13'b1011011100000;
    7'b1100??1: Q=13'b0100000001000;
    7'b1101??1: Q=13'b0000000001001;
    7'b1110??1: Q=13'b0011100000010;
    7'b1111??1: Q=13'b1011100100000;
    default     Q=13'b0000000000000;
  endcase
end

endmodule

module ALU (input [3:0]A, B, input [2:0]F, output [3:0]Y, output  FC, FZ);
  reg [4:0]S;
  always @(A, B, F)
    case (F)
      3'b000: S<= A;
      3'b001: S<= A - B;
      3'b010: S<= B;
      3'b011: S<= A + B;
      3'b100: S<= {1'b0, ~(A & B)};
      default: S<= 5'b10101;
    endcase

    assign Y = S[3:0];
    assign FC = S[4];
    assign FZ = ~(S[3] | S[2] | S[1] | S[0]);

endmodule

module Bus(input wire [3:0]D, input wire B, output wire [3:0]Q);
  assign Q = B ? D : 4'bz;
endmodule

module Accu(input wire clock, reset, enabled, input wire [3:0]D, output wire [3:0]Q);
FFD4 F1(clock, reset, enabled, D, Q);
endmodule

module Phase(input wire clock, reset, enabled, output reg Q);
always @(posedge clock or posedge reset) begin
if (reset) begin
  Q<=0;
  end
else if (enabled) begin
    Q<=~Q;
    end

end
endmodule


module Out(input wire clock, reset, enabled, input wire [3:0]D, output reg [3:0]Q);
always @(posedge clock or posedge reset) begin
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

	assign data = (cs & !we)? dataO: 8'bz;

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

module Flgs(input wire clock, reset, enabled, input wire [1:0]D, output wire [1:0]Q);
FFD1 m6(clock, reset, enabled, D[0], Q[0]);
FFD1 m8(clock, reset, enabled, D[1], Q[1]);
endmodule

module uP(input wire clock, reset, input wire [3:0]pushbuttons, output wire phase, c_flag, z_flag,
          output wire [3:0]instr, oprnd, accu, data_bus, FF_out, output wire [7:0] program_byte,
          output wire [11:0]PC, address_RAM);

wire[3:0] O_ALU;
wire[6:0] decode_in;
wire[12:0] decode_out;
wire C, ZERO;

assign decode_in = {instr, c_flag, z_flag, phase};
assign address_RAM={oprnd, program_byte};

PC PC1(clock, reset, decode_out[12], decode_out[11], address_RAM, PC);
ROM ROM1(PC, program_byte);
Fetch Fetch1(clock, reset, ~phase, program_byte, instr, oprnd);
Decode Decode1(decode_in, decode_out);
Bus bus_1(oprnd, decode_out[1], data_bus);
ALU ALU6(accu, data_bus, decode_out[8:6], O_ALU, C, ZERO);
Accu ACCU7(clock, reset, decode_out[10], O_ALU, accu);
Bus bus_2(O_ALU, decode_out[3], data_bus);
Phase PHase9(clock, reset, 1'b1, phase);
Out Out0(clock, reset, decode_out[0], data_bus, FF_out);
Bus in(pushbuttons, decode_out[2], data_bus);
RAM ram1(decode_out[5], decode_out[4], address_RAM, data_bus);
Flgs f1(clock, reset, decode_out[9], {C, ZERO}, {c_flag, z_flag});


endmodule
