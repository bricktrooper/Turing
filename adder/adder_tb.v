module AdderTB;

	parameter DELAY = 1;

	reg augend;
	reg addend;
	wire sum;
	wire carry;

	Adder adder
	(
		.i_augend(augend),
		.i_addend(addend),
		.o_sum(sum),
		.o_carry(carry)
	);

	initial begin
		$dumpfile("adder.vcd");
		$dumpvars();

		# DELAY;
		augend = 1;
		addend = 1;
		# DELAY;

		$finish;
	end

endmodule
