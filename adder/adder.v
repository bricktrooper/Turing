/* =================================================
 * ADDER: sum = augend + addend
 * ================================================= */

module Adder
(
	input wire i_augend,
	input wire i_addend,
	output wire o_sum,
	output wire o_carry
);
	wire a;
	wire b;
	wire c_in;
	wire c_out;
	wire half_sum;
	wire full_sum;

	assign c_in = 1'b0;
	assign half_sum = a ^ b;
	assign full_sum = half_sum ^ c_in;
	assign c_out = (a & b) | (half_sum & c_in);

	assign a = i_augend;
	assign b = i_addend;
	assign o_sum = full_sum;
	assign o_carry = c_out;

endmodule
