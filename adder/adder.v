/* =================================================
 * ADDER: sum = augend + addend
 * ================================================= */

module Adder
#(
	parameter BITS = 8
)
(
	input  wire [BITS - 1 : 0] i_augend,
	input  wire [BITS - 1 : 0] i_addend,
	output wire [BITS - 1 : 0] o_sum,
	output wire o_carry
);
	// WIRES //

	wire [BITS - 1 : 0] carry_in;
	wire [BITS - 1 : 0] carry_out;
	wire [BITS - 1 : 0] half_sum;

	// SUM //

	assign half_sum = i_augend ^ i_addend;
	assign o_sum = half_sum ^ carry_in;

	// CARRY //

	assign carry_out = (i_augend & i_addend) | (half_sum & carry_in);

	// carry propagation
	assign carry_in[0] = 1'b0;
	assign carry_in[BITS - 1 : 1] = carry_out[BITS - 2 : 0];
	assign o_carry = carry_out[BITS - 1];

endmodule
