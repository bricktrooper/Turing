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
	wire [(2 * N) - 1 : 0] adder_augend;
	wire [(2 * N) - 1 : 0] adder_addend;
	wire [(2 * N) - 1 : 0] adder_sum;

	Adder #(.N(2 * N)) adder
	(
		.i_augend(adder_augend),
		.i_addend(adder_addend),
		.o_sum(adder_sum),
		.o_carry()
	);

	Multiplier #(.N(N)) multiplier
	(
		.i_clock(i_clock),
		.i_reset(i_reset),
		.i_start(i_start),
		.o_finished(o_finished),

		.i_multiplicand(i_multiplicand),
		.i_multiplier(i_multiplier),
		.o_product(o_product),

		.o_adder_augend(adder_augend),
		.o_adder_addend(adder_addend),
		.i_adder_sum(adder_sum)
	);

	initial begin
`ifdef WAVES
		$dumpfile("multiplier.vcd");
		$dumpvars(0, multiplier);
`endif
	end

endmodule
