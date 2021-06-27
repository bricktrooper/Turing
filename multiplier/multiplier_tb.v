module MultiplierTB;

	parameter CLOCK_PERIOD = 2;
	parameter BITS = 4;
	//integer MAX_VALUE = $pow(2, BITS) - 1;

	//reg [BITS - 1 : 0] i_augend;
	//reg [BITS - 1 : 0] i_addend;
	//wire [BITS - 1 : 0] o_sum;
	//wire o_carry;

	wire clock;

	Clock #(.PERIOD(CLOCK_PERIOD)) clock_generator
	(
		.i_enable(1'b1),
		.o_clock(clock)
	);

	reg reset;
	reg start;
	wire finished;

	Multiplier #(.BITS(BITS)) multiplier
	(
		//.i_augend(i_augend),
		//.i_addend(i_addend),
		//.o_sum(o_sum),
		//.o_carry(o_carry)
		.i_clock(clock),
		.i_reset(reset),
		.i_start(start),
		.o_finished(finished)
	);

	//reg unsigned [BITS : 0] expected;
	//reg unsigned [BITS : 0] actual;

	initial begin
		$dumpfile("multiplier.vcd");
		$dumpvars();

		reset = 1;
		start = 0;

		# CLOCK_PERIOD;

		reset = 0;
		start = 1;

		# CLOCK_PERIOD;

		start = 0;

		# (CLOCK_PERIOD * (BITS - 1));

		if (finished != 1'b1)
			$display("Multiplier did not finish after %0d clock cycles", BITS);

		# CLOCK_PERIOD;

		start = 1;

		# (CLOCK_PERIOD * BITS);

		if (finished != 1'b1)
			$display("Overloaded multiplier did not finish after %0d clock cycles", BITS);

		start = 0;

		# CLOCK_PERIOD;

		//for (integer x = 0; x <= MAX_VALUE; x++)begin
		//	for (integer y = 0; y <= MAX_VALUE; y++) begin
		//		i_augend = x;
		//		i_addend = y;
		//		# DELAY;

		//		expected = x + y;
		//		actual = {o_carry, o_sum};

		//		if (expected != actual)
		//			$display("[%0d + %0d]: Expected %0d but result was %0d", x, y, expected, actual);
		//	end
		//end

		$finish;
	end

endmodule
