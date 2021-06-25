module AdderTB;

	parameter DELAY = 1;
	parameter BITS = 8;

	reg [BITS - 1 : 0 ] i_augend;
	reg [BITS - 1 : 0 ] i_addend;
	wire [BITS - 1 : 0 ] o_sum;
	wire o_carry;

	Adder #(.BITS(BITS)) adder
	(
		.i_augend(i_augend),
		.i_addend(i_addend),
		.o_sum(o_sum),
		.o_carry(o_carry)
	);

	integer expected;
	integer actual;
	integer MAX_VALUE = $pow(2, BITS) - 1;

	initial begin
		$dumpfile("adder.vcd");
		$dumpvars(0, adder);

		for (integer x = 0; x <= MAX_VALUE; x++)begin
			for (integer y = 0; y <= MAX_VALUE; y++) begin
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
