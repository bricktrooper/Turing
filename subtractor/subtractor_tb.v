module SubtractorTB;

	parameter DELAY = 1;
	parameter BITS = 4;
	parameter MAX_VALUE = $pow(2, BITS) - 1;

	reg [BITS - 1 : 0] i_minuend;
	reg [BITS - 1 : 0] i_subtrahend;
	wire [BITS - 1 : 0] o_difference;
	wire o_borrow;

	Subtractor #(.BITS(BITS)) subtractor
	(
		.i_minuend(i_minuend),
		.i_subtrahend(i_subtrahend),
		.o_difference(o_difference),
		.o_borrow(o_borrow)
	);

	reg signed [BITS : 0] expected;
	reg signed [BITS : 0] actual;

	initial begin
		$dumpfile("subtractor.vcd");
		$dumpvars(0, subtractor);

		for (integer x = 0; x <= MAX_VALUE; x++)begin
			for (integer y = 0; y <= MAX_VALUE; y++) begin
				i_minuend = x;
				i_subtrahend = y;
				# DELAY;

				expected = x - y;
				actual = {o_borrow, o_difference};

				if (expected != actual)
					$display("[%0d - %0d] expected: %0d, actual: %0d", x, y, expected, actual);
			end
		end

		$finish;
	end

endmodule
