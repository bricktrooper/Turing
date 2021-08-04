module DividerTB
#(
	parameter N = 4
)
(
	input wire i_clock,
	input wire i_reset,
	input wire i_start,
	output wire o_finished,

	input wire [N - 1 : 0] i_dividend,
	input wire [N - 1 : 0] i_divisor,
	output wire [N - 1 : 0] o_quotient,
	output wire [N - 1 : 0] o_remainder,

	output wire o_undefined
);
	wire [N - 1 : 0] subtractor_minuend;
	wire [N - 1 : 0] subtractor_subtrahend;
	wire [N - 1 : 0] subtractor_difference;
	wire subtractor_borrow;

	Subtractor #(.N(N)) Subtractor
	(
		.i_minuend(subtractor_minuend),
		.i_subtrahend(subtractor_subtrahend),
		.o_difference(subtractor_difference),
		.o_borrow(subtractor_borrow)
	);

	Divider #(.N(N)) divider
	(
		.i_clock(i_clock),
		.i_reset(i_reset),
		.i_start(i_start),
		.o_finished(o_finished),

		.i_dividend(i_dividend),
		.i_divisor(i_divisor),
		.o_quotient(o_quotient),
		.o_remainder(o_remainder),
		.o_undefined(o_undefined),

		.o_subtractor_minuend(subtractor_minuend),
		.o_subtractor_subtrahend(subtractor_subtrahend),
		.i_subtractor_difference(subtractor_difference),
		.i_subtractor_borrow(subtractor_borrow)
	);

	initial begin
`ifdef WAVES
		$dumpfile("divider.vcd");
		$dumpvars(0, divider);
`endif
	end

endmodule
