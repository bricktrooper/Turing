module ClockTB;

	parameter CLOCK_PERIOD = 10;

	reg enable;
	wire clock;

	Clock #(.PERIOD(CLOCK_PERIOD)) clock_generator
	(
		.i_enable(enable),
		.o_clock(clock)
	);

	initial begin
		$dumpfile("clock.vcd");
		$dumpvars(0, clock_generator);

		// test enable
		enable = 1;
		# (CLOCK_PERIOD * 4);
		enable = 0;
		# (CLOCK_PERIOD * 2);

		// test gating
		enable = 1;
		# (CLOCK_PERIOD / 10)
		enable = 0;
		# (CLOCK_PERIOD * 2)
		enable = 1;
		# (CLOCK_PERIOD * 2)

		$finish;
	end

endmodule
