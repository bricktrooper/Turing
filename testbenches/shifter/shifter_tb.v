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
	output wire [N - 1 : 0] o_value
);
	Shifter #(.N(N)) shifter
	(
		.i_clock(i_clock),
		.i_reset(i_reset),
		.i_direction(i_direction),
		.i_iterations(i_iterations),
		.i_rotate(i_rotate),
		.i_start(i_start),
		.o_finished(o_finished),
		.i_value(i_value),
		.o_value(o_value)
	);

	initial begin
		$dumpfile("shifter.vcd");
		$dumpvars(0, shifter);
	end

endmodule
