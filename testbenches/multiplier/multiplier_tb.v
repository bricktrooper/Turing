module MultiplierTB
#(
	parameter N = 4
)
(
	input wire i_clock,
	input wire i_reset,
	input wire i_start,
	output wire o_finished,

	input wire [N - 1 : 0] i_multiplicand,
	input wire [N - 1 : 0] i_multiplier,
	output wire [(2 * N) - 1 : 0] o_product
);

	Multiplier #(.N(N)) multiplier
	(
		.i_clock(i_clock),
		.i_reset(i_reset),
		.i_start(i_start),
		.o_finished(o_finished),

		.i_multiplicand(i_multiplicand),
		.i_multiplier(i_multiplier),
		.o_product(o_product)
	);

	initial begin
`ifdef WAVES
		$dumpfile("multiplier.vcd");
		$dumpvars(0, multiplier);
`endif
	end

endmodule
