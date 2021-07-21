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
		.o_undefined(o_undefined)
	);

	initial begin
		$dumpfile("divider.vcd");
		$dumpvars(0, divider);
	end

endmodule
