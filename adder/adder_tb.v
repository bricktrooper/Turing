module AdderTB;

	parameter DELAY = 1;
	parameter BITS = 4;
	integer MAX_VALUE = $pow(2, BITS) - 1;

	reg [BITS - 1 : 0] i_augend;
	reg [BITS - 1 : 0] i_addend;
	wire [BITS - 1 : 0] i_sum;
	wire i_carry;

	Adder #(.BITS(BITS)) adder
	(
		.i_augend(i_augend),
		.i_addend(i_addend),
		.o_sum(i_sum),
		.o_carry(i_carry)
	);

	reg unsigned [BITS : 0] expected;
	reg unsigned [BITS : 0] actual;

	initial begin
		$dumpfile("adder.vcd");
		$dumpvars();

		for (integer x = 0; x <= MAX_VALUE; x++)begin
			for (integer y = 0; y <= MAX_VALUE; y++) begin
				i_augend = x;
				i_addend = y;
				# DELAY;

				expected = x + y;
				actual = {i_carry, i_sum};

				if (expected != actual)
					$display("[%0d + %0d]: Expected %0d but result was %0d", x, y, expected, actual);
			end
		end

		$finish;
	end

endmodule
