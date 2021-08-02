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

	wire start;
	reg busy;

	// throttling for continuous operation
	assign start = i_start & ~busy;

	// busy flag
	always @ (posedge i_clock) begin
		if (i_reset | o_finished) begin
			busy <= 1'b0;
		end else if (start) begin
			busy <= 1'b1;
		end
	end

	// COUNTER //

	wire [N - 1 : 0] sum;         // incrementer output
	wire [N - 1 : 0] increment;   // hardcoded to 1
	wire [N - 1 : 0] current;     // current iteration count
	reg [N - 1 : 0] elapsed;      // number of elapsed iterations (registered value of current)

	assign increment = 1;

	Adder #(.N(N)) incrementer
	(
		.i_augend(elapsed),
		.i_addend(increment),
		.o_sum(sum),
		.o_carry()
	);

	assign current = start ? 0 : sum;

	always @ (posedge i_clock) begin
		elapsed <= current;
	end

	Comparator #(.N(N)) comparator
	(
		.i_left(current),
		.i_right(i_iterations),
		.o_equal(o_finished)
	);

	// REGISTER //

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
	assign result = start ? i_value : shifted;

	// save shifted / rotated value for next iteration
	always @ (posedge i_clock) begin
		previous <= result;
	end

	// OUTPUT //

	assign o_value = result;

endmodule
