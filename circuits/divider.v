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

	// REMAINDER //

	reg [N - 1 : 0] deaccumulation;   // de-accumuation shift register
	reg [N - 1 : 0] window;           // current dividend bits
	wire borrow;                      // borrow flag of de-accumulator
	reg [N - 1 : 0] yolo;           // current dividend bits

	always @ (*) begin
		case (start)
			1'b0: begin   // left shift
				window[N - 1 : 1] = deaccumulation[N - 2 : 0];
				window[0] = dividend[N - 1];   // "bring down" the next bit of the dividend (MSB)
			end
			1'b1: begin
				window = {N{1'b0}};   // start with zeros
			end
		endcase
	end

	assign o_remainder = yolo;

	// save the latest deaccumulation
	always @ (*) begin
		case (start)
			1'b0: begin
				case (borrow)
					1'b0: yolo = difference;      // save the difference if the subtraction was possible
					1'b1: yolo = window;  // don't subtract if divisor > partial_remainder
				endcase
			end
			1'b1: begin
				yolo = {N{1'b0}};  // start with zeros
			end
		endcase
	end

	always @ (posedge i_clock) begin
		deaccumulation <= yolo;
	end

	// DE-ACCUMULATE //

	wire [N - 1 : 0] difference;   // de-accumulator output

	//assign window[N - 1 : 1] = deaccumulation[N - 2 : 0];   // left shift
	//assign window[0] = dividend[N - 1];                     // "bring down" the next bit from the right
	//assign window = remainder;

	// de-accumulate the dividend
	Subtractor #(.N(N)) deaccumulator
	(
		.i_minuend(window),
		.i_subtrahend(divisor),
		.o_difference(difference),
		.o_borrow(borrow)
	);

	// QUOTIENT //

	reg [N - 1 : 0] quotient;   // shift register

	assign o_quotient[N - 1 : 1] = quotient[N - 2 : 0];   // left shift
	assign o_quotient[0] = ~borrow;                       // add a 1 if the subtraction was possible

	always @ (posedge i_clock) begin
		case (start)
			1'b0: quotient <= o_quotient;   // save the latest quotient value
			1'b1: quotient <= {N{1'b0}};    // start with zeros
		endcase
	end

endmodule
