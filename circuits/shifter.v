/* =================================================
 * SHIFTER: output = input << cycles
 *          output = input >> cycles
 * ================================================= */

module Shifter
#(
	parameter N = 8
)
(
	// CONTROL //

	input wire i_clock,
	input wire i_reset,
	input wire i_start,
	output wire o_finished,

	input wire i_direction,   // 1 = left, 0 = right
	input wire i_rotate,      // 1 = rotate, 0 = shift
	input wire [N i_iterations,

	// DATA //

	input wire [N - 1 : 0] i_value,
	output wire [N - 1 : 0] o_value
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

	// ROTATE //

	reg msb;                 // new MSB depending on shift or rotation
	reg lsb;                 // new LSB depending on shift or rotation

	always @ (*) begin
		if (i_rotate) begin
			msb <= value[0];   // new MSB = old LSB
		end else begin
			msb <= 1'b0;   // new MSB = 0
		end
	end

	always @ (*) begin
		if (i_rotate) begin
			lsb <= value[N - 1];   // new LSB = old MSB
		end else begin
			lsb <= 1'b0;   // new LSB = 0
		end
	end

	// SHIFT //

	reg [N - 1 : 0] value;   // shift register

	always @ (posedge i_clock) begin
		if (start) begin
			value <= i_value;   // load input value
		end else if (i_direction) begin
			value[N - 1 : 1] <= value[N - 2 : 0];   // left shift
			value[0] <= lsb;                        // new LSB
		end else begin
			value[N - 2 : 0] <= value[N - 1 : 1];   // right shift
			value[N - 1] <= msb;                    // new MSB
		end
	end

	// OUTPUT //

	assign o_value = value;

endmodule
