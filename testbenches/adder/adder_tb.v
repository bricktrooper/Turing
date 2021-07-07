module AdderTB
#(
	parameter N = 4
)
(
	input wire i_clock,

	input wire [N - 1 : 0] i_augend,
	input wire [N - 1 : 0] i_addend,
	output wire [N - 1 : 0] o_sum,
	output wire o_carry
);

	Adder #(.N(N)) adder
	(
		.i_augend(i_augend),
		.i_addend(i_addend),
		.o_sum(o_sum),
		.o_carry(o_carry)
	);

	initial begin
		$dumpfile("adder.vcd");
		$dumpvars(0, adder);
	end

endmodule
