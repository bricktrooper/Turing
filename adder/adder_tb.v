module AdderTB;

	parameter DELAY = 1;

	reg i_augend;
	reg i_addend;
	wire o_sum;
	wire o_carry;

	Adder adder
	(
		.i_augend(i_augend),
		.i_addend(i_addend),
		.o_sum(o_sum),
		.o_carry(o_carry)
	);

	integer expected;
	integer actual;

	initial begin
		$dumpfile("adder.vcd");
		$dumpvars(0, adder);

		for (integer x = 0; x < 2; x++)begin
			for (integer y = 0; y < 2; y++) begin
				i_augend = x;
				i_addend = y;
				# DELAY;
				expected = x + y;
				actual = {o_carry, o_sum};
				if (expected != actual)
					$display("[%0d + %0d]: Expected %0d but result was %0d", x, y, expected, actual);
			end
		end

		$finish;
	end

endmodule
