/* =================================================
 * SUBTRACTOR: difference = minuend - subtrahend
 * ================================================= */

module Subtractor
#(
	parameter N = 8
)
(
	input wire [N - 1 : 0] i_minuend,
	input wire [N - 1 : 0] i_subtrahend,
	output wire [N - 1 : 0] o_difference,
	output wire o_borrow
);
	// WIRES //

	wire [N - 1 : 0] borrow_in;
	wire [N - 1 : 0] borrow_out;
	wire [N - 1 : 0] half_difference;

	// DIFFERENCE //

	assign half_difference = i_subtrahend ^ borrow_in;
	assign o_difference = half_difference ^ i_minuend;

	// BORROW //

	assign borrow_out = (i_subtrahend & borrow_in) | (half_difference & ~i_minuend);

	// borrow propagation
	assign borrow_in[0] = 1'b0;
	assign borrow_in[N - 1 : 1] = borrow_out[N - 2 : 0];
	assign o_borrow = borrow_out[N - 1];

endmodule
