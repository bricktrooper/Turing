/* =================================================
 * ADDER: sum = augend + addend
 * ================================================= */

module Adder
(
	input wire augend,
	input wire addend,
	output wire sum,
	output wire carry
);
	wire a;
	wire b;
	wire c_in;
	wire c_out;
	wire half_sum;
	wire full_sum;

	assign half_sum = a ^ b;
	assign full_sum = half_sum ^ c_in;
	assign c_out = (a & b) | (half_sum & c_in);

	assign a = augend;
	assign b = addend;
	assign sum = full_sum;
	assign carry = c_out;

endmodule
