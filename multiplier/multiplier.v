/* =================================================
 * MULTIPLIER: product = multiplier * multiplicand
 * ================================================= */

module Multiplier
#(
	parameter BITS = 8
)
(
	input wire i_clock,
	input wire i_reset,
	input wire i_start,
	output wire o_finished
	//input  wire [BITS - 1 : 0] i_multiplier,
	//input  wire [BITS - 1 : 0] i_multiplicand,
	//output wire [BITS - 1 : 0] o_sum,
	//output wire o_carry
);
	// STATE MACHINE //

	reg [BITS - 1: 0] state;

	always @ (posedge i_clock) begin
		if (i_reset) begin
			state <= {BITS{1'b0}};
		end else begin
			state[0] <= i_start & (~|state);              // NOR gating to prevent more than one "hot" bit
			state[BITS - 1 : 1] <= state[BITS - 2 : 0];   // shift one-hot state
		end
	end

	assign o_finished = state[BITS - 1];

endmodule
