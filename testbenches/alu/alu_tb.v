module ALU_TB
#(
	parameter N = 4
)
(
	input wire clock,
	input wire reset,

	input wire start,
	output wire finished,

	input wire [4:0] opcode,

	input wire [N - 1 : 0] A,
	input wire [N - 1 : 0] B,
	output wire [N - 1 : 0] Y
);

	ALU #(.N(N)) alu
	(
		.clock(clock),
		.reset(reset),
		.start(start),
		.finished(finished),
		.opcode(opcode),
		.A(A),
		.B(B),
		.Y(Y)
	);

	initial begin
`ifdef WAVES
		$dumpfile("alu.vcd");
		$dumpvars(0, alu);
`endif
	end

endmodule
