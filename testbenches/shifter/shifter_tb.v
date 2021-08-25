module ShifterTB
#(
	parameter N = 4
)
(
	input wire i_clock,
	input wire i_reset,
	input wire i_start,
	output wire o_finished,

	input wire i_direction,
	input wire i_rotate,

	input wire [N - 1 : 0] i_iterations,

	input wire [N - 1 : 0] i_value,
	output wire [N - 1 : 0] o_result
);
	wire [N - 1 : 0] adder_augend;
	wire [N - 1 : 0] adder_addend;
	wire [N - 1 : 0] adder_sum;

	Adder #(.N(N)) adder
	(
		.i_augend(adder_augend),
		.i_addend(adder_addend),
		.o_sum(adder_sum),
		.o_carry()
	);

	wire [N - 1 : 0] comparator_left;
	wire [N - 1 : 0] comparator_right;
	wire comparator_equal;

	Comparator #(.N(N)) comparator
	(
		.i_left(comparator_left),
		.i_right(comparator_right),
		.o_equal(comparator_equal),

		.o_greater(),
		.o_less(),
		.o_greater_equal(),
		.o_not_equal(),
		.o_less_equal()
	);

	Shifter #(.N(N)) shifter
	(
		.i_clock(i_clock),
		.i_reset(i_reset),
		.i_start(i_start),
		.o_finished(o_finished),

		.i_direction(i_direction),
		.i_iterations(i_iterations),
		.i_rotate(i_rotate),

		.i_value(i_value),
		.o_result(o_result),

		.o_adder_augend(adder_augend),
		.o_adder_addend(adder_addend),
		.i_adder_sum(adder_sum),

		.o_comparator_left(comparator_left),
		.o_comparator_right(comparator_right),
		.i_comparator_equal(comparator_equal)
	);

	initial begin
`ifdef WAVES
		$dumpfile("shifter.vcd");
		$dumpvars(0, shifter);
`endif
	end

endmodule
