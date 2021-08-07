/* ========================================================================================================
 * |                                      ALU (Arithmetic Logic Unit)                                     |
 * | ---------------------------------------------------------------------------------------------------- |
 * | OPERATION                | COMMAND | OPCODE  | OPERAND #1 (A) | OPERAND #2 (B) | RESULT (Y)          |
 * | ---------------------------------------------------------------------------------------------------- |
 * | unsigned add             | add     | 00000   | addend         | augend         | sum                 |
 * | unsigned subtract        | sub     | 00001   | minuend        | subtrahend     | difference          |
 * | unsigned multiply        | mul     | 00010   | multiplicand   | multiplier     | product             |
 * | unsigned divide          | div     | 00011   | dividend       | divisor        | quotient, remainder |
 * | less than                | lt      | 00100   | left           | right          | result              |
 * | greater than             | gt      | 00101   | left           | right          | result              |
 * | equal to                 | eq      | 00110   | left           | right          | result              |
 * | less than or equal to    | le      | 00111   | left           | right          | result              |
 * | greater than or equal to | ge      | 01000   | left           | right          | result              |
 * | not equal                | ne      | 01001   | left           | right          | result              |
 * | logical shift left       | lsl     | 01010   | value          | iterations     | result              |
 * | logical shift right      | lsr     | 01011   | value          | iterations     | result              |
 * | logical rotate left      | lrl     | 01100   | value          | iterations     | result              |
 * | logical rotate right     | lrr     | 01101   | value          | iterations     | result              |
 * | bitwise and              | and     | 01110   | left           | right          | result              |
 * | bitwise or               | or      | 01111   | left           | right          | result              |
 * | bitwise not              | not     | 10000   | value          | ----------     | result              |
 * | bitwise xor              | xor     | 10001   | left           | right          | result              |
 * | bitwise nand             | nand    | 10010   | left           | right          | result              |
 * | bitwise nor              | nor     | 10011   | left           | right          | result              |
 * | bitwise xnor             | xnor    | 10100   | left           | right          | result              |
 * | passthrough              | nop     | default | value          | ----------     | result              |
 * ======================================================================================================== */

