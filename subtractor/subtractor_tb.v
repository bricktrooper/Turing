module SubtractorTB;

	parameter DELAY = 1;
	parameter BITS = 4;
	parameter MAX_VALUE = $pow(2, BITS) - 1;

	reg [BITS - 1 : 0] minuend;
	reg [BITS - 1 : 0] subtrahend;
	wire [BITS - 1 : 0] difference;
	wire borrow;

	Subtractor #(.BITS(BITS)) subtractor
	(
		.i_minuend(minuend),
		.i_subtrahend(subtrahend),
		.o_difference(difference),
		.o_borrow(borrow)
	);

	reg signed [BITS : 0] expected;
	reg signed [BITS : 0] actual;

	initial begin
		$dumpfile("subtractor.vcd");
		$dumpvars();

		for (integer x = 0; x <= MAX_VALUE; x++)begin
			for (integer y = 0; y <= MAX_VALUE; y++) begin
				minuend = x;
				subtrahend = y;
				# DELAY;

				expected = x - y;
				actual = {borrow, difference};

				if (expected != actual)
					$display("[%0d - %0d] expected: %0d, actual: %0d", x, y, expected, actual);
			end
		end

		$finish;
	end

endmodule
