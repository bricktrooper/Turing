/* =================================================
 * COMPARATOR: greater = left > right
 *             equal = left == right
 *             less = left < right
 *             greater_equal = left >= right
 *             not_equal = left != right
 *             less_equal = left <= right
 * ================================================= */

module Comparator
#(
	parameter N = 8
)
(
	input wire [N - 1 : 0] i_left,
	input wire [N - 1 : 0] i_right,

	output wire o_greater,
	output wire o_equal,
	output wire o_less,
	output wire o_greater_equal,
	output wire o_not_equal,
	output wire o_less_equal
);
	// WIRES //

	wire [N - 1 : 0] left;
	wire [N - 1 : 0] right;

	wire [N - 1 : 0] greater_in;
	wire [N - 1 : 0] equal_in;
	wire [N - 1 : 0] less_in;

	wire [N - 1 : 0] greater_out;
	wire [N - 1 : 0] equal_out;
	wire [N - 1 : 0] less_out;

	// INPUT BIT FLIP //

	// flip the bits so the comparison is performed MSB to LSB
	generate
		for (genvar i = 0; i < N; i = i + 1) begin : bit_flip
			assign left[i] = i_left[(N - 1) - i];
			assign right[i] = i_right[(N - 1) - i];
		end
	endgenerate

	// GREATER THAN //

	assign greater_out = greater_in | (equal_in & left & ~right);

	assign greater_in[0] = 1'b0;                             // initial value
	assign greater_in[N - 1 : 1] = greater_out[N - 2 : 0];   // propagation

	// EQUAL TO //

	assign equal_out = equal_in & (left ~^ right);

	assign equal_in[0] = 1'b1;                           // initial value
	assign equal_in[N - 1 : 1] = equal_out[N - 2 : 0];   // propagation

	// LESS THAN //

	assign less_out = less_in | (equal_in & ~left & right);

	assign less_in[0] = 1'b0;                          // initial value
	assign less_in[N - 1 : 1] = less_out[N - 2 : 0];   // propagation

	// OUTPUTS //

	assign o_greater = greater_out[N - 1];
	assign o_equal = equal_out[N - 1];
	assign o_less = less_out[N - 1];

	assign o_greater_equal = o_greater | o_equal;
	assign o_not_equal = ~o_equal;
	assign o_less_equal = o_less | o_equal;

endmodule
