module AdderTB
#(
	parameter BITS = 4
)
(
	input wire clock,

	input wire [BITS - 1 : 0] augend,
	input wire [BITS - 1 : 0] addend,
	output wire [BITS - 1 : 0] sum,
	output wire carry
);

	Adder #(.BITS(BITS)) adder
	(
		.i_augend(augend),
		.i_addend(addend),
		.o_sum(sum),
		.o_carry(carry)
	);

	initial begin
		$dumpfile("adder.vcd");
		$dumpvars(0, adder);
	end

endmodule
