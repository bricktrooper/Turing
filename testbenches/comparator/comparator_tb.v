module ComparatorTB
#(
	parameter N = 4
)
(
	input wire i_clock,

	input wire [N - 1 : 0] i_left,
	input wire [N - 1 : 0] i_right,

	output wire o_greater,
	output wire o_equal,
	output wire o_less,
	output wire o_greater_equal,
	output wire o_not_equal,
	output wire o_less_equal
);

	Comparator #(.N(N)) comparator
	(
		.i_left(i_left),
		.i_right(i_right),
		.o_greater(o_greater),
		.o_equal(o_equal),
		.o_less(o_less),
		.o_greater_equal(o_greater_equal),
		.o_not_equal(o_not_equal),
		.o_less_equal(o_less_equal)
	);

	initial begin
`ifdef WAVES
		$dumpfile("comparator.vcd");
		$dumpvars(0, comparator);
`endif
	end

endmodule
