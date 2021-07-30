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

	wire o_greater;
	wire o_equal;

	Comparator #(.N(N)) comparator
	(
		.i_left(iterations),
		.i_right(i_iterations),

		.o_greater(o_greater),
		.o_equal(o_equal)
	);

	// ROTATOR //

	wire msb;   // new MSB depending on shift or rotation
	wire lsb;   // new LSB depending on shift or rotation

	// if rotate then new MSB = old LSB, otherwise new MSB = 0
	assign msb = i_rotate ? old_value[0] : 1'b0;

	// if rotate then new new LSB = old MSB, otherwise new LSB = 0
	assign lsb = i_rotate ? old_value[N - 1] : 1'b0;

	// SHIFTER //

	reg [N - 1 : 0] old_value;   // value before shift (register)
	reg [N - 1 : 0] new_value;   // value after shift

	always @ (*) begin
		// TODO: FIx start?
		if (i_start) begin
			new_value = i_value;   // load input value
		end else if (i_direction) begin
			new_value[N - 1 : 1] = old_value[N - 2 : 0];   // left shift
			new_value[0] = lsb;                            // new LSB
		end else begin
			new_value[N - 2 : 0] = old_value[N - 1 : 1];   // right shift
			new_value[N - 1] = msb;                        // new MSB
		end
	end

	// save new shifted / rotated value for next iteration
	always @ (posedge i_clock) begin
		old_value <= new_value;
	end

	// OUTPUT //

	assign o_value = new_value;

endmodule
