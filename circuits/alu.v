/*
=====================================================================================================
|                                      ALU (Arithmetic Logic Unit)                                  |
| ------------------------------------------------------------------------------------------------- |
| OPERATION                | COMMAND | OPCODE        | OPERAND #1 (A) | OPERAND #2 (B) | RESULT (Y) |
| ------------------------------------------------------------------------------------------------- |
| unsigned add             | add     | 00000   (0)   | addend         | augend         | sum        |
| unsigned subtract        | sub     | 00001   (1)   | minuend        | subtrahend     | difference |
| unsigned multiply        | mul     | 00010   (2)   | multiplicand   | multiplier     | product    |
| unsigned divide          | div     | 00011   (3)   | dividend       | divisor        | quotient   |
| unsigned modulo          | mod     | 00100   (4)   | dividend       | divisor        | remainder  |
| less than                | lt      | 00101   (5)   | left           | right          | result     |
| greater than             | gt      | 00110   (6)   | left           | right          | result     |
| equal to                 | eq      | 00111   (7)   | left           | right          | result     |
| less than or equal to    | le      | 01000   (8)   | left           | right          | result     |
| greater than or equal to | ge      | 01001   (9)   | left           | right          | result     |
| not equal                | ne      | 01010   (10)  | left           | right          | result     |
| logical shift left       | lsl     | 01011   (11)  | value          | iterations     | result     |
| logical shift right      | lsr     | 01100   (12)  | value          | iterations     | result     |
| logical rotate left      | lrl     | 01101   (13)  | value          | iterations     | result     |
| logical rotate right     | lrr     | 01110   (14)  | value          | iterations     | result     |
| bitwise and              | and     | 01111   (15)  | left           | right          | result     |
| bitwise or               | or      | 10000   (16)  | left           | right          | result     |
| bitwise not              | not     | 10001   (17)  | value          | -------------- | result     |
| bitwise xor              | xor     | 10010   (18)  | left           | right          | result     |
| bitwise nand             | nand    | 10011   (19)  | left           | right          | result     |
| bitwise nor              | nor     | 10100   (20)  | left           | right          | result     |
| bitwise xnor             | xnor    | 10101   (21)  | left           | right          | result     |
| passthrough              | nop     | default (22+) | value          | -------------- | result     |
=====================================================================================================
*/

`define add    5'd0
`define sub    5'd1
`define mul    5'd2
`define div    5'd3
`define mod    5'd4
`define lt     5'd5
`define gt     5'd6
`define eq     5'd7
`define le     5'd8
`define ge     5'd9
`define ne     5'd10
`define lsl    5'd11
`define lsr    5'd12
`define lrl    5'd13
`define lrr    5'd14
`define and    5'd15
`define or     5'd16
`define not    5'd17
`define xor    5'd18
`define nand   5'd19
`define nor    5'd20
`define xnor   5'd21

