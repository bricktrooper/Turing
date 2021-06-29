/* =================================================
 * MULTIPLIER: product = multiplier * multiplicand
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

	input  wire [BITS - 1 : 0] i_multiplier
	//input  wire [BITS - 1 : 0] i_multiplicand,
	//output wire [(2 * BITS) - 1 : 0] o_product   // n bits * n bits requires at most 2n bits

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

	// MULTIPLIER //

	reg [(2 * BITS) - 1 : 0] multiplier;

	always @ (posedge i_clock) begin
		case (start)
			1'b0: begin   // left shift
				multiplier[0] <= 1'b0;
				multiplier[(2 * BITS) - 1 : 1] <= multiplier[(2 * BITS) - 2 : 0];
			end
			1'b1: begin   // load input value
				multiplier <= i_multiplier;
			end
		endcase
	end

	wire [(2 * BITS) - 1 : 0] test;
	assign test = multiplier;

endmodule
