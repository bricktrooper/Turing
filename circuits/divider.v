/* =================================================
 * DIVIDER: quotient = dividend / divisor
 *          remainder = dividend % divisor
 * ================================================= */

module Divider
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

	input wire [N - 1 : 0] i_dividend,
	input wire [N - 1 : 0] i_divisor,
	output wire [N - 1 : 0] o_quotient,   // N bits / N bits requires at most N bits
	output wire [N - 1 : 0] o_remainder

);
	// STATE MACHINE //

	reg [N - 1: 0] state;
	wire start;

	assign start = i_start & (~|state[N - 2 : 0]);   // NOR gating to prevent more than one "hot" bit

	always @ (posedge i_clock) begin
		if (i_reset) begin
			state <= {N{1'b0}};
		end else begin
			state[0] <= start;
			state[N - 1 : 1] <= state[N - 2 : 0];   // shift one-hot state
		end
	end

	assign o_finished = state[N - 1];

	// REMAINDER //

	reg [N - 1 : 0] remainder;  // shift register

	always @ (posedge i_clock) begin
		case (start)
			1'b0: begin   // left shift
				remainder[N - 1 : 1] <= remainder[N - 2 : 0];
				remainder[0] <= dividend[N - 1];   // shift in the next MSB of the dividend
			end
			1'b1: begin   // start with zeros
				remainder <= {N{1'b0}};
			end
		endcase
	end

	// DIVIDEND //

	reg [N - 1 : 0] dividend;   // shift register

	always @ (posedge i_clock) begin
		case (start)
			1'b0: begin   // left shift
				dividend[N - 1 : 1] <= dividend[N - 2 : 0];
				dividend[0] <= 1'b0;
			end
			1'b1: begin   // load input value
				dividend <= i_dividend;
			end
		endcase
	end

	// DIVISOR //

	reg [N - 1 : 0] divisor;   // normal register

	always @ (posedge i_clock) begin
		divisor <= i_divisor;   // load input value
	end

	// MULTIPLY //

	//wire [(2 * N) - 1 : 0] partial_product;

	//// binary multiplication using bitwise AND
	//assign partial_product = multiplicand & {(2 * N){multiplier[0]}};

	//// ACCUMULATE //

	//wire [(2 * N) - 1 : 0] sum;           // accumulator output
	//reg [(2 * N) - 1 : 0] accumulation;   // accumulation register

	//// accumulate partial products
	//Adder #(.N(2 * N)) accumulator
	//(
	//	.i_augend(accumulation),
	//	.i_addend(partial_product),
	//	.o_sum(sum),
	//	.o_carry()   // sum will never exceed 2n bits
	//);

	//always @ (posedge i_clock) begin
	//	case (start)
	//		1'b0: accumulation = o_product;            // save latest accumulation
	//		1'b1: accumulation = {(2 * N){1'b0}};   // reset accumulation to 0
	//	endcase
	//end

	//// PRODUCT //

	//assign o_product = sum;

endmodule
