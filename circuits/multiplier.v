/* =================================================
 * MULTIPLIER: product = multiplicand * multiplier
 * ================================================= */

module Multiplier
#(
	parameter N = 8
)
(
	// CONTROL //

	input wire i_clock,
	input wire i_reset,
	input wire i_start,
	output wire o_finished,

	// DATA //

	input wire [N - 1 : 0] i_multiplicand,
	input wire [N - 1 : 0] i_multiplier,
	output wire [(2 * N) - 1 : 0] o_product,   // N bits * N bits requires at most 2N bits

	// ADDER //

	output wire [(2 * N) - 1 : 0] o_adder_augend,
	output wire [(2 * N) - 1 : 0] o_adder_addend,
	input wire [(2 * N) - 1 : 0] i_adder_sum
);
	// STATE MACHINE //

	reg [N - 1: 0] state;
	wire start;

	// NOR gating to prevent more than one "hot" bit
	assign start = i_start & (~|state[N - 2 : 0]);

	always @ (posedge i_clock) begin
		if (i_reset) begin
			state <= 0;
		end else begin
			// shift one-hot state
			state[0] <= start;
			state[N - 1 : 1] <= state[N - 2 : 0];
		end
	end

	assign o_finished = state[N - 1];

	// MULTIPLICAND //

	reg [(2 * N) - 1 : 0] multiplicand;   // shift register

	always @ (posedge i_clock) begin
		if (start) begin
			// load input value
			multiplicand <= i_multiplicand;
		end else begin
			// left shift
			multiplicand[(2 * N) - 1 : 1] <= multiplicand[(2 * N) - 2 : 0];
			multiplicand[0] <= 1'b0;
		end
	end

	// MULTIPLIER //

	reg [N - 1 : 0] multiplier;   // shift register

	always @ (posedge i_clock) begin
		if (start) begin
			// load input value
			multiplier <= i_multiplier;
		end else begin
			// right shift
			multiplier[N - 1] <= 1'b0;
			multiplier[N - 2 : 0] <= multiplier[N - 1 : 1];
		end
	end

	// MULTIPLY //

	wire [(2 * N) - 1 : 0] partial_product;

	// binary multiplication using bitwise AND with multiplier LSB
	assign partial_product = multiplicand & {(2 * N){multiplier[0]}};

	// ACCUMULATE //

	wire [(2 * N) - 1 : 0] sum;      // accumulator output
	reg [(2 * N) - 1 : 0] product;   // accumulation register

	// accumulate partial products
	assign o_adder_augend = product;
	assign o_adder_addend = partial_product;
	assign sum = i_adder_sum;
	// carry is not required because the sum will never exceed 2N bits

	always @ (posedge i_clock) begin
		if (start) begin
			// reset product to 0
			product <= 0;
		end else begin
			// save latest product
			product <= sum;
		end
	end

	// PRODUCT //

	assign o_product = sum;

endmodule
