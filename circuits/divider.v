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
			state <= 0;
		end else begin
			state[0] <= start;
			state[N - 1 : 1] <= state[N - 2 : 0];   // shift one-hot state
		end
		$display("need to deal with divisor == 0 using error flag that forces o_finished early");
		$display("also simplify the zero outs in multiplier as well");
	end

	assign o_finished = state[N - 1];

	// DIVIDEND //

	reg [N - 1 : 0] dividend;   // shift register

	always @ (posedge i_clock) begin
		if (start) begin   // load input value
			dividend <= i_dividend;
		end else begin   // left shift
			dividend[N - 1 : 1] <= dividend[N - 2 : 0];
			dividend[0] <= 1'b0;
		end
	end

	// DIVISOR //

	reg [N - 1 : 0] divisor;   // normal register

	always @ (posedge i_clock) begin
		divisor <= i_divisor;   // load input value
	end

	// DE-ACCUMULATE //

	wire borrow;                      // borrow flag of de-accumulator
	wire [N - 1 : 0] difference;  // de-accumulator output
	wire [N - 1 : 0] window;          // current dividend bits
	reg [N - 1 : 0] remainder;        // remaining bits in the window after conditional subtraction

	always @ (posedge i_clock) begin
		if (start) begin
			remainder <= 0;   // start with zeros
		end else begin
			remainder <= o_remainder;   // save the latest remainder value
		end
	end

	assign window[N - 1 : 1] = remainder[N - 2 : 0];   // shift up the current remainder
	assign window[0] = dividend[N - 1];   // "bring down" the next bit of the dividend (MSB)

	// de-accumulate the dividend
	Subtractor #(.N(N)) deaccumulator
	(
		.i_minuend(window),
		.i_subtrahend(divisor),
		.o_difference(difference),
		.o_borrow(borrow)
	);

	// REMAINDER //

	// don't subtract if divisor > window (remainder = window)
	// save the difference if the subtraction was possible (remainder = difference)
	assign o_remainder = borrow ? window : difference;

	// QUOTIENT //

	reg [N - 1 : 0] quotient;   // shift register

	assign o_quotient[N - 1 : 1] = quotient[N - 2 : 0];   // left shift
	assign o_quotient[0] = ~borrow;                       // add a 1 if the subtraction was possible

	always @ (posedge i_clock) begin
		if (start) begin
			quotient <= 0;    // start with zeros
		end else begin
			quotient <= o_quotient;   // save the latest quotient value
		end
	end

endmodule
