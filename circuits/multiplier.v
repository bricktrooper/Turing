/* =================================================
 * MULTIPLIER: product = multiplicand * multiplier
 * ================================================= */

module Multiplier
#(
	parameter BITS = 8
)
(
	// CONTROL //

	input wire i_clock,
	input wire i_reset,
	input wire i_start,
	output wire o_finished,

	// DATA //

	input wire [BITS - 1 : 0] i_multiplicand,
	input wire [BITS - 1 : 0] i_multiplier,
	output wire [(2 * BITS) - 1 : 0] o_product   // n bits * n bits requires at most 2n bits

);
	// STATE MACHINE //

	reg [BITS - 1: 0] state;
	wire start;

	assign start = i_start & (~|state[BITS - 2 : 0]);   // NOR gating to prevent more than one "hot" bit

	always @ (posedge i_clock) begin
		if (i_reset) begin
			state <= {BITS{1'b0}};
		end else begin
			state[0] <= start;
			state[BITS - 1 : 1] <= state[BITS - 2 : 0];   // shift one-hot state
		end
	end

	assign o_finished = state[BITS - 1];

	// MULTIPLICAND //

	reg [(2 * BITS) - 1 : 0] multiplicand;   // shift register

	always @ (posedge i_clock) begin
		case (start)
			1'b0: begin   // left shift
				multiplicand[0] <= 1'b0;
				multiplicand[(2 * BITS) - 1 : 1] <= multiplicand[(2 * BITS) - 2 : 0];
			end
			1'b1: begin   // load input value
				multiplicand <= i_multiplicand;
			end
		endcase
	end

	// MULTIPLIER //

	reg [BITS - 1 : 0] multiplier;   // shift register

	always @ (posedge i_clock) begin
		case (start)
			1'b0: begin   // right shift
				multiplier[BITS - 1] <= 1'b0;
				multiplier[BITS - 2 : 0] <= multiplier[BITS - 1 : 1];
			end
			1'b1: begin   // load input value
				multiplier <= i_multiplier;
			end
		endcase
	end

	// MULTIPLY //

	wire [(2 * BITS) - 1 : 0] partial_product;

	// binary multiplication using bitwise AND
	assign partial_product = multiplicand & {(2 * BITS){multiplier[0]}};

	// ACCUMULATE //

	wire [(2 * BITS) - 1 : 0] sum;           // accumulator output
	reg [(2 * BITS) - 1 : 0] accumulation;   // accumulation register

	// accumulate partial products
	Adder #(.BITS(2 * BITS)) accumulator
	(
		.i_augend(accumulation),
		.i_addend(partial_product),
		.o_sum(sum),
		.o_carry()   // sum will never exceed 2n bits
	);

	always @ (posedge i_clock) begin
		case (start)
			1'b0: accumulation = o_product;            // save latest accumulation
			1'b1: accumulation = {(2 * BITS){1'b0}};   // reset accumulation to 0
		endcase
	end

	// PRODUCT //

	assign o_product = sum;

endmodule