module ALU
#(
	parameter N = 8
)
(
	input wire clock,
	input wire reset,

	input wire start,
	output wire finished,

	input wire [4:0] opcode,

	input wire [N - 1 : 0] A,
	input wire [N - 1 : 0] B,
	output wire [N - 1 : 0] Y
);
	// ===================== ARITHMETIC CIRCUITS ===================== //

	// ADDER //

	wire [N - 1 : 0] adder_augend;
	wire [N - 1 : 0] adder_addend;
	wire [N - 1 : 0] adder_sum;

	wire [(2 * N) - 1 : 0] adder_full_augend;
	wire [(2 * N) - 1 : 0] adder_full_addend;
	wire [(2 * N) - 1 : 0] adder_full_sum;

	wire adder_carry;

	Adder #(.N(2 * N)) adder
	(
		.i_augend(adder_full_augend),
		.i_addend(adder_full_addend),
		.o_sum(adder_full_sum),
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
	wire [N - 1 : 0] multiplier_product;
	wire multiplier_overflow;
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
		.o_overflow(multiplier_overflow),
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

	// ===================== LOGIC CIRCUITS ===================== //

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

	// BITWISE OPERATORS //

	wire [N - 1 : 0] and_result;
	wire [N - 1 : 0] or_result;
	wire [N - 1 : 0] not_result;
	wire [N - 1 : 0] xor_result;
	wire [N - 1 : 0] nand_result;
	wire [N - 1 : 0] nor_result;
	wire [N - 1 : 0] xnor_result;
	wire [N - 1 : 0] nop_result;

	// ===================== OPCODE DECODER ===================== //

	wire opcode_add;
	wire opcode_sub;
	wire opcode_mul;
	wire opcode_div;
	wire opcode_mod;
	wire opcode_lt;
	wire opcode_gt;
	wire opcode_eq;
	wire opcode_le;
	wire opcode_ge;
	wire opcode_ne;
	wire opcode_lsl;
	wire opcode_lsr;
	wire opcode_lrl;
	wire opcode_lrr;
	wire opcode_and;
	wire opcode_or;
	wire opcode_not;
	wire opcode_xor;
	wire opcode_nand;
	wire opcode_nor;
	wire opcode_xnor;

	reg [21:0] decoded;

	always @ (*) begin
		case (opcode)
			`add    : decoded = 22'b0000000000000000000001;
			`sub    : decoded = 22'b0000000000000000000010;
			`mul    : decoded = 22'b0000000000000000000100;
			`div    : decoded = 22'b0000000000000000001000;
			`mod    : decoded = 22'b0000000000000000010000;
			`lt     : decoded = 22'b0000000000000000100000;
			`gt     : decoded = 22'b0000000000000001000000;
			`eq     : decoded = 22'b0000000000000010000000;
			`le     : decoded = 22'b0000000000000100000000;
			`ge     : decoded = 22'b0000000000001000000000;
			`ne     : decoded = 22'b0000000000010000000000;
			`lsl    : decoded = 22'b0000000000100000000000;
			`lsr    : decoded = 22'b0000000001000000000000;
			`lrl    : decoded = 22'b0000000010000000000000;
			`lrr    : decoded = 22'b0000000100000000000000;
			`and    : decoded = 22'b0000001000000000000000;
			`or     : decoded = 22'b0000010000000000000000;
			`not    : decoded = 22'b0000100000000000000000;
			`xor    : decoded = 22'b0001000000000000000000;
			`nand   : decoded = 22'b0010000000000000000000;
			`nor    : decoded = 22'b0100000000000000000000;
			`xnor   : decoded = 22'b1000000000000000000000;
			default : decoded = 22'b0000000000000000000000;   // nop
		endcase
	end

	assign {
		opcode_add,
		opcode_sub,
		opcode_mul,
		opcode_div,
		opcode_mod,
		opcode_lt,
		opcode_gt,
		opcode_eq,
		opcode_le,
		opcode_ge,
		opcode_ne,
		opcode_lsl,
		opcode_lsr,
		opcode_lrl,
		opcode_lrr,
		opcode_and,
		opcode_or,
		opcode_not,
		opcode_xor,
		opcode_nand,
		opcode_nor,
		opcode_xnor
	} = decoded;

	// ===================== INPUT ROUTING ===================== //

	// ADDER //

	assign adder_augend = A;
	assign adder_addend = B;
	//assign Y = adder_sum[N - 1 : 0];
	//wire adder_carry;

	// truncate top N bits
	assign adder_full_augend[N - 1 : 0] = {{N{1'b0}}, adder_augend};
	assign adder_full_addend[N - 1 : 0] = {{N{1'b0}}, adder_addend};
	assign adder_sum = adder_full_sum[N - 1 : 0];

	// SUBTRACTOR //

	assign subtractor_minuend = A;
	assign subtractor_subtrahend = B;
	//assign Y = subtractor_difference;
	//wire subtractor_borrow;

	//// MULTIPLIER //

	//wire multiplier_start;
	//wire multiplier_finished;
	assign multiplier_multiplicand = A;
	assign multiplier_multiplier = B;
	//assign Y = multiplier_product;
	//wire multiplier_overflow;
	//wire [(2 * N) - 1 : 0] multiplier_adder_augend;
	//wire [(2 * N) - 1 : 0] multiplier_adder_addend;
	//wire [(2 * N) - 1 : 0] multiplier_adder_sum;

	//// DIVIDER //

	//wire divider_start;
	//wire divider_finished;
	//wire divider_undefined;
	assign divider_dividend = A;
	assign divider_divisor = B;
	//wire [N - 1 : 0] divider_quotient;
	//wire [N - 1 : 0] divider_remainder;
	//wire [N - 1 : 0] divider_subtractor_minuend;
	//wire [N - 1 : 0] divider_subtractor_subtrahend;
	//wire [N - 1 : 0] divider_subtractor_difference;
	//wire divider_subtractor_borrow;

	//// COMPARATOR //

	assign comparator_left = A;
	assign comparator_right = B;
	//wire comparator_greater;
	//wire comparator_equal;
	//wire comparator_less;
	//wire comparator_greater_equal;
	//wire comparator_not_equal;
	//wire comparator_less_equal;

	//// SHIFTER / ROTATOR //

	//wire shifter_start;
	//wire shifter_finished;
	//wire shifter_direction;
	//wire shifter_rotate;
	assign shifter_input_value = A;
	assign shifter_iterations = B;
	//wire [N - 1 : 0] shifter_output_value;
	//wire [N - 1 : 0] shifter_adder_augend;
	//wire [N - 1 : 0] shifter_adder_addend;
	//wire [N - 1 : 0] shifter_adder_sum;
	//wire [N - 1 : 0] shifter_comparator_left;
	//wire [N - 1 : 0] shifter_comparator_right;
	//wire shifter_comparator_equal;

	// BITWISE OPERATORS //

	// NOTE: B is not used for unary operators
	assign and_result = A & B;
	assign or_result = A | B;
	assign not_result = ~A;
	assign xor_result = A ^ B;
	assign nand_result = A ~& B;
	assign nor_result = A ~| B;
	assign xnor_result = A ~^ B;
	assign nop_result = A;

	// ===================== STATE MACHINE CONTROLS ===================== //

	// TODO: start should only happen when the main ALU start is asserted

	// ===================== OUTPUT MUX ===================== //

	reg [N - 1 : 0] result;

	always @ (*) begin
		case (opcode)
			`add    : result = adder_sum;
			`sub    : result = subtractor_difference;
			`mul    : result = multiplier_product;
			`div    : result = divider_quotient;
			`mod    : result = divider_remainder;
			`lt     : result = comparator_less;
			`gt     : result = comparator_greater;
			`eq     : result = comparator_equal;
			`le     : result = comparator_less_equal;
			`ge     : result = comparator_greater_equal;
			`ne     : result = comparator_not_equal;
			`lsl    : result = shifter_output_value;
			`lsr    : result = shifter_output_value;
			`lrl    : result = shifter_output_value;
			`lrr    : result = shifter_output_value;
			`and    : result = and_result;
			`or     : result = or_result;
			`not    : result = not_result;
			`xor    : result = xor_result;
			`nand   : result = nand_result;
			`nor    : result = nor_result;
			`xnor   : result = xor_result;
			default : result = nop_result;
		endcase
	end

	assign Y = result;

	// ===================== STATUS REGISTER ===================== //

endmodule
