/* =================================================
 * CLOCK GENERATOR
 * ================================================= */

module Clock
#(
	parameter PERIOD = 2   // must be at least 2 time units
)
(
	input wire i_enable,
	output wire o_clock
);
	reg clock;
	reg enable;

	initial begin
		clock <= 1'b0;
		enable <= 1'b1;
	end

	// clock generator
	always begin
		clock <= 1'b1;
		# (PERIOD / 2);
		clock <= 1'b0;
		# (PERIOD / 2);
	end

	// enable gating (only enable/disable at rising edge)
	always @ (*) begin
		if (~clock)
			enable <= i_enable;
	end

	// drive clock low when disabled
	assign o_clock = enable ? clock : 1'b0;

endmodule
