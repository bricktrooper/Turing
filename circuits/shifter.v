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
	output wire [N - 1 : 0] o_result,

	// ADDER //

	output wire [N - 1 : 0] o_adder_augend,
	output wire [N - 1 : 0] o_adder_addend,
	input wire [N - 1 : 0] i_adder_sum,

	// COMPARATOR //

	output wire [N - 1 : 0] o_comparator_left,
	output wire [N - 1 : 0] o_comparator_right,
	input wire i_comparator_equal
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

	// increment each time a shift or rotate occurs
	assign o_adder_augend = elapsed;
	assign o_adder_addend = increment;
	assign sum = i_adder_sum;
	// carry doesn't matter because iterations > N becomes meaningless

	assign current = start ? 0 : sum;

	// save the latest counter value
	always @ (posedge i_clock) begin
		elapsed <= current;
	end

	// check if the required number of shifts have occurred
	assign o_comparator_left = current;
	assign o_comparator_right = i_iterations;
	assign o_finished = i_comparator_equal;

	// SHIFTER / ROTATOR //

	reg [N - 1 : 0] value;      // previous value (shift register)
	wire [N - 1 : 0] shifted;   // shifted or rotated value
	wire msb;                   // new MSB depending on shift or rotation
	wire lsb;                   // new LSB depending on shift or rotation

	assign msb = i_rotate ? value[0] : 1'b0;       // if rotate then new MSB = old LSB, otherwise new MSB = 0
	assign lsb = i_rotate ? value[N - 1] : 1'b0;   // if rotate then new LSB = old MSB, otherwise new LSB = 0

	// shift left or right depending on the value of i_direction
	assign shifted = i_direction ? {value[N - 2 : 0], lsb} : {msb, value[N - 1 : 1]};

	// save shifted or rotated value for next iteration
	always @ (posedge i_clock) begin
		value <= o_result;
	end

	assign o_result = start ? i_value : shifted;

endmodule
