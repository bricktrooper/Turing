module AdderTB;

	parameter DELAY = 1;
	parameter BITS = 4;
	integer MAX_VALUE = $pow(2, BITS) - 1;

	reg [BITS - 1 : 0] augend;
	reg [BITS - 1 : 0] addend;
	wire [BITS - 1 : 0] sum;
	wire carry;

	Adder #(.BITS(BITS)) adder
	(
		.i_augend(augend),
		.i_addend(addend),
		.o_sum(sum),
		.o_carry(carry)
	);

	reg unsigned [BITS : 0] expected;
	reg unsigned [BITS : 0] actual;

	initial begin
		$dumpfile("adder.vcd");
		$dumpvars();

		for (integer x = 0; x <= MAX_VALUE; x++)begin
			for (integer y = 0; y <= MAX_VALUE; y++) begin
				augend = x;
				addend = y;
				# DELAY;

				expected = x + y;
				actual = {carry, sum};

				if (expected != actual)
					$display("[%0d + %0d]: Expected %0d but result was %0d", x, y, expected, actual);
			end
		end

		$finish;
	end

endmodule
