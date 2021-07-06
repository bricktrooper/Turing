/* =================================================
 * ADDER: sum = augend + addend
 * ================================================= */

module Adder
#(
	parameter N = 8
)
(
	input wire [N - 1 : 0] i_augend,
	input wire [N - 1 : 0] i_addend,
	output wire [N - 1 : 0] o_sum,
	output wire o_carry
);
	// WIRES //

	wire [N - 1 : 0] carry_in;
	wire [N - 1 : 0] carry_out;
	wire [N - 1 : 0] half_sum;

	// SUM //

	assign half_sum = i_augend ^ i_addend;
	assign o_sum = half_sum ^ carry_in;

	// CARRY //

	assign carry_out = (i_augend & i_addend) | (half_sum & carry_in);

	// carry propagation
	assign carry_in[0] = 1'b0;
	assign carry_in[N - 1 : 1] = carry_out[N - 2 : 0];
	assign o_carry = carry_out[N - 1];

endmodule
