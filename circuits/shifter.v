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

	input wire [N - 1 : 0] i_iterations,

	// DATA //

	input wire [N - 1 : 0] i_value,
	output wire [N - 1 : 0] o_value
);
	// STATE MACHINE //
	//wire start;

	//// NOR gating to prevent more than one "hot" bit
	//assign start = i_start & (~|state[N - 2 : 0]);

	// COUNTER //

	reg [N - 1 : 0] iterations;
	wire [N - 1 : 0] sum;
	wire [N - 1 : 0] increment;

	assign increment = 1;

	always @ (posedge i_clock) begin
		// TODO: FIX THIS TO BE START INSTEAD OF RESET
		if (i_start) begin
			iterations <= 0;
		end else begin
			iterations <= sum;
		end
	end

	Adder #(.N(N)) incrementer
	(
		.i_augend(iterations),
		.i_addend(increment),
		.o_sum(sum),
		.o_carry()
	);

	Comparator #(.N(N)) comparator
	(
		.i_left(iterations),
		.i_right(i_iterations),
		.o_equal(o_finished)
	);

	// REGISTERS //

	reg [N - 1 : 0] previous;   // previous value (shift register)

	// ROTATOR //

	wire msb;   // new MSB depending on shift or rotation
	wire lsb;   // new LSB depending on shift or rotation

	// if rotate then new MSB = old LSB, otherwise new MSB = 0
	assign msb = i_rotate ? previous[0] : 1'b0;

	// if rotate then new new LSB = old MSB, otherwise new LSB = 0
	assign lsb = i_rotate ? previous[N - 1] : 1'b0;

	// SHIFTER //

	wire [N - 1 : 0] result;    // output value
	wire [N - 1 : 0] shifted;   // shifted / rotated value

	// shift left / right depending on the value of i_direction
	assign shifted = i_direction ? {previous[N - 2 : 0], lsb} : {msb, previous[N - 1 : 1]};

	// set the output value
	assign result = i_start ? i_value : shifted;

	// save shifted / rotated value for next iteration
	always @ (posedge i_clock) begin
		previous <= result;
	end

	// OUTPUT //

	assign o_value = result;

endmodule
