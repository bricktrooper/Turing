module SubtractorTB
#(
	parameter N = 4
)
(
	input wire i_clock,

	input wire [N - 1 : 0] i_minuend,
	input wire [N - 1 : 0] i_subtrahend,
	output wire [N - 1 : 0] o_difference,
	output wire o_borrow
);

	Subtractor #(.N(N)) subtractor
	(
		.i_minuend(i_minuend),
		.i_subtrahend(i_subtrahend),
		.o_difference(o_difference),
		.o_borrow(o_borrow)
	);

	initial begin
`ifdef WAVES
		$dumpfile("subtractor.vcd");
		$dumpvars(0, subtractor);
`endif
	end

endmodule