`define add    5'b00000
`define sub    5'b00001
`define mul    5'b00010
`define div    5'b00011
`define lt     5'b00100
`define gt     5'b00101
`define eq     5'b00110
`define le     5'b00111
`define ge     5'b01000
`define ne     5'b01001
`define lsl    5'b01010
`define lsr    5'b01011
`define lrl    5'b01100
`define lrr    5'b01101
`define and    5'b01110
`define or     5'b01111
`define not    5'b10000
`define xor    5'b10001
`define nand   5'b10010
`define nor    5'b10011
`define xnor   5'b10100

module ALU
#(
	parameter N = 8
)
(
	input wire clock,
	input wire reset,

	input wire start,
	output wire finished,

	input wire [N - 1 : 0] A,
	input wire [N - 1 : 0] B,
	output wire [N - 1 : 0] Y,
	output wire [N - 1 : 0] X
);

	// ADDER //

	wire [(2 * N) - 1 : 0] adder_augend;
	wire [(2 * N) - 1 : 0] adder_addend;
	wire [(2 * N) - 1 : 0] adder_sum;
	wire adder_carry;

	Adder #(.N(2 * N)) adder
	(
		.i_augend(adder_augend),
		.i_addend(adder_addend),
		.o_sum(adder_sum),
		.o_carry(adder_carry)
	);

	// SUBTRACTOR //

	wire [N - 1 : 0] subtractor_minuend;
	wire [N - 1 : 0] subtractor_subtrahend;
	wire [N - 1 : 0] subtractor_difference;
	wire subtractor_borrow;

	Subtractor #(.N(N)) subtractor
	(
		.i_minuend(subtractor_minuend),
		.i_subtrahend(subtractor_subtrahend),
		.o_difference(subtractor_difference),
		.o_borrow(subtractor_borrow)
	);

	// MULTIPLIER //

	wire multiplier_start;
	wire multiplier_finished;
	wire [N - 1 : 0] multiplier_multiplicand;
	wire [N - 1 : 0] multiplier_multiplier;
	wire [(2 * N) - 1 : 0] multiplier_product;
	wire [(2 * N) - 1 : 0] multiplier_adder_augend;
	wire [(2 * N) - 1 : 0] multiplier_adder_addend;
	wire [(2 * N) - 1 : 0] multiplier_adder_sum;

	Multiplier #(.N(N)) multiplier
	(
		.i_clock(clock),
		.i_reset(reset),
		.i_start(multiplier_start),
		.o_finished(multiplier_finished),
		.i_multiplicand(multiplier_multiplicand),
		.i_multiplier(multiplier_multiplier),
		.o_product(multiplier_product),
		.o_adder_augend(multiplier_adder_augend),
		.o_adder_addend(multiplier_adder_addend),
		.i_adder_sum(multiplier_adder_sum)
	);

	// DIVIDER //

	wire divider_start;
	wire divider_finished;
	wire divider_undefined;
	wire [N - 1 : 0] divider_dividend;
	wire [N - 1 : 0] divider_divisor;
	wire [N - 1 : 0] divider_quotient;
	wire [N - 1 : 0] divider_remainder;
	wire [N - 1 : 0] divider_subtractor_minuend;
	wire [N - 1 : 0] divider_subtractor_subtrahend;
	wire [N - 1 : 0] divider_subtractor_difference;
	wire divider_subtractor_borrow;

	Divider #(.N(N)) divider
	(
		.i_clock(clock),
		.i_reset(reset),
		.i_start(divider_start),
		.o_finished(divider_finished),
		.i_dividend(divider_dividend),
		.i_divisor(divider_divisor),
		.o_quotient(divider_quotient),
		.o_remainder(divider_remainder),
		.o_undefined(divider_undefined),
		.o_subtractor_minuend(divider_subtractor_minuend),
		.o_subtractor_subtrahend(divider_subtractor_subtrahend),
		.i_subtractor_difference(divider_subtractor_difference),
		.i_subtractor_borrow(divider_subtractor_borrow)
	);

	// COMPARATOR //

	wire [N - 1 : 0] comparator_left;
	wire [N - 1 : 0] comparator_right;
	wire comparator_greater;
	wire comparator_equal;
	wire comparator_less;
	wire comparator_greater_equal;
	wire comparator_not_equal;
	wire comparator_less_equal;

	Comparator #(.N(N)) comparator
	(
		.i_left(comparator_left),
		.i_right(comparator_right),
		.o_greater(comparator_greater),
		.o_equal(comparator_equal),
		.o_less(comparator_less),
		.o_greater_equal(comparator_greater_equal),
		.o_not_equal(comparator_not_equal),
		.o_less_equal(comparator_less_equal)
	);

	// SHIFTER / ROTATOR //

	wire shifter_start;
	wire shifter_finished;
	wire shifter_direction;
	wire shifter_rotate;
	wire [N - 1 : 0] shifter_iterations;
	wire [N - 1 : 0] shifter_input_value;
	wire [N - 1 : 0] shifter_output_value;
	wire [N - 1 : 0] shifter_adder_augend;
	wire [N - 1 : 0] shifter_adder_addend;
	wire [N - 1 : 0] shifter_adder_sum;
	wire [N - 1 : 0] shifter_comparator_left;
	wire [N - 1 : 0] shifter_comparator_right;
	wire shifter_comparator_equal;

	Shifter #(.N(N)) shifter
	(
		.i_clock(clock),
		.i_reset(reset),
		.i_start(shifter_start),
		.o_finished(shifter_finished),
		.i_direction(shifter_direction),
		.i_rotate(shifter_rotate),
		.i_iterations(shifter_iterations),
		.i_value(shifter_input_value),
		.o_value(shifter_output_value),
		.o_adder_augend(shifter_adder_augend),
		.o_adder_addend(shifter_adder_addend),
		.i_adder_sum(shifter_adder_sum),
		.o_comparator_left(shifter_comparator_left),
		.o_comparator_right(shifter_comparator_right),
		.i_comparator_equal(shifter_comparator_equal)
	);

endmodule
