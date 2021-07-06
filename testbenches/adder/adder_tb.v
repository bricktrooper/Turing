module AdderTB
#(
	parameter N = 4
)
(
	input wire clock,

	input wire [N - 1 : 0] augend,
	input wire [N - 1 : 0] addend,
	output wire [N - 1 : 0] sum,
	output wire carry
);

	Adder #(.N(N)) adder
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
