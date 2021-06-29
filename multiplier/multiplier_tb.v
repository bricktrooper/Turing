module MultiplierTB;

	parameter CLOCK_PERIOD = 2;
	parameter BITS = 4;
	//integer MAX_VALUE = $pow(2, BITS) - 1;

	//reg [BITS - 1 : 0] i_augend;
	//reg [BITS - 1 : 0] i_addend;
	//wire [BITS - 1 : 0] o_sum;
	//wire o_carry;

	wire i_clock;

	Clock #(.PERIOD(CLOCK_PERIOD)) clock
	(
		.i_enable(1'b1),
		.o_clock(i_clock)
	);

	reg i_reset;
	reg i_start;
	wire o_finished;
	reg [BITS - 1 : 0] i_multiplier;

	Multiplier #(.BITS(BITS)) multiplier
	(
		.i_clock(i_clock),
		.i_reset(i_reset),
		.i_start(i_start),
		.o_finished(o_finished),
		.i_multiplier(i_multiplier)
		//.i_addend(i_addend),
		//.o_sum(o_sum),
		//.o_carry(o_carry)
	);

	//reg unsigned [BITS : 0] expected;
	//reg unsigned [BITS : 0] actual;

	initial begin
		$dumpfile("multiplier.vcd");
		$dumpvars();

		i_reset = 1;
		i_start = 0;

		# CLOCK_PERIOD;

		i_reset = 0;
		i_start = 1;
		i_multiplier = 11;

		# CLOCK_PERIOD;

		//i_start = 0;
		i_multiplier = 13;

		# (CLOCK_PERIOD * BITS);

		//i_start = 1;


		# (CLOCK_PERIOD * BITS);

		i_start = 0;

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
